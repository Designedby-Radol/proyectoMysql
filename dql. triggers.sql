USE CampusLandsDB;
-- 1. Al insertar una evaluación, calcular automáticamente la nota final.
-- Note: This is already implemented in the table design using GENERATED ALWAYS AS columns
DELIMITER //
-- Trigger para calcular la nota final antes de insertar una evaluación
CREATE TRIGGER before_insert_evaluaciones
BEFORE INSERT ON Evaluaciones
FOR EACH ROW
BEGIN
    SET NEW.nota_final = (NEW.nota_teorica * 0.3) + (NEW.nota_practica * 0.6) + (NEW.nota_quizzes * 0.1);
    SET NEW.aprobado = NEW.nota_final >= 60;
END //
DELIMITER ;

-- 2. Al actualizar la nota final de un módulo, verificar si el camper aprueba o reprueba.
-- Note: This is already implemented in the table design using GENERATED ALWAYS AS columns
DELIMITER //
-- Trigger para verificar si el camper aprueba o reprueba después de actualizar una nota
CREATE TRIGGER after_update_evaluaciones
AFTER UPDATE ON Evaluaciones
FOR EACH ROW
BEGIN
    IF NEW.aprobado THEN
        UPDATE Campers SET estado = 'Aprobado' WHERE camper_id = NEW.camper_id;
    ELSE
        UPDATE Campers SET estado = 'Reprobado' WHERE camper_id = NEW.camper_id;
    END IF;
END //
DELIMITER ;

-- 3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito".
DELIMITER //
CREATE TRIGGER after_inscripcion_insert
AFTER INSERT ON InscripcionesCamperRuta
FOR EACH ROW
BEGIN
    UPDATE Campers 
    SET estado = 'Inscrito',
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE camper_id = NEW.camper_id AND estado = 'En proceso de ingreso';
    
    -- Add to history
    INSERT INTO HistorialEstadosCamper (camper_id, estado_anterior, estado_nuevo, motivo)
    SELECT camper_id, estado, 'Inscrito', 'Inscripción automática a ruta'
    FROM Campers 
    WHERE camper_id = NEW.camper_id AND estado != 'Inscrito';
END //
DELIMITER ;

-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente.
-- Note: This is already implemented in the table design using GENERATED ALWAYS AS columns
DELIMITER //
CREATE TRIGGER after_update_promedio_camper
AFTER UPDATE ON Evaluaciones
FOR EACH ROW
BEGIN
    UPDATE Campers
    SET promedio = (SELECT AVG(nota_final) FROM Evaluaciones WHERE camper_id = NEW.camper_id)
    WHERE camper_id = NEW.camper_id;
END //

DELIMITER ;


-- 5. Al eliminar una inscripción, marcar al camper como "Retirado".
DELIMITER //
CREATE TRIGGER after_inscripcion_delete
AFTER DELETE ON InscripcionesCamperRuta
FOR EACH ROW
BEGIN
    DECLARE inscripciones_activas INT;
    
    -- Check if the camper has other active inscriptions
    SELECT COUNT(*) INTO inscripciones_activas
    FROM InscripcionesCamperRuta
    WHERE camper_id = OLD.camper_id AND estado != 'Cancelada';
    
    -- If no other active inscriptions, mark as "Retirado"
    IF inscripciones_activas = 0 THEN
        -- Get current state before updating
        INSERT INTO HistorialEstadosCamper (camper_id, estado_anterior, estado_nuevo, motivo)
        SELECT camper_id, estado, 'Retirado', 'Eliminación de inscripción'
        FROM Campers 
        WHERE camper_id = OLD.camper_id;
        
        -- Update state
        UPDATE Campers 
        SET estado = 'Retirado',
            fecha_actualizacion = CURRENT_TIMESTAMP
        WHERE camper_id = OLD.camper_id;
    END IF;
END //
DELIMITER ;

-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado.
-- Note: The schema doesn't show a direct relationship between módulos and SGBDs.
-- This trigger assumes we're adding a default association in ModuloCategoria

DELIMITER //
CREATE TRIGGER after_modulo_insert
AFTER INSERT ON Modulos
FOR EACH ROW
BEGIN
    -- Assuming there's a default category for each SGBD
    -- This is a placeholder - adjust according to your actual business logic
    INSERT INTO ModuloCategoria (modulo_id, categoria_id)
    VALUES (NEW.modulo_id, 1); -- Default category ID, adjust as needed
END //
DELIMITER ;

-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación.
DELIMITER //
CREATE TRIGGER before_trainer_insert
BEFORE INSERT ON Trainers
FOR EACH ROW
BEGIN
    DECLARE trainer_count INT;
    
    SELECT COUNT(*) INTO trainer_count
    FROM Trainers
    WHERE numero_identificacion = NEW.numero_identificacion;
    
    IF trainer_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Ya existe un trainer con este número de identificación';
    END IF;
END //
DELIMITER ;

