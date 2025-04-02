-- USUARIOS

    -- Obtener todos los campers inscritos actualmente:
SELECT  nombres, estado FROM Campers WHERE estado = 'Inscrito';

    --Listar los campers con estado "Aprobado":
SELECT  nombres, estado FROM Campers WHERE estado = 'Aprobado';

    --Mostrar los campers que ya están cursando alguna ruta:
SELECT  nombres, estado FROM Campers WHERE estado = 'Cursando';

    --Consultar los campers graduados por cada ruta:
SELECT r.nombre AS ruta, COUNT(e.camper_id) AS total_graduados
FROM Egresados e
JOIN Rutas r ON e.ruta_id = r.ruta_id
GROUP BY r.nombre;

    --Obtener los campers que se encuentran en estado "Expulsado" o "Retirado":
SELECT nombres, estado FROM Campers WHERE estado IN ('Expulsado', 'Retirado');

    --Listar campers con nivel de riesgo "Alto":
SELECT nombres,nivel_riesgo FROM Campers WHERE nivel_riesgo = 'Alto';

    --Mostrar el total de campers por cada nivel de riesgo:
SELECT nivel_riesgo, COUNT(*) AS total
FROM Campers
GROUP BY nivel_riesgo;

    -- Obtener campers con más de un número telefónico registrado:

SELECT c.camper_id, c.nombres, c.apellidos, COUNT(t.telefono_id) AS num_telefonos
FROM Campers c
JOIN TelefonosCampers t ON c.camper_id = t.camper_id
GROUP BY c.camper_id, c.nombres, c.apellidos
HAVING COUNT(t.telefono_id) > 1;

    -- Listar los campers y sus respectivos acudientes y teléfonos:
SELECT c.camper_id, c.nombres, c.apellidos, c.acudiente, t.numero_telefono, t.tipo
FROM Campers c
LEFT JOIN TelefonosCampers t ON c.camper_id = t.camper_id;

    --Mostrar campers que aún no han sido asignados a una ruta:
SELECT c.camper_id, c.numero_identificacion, c.nombres, c.apellidos, c.estado
FROM Campers c
LEFT JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
WHERE icr.camper_id IS NULL;

--  EVALUACIONES

    --Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo:
SELECT c.nombres, c.apellidos, m.nombre AS modulo, 
    e.nota_teorica, e.nota_practica, e.nota_quizzes
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id;

    --Calcular la nota final de cada camper por módulo:

SELECT c.nombres, c.apellidos, m.nombre AS modulo, 
    e.nota_final
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id;

    --Mostrar los campers que reprobaron algún módulo (nota < 60):
SELECT c.nombres, c.apellidos, m.nombre AS modulo, 
    e.nota_final
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
WHERE e.aprobado = FALSE;

    --Listar los módulos con más campers en bajo rendimiento:
SELECT m.nombre AS modulo, COUNT(*) AS campers_bajo_rendimiento
FROM Evaluaciones e
JOIN Modulos m ON e.modulo_id = m.modulo_id
WHERE e.aprobado = FALSE
GROUP BY m.nombre
ORDER BY campers_bajo_rendimiento DESC;

    --Obtener el promedio de notas finales por cada módulo:

SELECT m.nombre AS modulo, AVG(e.nota_final) AS promedio
FROM Evaluaciones e
JOIN Modulos m ON e.modulo_id = m.modulo_id
GROUP BY m.nombre;

    -- Consultar el rendimiento general por ruta de entrenamiento:

SELECT r.nombre AS ruta, AVG(e.nota_final) AS promedio_ruta
FROM Evaluaciones e
JOIN Modulos m ON e.modulo_id = m.modulo_id
JOIN RutaModulos rm ON m.modulo_id = rm.modulo_id
JOIN Rutas r ON rm.ruta_id = r.ruta_id
GROUP BY r.nombre;

    --Mostrar los trainers responsables de campers con bajo rendimiento:
