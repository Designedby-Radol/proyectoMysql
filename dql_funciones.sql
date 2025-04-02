-- 1. Calcular el promedio ponderado de evaluaciones de un camper
DELIMITER //
CREATE FUNCTION calcular_promedio_ponderado_camper(p_camper_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(nota_final) INTO promedio
    FROM Evaluaciones
    WHERE camper_id = p_camper_id;
    RETURN promedio;
END //
DELIMITER ;

-- 2. Determinar si un camper aprueba o no un módulo específico
DELIMITER //
CREATE FUNCTION verificar_aprobacion_modulo(p_camper_id INT, p_modulo_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE aprobado BOOLEAN;
    SELECT aprobado INTO aprobado
    FROM Evaluaciones
    WHERE camper_id = p_camper_id AND modulo_id = p_modulo_id
    ORDER BY fecha_evaluacion DESC
    LIMIT 1;
    RETURN aprobado;
END //
DELIMITER ;

-- 3. Evaluar el nivel de riesgo de un camper según su rendimiento promedio
DELIMITER //
CREATE FUNCTION evaluar_nivel_riesgo(p_camper_id INT)
RETURNS ENUM('Bajo', 'Medio', 'Alto')
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    DECLARE nivel_riesgo ENUM('Bajo', 'Medio', 'Alto');
    
    SELECT AVG(nota_final) INTO promedio
    FROM Evaluaciones
    WHERE camper_id = p_camper_id;
    
    IF promedio >= 80 THEN
        SET nivel_riesgo = 'Bajo';
    ELSEIF promedio >= 60 THEN
        SET nivel_riesgo = 'Medio';
    ELSE
        SET nivel_riesgo = 'Alto';
    END IF;
    
    RETURN nivel_riesgo;
END //
DELIMITER ;

-- 4. Obtener el total de campers asignados a una ruta específica
DELIMITER //
CREATE FUNCTION obtener_total_campers_ruta(p_ruta_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM InscripcionesCamperRuta
    WHERE ruta_id = p_ruta_id AND estado = 'En curso';
    RETURN total;
END //
DELIMITER ;

-- 5. Consultar la cantidad de módulos que ha aprobado un camper
DELIMITER //
CREATE FUNCTION contar_modulos_aprobados(p_camper_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Evaluaciones
    WHERE camper_id = p_camper_id AND aprobado = TRUE;
    RETURN total;
END //
DELIMITER ;

-- 6. Validar si hay cupos disponibles en una determinada área
DELIMITER //
CREATE FUNCTION verificar_cupos_area(p_area_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE cupos_disponibles BOOLEAN;
    DECLARE capacidad_maxima INT;
    DECLARE ocupacion_actual INT;
    
    SELECT capacidad_maxima INTO capacidad_maxima
    FROM AreasEntrenamiento
    WHERE area_id = p_area_id;
    
    SELECT COUNT(*) INTO ocupacion_actual
    FROM AsignacionCamperArea
    WHERE area_id = p_area_id AND fecha_fin IS NULL;
    
    SET cupos_disponibles = (ocupacion_actual < capacidad_maxima);
    RETURN cupos_disponibles;
END //
DELIMITER ;

-- 7. Calcular el porcentaje de ocupación de un área de entrenamiento
DELIMITER //
CREATE FUNCTION calcular_porcentaje_ocupacion(p_area_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE porcentaje DECIMAL(5,2);
    DECLARE capacidad_maxima INT;
    DECLARE ocupacion_actual INT;
    
    SELECT capacidad_maxima INTO capacidad_maxima
    FROM AreasEntrenamiento
    WHERE area_id = p_area_id;
    
    SELECT COUNT(*) INTO ocupacion_actual
    FROM AsignacionCamperArea
    WHERE area_id = p_area_id AND fecha_fin IS NULL;
    
    SET porcentaje = (ocupacion_actual / capacidad_maxima) * 100;
    RETURN porcentaje;
END //
DELIMITER ;

-- 8. Determinar la nota más alta obtenida en un módulo
DELIMITER //
CREATE FUNCTION obtener_nota_maxima_modulo(p_modulo_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE nota_maxima DECIMAL(5,2);
    SELECT MAX(nota_final) INTO nota_maxima
    FROM Evaluaciones
    WHERE modulo_id = p_modulo_id;
    RETURN nota_maxima;
END //
DELIMITER ;

-- 9. Calcular la tasa de aprobación de una ruta
DELIMITER //
CREATE FUNCTION calcular_tasa_aprobacion_ruta(p_ruta_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE tasa DECIMAL(5,2);
    DECLARE total_inscritos INT;
    DECLARE total_graduados INT;
    
    SELECT COUNT(*) INTO total_inscritos
    FROM InscripcionesCamperRuta
    WHERE ruta_id = p_ruta_id AND estado = 'Finalizada';
    
    SELECT COUNT(*) INTO total_graduados
    FROM InscripcionesCamperRuta
    WHERE ruta_id = p_ruta_id AND estado = 'Finalizada';
    
    IF total_inscritos > 0 THEN
        SET tasa = (total_graduados / total_inscritos) * 100;
    ELSE
        SET tasa = 0;
    END IF;
    
    RETURN tasa;
END //
DELIMITER ;

-- 10. Verificar si un trainer tiene horario disponible
DELIMITER //
CREATE FUNCTION verificar_disponibilidad_trainer(p_trainer_id INT, p_hora_inicio TIME, p_hora_fin TIME, p_dia_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE disponible BOOLEAN;
    SELECT NOT EXISTS (
        SELECT 1
        FROM TrainerAreaHorario
        WHERE trainer_id = p_trainer_id
        AND dia_id = p_dia_id
        AND (
            (p_hora_inicio BETWEEN hora_inicio AND hora_fin)
            OR (p_hora_fin BETWEEN hora_inicio AND hora_fin)
            OR (hora_inicio BETWEEN p_hora_inicio AND p_hora_fin)
            OR (hora_fin BETWEEN p_hora_inicio AND p_hora_fin)
        )
        AND fecha_fin IS NULL
    ) INTO disponible;
    RETURN disponible;
END //
DELIMITER ;

-- 11. Obtener el promedio de notas por ruta
DELIMITER //
CREATE FUNCTION obtener_promedio_ruta(p_ruta_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(e.nota_final) INTO promedio
    FROM Evaluaciones e
    JOIN InscripcionesCamperRuta icr ON e.camper_id = icr.camper_id
    WHERE icr.ruta_id = p_ruta_id;
    RETURN promedio;
END //
DELIMITER ;

-- 12. Calcular cuántas rutas tiene asignadas un trainer
DELIMITER //
CREATE FUNCTION contar_rutas_trainer(p_trainer_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(DISTINCT ruta_id) INTO total
    FROM AsignacionesTrainerRuta
    WHERE trainer_id = p_trainer_id AND activo = TRUE;
    RETURN total;
END //
DELIMITER ;

-- 13. Verificar si un camper puede ser graduado
DELIMITER //
CREATE FUNCTION verificar_graduacion_camper(p_camper_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE puede_graduarse BOOLEAN;
    DECLARE total_modulos INT;
    DECLARE modulos_aprobados INT;
    
    SELECT COUNT(*) INTO total_modulos
    FROM RutaModulos rm
    JOIN InscripcionesCamperRuta icr ON rm.ruta_id = icr.ruta_id
    WHERE icr.camper_id = p_camper_id AND icr.estado = 'En curso';
    
    SELECT COUNT(*) INTO modulos_aprobados
    FROM Evaluaciones
    WHERE camper_id = p_camper_id AND aprobado = TRUE;
    
    SET puede_graduarse = (modulos_aprobados = total_modulos);
    RETURN puede_graduarse;
END //
DELIMITER ;

-- 14. Obtener el estado actual de un camper en función de sus evaluaciones
DELIMITER //
CREATE FUNCTION obtener_estado_camper(p_camper_id INT)
RETURNS ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado')
DETERMINISTIC
BEGIN
    DECLARE estado_actual ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado');
    SELECT estado INTO estado_actual
    FROM Campers
    WHERE camper_id = p_camper_id;
    RETURN estado_actual;
END //
DELIMITER ;

-- 15. Calcular la carga horaria semanal de un trainer
DELIMITER //
CREATE FUNCTION calcular_carga_horaria_trainer(p_trainer_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE carga_horaria INT;
    SELECT COUNT(*) * 4 INTO carga_horaria
    FROM TrainerAreaHorario
    WHERE trainer_id = p_trainer_id
    AND fecha_fin IS NULL;
    RETURN carga_horaria;
END //
DELIMITER ;

-- 16. Determinar si una ruta tiene módulos pendientes por evaluación
DELIMITER //
CREATE FUNCTION verificar_modulos_pendientes(p_ruta_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE tiene_pendientes BOOLEAN;
    SELECT EXISTS (
        SELECT 1
        FROM RutaModulos rm
        JOIN InscripcionesCamperRuta icr ON rm.ruta_id = icr.ruta_id
        LEFT JOIN Evaluaciones e ON e.camper_id = icr.camper_id AND e.modulo_id = rm.modulo_id
        WHERE rm.ruta_id = p_ruta_id
        AND icr.estado = 'En curso'
        AND e.evaluacion_id IS NULL
    ) INTO tiene_pendientes;
    RETURN tiene_pendientes;
END //
DELIMITER ;

-- 17. Calcular el promedio general del programa
DELIMITER //
CREATE FUNCTION calcular_promedio_general_programa()
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    SELECT AVG(nota_final) INTO promedio
    FROM Evaluaciones;
    RETURN promedio;
END //
DELIMITER ;

-- 18. Verificar si un horario choca con otros entrenadores en el área
DELIMITER //
CREATE FUNCTION verificar_conflicto_horario(p_area_id INT, p_hora_inicio TIME, p_hora_fin TIME, p_dia_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE hay_conflicto BOOLEAN;
    SELECT EXISTS (
        SELECT 1
        FROM TrainerAreaHorario
        WHERE area_id = p_area_id
        AND dia_id = p_dia_id
        AND (
            (p_hora_inicio BETWEEN hora_inicio AND hora_fin)
            OR (p_hora_fin BETWEEN hora_inicio AND hora_fin)
            OR (hora_inicio BETWEEN p_hora_inicio AND p_hora_fin)
            OR (hora_fin BETWEEN p_hora_inicio AND p_hora_fin)
        )
        AND fecha_fin IS NULL
    ) INTO hay_conflicto;
    RETURN hay_conflicto;
END //
DELIMITER ;

-- 19. Calcular cuántos campers están en riesgo en una ruta específica
DELIMITER //
CREATE FUNCTION contar_campers_riesgo_ruta(p_ruta_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_riesgo INT;
    SELECT COUNT(DISTINCT c.camper_id) INTO total_riesgo
    FROM Campers c
    JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
    WHERE icr.ruta_id = p_ruta_id
    AND c.nivel_riesgo = 'Alto'
    AND icr.estado = 'En curso';
    RETURN total_riesgo;
END //
DELIMITER ;

-- 20. Consultar el número de módulos evaluados por un camper
DELIMITER //
CREATE FUNCTION contar_modulos_evaluados(p_camper_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_evaluados INT;
    SELECT COUNT(*) INTO total_evaluados
    FROM Evaluaciones
    WHERE camper_id = p_camper_id;
    RETURN total_evaluados;
END //
DELIMITER ;
