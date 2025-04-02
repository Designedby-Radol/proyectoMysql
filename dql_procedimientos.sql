-- 1. Registrar un nuevo camper
DELIMITER //
CREATE PROCEDURE registrar_nuevo_camper(
    IN p_numero_identificacion VARCHAR(20),
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_direccion TEXT,
    IN p_acudiente VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_tipo_telefono ENUM('Celular', 'Fijo')
)
BEGIN
    -- Insertar en la tabla Campers
    INSERT INTO Campers (numero_identificacion, nombres, apellidos, direccion, acudiente, estado, nivel_riesgo, fecha_registro)
    VALUES (p_numero_identificacion, p_nombres, p_apellidos, p_direccion, p_acudiente, 'En proceso de ingreso', 'Bajo', CURRENT_DATE);
    
    -- Obtener el ID del camper recién insertado
    SET @camper_id = LAST_INSERT_ID();
    
    -- Insertar el teléfono
    INSERT INTO TelefonosCampers (camper_id, numero_telefono, tipo)
    VALUES (@camper_id, p_telefono, p_tipo_telefono);
END //
DELIMITER ;

-- 2. Actualizar estado de camper
DELIMITER //
CREATE PROCEDURE actualizar_estado_camper(
    IN p_camper_id INT,
    IN p_estado_nuevo ENUM('Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Retirado', 'Expulsado'),
    IN p_motivo TEXT
)
BEGIN
    -- Registrar el cambio en el historial
    INSERT INTO HistorialEstadosCamper (camper_id, estado_anterior, estado_nuevo, fecha_cambio, motivo, usuario_cambio)
    SELECT 
        p_camper_id,
        estado,
        p_estado_nuevo,
        CURRENT_TIMESTAMP,
        p_motivo,
        USER()
    FROM Campers
    WHERE camper_id = p_camper_id;
    
    -- Actualizar el estado
    UPDATE Campers
    SET estado = p_estado_nuevo
    WHERE camper_id = p_camper_id;
END //
DELIMITER ;

-- 3. Procesar inscripción a ruta
DELIMITER //
CREATE PROCEDURE procesar_inscripcion_ruta(
    IN p_camper_id INT,
    IN p_ruta_id INT,
    IN p_area_id INT
)
BEGIN
    -- Verificar disponibilidad del área
    SET @ocupacion_actual = (
        SELECT COUNT(*)
        FROM AsignacionCamperArea
        WHERE area_id = p_area_id AND fecha_fin IS NULL
    );
    
    SET @capacidad_maxima = (
        SELECT capacidad_maxima
        FROM AreasEntrenamiento
        WHERE area_id = p_area_id
    );
    
    IF @ocupacion_actual < @capacidad_maxima THEN
        -- Registrar la inscripción
        INSERT INTO InscripcionesCamperRuta (camper_id, ruta_id, fecha_inscripcion, estado)
        VALUES (p_camper_id, p_ruta_id, CURRENT_DATE, 'Pendiente');
        
        -- Asignar al área
        INSERT INTO AsignacionCamperArea (camper_id, area_id, fecha_inicio)
        VALUES (p_camper_id, p_area_id, CURRENT_DATE);
        
        -- Actualizar estado del camper
        CALL actualizar_estado_camper(p_camper_id, 'Inscrito', 'Inscripción a ruta completada');
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El área seleccionada está al máximo de su capacidad';
    END IF;
END //
DELIMITER ;

-- 4. Registrar evaluación completa
DELIMITER //
CREATE PROCEDURE registrar_evaluacion(
    IN p_camper_id INT,
    IN p_modulo_id INT,
    IN p_nota_teorica DECIMAL(5,2),
    IN p_nota_practica DECIMAL(5,2),
    IN p_nota_quizzes DECIMAL(5,2),
    IN p_comentarios TEXT
)
BEGIN
    -- Calcular nota final
    SET @nota_final = (
        SELECT 
            (p_nota_teorica * m.porcentaje_teorico +
             p_nota_practica * m.porcentaje_practico +
             p_nota_quizzes * m.porcentaje_quizzes) / 100
        FROM Modulos m
        WHERE m.modulo_id = p_modulo_id
    );
    
    -- Registrar la evaluación
    INSERT INTO Evaluaciones (
        camper_id, modulo_id, nota_teorica, nota_practica, 
        nota_quizzes, nota_final, fecha_evaluacion, comentarios
    )
    VALUES (
        p_camper_id, p_modulo_id, p_nota_teorica, p_nota_practica,
        p_nota_quizzes, @nota_final, CURRENT_DATE, p_comentarios
    );