SELECT DISTINCT T.trainer_id, T.nombres, T.apellidos
FROM Trainers T
JOIN AsignacionesTrainerRuta ATR ON T.trainer_id = ATR.trainer_id
JOIN InscripcionesCamperRuta ICR ON ATR.ruta_id = ICR.ruta_id
JOIN Evaluaciones E ON ICR.camper_id = E.camper_id
WHERE E.nota_final < 60;

    --Comparar el promedio de rendimiento por trainer:
SELECT t.nombres, t.apellidos, AVG(e.nota_final) AS promedio_rendimiento
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
JOIN InscripcionesCamperRuta icr ON atr.ruta_id = icr.ruta_id
JOIN Evaluaciones e ON icr.camper_id = e.camper_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
ORDER BY promedio_rendimiento DESC;

    --Listar los mejores 5 campers por nota final en cada ruta:
SELECT r.nombre AS ruta, c.nombres, c.apellidos, AVG(e.nota_final) AS promedio
FROM Campers c
JOIN Evaluaciones e ON c.camper_id = e.camper_id
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
GROUP BY r.ruta_id, r.nombre, c.camper_id, c.nombres, c.apellidos
ORDER BY r.nombre, promedio DESC;

    --Mostrar cuántos campers pasaron cada módulo por ruta:
SELECT r.nombre AS ruta, m.nombre AS modulo, 
    COUNT(CASE WHEN e.aprobado = TRUE THEN 1 END) AS campers_aprobados
FROM Evaluaciones e
JOIN Modulos m ON e.modulo_id = m.modulo_id
JOIN RutaModulos rm ON m.modulo_id = rm.modulo_id
JOIN Rutas r ON rm.ruta_id = r.ruta_id
JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id AND e.camper_id = icr.camper_id
GROUP BY r.nombre, m.nombre;

    --Rutas y Áreas de Entrenamiento



    --Mostrar todas las rutas de entrenamiento disponibles
SELECT * FROM Rutas;

    --Obtener las rutas con su SGDB principal y alternativo:
SELECT r.nombre AS ruta, 
       s1.nombre AS sgdb_principal, 
       s2.nombre AS sgdb_alternativo
FROM Rutas r
JOIN SGBD s1 ON r.sgbd_principal = s1.sgbd_id
JOIN SGBD s2 ON r.sgbd_alternativo = s2.sgbd_id;

    --Listar los módulos asociados a cada ruta:
SELECT r.nombre AS ruta, m.nombre AS modulo, rm.orden
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
JOIN Modulos m ON rm.modulo_id = m.modulo_id
ORDER BY r.nombre, rm.orden;


SELECT r.nombre AS ruta, COUNT(icr.camper_id) AS total_campers
FROM Rutas r
LEFT JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id
WHERE icr.estado = 'En curso'
GROUP BY r.nombre;


SELECT nombre, capacidad_maxima FROM AreasEntrenamiento;


SELECT ae.nombre, ae.capacidad_maxima, COUNT(aca.camper_id) AS ocupacion_actual
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima
HAVING COUNT(aca.camper_id) >= ae.capacidad_maxima;


SELECT ae.nombre, ae.capacidad_maxima, 
       COUNT(aca.camper_id) AS ocupacion_actual,
       (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) AS porcentaje_ocupacion
FROM AreasEntrenamiento ae
LEFT JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id AND aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima;


SELECT ae.nombre AS area, h.hora_inicio, h.hora_fin, d.nombre AS dia
FROM AreasEntrenamiento ae
JOIN DisponibilidadAreas da ON ae.area_id = da.area_id
JOIN Horarios h ON da.horario_id = h.horario_id
JOIN DiasSemanales d ON da.dia_id = d.dia_id
WHERE da.disponible = TRUE
ORDER BY ae.nombre, d.dia_id, h.hora_inicio;



