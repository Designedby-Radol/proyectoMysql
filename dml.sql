use campuslandsdb;
INSERT INTO DiasSemanales (nombre) VALUES 
('Lunes'), ('Martes'), ('Miércoles'), ('Jueves'), ('Viernes'), ('Sábado'), ('Domingo');


INSERT INTO Horarios (hora_inicio, hora_fin) VALUES 
('06:00:00', '10:00:00'),
('10:00:00', '14:00:00'),
('14:00:00', '18:00:00'),
('18:00:00', '22:00:00');

INSERT INTO SGBD (nombre, descripcion) VALUES 
('MySQL', 'Sistema de gestión de bases de datos relacional'),
('MongoDB', 'Base de datos NoSQL orientada a documentos'),
('PostgreSQL', 'Sistema de gestión de bases de datos relacional de código abierto');

INSERT INTO CategoriasModulos (nombre, descripcion) VALUES 
('Fundamentos de programación', 'Conocimientos básicos de algoritmia y programación'),
('Programación Web', 'Desarrollo de interfaces web con HTML, CSS y Bootstrap'),
('Programación formal', 'Lenguajes de programación estructurados como Java, JavaScript y C#'),
('Bases de datos', 'Gestión y administración de bases de datos relacionales y NoSQL'),
('Backend', 'Desarrollo de servidores y APIs con diferentes tecnologías');


INSERT INTO Modulos (nombre, descripcion) VALUES 
('Introducción a la algoritmia', 'Fundamentos básicos de lógica de programación'),
('PSeInt', 'Pseudocódigo e introducción a la programación'),
('Python', 'Programación básica con Python'),
('HTML', 'Lenguaje de marcado para páginas web'),
('CSS', 'Hojas de estilo en cascada'),
('Bootstrap', 'Framework para diseño web responsive'),
('Java', 'Programación orientada a objetos con Java'),
('JavaScript', 'Programación del lado del cliente'),
('C#', 'Desarrollo con .NET Framework'),
('MySQL Básico', 'Fundamentos de MySQL'),
('MongoDB Básico', 'Introducción a MongoDB'),
('PostgreSQL Básico', 'Fundamentos de PostgreSQL'),
('NetCore', 'Desarrollo backend con .NET Core'),
('Spring Boot', 'Framework para desarrollo Java'),
('NodeJS', 'Entorno de ejecución para JavaScript'),
('Express', 'Framework web para NodeJS');


INSERT INTO ModuloCategoria (modulo_id, categoria_id) VALUES 
(1, 1), (2, 1), (3, 1),  -- Fundamentos de programación
(4, 2), (5, 2), (6, 2),  -- Programación Web
(7, 3), (8, 3), (9, 3),  -- Programación formal
(10, 4), (11, 4), (12, 4),  -- Bases de datos
(13, 5), (14, 5), (15, 5), (16, 5);  -- Backend

-- Inserciones para la tabla de Rutas de Entrenamiento
INSERT INTO Rutas (nombre, descripcion, sgbd_principal, sgbd_alternativo) VALUES
('Desarrollo Web FullStack', 'Ruta de formación completa para desarrollo web frontend y backend', 1, 3),
('Desarrollo Java', 'Especialización en desarrollo de aplicaciones con Java y Spring Boot', 3, 1),
('Desarrollo .NET', 'Especialización en desarrollo de aplicaciones con C# y .NET Core', 1, 3),
('Desarrollo MEAN Stack', 'Desarrollo con MongoDB, Express, Angular y NodeJS', 2, 1);


-- Inserciones para la tabla de relación entre Rutas y Módulos
INSERT INTO RutaModulos (ruta_id, modulo_id, orden) VALUES 
-- Ruta 1: Desarrollo Web FullStack
(1, 1, 1), -- Introducción a la algoritmia
(1, 4, 2), -- HTML
(1, 5, 3), -- CSS
(1, 6, 4), -- Bootstrap
(1, 8, 5), -- JavaScript
(1, 10, 6), -- MySQL Básico
(1, 15, 7), -- NodeJS
(1, 16, 8), -- Express

-- Ruta 2: Desarrollo Java
(2, 1, 1), -- Introducción a la algoritmia
(2, 7, 2), -- Java
(2, 4, 3), -- HTML
(2, 5, 4), -- CSS
(2, 12, 5), -- PostgreSQL Básico
(2, 14, 6), -- Spring Boot

-- Ruta 3: Desarrollo .NET
(3, 1, 1), -- Introducción a la algoritmia
(3, 9, 2), -- C#
(3, 4, 3), -- HTML
(3, 5, 4), -- CSS
(3, 10, 5), -- MySQL Básico
(3, 13, 6), -- NetCore

-- Ruta 4: Desarrollo MEAN Stack
(4, 1, 1), -- Introducción a la algoritmia
(4, 4, 2), -- HTML
(4, 5, 3), -- CSS
(4, 8, 4), -- JavaScript
(4, 11, 5), -- MongoDB Básico
(4, 15, 6), -- NodeJS
(4, 16, 7); -- Express