END //
DELIMITER ;

-- 5. Calcular nota final de módulo
DELIMITER //
CREATE FUNCTION calcular_nota_final_modulo(
    p_camper_id INT,
    p_modulo_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    SELECT 
        (nota_teorica * m.porcentaje_teorico +
         nota_practica * m.porcentaje_practico +
         nota_quizzes * m.porcentaje_quizzes) / 100
    INTO v_nota_final
    FROM Evaluaciones e
    JOIN Modulos m ON e.modulo_id = m.modulo_id
    WHERE e.camper_id = p_camper_id 
    AND e.modulo_id = p_modulo_id;
    
    RETURN v_nota_final;
END //
DELIMITER ;

-- 6. Asignar campers aprobados a ruta
DELIMITER //
CREATE PROCEDURE asignar_campers_aprobados_ruta(
    IN p_ruta_id INT,
    IN p_area_id INT
)
BEGIN
    DECLARE v_camper_id INT;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_cursor CURSOR FOR 
        SELECT c.camper_id
        FROM Campers c
        WHERE c.estado = 'Aprobado'
        AND NOT EXISTS (
            SELECT 1 FROM InscripcionesCamperRuta icr 
            WHERE icr.camper_id = c.camper_id
        );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    OPEN v_cursor;
    
    read_loop: LOOP
        FETCH v_cursor INTO v_camper_id;
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        CALL procesar_inscripcion_ruta(v_camper_id, p_ruta_id, p_area_id);
    END LOOP;
    
    CLOSE v_cursor;
END //
DELIMITER ;

-- 7. Asignar trainer a ruta y área
DELIMITER //
CREATE PROCEDURE asignar_trainer_ruta_area(
    IN p_trainer_id INT,
    IN p_ruta_id INT,
    IN p_area_id INT,
    IN p_horario_id INT,
    IN p_dia_id INT
)
BEGIN
    -- Verificar disponibilidad del trainer
    IF NOT EXISTS (
        SELECT 1
        FROM TrainerAreaHorario tah
        WHERE tah.trainer_id = p_trainer_id
        AND tah.horario_id = p_horario_id
        AND tah.dia_id = p_dia_id
        AND tah.fecha_fin IS NULL
    ) THEN
        -- Asignar trainer a la ruta
        INSERT INTO AsignacionesTrainerRuta (trainer_id, ruta_id, fecha_inicio, activo)
        VALUES (p_trainer_id, p_ruta_id, CURRENT_DATE, TRUE);
        
        -- Asignar horario y área
        INSERT INTO TrainerAreaHorario (trainer_id, area_id, horario_id, dia_id, fecha_inicio)
        VALUES (p_trainer_id, p_area_id, p_horario_id, p_dia_id, CURRENT_DATE);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El trainer ya tiene asignación en este horario';
    END IF;
END //
DELIMITER ;

-- 8. Registrar nueva ruta
DELIMITER //
CREATE PROCEDURE registrar_nueva_ruta(
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_sgbd_principal INT,
    IN p_sgbd_alternativo INT,
    IN p_modulos JSON
)
BEGIN
    -- Insertar la ruta
    INSERT INTO Rutas (nombre, descripcion, sgbd_principal, sgbd_alternativo)
    VALUES (p_nombre, p_descripcion, p_sgbd_principal, p_sgbd_alternativo);
    
    SET @ruta_id = LAST_INSERT_ID();
    
    -- Insertar módulos de la ruta
    INSERT INTO RutaModulos (ruta_id, modulo_id, orden)
    SELECT @ruta_id, 
           JSON_EXTRACT(p_modulos, CONCAT('$[', n.n, '].modulo_id')),
           JSON_EXTRACT(p_modulos, CONCAT('$[', n.n, '].orden'))
    FROM (
        SELECT a.N - 1 as n
        FROM (
            SELECT 1 as N UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        ) a
        WHERE a.N <= JSON_LENGTH(p_modulos)
    ) n;
END //
DELIMITER ;

-- 9. Registrar nueva área de entrenamiento
DELIMITER //
CREATE PROCEDURE registrar_nueva_area(
    IN p_nombre VARCHAR(100),
    IN p_capacidad_maxima INT,
    IN p_estado ENUM('Activa', 'Inactiva', 'Mantenimiento')
)
BEGIN
    -- Insertar el área
    INSERT INTO AreasEntrenamiento (nombre, capacidad_maxima, estado)
    VALUES (p_nombre, p_capacidad_maxima, p_estado);
    
    SET @area_id = LAST_INSERT_ID();
    
    -- Insertar disponibilidad por defecto (lunes a viernes, todos los horarios)
    INSERT INTO DisponibilidadAreas (area_id, horario_id, dia_id, disponible)
    SELECT @area_id, h.horario_id, d.dia_id, TRUE
    FROM Horarios h
    CROSS JOIN DiasSemanales d
    WHERE d.dia_id <= 5;
END //
DELIMITER ;

-- 10. Consultar disponibilidad de horario
DELIMITER //
CREATE PROCEDURE consultar_disponibilidad_area(
    IN p_area_id INT,
    IN p_fecha DATE
)
BEGIN
    SELECT 
        ae.nombre as area,
        h.hora_inicio,
        h.hora_fin,
        d.nombre as dia,
        da.disponible,
        COUNT(aca.camper_id) as ocupacion_actual,
        ae.capacidad_maxima
    FROM AreasEntrenamiento ae
    JOIN DisponibilidadAreas da ON ae.area_id = da.area_id
    JOIN Horarios h ON da.horario_id = h.horario_id
    JOIN DiasSemanales d ON da.dia_id = d.dia_id
    LEFT JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id 
        AND aca.fecha_fin IS NULL
    WHERE ae.area_id = p_area_id
    AND d.dia_id = DAYOFWEEK(p_fecha)
    GROUP BY ae.area_id, h.horario_id, d.dia_id
    ORDER BY h.hora_inicio;
END //
DELIMITER ;

-- 11. Reasignar camper a otra ruta
DELIMITER //
CREATE PROCEDURE reasignar_camper_ruta(
    IN p_camper_id INT,
    IN p_nueva_ruta_id INT,
    IN p_nueva_area_id INT,
    IN p_motivo TEXT
)
BEGIN
    -- Finalizar inscripción actual
    UPDATE InscripcionesCamperRuta
    SET fecha_fin = CURRENT_DATE,
        estado = 'Cancelada'
    WHERE camper_id = p_camper_id
    AND fecha_fin IS NULL;
    
    -- Finalizar asignación actual al área
    UPDATE AsignacionCamperArea
    SET fecha_fin = CURRENT_DATE
    WHERE camper_id = p_camper_id
    AND fecha_fin IS NULL;
    
    -- Registrar nueva inscripción
    CALL procesar_inscripcion_ruta(p_camper_id, p_nueva_ruta_id, p_nueva_area_id);
    
    -- Registrar el cambio en el historial
    INSERT INTO HistorialEstadosCamper (
        camper_id, estado_anterior, estado_nuevo, 
        fecha_cambio, motivo, usuario_cambio
    )
    VALUES (
        p_camper_id, 'Cursando', 'Inscrito',
        CURRENT_TIMESTAMP, p_motivo, USER()
    );
END //
DELIMITER ;

-- 12. Cambiar estado a Graduado
DELIMITER //
CREATE PROCEDURE graduar_camper(
    IN p_camper_id INT
)
BEGIN
    -- Verificar que haya aprobado todos los módulos de su ruta
    IF NOT EXISTS (
        SELECT 1
        FROM InscripcionesCamperRuta icr
        JOIN RutaModulos rm ON icr.ruta_id = rm.ruta_id
        LEFT JOIN Evaluaciones e ON icr.camper_id = e.camper_id 
            AND rm.modulo_id = e.modulo_id
        WHERE icr.camper_id = p_camper_id
        AND (e.nota_final < 60 OR e.nota_final IS NULL)
    ) THEN
        -- Registrar como egresado
        INSERT INTO Egresados (camper_id, fecha_graduacion, ruta_id, promedio_final)
        SELECT 
            p_camper_id,
            CURRENT_DATE,
            icr.ruta_id,
            AVG(e.nota_final)
        FROM InscripcionesCamperRuta icr
        JOIN Evaluaciones e ON icr.camper_id = e.camper_id
        WHERE icr.camper_id = p_camper_id
        AND icr.fecha_fin IS NULL;
        
        -- Actualizar estado
        CALL actualizar_estado_camper(
            p_camper_id, 
            'Graduado',
            'Completó satisfactoriamente todos los módulos'
        );
        
        -- Finalizar inscripción
        UPDATE InscripcionesCamperRuta
        SET fecha_fin = CURRENT_DATE,
            estado = 'Finalizada'
        WHERE camper_id = p_camper_id
        AND fecha_fin IS NULL;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El camper no ha aprobado todos los módulos';
    END IF;
END //
DELIMITER ;

-- 13. Consultar rendimiento de camper
DELIMITER //
CREATE PROCEDURE consultar_rendimiento_camper(
    IN p_camper_id INT
)
BEGIN
    SELECT 
        c.nombres,
        c.apellidos,
        r.nombre as ruta,
        m.nombre as modulo,
        e.nota_teorica,
        e.nota_practica,
        e.nota_quizzes,
        e.nota_final,
        e.fecha_evaluacion,
        e.comentarios
    FROM Campers c
    JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
    JOIN Rutas r ON icr.ruta_id = r.ruta_id
    JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
    LEFT JOIN Evaluaciones e ON c.camper_id = e.camper_id 
        AND rm.modulo_id = e.modulo_id
    WHERE c.camper_id = p_camper_id
    ORDER BY rm.orden, e.fecha_evaluacion;
END //
DELIMITER ;

-- 14. Registrar asistencia
DELIMITER //
CREATE PROCEDURE registrar_asistencia(
    IN p_camper_id INT,
    IN p_area_id INT,
    IN p_fecha DATE,
    IN p_horario_id INT,
    IN p_presente BOOLEAN,
    IN p_observaciones TEXT
)
BEGIN
    INSERT INTO Asistencia (
        camper_id, area_id, fecha, horario_id, 
        presente, observaciones
    )
    VALUES (
        p_camper_id, p_area_id, p_fecha, p_horario_id,
        p_presente, p_observaciones
    );
END //
DELIMITER ;

-- 15. Generar reporte mensual de notas
DELIMITER //
CREATE PROCEDURE generar_reporte_mensual_notas(
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    SELECT 
        r.nombre as ruta,
        m.nombre as modulo,
        COUNT(e.evaluacion_id) as total_evaluaciones,
        AVG(e.nota_final) as promedio_nota_final,
        COUNT(CASE WHEN e.nota_final >= 60 THEN 1 END) as aprobados,
        COUNT(CASE WHEN e.nota_final < 60 THEN 1 END) as reprobados
    FROM Rutas r
    JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
    JOIN Modulos m ON rm.modulo_id = m.modulo_id
    LEFT JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
        AND MONTH(e.fecha_evaluacion) = p_mes
        AND YEAR(e.fecha_evaluacion) = p_anio
    GROUP BY r.ruta_id, r.nombre, m.modulo_id, m.nombre
    ORDER BY r.nombre, m.nombre;
END //
DELIMITER ;

-- 16. Validar y registrar asignación de salón
DELIMITER //
CREATE PROCEDURE asignar_salon_ruta(
    IN p_ruta_id INT,
    IN p_area_id INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    -- Verificar capacidad
    SET @ocupacion_actual = (
        SELECT COUNT(*)
        FROM AsignacionCamperArea
        WHERE area_id = p_area_id
        AND fecha_fin IS NULL
    );
    
    SET @capacidad_maxima = (
        SELECT capacidad_maxima
        FROM AreasEntrenamiento
        WHERE area_id = p_area_id
    );
    
    IF @ocupacion_actual < @capacidad_maxima THEN
        -- Asignar el área a todos los campers de la ruta
        INSERT INTO AsignacionCamperArea (
            camper_id, area_id, fecha_inicio, fecha_fin
        )
        SELECT 
            icr.camper_id,
            p_area_id,
            p_fecha_inicio,
            p_fecha_fin
        FROM InscripcionesCamperRuta icr
        WHERE icr.ruta_id = p_ruta_id
        AND icr.estado = 'En curso';
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El área seleccionada está al máximo de su capacidad';
    END IF;
END //
DELIMITER ;

-- 17. Registrar cambio de horario de trainer
DELIMITER //
CREATE PROCEDURE cambiar_horario_trainer(
    IN p_trainer_id INT,
    IN p_area_id INT,
    IN p_horario_actual_id INT,
    IN p_dia_actual_id INT,
    IN p_nuevo_horario_id INT,
    IN p_nuevo_dia_id INT
)
BEGIN
    -- Finalizar asignación actual
    UPDATE TrainerAreaHorario
    SET fecha_fin = CURRENT_DATE
    WHERE trainer_id = p_trainer_id
    AND area_id = p_area_id
    AND horario_id = p_horario_actual_id
    AND dia_id = p_dia_actual_id
    AND fecha_fin IS NULL;
    
    -- Verificar disponibilidad del nuevo horario
    IF NOT EXISTS (
        SELECT 1
        FROM TrainerAreaHorario tah
        WHERE tah.trainer_id = p_trainer_id
        AND tah.horario_id = p_nuevo_horario_id
        AND tah.dia_id = p_nuevo_dia_id
        AND tah.fecha_fin IS NULL
    ) THEN
        -- Registrar nueva asignación
        INSERT INTO TrainerAreaHorario (
            trainer_id, area_id, horario_id, dia_id, fecha_inicio
        )
        VALUES (
            p_trainer_id, p_area_id, p_nuevo_horario_id, 
            p_nuevo_dia_id, CURRENT_DATE
        );
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El trainer ya tiene asignación en este horario';
    END IF;
END //
DELIMITER ;

-- 18. Eliminar inscripción de camper
DELIMITER //
CREATE PROCEDURE eliminar_inscripcion_camper(
    IN p_camper_id INT,
    IN p_motivo TEXT
)
BEGIN
    -- Finalizar inscripción
    UPDATE InscripcionesCamperRuta
    SET fecha_fin = CURRENT_DATE,
        estado = 'Cancelada'
    WHERE camper_id = p_camper_id
    AND fecha_fin IS NULL;
    
    -- Finalizar asignación al área
    UPDATE AsignacionCamperArea
    SET fecha_fin = CURRENT_DATE
    WHERE camper_id = p_camper_id
    AND fecha_fin IS NULL;
    
    -- Actualizar estado del camper
    CALL actualizar_estado_camper(
        p_camper_id,
        'Retirado',
        p_motivo
    );
END //
DELIMITER ;

-- 19. Recalcular estado de campers
DELIMITER //
CREATE PROCEDURE recalcular_estado_campers()
BEGIN
    DECLARE v_camper_id INT;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_cursor CURSOR FOR 
        SELECT DISTINCT c.camper_id
        FROM Campers c
        WHERE c.estado = 'Cursando';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    OPEN v_cursor;
    
    read_loop: LOOP
        FETCH v_cursor INTO v_camper_id;
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        
        -- Verificar si ha aprobado todos los módulos
        IF NOT EXISTS (
            SELECT 1
            FROM InscripcionesCamperRuta icr
            JOIN RutaModulos rm ON icr.ruta_id = rm.ruta_id
            LEFT JOIN Evaluaciones e ON icr.camper_id = e.camper_id 
                AND rm.modulo_id = e.modulo_id
            WHERE icr.camper_id = v_camper_id
            AND (e.nota_final < 60 OR e.nota_final IS NULL)
        ) THEN
            -- Graduar al camper
            CALL graduar_camper(v_camper_id);
        ELSE
            -- Verificar si tiene bajo rendimiento
            IF EXISTS (
                SELECT 1
                FROM Evaluaciones e
                WHERE e.camper_id = v_camper_id
                AND e.nota_final < 60
                AND e.fecha_evaluacion >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
            ) THEN
                -- Actualizar nivel de riesgo
                UPDATE Campers
                SET nivel_riesgo = 'Alto'
                WHERE camper_id = v_camper_id;
            END IF;
        END IF;
    END LOOP;
    
    CLOSE v_cursor;
END //
DELIMITER ;