SELECT ae.nombre, COUNT(aca.camper_id) AS total_campers
FROM AreasEntrenamiento ae
LEFT JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.nombre
ORDER BY total_campers DESC;



SELECT r.nombre AS ruta, 
       CONCAT(t.nombres, ' ', t.apellidos) AS trainer,
       ae.nombre AS area
FROM Rutas r
JOIN AsignacionesTrainerRuta atr ON r.ruta_id = atr.ruta_id
JOIN Trainers t ON atr.trainer_id = t.trainer_id
JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id
JOIN AreasEntrenamiento ae ON tah.area_id = ae.area_id
WHERE atr.activo = TRUE AND tah.fecha_fin IS NULL;


SELECT * FROM Trainers WHERE estado = 'Activo';


SELECT t.nombres, t.apellidos, 
       ae.nombre AS area, 
       h.hora_inicio, h.hora_fin, 
       d.nombre AS dia
FROM Trainers t
JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id
JOIN AreasEntrenamiento ae ON tah.area_id = ae.area_id
JOIN Horarios h ON tah.horario_id = h.horario_id
JOIN DiasSemanales d ON tah.dia_id = d.dia_id
WHERE tah.fecha_fin IS NULL
ORDER BY t.nombres, t.apellidos, d.dia_id, h.hora_inicio;



SELECT t.nombres, t.apellidos, COUNT(DISTINCT atr.ruta_id) AS total_rutas
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
HAVING COUNT(DISTINCT atr.ruta_id) > 1;



SELECT t.nombres, t.apellidos, COUNT(DISTINCT icr.camper_id) AS total_campers
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
JOIN InscripcionesCamperRuta icr ON atr.ruta_id = icr.ruta_id
WHERE atr.activo = TRUE AND icr.estado = 'En curso'
GROUP BY t.trainer_id, t.nombres, t.apellidos;



SELECT t.nombres, t.apellidos, 
       GROUP_CONCAT(DISTINCT ae.nombre ORDER BY ae.nombre) AS areas
FROM Trainers t
JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id
JOIN AreasEntrenamiento ae ON tah.area_id = ae.area_id
WHERE tah.fecha_fin IS NULL
GROUP BY t.trainer_id, t.nombres, t.apellidos;



SELECT t.*
FROM Trainers t
LEFT JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id AND atr.activo = TRUE
LEFT JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id AND tah.fecha_fin IS NULL
WHERE t.estado = 'Activo' AND atr.trainer_id IS NULL AND tah.trainer_id IS NULL;


SELECT t.nombres, t.apellidos, COUNT(DISTINCT et.modulo_id) AS total_modulos
FROM Trainers t
JOIN EspecialidadesTrainers et ON t.trainer_id = et.trainer_id
WHERE t.estado = 'Activo'
GROUP BY t.trainer_id, t.nombres, t.apellidos;


SELECT t.nombres, t.apellidos, AVG(e.nota_final) AS rendimiento_promedio
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
JOIN InscripcionesCamperRuta icr ON atr.ruta_id = icr.ruta_id
JOIN Evaluaciones e ON icr.camper_id = e.camper_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
ORDER BY rendimiento_promedio DESC
LIMIT 1;



SELECT t.nombres, t.apellidos, 
       d.nombre AS dia, 
       h.hora_inicio, h.hora_fin
FROM Trainers t
JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id
JOIN Horarios h ON tah.horario_id = h.horario_id
JOIN DiasSemanales d ON tah.dia_id = d.dia_id
WHERE tah.fecha_fin IS NULL
ORDER BY t.nombres, t.apellidos, d.dia_id, h.hora_inicio;


SELECT t.nombres, t.apellidos, d.nombre AS dia,
       GROUP_CONCAT(CONCAT(h.hora_inicio, '-', h.hora_fin) ORDER BY h.hora_inicio) AS horarios_ocupados