-- Inserciones para la tabla de Áreas de Entrenamiento
INSERT INTO AreasEntrenamiento (nombre, capacidad_maxima, estado) VALUES 
('Artemis', 33, 'Activa'),
('Apolo', 30, 'Activa'),
('Sputnik', 32, 'Activa'),
('Skylab', 28, 'Activa'),
('Hunters', 25, 'Activa');

-- Inserciones para la tabla de Disponibilidad de Áreas
-- Asumimos que todas las áreas están disponibles en todos los horarios de lunes a viernes
INSERT INTO DisponibilidadAreas (area_id, horario_id, dia_id, disponible) 
SELECT a.area_id, h.horario_id, d.dia_id, TRUE
FROM AreasEntrenamiento a
CROSS JOIN Horarios h
CROSS JOIN DiasSemanales d
WHERE d.dia_id <= 5; -- Solo dias laborales (lunes a viernes)

INSERT INTO Trainers (numero_identificacion, nombres, apellidos, email, telefono, fecha_contratacion, estado) VALUES 
('1098765432', 'Miguel', 'López Fernández', 'miguel.lopez@campuslands.com', '3001234567', '2022-01-15', 'Activo'),
('1087654321', 'Ana María', 'García Torres', 'ana.garcia@campuslands.com', '3109876543', '2022-02-20', 'Activo'),
('1076543210', 'Carlos', 'Rodríguez Pérez', 'carlos.rodriguez@campuslands.com', '3208765432', '2022-03-10', 'Activo'),
('1065432109', 'Laura', 'Martínez Sánchez', 'laura.martinez@campuslands.com', '3157654321', '2022-04-05', 'Activo'),
('1054321098', 'Javier', 'Morales Jiménez', 'javier.morales@campuslands.com', '3043210987', '2022-05-12', 'Activo');


INSERT INTO EspecialidadesTrainers (trainer_id, modulo_id, nivel) VALUES 
-- Miguel López - especializado en programación fundamental y Java
(1, 1, 'Experto'), -- Introducción a la algoritmia
(1, 2, 'Experto'), -- PSeInt
(1, 7, 'Experto'), -- Java
(1, 14, 'Avanzado'), -- Spring Boot

-- Ana María García - especializada en desarrollo web
(2, 4, 'Experto'), -- HTML
(2, 5, 'Experto'), -- CSS
(2, 6, 'Avanzado'), -- Bootstrap
(2, 8, 'Experto'), -- JavaScript

-- Carlos Rodríguez - especializado en bases de datos y backend
(3, 10, 'Experto'), -- MySQL Básico
(3, 11, 'Avanzado'), -- MongoDB Básico
(3, 12, 'Experto'), -- PostgreSQL Básico
(3, 15, 'Intermedio'), -- NodeJS

-- Laura Martínez - especializada en .NET y C#
(4, 9, 'Experto'), -- C#
(4, 13, 'Experto'), -- NetCore
(4, 10, 'Avanzado'), -- MySQL Básico

-- Javier Morales - especializado en JavaScript y backend
(5, 8, 'Experto'), -- JavaScript
(5, 15, 'Experto'), -- NodeJS
(5, 16, 'Experto'), -- Express
(5, 11, 'Avanzado'); -- MongoDB Básico


INSERT INTO AsignacionesTrainerRuta (trainer_id, ruta_id, fecha_inicio, fecha_fin, activo) VALUES 
(1, 2, '2023-01-10', NULL, TRUE), -- Miguel López - Desarrollo Java
(2, 1, '2023-01-10', NULL, TRUE), -- Ana María García - Desarrollo Web FullStack
(3, 1, '2023-01-10', NULL, TRUE), -- Carlos Rodríguez - Desarrollo Web FullStack (parte de BBDD)
(4, 3, '2023-01-10', NULL, TRUE), -- Laura Martínez - Desarrollo .NET
(5, 4, '2023-01-10', NULL, TRUE); -- Javier Morales - Desarrollo MEAN Stack


INSERT INTO TrainerAreaHorario (trainer_id, area_id, horario_id, dia_id, fecha_inicio, fecha_fin) VALUES 
-- Miguel López en Artemis por las mañanas
(1, 1, 1, 1, '2023-01-10', NULL), -- Lunes mañana
(1, 1, 1, 2, '2023-01-10', NULL), -- Martes mañana
(1, 1, 1, 3, '2023-01-10', NULL), -- Miércoles mañana

-- Ana María García en Apolo por las tardes
(2, 2, 3, 1, '2023-01-10', NULL), -- Lunes tarde
(2, 2, 3, 2, '2023-01-10', NULL), -- Martes tarde
(2, 2, 3, 3, '2023-01-10', NULL), -- Miércoles tarde

-- Carlos Rodríguez en Sputnik a medio día
(3, 3, 2, 3, '2023-01-10', NULL), -- Miércoles medio día
(3, 3, 2, 4, '2023-01-10', NULL), -- Jueves medio día
(3, 3, 2, 5, '2023-01-10', NULL), -- Viernes medio día

