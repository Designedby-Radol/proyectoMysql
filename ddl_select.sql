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