FROM Trainers t
CROSS JOIN DiasSemanales d
LEFT JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id AND tah.dia_id = d.dia_id AND tah.fecha_fin IS NULL
LEFT JOIN Horarios h ON tah.horario_id = h.horario_id
GROUP BY t.trainer_id, t.nombres, t.apellidos, d.dia_id, d.nombre
ORDER BY t.nombres, d.dia_id;



SELECT m.nombre AS modulo, c.nombres, c.apellidos, e.nota_final
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
WHERE (e.modulo_id, e.nota_final) IN (
    SELECT modulo_id, MAX(nota_final)
    FROM Evaluaciones
    GROUP BY modulo_id
);



WITH PromedioPorRuta AS (
    SELECT r.ruta_id, r.nombre AS ruta, AVG(e.nota_final) AS promedio_ruta
    FROM Evaluaciones e
    JOIN Modulos m ON e.modulo_id = m.modulo_id
    JOIN RutaModulos rm ON m.modulo_id = rm.modulo_id
    JOIN Rutas r ON rm.ruta_id = r.ruta_id
    GROUP BY r.ruta_id, r.nombre
),
PromedioGlobal AS (
    SELECT AVG(nota_final) AS promedio_global
    FROM Evaluaciones
)
SELECT pr.ruta, pr.promedio_ruta, pg.promedio_global,
       pr.promedio_ruta - pg.promedio_global AS diferencia
FROM PromedioPorRuta pr, PromedioGlobal pg
ORDER BY diferencia DESC;



SELECT ae.nombre, ae.capacidad_maxima, 
       COUNT(aca.camper_id) AS ocupacion_actual,
       (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) AS porcentaje_ocupacion
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima
HAVING (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) > 80;



SELECT ae.nombre, ae.capacidad_maxima, 
       COUNT(aca.camper_id) AS ocupacion_actual,
       (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) AS porcentaje_ocupacion
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima
HAVING (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) > 80; 



SELECT t.nombres, t.apellidos, AVG(e.nota_final) AS rendimiento_promedio
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
JOIN InscripcionesCamperRuta icr ON atr.ruta_id = icr.ruta_id
JOIN Evaluaciones e ON icr.camper_id = e.camper_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
HAVING AVG(e.nota_final) < 70
ORDER BY rendimiento_promedio;



WITH PromediosCamper AS (
    SELECT c.camper_id, c.nombres, c.apellidos, AVG(e.nota_final) AS promedio_camper
    FROM Campers c
    JOIN Evaluaciones e ON c.camper_id = e.camper_id
    GROUP BY c.camper_id, c.nombres, c.apellidos
),
PromedioGlobal AS (
    SELECT AVG(nota_final) AS promedio_global
    FROM Evaluaciones
)
SELECT pc.nombres, pc.apellidos, pc.promedio_camper, pg.promedio_global
FROM PromediosCamper pc, PromedioGlobal pg
WHERE pc.promedio_camper < pg.promedio_global
ORDER BY pc.promedio_camper;




SELECT m.nombre AS modulo,
       COUNT(e.evaluacion_id) AS total_evaluaciones,
       COUNT(CASE WHEN e.aprobado = TRUE THEN 1 END) AS aprobados,
       (COUNT(CASE WHEN e.aprobado = TRUE THEN 1 END) / COUNT(e.evaluacion_id) * 100) AS tasa_aprobacion
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY tasa_aprobacion ASC;




SELECT c.camper_id, c.nombres, c.apellidos, r.nombre AS ruta
FROM Campers c
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
WHERE NOT EXISTS (
    SELECT 1
    FROM RutaModulos rm
    WHERE rm.ruta_id = icr.ruta_id
    AND NOT EXISTS (
        SELECT 1
        FROM Evaluaciones e
        WHERE e.camper_id = c.camper_id
        AND e.modulo_id = rm.modulo_id
        AND e.aprobado = TRUE
    )
);