-- Laura Martínez en Skylab por las mañanas
(4, 4, 1, 3, '2023-01-10', NULL), -- Miércoles mañana
(4, 4, 1, 4, '2023-01-10', NULL), -- Jueves mañana
(4, 4, 1, 5, '2023-01-10', NULL), -- Viernes mañana

-- Miguel López en Artemis por las tardes
(5, 5, 3, 3, '2023-01-10', NULL), -- Miércoles tarde
(5, 5, 3, 4, '2023-01-10', NULL), -- Jueves tarde
(5, 5, 3, 5, '2023-01-10', NULL); -- Viernes tarde


INSERT INTO Campers (numero_identificacion, nombres, apellidos, direccion, acudiente, estado, nivel_riesgo, fecha_registro) VALUES 
('1001234567', 'Juan Pablo', 'Ramírez Gómez', 'Calle 123 #45-67, Bucaramanga', 'María Gómez', 'Cursando', 'Bajo', '2023-01-15'),
('1002345678', 'María José', 'Torres Silva', 'Carrera 78 #90-12, Bucaramanga', 'Pedro Torres', 'Cursando', 'Bajo', '2023-01-20'),
('1003456789', 'Andrés Felipe', 'Castro Díaz', 'Avenida 34 #56-78, Floridablanca', 'Ana Díaz', 'Aprobado', 'Bajo', '2023-02-05'),
('1004567890', 'Valentina', 'Reyes Parra', 'Calle 45 #67-89, Girón', 'Luis Reyes', 'Inscrito', 'Medio', '2023-02-10'),
('1005678901', 'Sebastián', 'Moreno Vargas', 'Carrera 12 #34-56, Piedecuesta', 'Clara Vargas', 'En proceso de ingreso', 'Bajo', '2023-02-15'),
('1006789012', 'Camila Andrea', 'Pinzón López', 'Avenida 67 #89-01, Bucaramanga', 'Ricardo Pinzón', 'Cursando', 'Bajo', '2023-03-01'),
('1007890123', 'David Santiago', 'Mendoza Ríos', 'Calle 23 #45-67, Floridablanca', 'Patricia Ríos', 'Cursando', 'Medio', '2023-03-05'),
('1008901234', 'Sofia Isabella', 'Jiménez Ortiz', 'Carrera 56 #78-90, Bucaramanga', 'Manuel Jiménez', 'Graduado', 'Bajo', '2023-03-10'),
('1009012345', 'Daniel Alejandro', 'Rojas Herrera', 'Avenida 89 #01-23, Girón', 'Laura Herrera', 'Retirado', 'Alto', '2023-03-15'),
('1000123456', 'Isabella', 'Santos Medina', 'Calle 34 #56-78, Piedecuesta', 'Jorge Santos', 'Expulsado', 'Alto', '2023-03-20'),
('1010234567', 'Santiago', 'Duarte Álvarez', 'Carrera 45 #12-34, Bucaramanga', 'Carmen Álvarez', 'Cursando', 'Bajo', '2023-04-05'),
('1011345678', 'Gabriela', 'Pérez Ortiz', 'Calle 67 #89-10, Floridablanca', 'Roberto Pérez', 'Cursando', 'Bajo', '2023-04-05'),
('1012456789', 'Samuel', 'Quintero Rueda', 'Avenida 12 #34-56, Piedecuesta', 'Patricia Rueda', 'Cursando', 'Medio', '2023-04-10'),
('1013567890', 'Luciana', 'Zúñiga Suárez', 'Carrera 78 #90-12, Girón', 'Federico Zúñiga', 'Cursando', 'Bajo', '2023-04-10'),
('1014678901', 'Nicolás', 'Acosta Rangel', 'Calle 23 #45-67, Bucaramanga', 'Diana Rangel', 'Aprobado', 'Bajo', '2023-04-15'),
('1015789012', 'Valeria', 'Bautista Cruz', 'Avenida 56 #78-90, Floridablanca', 'Mauricio Bautista', 'Aprobado', 'Bajo', '2023-04-15'),
('1016890123', 'Martín', 'Carvajal Durán', 'Carrera 89 #01-23, Bucaramanga', 'Sofía Durán', 'Inscrito', 'Medio', '2023-04-20'),
('1017901234', 'Mariana', 'Echeverri Flórez', 'Calle 12 #34-56, Piedecuesta', 'Jaime Echeverri', 'Inscrito', 'Bajo', '2023-04-20'),
('1018012345', 'Jerónimo', 'Galindo Herrera', 'Avenida 45 #67-89, Girón', 'Mónica Herrera', 'En proceso de ingreso', 'Bajo', '2023-04-25'),
('1019123456', 'Antonella', 'Ibáñez Jaimes', 'Carrera 12 #34-56, Bucaramanga', 'Ernesto Ibáñez', 'En proceso de ingreso', 'Bajo', '2023-04-25'),
('1020234567', 'Sebastián', 'Leal Mora', 'Calle 56 #78-90, Floridablanca', 'Liliana Mora', 'Cursando', 'Bajo', '2023-05-02'),
('1021345678', 'Isabella', 'Navarro Ochoa', 'Avenida 23 #45-67, Bucaramanga', 'Andrés Navarro', 'Cursando', 'Bajo', '2023-05-02'),
('1022456789', 'Maximiliano', 'Prada Quintero', 'Carrera 56 #78-90, Piedecuesta', 'Natalia Quintero', 'Cursando', 'Medio', '2023-05-05'),
('1023567890', 'Salomé', 'Rincón Silva', 'Calle 89 #01-23, Girón', 'Carlos Rincón', 'Cursando', 'Bajo', '2023-05-05'),
('1024678901', 'Emiliano', 'Toro Uribe', 'Avenida 12 #34-56, Bucaramanga', 'Laura Uribe', 'Cursando', 'Alto', '2023-05-10'),
('1025789012', 'Luciana', 'Vargas Wilches', 'Carrera 45 #67-89, Floridablanca', 'Fernando Vargas', 'Retirado', 'Bajo', '2023-05-10'),
('1026890123', 'Joaquín', 'Zamora Botero', 'Calle 78 #90-12, Bucaramanga', 'Claudia Botero', 'Expulsado', 'Alto', '2023-05-15'),
('1027901234', 'Victoria', 'Arenas Cadena', 'Avenida 56 #78-90, Piedecuesta', 'Camilo Arenas', 'Graduado', 'Bajo', '2023-05-15'),
('1028012345', 'Leonardo', 'Delgado Espinosa', 'Carrera 89 #01-23, Girón', 'Marcela Espinosa', 'Graduado', 'Bajo', '2023-05-20'),
('1029123456', 'Samantha', 'Franco Guzmán', 'Calle 12 #34-56, Bucaramanga', 'Ricardo Franco', 'Cursando', 'Medio', '2023-05-20');