-- 8. Al asignar un área, validar que no exceda su capacidad.
DELIMITER //
CREATE TRIGGER before_asignacion_camper_area
BEFORE INSERT ON AsignacionCamperArea
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_capacity INT;
    
    -- Get current count
    SELECT COUNT(*) INTO current_count
    FROM AsignacionCamperArea
    WHERE area_id = NEW.area_id
    AND (fecha_fin IS NULL OR fecha_fin >= NEW.fecha_inicio);
    
    -- Get max capacity
    SELECT capacidad_maxima INTO max_capacity
    FROM AreasEntrenamiento
    WHERE area_id = NEW.area_id;
    
    -- Check if adding this camper would exceed capacity
    IF current_count >= max_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El área ha alcanzado su capacidad máxima';
    END IF;
END //
DELIMITER ;

-- 9. Al insertar una evaluación con nota < 60, marcar al camper como "Bajo rendimiento".
DELIMITER //
CREATE TRIGGER after_evaluacion_insert
AFTER INSERT ON Evaluaciones
FOR EACH ROW
BEGIN
    -- Check if the nota_final is below 60 and update risk level accordingly
    IF NEW.nota_final < 60 THEN
        UPDATE Campers
        SET nivel_riesgo = 'Alto',
            fecha_actualizacion = CURRENT_TIMESTAMP
        WHERE camper_id = NEW.camper_id;
    END IF;
END //
DELIMITER ;

-- 10. Al cambiar de estado a "Graduado", mover registro a la tabla de egresados.
DELIMITER //
CREATE TRIGGER after_camper_update_to_graduado
AFTER UPDATE ON Campers
FOR EACH ROW
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    DECLARE v_ruta_id INT;
    
    IF NEW.estado = 'Graduado' AND OLD.estado != 'Graduado' THEN
        -- Get the camper's average grade
        SELECT AVG(nota_final) INTO v_promedio
        FROM Evaluaciones
        WHERE camper_id = NEW.camper_id;
        
        -- Get the most recent ruta_id
        SELECT ruta_id INTO v_ruta_id
        FROM InscripcionesCamperRuta
        WHERE camper_id = NEW.camper_id
        ORDER BY fecha_inscripcion DESC
        LIMIT 1;
        
        -- Insert into Egresados
        INSERT INTO Egresados (camper_id, fecha_graduacion, ruta_id, promedio_final, observaciones)
        VALUES (NEW.camper_id, CURDATE(), v_ruta_id, v_promedio, 'Graduación automática');
    END IF;
END //
DELIMITER ;

-- 11. Al modificar horarios de trainer, verificar solapamiento con otros.
DELIMITER //
CREATE TRIGGER before_trainer_horario_insert
BEFORE INSERT ON TrainerAreaHorario
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;
    
    -- Check for overlaps
    SELECT COUNT(*) INTO overlap_count
    FROM TrainerAreaHorario
    WHERE trainer_id = NEW.trainer_id
    AND dia_id = NEW.dia_id
    AND fecha_fin IS NULL OR fecha_fin >= NEW.fecha_inicio
    AND (
        (NEW.horario_id = horario_id) OR
        EXISTS (
            SELECT 1 FROM Horarios h1, Horarios h2
            WHERE h1.horario_id = NEW.horario_id
            AND h2.horario_id = TrainerAreaHorario.horario_id
            AND (
                (h1.hora_inicio BETWEEN h2.hora_inicio AND h2.hora_fin) OR
                (h1.hora_fin BETWEEN h2.hora_inicio AND h2.hora_fin) OR
                (h2.hora_inicio BETWEEN h1.hora_inicio AND h1.hora_fin)
            )
        )
    );
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El horario se solapa con otro ya asignado al trainer';
    END IF;
END //
DELIMITER ;

-- 12. Al eliminar un trainer, liberar sus horarios y rutas asignadas.
DELIMITER //
CREATE TRIGGER before_trainer_delete
BEFORE DELETE ON Trainers
FOR EACH ROW
BEGIN
    -- Mark trainer assignments as inactive
    UPDATE AsignacionesTrainerRuta
    SET activo = FALSE, fecha_fin = CURDATE()
    WHERE trainer_id = OLD.trainer_id AND activo = TRUE;
    
    -- Set end date for area-horario assignments
    UPDATE TrainerAreaHorario
    SET fecha_fin = CURDATE()
    WHERE trainer_id = OLD.trainer_id AND fecha_fin IS NULL;
END //
DELIMITER ;

-- 13. Al cambiar la ruta de un camper, actualizar automáticamente sus módulos.
-- Note: This would require additional tables/fields not present in the schema
-- A placeholder is provided below that would need to be adapted to your specific implementation

DELIMITER $$

CREATE TRIGGER actualizar_modulos_camper
AFTER UPDATE ON InscripcionesCamperRuta
FOR EACH ROW
BEGIN
    -- Verificar si la ruta cambió
    IF OLD.ruta_id <> NEW.ruta_id THEN
        -- Eliminar módulos previos del camper
        DELETE FROM ModulosCamper WHERE camper_id = NEW.camper_id;
        
        -- Insertar los nuevos módulos según la nueva ruta
        INSERT INTO ModulosCamper (camper_id, modulo_id)
        SELECT NEW.camper_id, rm.modulo_id
        FROM RutaModulos rm
        WHERE rm.ruta_id = NEW.ruta_id;
    END IF;