SELECT r.nombre AS ruta, COUNT(DISTINCT e.camper_id) AS campers_bajo_rendimiento
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
JOIN Evaluaciones e ON rm.modulo_id = e.modulo_id
JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id AND e.camper_id = icr.camper_id
WHERE e.aprobado = FALSE
GROUP BY r.ruta_id, r.nombre
HAVING COUNT(DISTINCT e.camper_id) > 10;



SELECT s.nombre AS sgbd_principal, AVG(e.nota_final) AS promedio_rendimiento
FROM SGBD s
JOIN Rutas r ON s.sgbd_id = r.sgbd_principal
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
JOIN Evaluaciones e ON rm.modulo_id = e.modulo_id
GROUP BY s.sgbd_id, s.nombre
ORDER BY promedio_rendimiento DESC;



SELECT m.nombre AS modulo,
       COUNT(e.evaluacion_id) AS total_evaluaciones,
       COUNT(CASE WHEN e.aprobado = FALSE THEN 1 END) AS reprobados,
       (COUNT(CASE WHEN e.aprobado = FALSE THEN 1 END) / COUNT(e.evaluacion_id) * 100) AS porcentaje_reprobados
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
HAVING porcentaje_reprobados >= 30
ORDER BY porcentaje_reprobados DESC;



SELECT m.nombre AS modulo, COUNT(DISTINCT e.camper_id) AS total_campers_riesgo_alto
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
JOIN Campers c ON e.camper_id = c.camper_id
WHERE c.nivel_riesgo = 'Alto'
GROUP BY m.modulo_id, m.nombre
ORDER BY total_campers_riesgo_alto DESC
LIMIT 1;



SELECT t.nombres, t.apellidos, COUNT(DISTINCT atr.ruta_id) AS total_rutas
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
HAVING COUNT(DISTINCT atr.ruta_id) > 3;



SELECT ae.nombre AS area, h.hora_inicio, h.hora_fin, COUNT(tah.trainer_id) AS total_asignaciones
FROM AreasEntrenamiento ae
JOIN TrainerAreaHorario tah ON ae.area_id = tah.area_id
JOIN Horarios h ON tah.horario_id = h.horario_id
WHERE tah.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, h.horario_id, h.hora_inicio, h.hora_fin
ORDER BY total_asignaciones DESC;



SELECT r.nombre AS ruta, COUNT(rm.modulo_id) AS total_modulos
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
GROUP BY r.ruta_id, r.nombre
ORDER BY total_modulos DESC;




SELECT c.nombres, c.apellidos, m.nombre AS modulo,
       e.nota_teorica, e.nota_practica
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
WHERE e.nota_teorica > e.nota_practica;



SELECT m.nombre AS modulo, AVG(e.nota_quizzes) AS promedio_quizzes
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
HAVING AVG(e.nota_quizzes) > 90;



SELECT r.nombre AS ruta,
       COUNT(e.egresado_id) AS total_graduados,
       COUNT(icr.inscripcion_id) AS total_inscritos,
       (COUNT(e.egresado_id) / COUNT(icr.inscripcion_id) * 100) AS tasa_graduacion
FROM Rutas r
LEFT JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id
LEFT JOIN Egresados e ON icr.camper_id = e.camper_id AND icr.ruta_id = e.ruta_id
GROUP BY r.ruta_id, r.nombre
ORDER BY tasa_graduacion DESC
LIMIT 1;



SELECT m.nombre AS modulo, 
       COUNT(DISTINCT CASE WHEN c.nivel_riesgo = 'Medio' THEN e.camper_id END) AS campers_riesgo_medio,
       COUNT(DISTINCT CASE WHEN c.nivel_riesgo = 'Alto' THEN e.camper_id END) AS campers_riesgo_alto
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
JOIN Campers c ON e.camper_id = c.camper_id
WHERE c.nivel_riesgo IN ('Medio', 'Alto')
GROUP BY m.modulo_id, m.nombre
ORDER BY campers_riesgo_alto DESC, campers_riesgo_medio DESC;