INSERT INTO TelefonosCampers (camper_id, numero_telefono, tipo) VALUES 
(1, '3001234567', 'Celular'),
(1, '6078765432', 'Fijo'),
(2, '3109876543', 'Celular'),
(3, '3208765432', 'Celular'),
(3, '6077654321', 'Fijo'),
(4, '3157654321', 'Celular'),
(5, '3043210987', 'Celular'),
(6, '3112345678', 'Celular'),
(7, '3209876543', 'Celular'),
(8, '3158765432', 'Celular'),
(9, '3047654321', 'Celular'),
(10, '3113210987', 'Celular'),
(11, '3201234567', 'Celular'),
(12, '3102345678', 'Celular'),
(13, '3153456789', 'Celular'),
(13, '6074567890', 'Fijo'),
(14, '3045678901', 'Celular'),
(15, '3116789012', 'Celular'),
(16, '3207890123', 'Celular'),
(16, '6078901234', 'Fijo'),
(17, '3159012345', 'Celular'),
(18, '3040123456', 'Celular'),
(19, '3111234567', 'Celular'),
(20, '3202345678', 'Celular'),
(21, '3103456789', 'Celular'),
(21, '6074567890', 'Fijo'),
(22, '3154567890', 'Celular'),
(23, '3045678901', 'Celular'),
(24, '3116789012', 'Celular'),
(25, '3207890123', 'Celular'),
(25, '6078901234', 'Fijo'),
(26, '3159012345', 'Celular'),
(27, '3040123456', 'Celular'),
(28, '3111234567', 'Celular'),
(29, '3202345678', 'Celular'),
(30, '3103456789', 'Celular'),
(30, '6074567890', 'Fijo');

