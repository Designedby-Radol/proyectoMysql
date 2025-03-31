-- ================================
-- INSERTAR RUTAS DE ENTRENAMIENTO
-- ================================
INSERT INTO RutasEntrenamiento (nombre, sgdb_principal, sgdb_alternativo) VALUES
('Full Stack JavaScript', 'MongoDB', 'PostgreSQL'),
('Backend con Java', 'MySQL', 'PostgreSQL'),
('Data Science con Python', 'PostgreSQL', 'MongoDB');

-- ================================
-- INSERTAR MÓDULOS
-- ================================
INSERT INTO Modulos (nombre) VALUES
('JavaScript'),
('Node.js'),
('React'),
('Java'),
('Spring Boot'),
('SQL'),
('Python'),
('Machine Learning'),
('Data Analysis');

-- ================================
-- ASOCIAR MÓDULOS A RUTAS
-- ================================
INSERT INTO RutasModulos (ruta_id, modulo_id) VALUES
(1, 1), (1, 2), (1, 3),  -- Full Stack JS
(2, 4), (2, 5), (2, 6),  -- Backend Java
(3, 7), (3, 8), (3, 9);  -- Data Science

-- ================================
-- INSERTAR GRUPOS
-- ================================
INSERT INTO Grupos (nombre) VALUES ('J1'), ('M1'), ('S1');  -- Jholver, Miguel, Santiago

-- ================================
-- INSERTAR CAMPERS
-- ================================
INSERT INTO Campers (nombres, apellidos, direccion, acudiente, telefono, nivel_riesgo) VALUES
('Juan', 'Pérez', 'Calle 123', 'Ana Pérez', '3111234567', 'Bajo'),
('Maria', 'Gómez', 'Av. Siempre Viva', 'Carlos Gómez', '3122345678', 'Medio'),
('Luis', 'Fernández', 'Cra 45', 'Laura Fernández', '3203456789', 'Alto'),
('Ana', 'Ramírez', 'Calle 8', 'Pedro Ramírez', '3154567890', 'Bajo'),
('Carlos', 'Torres', 'Calle 10', 'José Torres', '3225678901', 'Medio'),
('Laura', 'López', 'Cra 50', 'Marta López', '3146789012', 'Alto'),
('David', 'Martínez', 'Calle 22', 'Lucía Martínez', '3107890123', 'Bajo'),
('Isabel', 'Rodríguez', 'Av. 33', 'Sofía Rodríguez', '3138901234', 'Medio');

-- ================================
-- INSERTAR TRAINERS
-- ================================
INSERT INTO Trainers (nombre, apellido) VALUES
('Jholver', 'García'),
('Miguel', 'Pineda'),
('Santiago', 'Ortiz');

-- ================================
-- ASIGNAR CAMPERS A GRUPOS
-- ================================
INSERT INTO CampersGrupos (camper_id, grupo_id) VALUES
(1, 1), (1, 2), 
(2, 1), (3, 2), (4, 3), 
(5, 1), (6, 2), (7, 3), (8, 1);  

-- ================================
-- ASIGNAR TRAINERS A GRUPOS
-- ================================
INSERT INTO TrainersGrupos (trainer_id, grupo_id) VALUES
(1, 1),  -- Jholver en J1
(2, 2),  -- Miguel en M1
(3, 3);  -- Santiago en S1

-- ================================
-- INSERTAR ESTADOS
-- ================================
INSERT INTO Estados (nombre) VALUES 
('En proceso de ingreso'),
('Inscrito'),
('Aprobado'),
('Cursando'),
('Graduado'),
('Expulsado'),
('Retirado');

-- ================================
-- ASIGNAR ESTADOS A CAMPERS
-- ================================
INSERT INTO CampersEstados (camper_id, estado_id) VALUES
(1, 3), (1, 4),  -- Juan está aprobado y cursando
(2, 2), (2, 3),  -- María está inscrita y aprobada
(3, 4), (4, 5);  -- Luis cursando, Ana graduada

-- ================================
-- INSERTAR ÁREAS DE ENTRENAMIENTO
-- ================================
INSERT INTO AreasEntrenamiento (nombre, capacidad_maxima) VALUES
('Laboratorio 1', 30),
('Laboratorio 2', 25),
('Aula de conferencias', 50);

-- ================================
-- INSERTAR HORARIOS
-- ================================
INSERT INTO Horario (trainers_grupos_id, area_id, hora_inicio, hora_fin) VALUES
(1, 1, '06:00:00', '09:00:00'),  -- Jholver en Lab 1
(2, 2, '10:00:00', '13:00:00'),  -- Miguel en Lab 2
(3, 3, '14:00:00', '17:00:00');  -- Santiago en Aula de conferencias

-- ================================
-- INSERTAR EVALUACIONES
-- ================================
INSERT INTO Evaluaciones (camper_id, modulo_id, teorica, practica, quizzes) VALUES
(1, 1, 85, 90, 80),
(1, 2, 88, 92, 84),
(1, 3, 75, 80, 78),
(1, 4, 90, 94, 88),
(1, 5, 76, 85, 80),

(2, 1, 70, 78, 75),
(2, 2, 60, 65, 70),
(2, 3, 80, 85, 88),
(2, 6, 75, 79, 80),
(2, 7, 95, 98, 92),

(3, 4, 85, 90, 87),
(3, 5, 90, 92, 88),
(3, 6, 65, 70, 72),
(3, 7, 75, 80, 78),
(3, 8, 92, 96, 91),

(4, 1, 55, 60, 58),
(4, 2, 68, 72, 70),
(4, 3, 77, 80, 75),
(4, 5, 80, 85, 82),
(4, 9, 93, 97, 90),

(5, 1, 88, 92, 89),
(5, 2, 95, 97, 93),
(5, 4, 85, 89, 86),
(5, 6, 78, 80, 76),
(5, 9, 92, 95, 90),

(6, 3, 79, 82, 80),
(6, 4, 88, 91, 85),
(6, 5, 90, 94, 92),
(6, 7, 85, 87, 84),
(6, 8, 93, 97, 95),

(7, 2, 74, 78, 76),
(7, 3, 69, 70, 68),
(7, 5, 81, 85, 83),
(7, 6, 92, 96, 94),
(7, 9, 79, 82, 80),

(8, 1, 95, 98, 96),
(8, 2, 88, 92, 90),
(8, 3, 85, 88, 86),
(8, 4, 80, 85, 82),
(8, 5, 75, 78, 76);