SELECT ae.nombre AS area, 
       ae.capacidad_maxima,
       COUNT(aca.camper_id) AS ocupacion_actual,
       ae.capacidad_maxima - COUNT(aca.camper_id) AS disponibilidad
FROM AreasEntrenamiento ae
LEFT JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id AND aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima
ORDER BY disponibilidad;

SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as nombre_completo,
    r.nombre as ruta
FROM Campers c
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
WHERE icr.estado = 'En curso';


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as nombre_completo,
    m.nombre as modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_quizzes,
    e.nota_final
FROM Campers c
JOIN Evaluaciones e ON c.camper_id = e.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
ORDER BY c.nombres, m.nombre;


SELECT 
    r.nombre as ruta,
    m.nombre as modulo,
    rm.orden
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
JOIN Modulos m ON rm.modulo_id = m.modulo_id
ORDER BY r.nombre, rm.orden;


SELECT 
    r.nombre as ruta,
    CONCAT(t.nombres, ' ', t.apellidos) as trainer,
    ae.nombre as area
FROM Rutas r
JOIN AsignacionesTrainerRuta atr ON r.ruta_id = atr.ruta_id
JOIN Trainers t ON atr.trainer_id = t.trainer_id
JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id
JOIN AreasEntrenamiento ae ON tah.area_id = ae.area_id
WHERE atr.activo = TRUE
ORDER BY r.nombre, t.nombres;

SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    r.nombre as ruta,
    CONCAT(t.nombres, ' ', t.apellidos) as trainer
FROM Campers c
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
JOIN AsignacionesTrainerRuta atr ON r.ruta_id = atr.ruta_id
JOIN Trainers t ON atr.trainer_id = t.trainer_id
WHERE icr.estado = 'En curso' AND atr.activo = TRUE;



SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    m.nombre as modulo,
    r.nombre as ruta,
    e.nota_final,
    e.fecha_evaluacion
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
ORDER BY c.nombres, m.nombre;



SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) as trainer,
    ae.nombre as area,
    h.hora_inicio,
    h.hora_fin,
    ds.nombre as dia
FROM Trainers t
JOIN TrainerAreaHorario tah ON t.trainer_id = tah.trainer_id
JOIN AreasEntrenamiento ae ON tah.area_id = ae.area_id
JOIN Horarios h ON tah.horario_id = h.horario_id
JOIN DiasSemanales ds ON tah.dia_id = ds.dia_id
ORDER BY t.nombres, ds.nombre, h.hora_inicio;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    c.estado,
    c.nivel_riesgo
FROM Campers c
ORDER BY c.estado, c.nivel_riesgo;


SELECT 
    r.nombre as ruta,
    m.nombre as modulo,
    m.porcentaje_teorico,
    m.porcentaje_practico,
    m.porcentaje_quizzes
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
JOIN Modulos m ON rm.modulo_id = m.modulo_id
ORDER BY r.nombre, rm.orden;


SELECT 
    ae.nombre as area,
    CONCAT(c.nombres, ' ', c.apellidos) as camper
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
JOIN Campers c ON aca.camper_id = c.camper_id
WHERE aca.fecha_fin IS NULL
ORDER BY ae.nombre, c.nombres;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    r.nombre as ruta
FROM Campers c
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
WHERE NOT EXISTS (
    SELECT 1
    FROM RutaModulos rm
    WHERE rm.ruta_id = icr.ruta_id
    AND NOT EXISTS (
        SELECT 1
        FROM Evaluaciones e
        WHERE e.camper_id = c.camper_id
        AND e.modulo_id = rm.modulo_id
        AND e.nota_final >= 60
    )
);

SELECT 
    r.nombre as ruta,
    COUNT(icr.camper_id) as total_campers
FROM Rutas r
JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id
WHERE icr.estado = 'En curso'
GROUP BY r.ruta_id, r.nombre
HAVING COUNT(icr.camper_id) > 10;