INSERT INTO InscripcionesCamperRuta (camper_id, ruta_id, fecha_inscripcion, fecha_inicio, fecha_fin, estado) VALUES 
(1, 1, '2023-01-20', '2023-02-01', NULL, 'En curso'), -- Juan Pablo - Desarrollo Web FullStack
(2, 2, '2023-01-25', '2023-02-01', NULL, 'En curso'), -- María José - Desarrollo Java
(3, 3, '2023-02-10', '2023-02-15', NULL, 'Pendiente'), -- Andrés Felipe - Desarrollo .NET
(4, 1, '2023-02-15', NULL, NULL, 'Pendiente'), -- Valentina - Desarrollo Web FullStack
(5, 4, '2023-02-20', NULL, NULL, 'Pendiente'), -- Sebastián - Desarrollo MEAN Stack
(6, 1, '2023-03-05', '2023-03-15', NULL, 'En curso'), -- Camila Andrea - Desarrollo Web FullStack
(7, 2, '2023-03-10', '2023-03-15', NULL, 'En curso'), -- David Santiago - Desarrollo Java
(8, 3, '2023-03-15', '2023-03-20', '2023-09-20', 'Finalizada'), -- Sofia Isabella - Desarrollo .NET (graduada)
(9, 4, '2023-03-20', '2023-04-01', '2023-05-10', 'Cancelada'), -- Daniel Alejandro - Desarrollo MEAN Stack (retirado)
(10, 2, '2023-03-25', '2023-04-01', '2023-05-15', 'Cancelada'), -- Isabella - Desarrollo Java (expulsada)
(11, 3, '2023-04-10', '2023-05-01', NULL, 'En curso'), -- Santiago - Desarrollo .NET
(12, 4, '2023-04-10', '2023-05-01', NULL, 'En curso'), -- Gabriela - Desarrollo MEAN Stack
(13, 1, '2023-04-15', '2023-05-01', NULL, 'En curso'), -- Samuel - Desarrollo Web FullStack
(14, 2, '2023-04-15', '2023-05-01', NULL, 'En curso'), -- Luciana - Desarrollo Java
(15, 3, '2023-04-20', '2023-05-15', NULL, 'Pendiente'), -- Nicolás - Desarrollo .NET
(16, 4, '2023-04-20', '2023-05-15', NULL, 'Pendiente'), -- Valeria - Desarrollo MEAN Stack
(17, 1, '2023-04-25', NULL, NULL, 'Pendiente'), -- Martín - Desarrollo Web FullStack
(18, 2, '2023-04-25', NULL, NULL, 'Pendiente'), -- Mariana - Desarrollo Java
(21, 3, '2023-05-05', '2023-05-15', NULL, 'En curso'), -- Sebastián - Desarrollo .NET
(22, 4, '2023-05-05', '2023-05-15', NULL, 'En curso'), -- Isabella - Desarrollo MEAN Stack
(23, 1, '2023-05-10', '2023-05-15', NULL, 'En curso'), -- Maximiliano - Desarrollo Web FullStack
(24, 2, '2023-05-10', '2023-05-15', NULL, 'En curso'), -- Salomé - Desarrollo Java
(25, 3, '2023-05-15', '2023-05-22', NULL, 'En curso'), -- Emiliano - Desarrollo .NET
(26, 4, '2023-05-15', '2023-05-22', '2023-06-10', 'Cancelada'), -- Luciana - Desarrollo MEAN Stack (retirada)
(27, 1, '2023-05-20', '2023-05-22', '2023-06-15', 'Cancelada'), -- Joaquín - Desarrollo Web FullStack (expulsado)
(28, 2, '2023-05-20', '2023-05-22', '2023-09-22', 'Finalizada'), -- Victoria - Desarrollo Java (graduada)
(29, 3, '2023-05-25', '2023-05-30', '2023-10-01', 'Finalizada'), -- Leonardo - Desarrollo .NET (graduado)
(30, 4, '2023-05-25', '2023-05-30', NULL, 'En curso'); -- Samantha - Desarrollo MEAN Stack

INSERT INTO AsignacionCamperArea (camper_id, area_id, fecha_inicio, fecha_fin) VALUES 
(1, 1, '2023-02-01', NULL), -- Juan Pablo en Artemis
(2, 2, '2023-02-01', NULL), -- María José en Apolo
(3, 3, '2023-02-15', NULL), -- Andrés Felipe en Sputnik
(6, 1, '2023-03-15', NULL), -- Camila Andrea en Artemis
(7, 2, '2023-03-15', NULL), -- David Santiago en Apolo
(8, 4, '2023-03-20', '2023-09-20'), -- Sofia Isabella en Skylab (completó)
(9, 5, '2023-04-01', '2023-05-10'), -- Daniel Alejandro en Laboratorio Digital (retirado)
(10, 2, '2023-04-01', '2023-05-15'),
(11, 4, '2023-05-01', NULL), -- Santiago en Skylab
(12, 5, '2023-05-01', NULL), -- Gabriela en Laboratorio Digital
(13, 1, '2023-05-01', NULL), -- Samuel en Artemis
(14, 2, '2023-05-01', NULL), -- Luciana en Apolo
(21, 4, '2023-05-15', NULL), -- Sebastián en Skylab
(22, 5, '2023-05-15', NULL), -- Isabella en Laboratorio Digital
(23, 1, '2023-05-15', NULL), -- Maximiliano en Artemis
(24, 2, '2023-05-15', NULL), -- Salomé en Apolo
(25, 3, '2023-05-22', NULL), -- Emiliano en Sputnik
(26, 5, '2023-05-22', '2023-06-10'), -- Luciana en Laboratorio Digital (retirada)
(27, 1, '2023-05-22', '2023-06-15'), -- Joaquín en Artemis (expulsado)
(28, 2, '2023-05-22', '2023-09-22'), -- Victoria en Apolo (graduada)
(29, 3, '2023-05-30', '2023-10-01'), -- Leonardo en Sputnik (graduado)
(30, 5, '2023-05-30', NULL); -- Isabella en Apolo (expulsada)

INSERT INTO Evaluaciones (camper_id, modulo_id, nota_teorica, nota_practica, nota_quizzes, fecha_evaluacion, comentarios) VALUES 
-- Juan Pablo (Desarrollo Web FullStack)
(1, 1, 85.5, 90.0, 88.0, '2023-03-01', 'Buen rendimiento en algoritmia'),
(1, 4, 90.0, 92.5, 95.0, '2023-03-15', 'Excelente manejo de HTML'),
(1, 5, 87.5, 89.0, 85.0, '2023-04-01', 'Buen trabajo con CSS'),

-- María José (Desarrollo Java)
(2, 1, 82.0, 85.5, 80.0, '2023-03-01', 'Comprensión adecuada de algoritmia'),
(2, 7, 78.5, 82.0, 75.0, '2023-03-15', 'Progresando bien en Java'),