END $$

DELIMITER ;DELIMITER ;

-- 14. Al insertar un nuevo camper, verificar si ya existe por número de documento.
DELIMITER //
CREATE TRIGGER before_camper_insert
BEFORE INSERT ON Campers
FOR EACH ROW
BEGIN
    DECLARE camper_count INT;
    
    SELECT COUNT(*) INTO camper_count
    FROM Campers
    WHERE numero_identificacion = NEW.numero_identificacion;
    
    IF camper_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Ya existe un camper con este número de identificación';
    END IF;
END //
DELIMITER ;

-- 15. Al actualizar la nota final, recalcular el estado del módulo automáticamente.
-- Note: The "estado del módulo" is not clearly defined in the schema.
-- This is a placeholder that assumes there's a ModuloEstado table or similar.

DELIMITER $$

CREATE TRIGGER actualizar_estado_modulo
AFTER UPDATE ON Evaluaciones
FOR EACH ROW
BEGIN
    -- Actualizar el campo 'aprobado' en Evaluaciones basado en la nota final
    IF NEW.nota_final >= 60 THEN
        UPDATE Evaluaciones
        SET aprobado = 1
        WHERE evaluacion_id = NEW.evaluacion_id;
    ELSE
        UPDATE Evaluaciones
        SET aprobado = 0
        WHERE evaluacion_id = NEW.evaluacion_id;
    END IF;
END $$

DELIMITER ;


-- 16. Al asignar un módulo, verificar que el trainer tenga ese conocimiento.
DELIMITER //
CREATE TRIGGER before_asignacion_trainer_ruta
BEFORE INSERT ON AsignacionesTrainerRuta
FOR EACH ROW
BEGIN
    DECLARE modulo_count INT;
    
    -- Check if trainer has the required modules
    SELECT COUNT(DISTINCT rm.modulo_id) INTO modulo_count
    FROM RutaModulos rm
    LEFT JOIN EspecialidadesTrainers et ON rm.modulo_id = et.modulo_id AND et.trainer_id = NEW.trainer_id
    WHERE rm.ruta_id = NEW.ruta_id AND et.especialidad_id IS NULL;
    
    -- If there are modules in the route that the trainer doesn't know
    IF modulo_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El trainer no tiene conocimientos en todos los módulos de la ruta';
    END IF;
END //
DELIMITER ;

-- 17. Al cambiar el estado de un área a inactiva, liberar campers asignados.
DELIMITER //
CREATE TRIGGER after_area_update_to_inactive
AFTER UPDATE ON AreasEntrenamiento
FOR EACH ROW
BEGIN
    IF NEW.estado != 'Activa' AND OLD.estado = 'Activa' THEN
        -- Set end date for all active camper assignments to this area
        UPDATE AsignacionCamperArea
        SET fecha_fin = CURDATE()
        WHERE area_id = NEW.area_id AND fecha_fin IS NULL;
    END IF;
END //
DELIMITER ;

-- 18. Al crear una nueva ruta, clonar la plantilla base de módulos y SGDBs.
DELIMITER $$

CREATE TRIGGER clonar_plantilla_ruta
AFTER INSERT ON Rutas
FOR EACH ROW
BEGIN
    -- Clonar los módulos base de la plantilla
    INSERT INTO RutaModulos (ruta_id, modulo_id)
    SELECT NEW.ruta_id, modulo_id FROM PlantillaModulos;
    
    -- Clonar los SGDBs base de la plantilla
    INSERT INTO RutaSGDBs (ruta_id, sgdb_id)
    SELECT NEW.ruta_id, sgdb_id FROM PlantillaSGDBs;
END $$

DELIMITER ;
-- 19. Al registrar la nota práctica, verificar que no supere 60% del total.
DELIMITER $$

CREATE TRIGGER verificar_nota_practica
BEFORE INSERT OR UPDATE ON Evaluaciones
FOR EACH ROW
BEGIN
    IF NEW.nota_practica > (NEW.nota_total * 0.6) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La nota práctica no puede superar el 60% del total.';
    END IF;
END $$
\DELIMITER ;

-- 20. Al modificar una ruta, notificar cambios a los trainers asignados.
-- This would typically involve external notification mechanisms.
-- Below is a placeholder that logs changes to a notification table.


CREATE TABLE IF NOT EXISTS Notificaciones (
    notificacion_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_id INT NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id)
);

DELIMITER //
CREATE TRIGGER after_ruta_update
AFTER UPDATE ON Rutas
FOR EACH ROW
BEGIN
    -- Insert notifications for all trainers assigned to this route
    INSERT INTO Notificaciones (trainer_id, mensaje)
    SELECT trainer_id, CONCAT('La ruta "', NEW.nombre, '" ha sido modificada. Por favor, revise los cambios.')
    FROM AsignacionesTrainerRuta
    WHERE ruta_id = NEW.ruta_id AND activo = TRUE;
END //
DELIMITER ;