SELECT 
    ae.nombre,
    ae.capacidad_maxima,
    COUNT(aca.camper_id) as ocupacion_actual,
    (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) as porcentaje_ocupacion
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima
HAVING (COUNT(aca.camper_id) / ae.capacidad_maxima * 100) > 80;


SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) as trainer,
    COUNT(DISTINCT atr.ruta_id) as total_rutas
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
HAVING COUNT(DISTINCT atr.ruta_id) > 1;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    m.nombre as modulo,
    e.nota_teorica,
    e.nota_practica
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
WHERE e.nota_practica > e.nota_teorica;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    m.nombre as modulo,
    e.nota_teorica,
    e.nota_practica
FROM Evaluaciones e
JOIN Campers c ON e.camper_id = c.camper_id
JOIN Modulos m ON e.modulo_id = m.modulo_id
WHERE e.nota_practica > e.nota_teorica;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    r.nombre as ruta
FROM Campers c
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
JOIN SGBD s ON r.sgbd_principal = s.sgbd_id
WHERE s.nombre = 'MySQL' AND icr.estado = 'En curso';


SELECT 
    m.nombre as modulo,
    COUNT(e.evaluacion_id) as total_evaluaciones,
    COUNT(CASE WHEN e.aprobado = FALSE THEN 1 END) as reprobados,
    (COUNT(CASE WHEN e.aprobado = FALSE THEN 1 END) / COUNT(e.evaluacion_id) * 100) as porcentaje_reprobados
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
HAVING porcentaje_reprobados >= 30
ORDER BY porcentaje_reprobados DESC;


SELECT 
    r.nombre as ruta,
    COUNT(rm.modulo_id) as total_modulos
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
GROUP BY r.ruta_id, r.nombre
HAVING COUNT(rm.modulo_id) > 3;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    r.nombre as ruta,
    icr.fecha_inscripcion
FROM InscripcionesCamperRuta icr
JOIN Campers c ON icr.camper_id = c.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
WHERE icr.fecha_inscripcion >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
ORDER BY icr.fecha_inscripcion DESC;


SELECT DISTINCT
    CONCAT(t.nombres, ' ', t.apellidos) as trainer,
    r.nombre as ruta
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
JOIN Rutas r ON atr.ruta_id = r.ruta_id
JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id
JOIN Campers c ON icr.camper_id = c.camper_id
WHERE c.nivel_riesgo = 'Alto' AND icr.estado = 'En curso'
ORDER BY t.nombres, r.nombre;


SELECT 
    m.nombre as modulo,
    COUNT(e.evaluacion_id) as total_evaluaciones,
    ROUND(AVG(e.nota_final), 2) as promedio_nota_final
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY promedio_nota_final DESC;


SELECT 
    r.nombre as ruta,
    COUNT(icr.camper_id) as total_campers,
    COUNT(CASE WHEN icr.estado = 'En curso' THEN 1 END) as campers_activos,
    COUNT(CASE WHEN icr.estado = 'Finalizada' THEN 1 END) as campers_graduados
FROM Rutas r
JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id
GROUP BY r.ruta_id, r.nombre
ORDER BY total_campers DESC;


SELECT 
    CONCAT(t.nombres, ' ', t.apellidos) as trainer,
    COUNT(e.evaluacion_id) as total_evaluaciones,
    COUNT(DISTINCT e.modulo_id) as modulos_evaluados
FROM Trainers t
JOIN AsignacionesTrainerRuta atr ON t.trainer_id = atr.trainer_id
JOIN InscripcionesCamperRuta icr ON atr.ruta_id = icr.ruta_id
JOIN Evaluaciones e ON icr.camper_id = e.camper_id
WHERE atr.activo = TRUE
GROUP BY t.trainer_id, t.nombres, t.apellidos
ORDER BY total_evaluaciones DESC;