-- Andrés Felipe (Aún no ha empezado)

-- Camila Andrea (Desarrollo Web FullStack)
(6, 1, 90.0, 88.5, 92.0, '2023-04-15', 'Excelente comprensión de conceptos algorítmicos'),

-- David Santiago (Desarrollo Java)
(7, 1, 75.5, 78.0, 72.0, '2023-04-15', 'Necesita reforzar algunos conceptos básicos'),

-- Sofia Isabella (Graduada de Desarrollo .NET)
(8, 1, 95.0, 98.0, 97.0, '2023-04-20', 'Desempeño excepcional en fundamentos'),
(8, 9, 92.5, 95.0, 90.0, '2023-05-15', 'Excelente manejo de C#'),
(8, 4, 88.0, 90.5, 85.0, '2023-06-10', 'Muy buen manejo de HTML'),
(8, 5, 87.5, 89.0, 82.0, '2023-07-05', 'Buen dominio de CSS'),
(8, 10, 90.0, 93.5, 88.0, '2023-08-01', 'Excelente conocimiento de MySQL'),
(8, 13, 94.5, 96.0, 91.0, '2023-09-01', 'Dominio sobresaliente de NetCore'),

-- Daniel Alejandro (Retirado)
(9, 1, 65.0, 68.0, 60.0, '2023-04-20', 'Dificultades con conceptos básicos'),
(9, 4, 55.0, 52.0, 50.0, '2023-05-05', 'Problemas significativos, necesita apoyo adicional'),

-- Isabella (Expulsada)
(10, 1, 45.0, 40.0, 35.0, '2023-04-20', 'Rendimiento muy bajo, no muestra interés'),

-- Gabriela (Desarrollo MEAN Stack)
(12, 1, 90.0, 92.5, 88.0, '2023-06-01', 'Excelente comprensión algorítmica'),
(12, 4, 92.0, 94.0, 90.0, '2023-06-15', 'Dominio sobresaliente de HTML'),

-- Samuel (Desarrollo Web FullStack)
(13, 1, 82.0, 85.0, 78.0, '2023-06-01', 'Buena base algorítmica, puede mejorar'),
(13, 4, 88.0, 90.0, 85.0, '2023-06-15', 'Buen manejo de HTML'),

-- Victoria (graduada de Desarrollo Java)
(28, 1, 94.0, 96.0, 92.0, '2023-06-01', 'Comprensión excepcional de algoritmia'),
(28, 7, 92.0, 94.0, 90.0, '2023-06-22', 'Excelente dominio de Java'),
(28, 4, 88.5, 90.0, 86.0, '2023-07-15', 'Muy buen trabajo con HTML'),
(28, 5, 89.0, 92.0, 87.0, '2023-08-01', 'Excelente manejo de CSS'),
(28, 12, 91.0, 93.0, 89.0, '2023-08-15', 'Dominio destacado de PostgreSQL'),
(28, 14, 93.5, 95.0, 91.0, '2023-09-10', 'Excelente comprensión de Spring Boot'),

-- Leonardo (graduado de Desarrollo .NET)
(29, 1, 96.0, 98.0, 95.0, '2023-06-01', 'Desempeño excepcional en fundamentos'),
(29, 9, 94.0, 96.0, 93.0, '2023-06-22', 'Dominio sobresaliente de C#'),
(29, 4, 90.0, 92.0, 89.0, '2023-07-15', 'Excelente trabajo con HTML'),
(29, 5, 91.0, 93.0, 90.0, '2023-08-01', 'Muy buen manejo de CSS'),
(29, 10, 93.0, 95.0, 92.0, '2023-08-15', 'Destacado conocimiento de MySQL'),
(29, 13, 95.0, 97.0, 94.0, '2023-09-20', 'Dominio excepcional de NetCore'),

-- Joaquín (expulsado)
(27, 1, 50.0, 45.0, 40.0, '2023-06-01', 'Rendimiento insuficiente'),
(27, 4, 45.0, 40.0, 38.0, '2023-06-15', 'No muestra mejoría ni interés'),

-- Luciana (retirada)
(26, 1, 70.0, 65.0, 68.0, '2023-06-01', 'Rendimiento aceptable pero con dificultades');


INSERT INTO Asistencia (camper_id, area_id, fecha, horario_id, presente, observaciones) VALUES 
-- Juan Pablo
(1, 1, '2023-02-01', 1, TRUE, NULL),
(1, 1, '2023-02-02', 1, TRUE, NULL),
(1, 1, '2023-02-03', 1, TRUE, NULL),
(1, 1, '2023-02-06', 1, FALSE, 'Enfermedad con excusa médica'),
(1, 1, '2023-02-07', 1, TRUE, NULL),

-- María José
(2, 2, '2023-02-01', 2, TRUE, NULL),
(2, 2, '2023-02-02', 2, TRUE, NULL),
(2, 2, '2023-02-03', 2, FALSE, 'Problemas de transporte'),
(2, 2, '2023-02-06', 2, TRUE, NULL),
(2, 2, '2023-02-07', 2, TRUE, NULL),