SELECT 
    ae.nombre as area,
    COUNT(DISTINCT e.camper_id) as total_campers,
    ROUND(AVG(e.nota_final), 2) as promedio_rendimiento
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
JOIN Evaluaciones e ON aca.camper_id = e.camper_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre
ORDER BY promedio_rendimiento DESC;


SELECT 
    r.nombre as ruta,
    COUNT(rm.modulo_id) as total_modulos,
    GROUP_CONCAT(m.nombre ORDER BY rm.orden) as modulos
FROM Rutas r
JOIN RutaModulos rm ON r.ruta_id = rm.ruta_id
JOIN Modulos m ON rm.modulo_id = m.modulo_id
GROUP BY r.ruta_id, r.nombre
ORDER BY total_modulos DESC;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    r.nombre as ruta,
    ROUND(AVG(e.nota_final), 2) as promedio_nota_final
FROM Campers c
JOIN InscripcionesCamperRuta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
JOIN Evaluaciones e ON c.camper_id = e.camper_id
WHERE c.estado = 'Cursando'
GROUP BY c.camper_id, c.nombres, c.apellidos, r.nombre
ORDER BY promedio_nota_final DESC;


SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) as camper,
    r.nombre as ruta,
    ROUND(AVG(e.nota_final), 2) as promedio_nota_final
FROM Campers c
JOIN InscripcionesCamperruta icr ON c.camper_id = icr.camper_id
JOIN Rutas r ON icr.ruta_id = r.ruta_id
JOIN Evaluaciones e ON c.camper_id = e.camper_id
WHERE c.estado = 'Cursando'
GROUP BY c.camper_id, c.nombres, c.apellidos, r.nombre
ORDER BY promedio_nota_final DESC;



SELECT 
    m.nombre as modulo,
    COUNT(DISTINCT e.camper_id) as total_campers_evaluados,
    COUNT(e.evaluacion_id) as total_evaluaciones
FROM Modulos m
JOIN Evaluaciones e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY total_campers_evaluados DESC;


SELECT 
    ae.nombre as area,
    ae.capacidad_maxima,
    COUNT(aca.camper_id) as ocupacion_actual,
    ROUND((COUNT(aca.camper_id) / ae.capacidad_maxima * 100), 2) as porcentaje_ocupacion
FROM AreasEntrenamiento ae
JOIN AsignacionCamperArea aca ON ae.area_id = aca.area_id
WHERE aca.fecha_fin IS NULL
GROUP BY ae.area_id, ae.nombre, ae.capacidad_maxima
ORDER BY porcentaje_ocupacion DESC;


SELECT 
    ae.nombre as area,
    COUNT(DISTINCT t.trainer_id) as total_trainers,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombres, ' ', t.apellidos)) as trainers
FROM AreasEntrenamiento ae
JOIN TrainerAreaHorario tah ON ae.area_id = tah.area_id
JOIN Trainers t ON tah.trainer_id = t.trainer_id
GROUP BY ae.area_id, ae.nombre
ORDER BY total_trainers DESC;


SELECT 
    r.nombre as ruta,
    COUNT(c.camper_id) as total_campers,
    COUNT(CASE WHEN c.nivel_riesgo = 'Alto' THEN 1 END) as campers_alto_riesgo,
    ROUND((COUNT(CASE WHEN c.nivel_riesgo = 'Alto' THEN 1 END) / COUNT(c.camper_id) * 100), 2) as porcentaje_alto_riesgo
FROM Rutas r
JOIN InscripcionesCamperRuta icr ON r.ruta_id = icr.ruta_id
JOIN Campers c ON icr.camper_id = c.camper_id
WHERE icr.estado = 'En curso'
GROUP BY r.ruta_id, r.nombre
HAVING COUNT(CASE WHEN c.nivel_riesgo = 'Alto' THEN 1 END) > 0
ORDER BY campers_alto_riesgo DESC;