-- Sofia Isabella (graduada)
(8, 4, '2023-03-20', 1, TRUE, NULL),
(8, 4, '2023-03-21', 1, TRUE, NULL),
(8, 4, '2023-03-22', 1, TRUE, NULL),
(8, 4, '2023-03-23', 1, TRUE, NULL),
(8, 4, '2023-03-24', 1, TRUE, NULL),

-- Daniel Alejandro (retirado)
(9, 5, '2023-04-03', 3, FALSE, 'No asistió sin justificación'),
(9, 5, '2023-04-04', 3, FALSE, 'No asistió sin justificación'),
(9, 5, '2023-04-05', 3, TRUE, NULL),
(9, 5, '2023-04-06', 3, FALSE, 'No asistió sin justificación'),
(9, 5, '2023-04-07', 3, FALSE, 'No asistió sin justificación'),

-- Isabella (expulsada)
(10, 2, '2023-04-03', 2, FALSE, 'No asistió sin justificación'),
(10, 2, '2023-04-04', 2, FALSE, 'No asistió sin justificación'),
(10, 2, '2023-04-05', 2, FALSE, 'No asistió sin justificación'),

-- Santiago
(11, 4, '2023-05-01', 1, TRUE, NULL),
(11, 4, '2023-05-02', 1, TRUE, NULL),
(11, 4, '2023-05-03', 1, TRUE, NULL),
(11, 4, '2023-05-04', 1, TRUE, NULL),
(11, 4, '2023-05-05', 1, FALSE, 'Cita médica con excusa'),

-- Gabriela
(12, 5, '2023-05-01', 3, TRUE, NULL),
(12, 5, '2023-05-02', 3, TRUE, NULL),
(12, 5, '2023-05-03', 3, TRUE, NULL),
(12, 5, '2023-05-04', 3, FALSE, 'Problemas de transporte'),
(12, 5, '2023-05-05', 3, TRUE, NULL),

-- Victoria (graduada)
(28, 2, '2023-05-22', 2, TRUE, NULL),
(28, 2, '2023-05-23', 2, TRUE, NULL),
(28, 2, '2023-05-24', 2, TRUE, NULL),
(28, 2, '2023-05-25', 2, TRUE, NULL),
(28, 2, '2023-05-26', 2, TRUE, NULL),

-- Leonardo (graduado)
(29, 3, '2023-05-30', 2, TRUE, NULL),
(29, 3, '2023-05-31', 2, TRUE, NULL),
(29, 3, '2023-06-01', 2, TRUE, NULL),
(29, 3, '2023-06-02', 2, TRUE, NULL),

-- Joaquín (expulsado)
(27, 1, '2023-05-22', 1, FALSE, 'No asistió sin justificación'),
(27, 1, '2023-05-23', 1, FALSE, 'No asistió sin justificación'),
(27, 1, '2023-05-24', 1, TRUE, NULL),
(27, 1, '2023-05-25', 1, FALSE, 'No asistió sin justificación'),
(27, 1, '2023-05-26', 1, FALSE, 'No asistió sin justificación'),
(27, 1, '2023-05-29', 1, FALSE, 'No asistió sin justificación'),
(27, 1, '2023-05-30', 1, FALSE, 'No asistió sin justificación'),

-- Luciana (retirada)
(26, 5, '2023-05-22', 3, TRUE, NULL),
(26, 5, '2023-05-23', 3, TRUE, NULL),
(26, 5, '2023-05-24', 3, FALSE, 'Problemas personales'),
(26, 5, '2023-05-25', 3, FALSE, 'Problemas personales'),
(26, 5, '2023-05-26', 3, FALSE, 'Comunicó intención de retirarse'),
(26, 5, '2023-05-29', 3, FALSE, 'Proceso de retiro iniciado');


INSERT INTO HistorialEstadosCamper (camper_id, estado_anterior, estado_nuevo, fecha_cambio, motivo, usuario_cambio) VALUES 
-- Juan Pablo
(1, 'En proceso de ingreso', 'Inscrito', '2023-01-15', 'Proceso de admisión completado', 'admin'),
(1, 'Inscrito', 'Aprobado', '2023-01-25', 'Aprobado en prueba técnica y entrevista', 'admin'),
(1, 'Aprobado', 'Cursando', '2023-02-01', 'Inicio de formación', 'admin'),

-- María José
(2, 'En proceso de ingreso', 'Inscrito', '2023-01-20', 'Proceso de admisión completado', 'admin'),
(2, 'Inscrito', 'Aprobado', '2023-01-28', 'Aprobado en prueba técnica y entrevista', 'admin'),
(2, 'Aprobado', 'Cursando', '2023-02-01', 'Inicio de formación', 'admin'),

-- Andrés Felipe
(3, 'En proceso de ingreso', 'Inscrito', '2023-02-05', 'Proceso de admisión completado', 'admin'),
(3, 'Inscrito', 'Aprobado', '2023-02-12', 'Aprobado en prueba técnica y entrevista', 'admin'),

-- Valentina
(4, 'En proceso de ingreso', 'Inscrito', '2023-02-10', 'Proceso de admisión completado', 'admin'),

-- Sofia Isabella (graduada)
(8, 'En proceso de ingreso', 'Inscrito', '2023-03-10', 'Proceso de admisión completado', 'admin'),
(8, 'Inscrito', 'Aprobado', '2023-03-17', 'Aprobado en prueba técnica y entrevista', 'admin'),
(8, 'Aprobado', 'Cursando', '2023-03-20', 'Inicio de formación', 'admin'),
(8, 'Cursando', 'Graduado', '2023-09-20', 'Completó satisfactoriamente el programa', 'admin'),

-- Daniel Alejandro (retirado)
(9, 'En proceso de ingreso', 'Inscrito', '2023-03-15', 'Proceso de admisión completado', 'admin'),
(9, 'Inscrito', 'Aprobado', '2023-03-25', 'Aprobado en prueba técnica y entrevista', 'admin'),
(9, 'Aprobado', 'Cursando', '2023-04-01', 'Inicio de formación', 'admin'),
(9, 'Cursando', 'Retirado', '2023-05-10', 'Retiro voluntario por motivos personales', 'admin'),

-- Isabella (expulsada)
(10, 'En proceso de ingreso', 'Inscrito', '2023-03-20', 'Proceso de admisión completado', 'admin'),
(10, 'Inscrito', 'Aprobado', '2023-03-27', 'Aprobado en prueba técnica y entrevista', 'admin'),
(10, 'Aprobado', 'Cursando', '2023-04-01', 'Inicio de formación', 'admin'),
(10, 'Cursando', 'Expulsado', '2023-05-15', 'Bajo rendimiento académico y faltas de asistencia reiteradas', 'admin'),
-- Santiago
(11, 'En proceso de ingreso', 'Inscrito', '2023-04-05', 'Proceso de admisión completado', 'admin'),
(11, 'Inscrito', 'Aprobado', '2023-04-20', 'Aprobado en prueba técnica y entrevista', 'admin'),
(11, 'Aprobado', 'Cursando', '2023-05-01', 'Inicio de formación', 'admin'),

-- Gabriela
(12, 'En proceso de ingreso', 'Inscrito', '2023-04-05', 'Proceso de admisión completado', 'admin'),
(12, 'Inscrito', 'Aprobado', '2023-04-20', 'Aprobado en prueba técnica y entrevista', 'admin'),
(12, 'Aprobado', 'Cursando', '2023-05-01', 'Inicio de formación', 'admin'),

-- Victoria (graduada)
(28, 'En proceso de ingreso', 'Inscrito', '2023-05-15', 'Proceso de admisión completado', 'admin'),
(28, 'Inscrito', 'Aprobado', '2023-05-18', 'Aprobado en prueba técnica y entrevista', 'admin'),
(28, 'Aprobado', 'Cursando', '2023-05-22', 'Inicio de formación', 'admin'),
(28, 'Cursando', 'Graduado', '2023-09-22', 'Completó satisfactoriamente el programa', 'admin'),

-- Leonardo (graduado)
(29, 'En proceso de ingreso', 'Inscrito', '2023-05-20', 'Proceso de admisión completado', 'admin'),
(29, 'Inscrito', 'Aprobado', '2023-05-25', 'Aprobado en prueba técnica y entrevista', 'admin'),
(29, 'Aprobado', 'Cursando', '2023-05-30', 'Inicio de formación', 'admin'),
(29, 'Cursando', 'Graduado', '2023-10-01', 'Completó satisfactoriamente el programa', 'admin'),

-- Joaquín (expulsado)
(27, 'En proceso de ingreso', 'Inscrito', '2023-05-15', 'Proceso de admisión completado', 'admin'),
(27, 'Inscrito', 'Aprobado', '2023-05-18', 'Aprobado en prueba técnica y entrevista', 'admin'),
(27, 'Aprobado', 'Cursando', '2023-05-22', 'Inicio de formación', 'admin'),
(27, 'Cursando', 'Expulsado', '2023-06-15', 'Bajo rendimiento académico, inasistencias reiteradas y falta de interés', 'admin'),

-- Luciana (retirada)
(26, 'En proceso de ingreso', 'Inscrito', '2023-05-10', 'Proceso de admisión completado', 'admin'),
(26, 'Inscrito', 'Aprobado', '2023-05-18', 'Aprobado en prueba técnica y entrevista', 'admin'),
(26, 'Aprobado', 'Cursando', '2023-05-22', 'Inicio de formación', 'admin'),
(26, 'Cursando', 'Retirado', '2023-06-10', 'Retiro voluntario por problemas personales', 'admin');


INSERT INTO Egresados (camper_id, fecha_graduacion, ruta_id, promedio_final, observaciones) VALUES 
(8, '2023-09-20', 3, 91.5, 'Excelente desempeño durante todo el programa. Recomendado para prácticas empresariales.'),
(28, '2023-09-22', 2, 92.3, 'Desempeño sobresaliente en todas las áreas. Excelente actitud y colaboración con compañeros.'),
(29, '2023-10-01', 3, 94.6, 'Rendimiento excepcional. Destacó por sus proyectos innovadores y comprensión profunda de las tecnologías.');