-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS CampusLandsDB;
USE CampusLandsDB;

-- Tabla de Campers (Estudiantes)
CREATE TABLE Campers (
    camper_id INT AUTO_INCREMENT PRIMARY KEY,
    numero_identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    acudiente VARCHAR(100),
    estado ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado') NOT NULL DEFAULT 'En proceso de ingreso',
    nivel_riesgo ENUM('Bajo', 'Medio', 'Alto') DEFAULT 'Bajo',
    fecha_registro DATE NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Teléfonos de Contacto (relación 1:N con Campers)
CREATE TABLE TelefonosCampers (
    telefono_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL,
    numero_telefono VARCHAR(15) NOT NULL,
    tipo ENUM('Celular', 'Fijo', 'Trabajo', 'Otro') NOT NULL DEFAULT 'Celular',
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id) ON DELETE CASCADE
);

-- Tabla de SGBDs (Sistemas Gestores de Bases de Datos)
CREATE TABLE SGBD (
    sgbd_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de Módulos de Aprendizaje
CREATE TABLE Modulos (
    modulo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    porcentaje_teorico DECIMAL(5,2) DEFAULT 30.00,  -- 30%
    porcentaje_practico DECIMAL(5,2) DEFAULT 60.00,  -- 60%
    porcentaje_quizzes DECIMAL(5,2) DEFAULT 10.00   -- 10%
);

-- Tabla de Categorías de Módulos
CREATE TABLE CategoriasModulos (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Relación entre Módulos y Categorías
CREATE TABLE ModuloCategoria (
    modulo_id INT NOT NULL,
    categoria_id INT NOT NULL,
    PRIMARY KEY (modulo_id, categoria_id),
    FOREIGN KEY (modulo_id) REFERENCES Modulos(modulo_id),
    FOREIGN KEY (categoria_id) REFERENCES CategoriasModulos(categoria_id)
);

-- Tabla de Rutas de Entrenamiento
CREATE TABLE Rutas (
    ruta_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    sgbd_principal INT NOT NULL,
    sgbd_alternativo INT NOT NULL,
    FOREIGN KEY (sgbd_principal) REFERENCES SGBD(sgbd_id),
    FOREIGN KEY (sgbd_alternativo) REFERENCES SGBD(sgbd_id)
);

-- Tabla de relación entre Rutas y Módulos
CREATE TABLE RutaModulos (
    ruta_id INT NOT NULL,
    modulo_id INT NOT NULL,
    orden INT NOT NULL,
    PRIMARY KEY (ruta_id, modulo_id),
    FOREIGN KEY (ruta_id) REFERENCES Rutas(ruta_id),
    FOREIGN KEY (modulo_id) REFERENCES Modulos(modulo_id)
);

-- Tabla de Áreas de Entrenamiento
CREATE TABLE AreasEntrenamiento (
    area_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    capacidad_maxima INT NOT NULL DEFAULT 33,
    estado ENUM('Activa', 'Inactiva', 'En mantenimiento') NOT NULL DEFAULT 'Activa'
);

-- Tabla de Horarios
CREATE TABLE Horarios (
    horario_id INT AUTO_INCREMENT PRIMARY KEY,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    UNIQUE (hora_inicio, hora_fin)
);

-- Tabla de Días de la Semana
CREATE TABLE DiasSemanales (
    dia_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE
);

-- Tabla de Disponibilidad de Áreas (relación entre Áreas, Horarios y Días)
CREATE TABLE DisponibilidadAreas (
    disponibilidad_id INT AUTO_INCREMENT PRIMARY KEY,
    area_id INT NOT NULL,
    horario_id INT NOT NULL,
    dia_id INT NOT NULL,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (area_id, horario_id, dia_id),
    FOREIGN KEY (area_id) REFERENCES AreasEntrenamiento(area_id),
    FOREIGN KEY (horario_id) REFERENCES Horarios(horario_id),
    FOREIGN KEY (dia_id) REFERENCES DiasSemanales(dia_id)
);

-- Tabla de Trainers (Entrenadores)
CREATE TABLE Trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    numero_identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    fecha_contratacion DATE NOT NULL,
    estado ENUM('Activo', 'Inactivo', 'De baja') NOT NULL DEFAULT 'Activo'
);

-- Tabla de Especialidades de Trainers
CREATE TABLE EspecialidadesTrainers (
    especialidad_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_id INT NOT NULL,
    modulo_id INT NOT NULL,
    nivel ENUM('Básico', 'Intermedio', 'Avanzado', 'Experto') NOT NULL DEFAULT 'Intermedio',
    UNIQUE (trainer_id, modulo_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id),
    FOREIGN KEY (modulo_id) REFERENCES Modulos(modulo_id)
);

-- Tabla de Asignaciones de Trainers a Rutas
CREATE TABLE AsignacionesTrainerRuta (
    asignacion_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_id INT NOT NULL,
    ruta_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id),
    FOREIGN KEY (ruta_id) REFERENCES Rutas(ruta_id)
);

-- Tabla de Asignaciones de Trainers a Áreas y Horarios
CREATE TABLE TrainerAreaHorario (
    asignacion_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_id INT NOT NULL,
    area_id INT NOT NULL,
    horario_id INT NOT NULL,
    dia_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    UNIQUE (area_id, horario_id, dia_id, fecha_inicio),
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id),
    FOREIGN KEY (area_id) REFERENCES AreasEntrenamiento(area_id),
    FOREIGN KEY (horario_id) REFERENCES Horarios(horario_id),
    FOREIGN KEY (dia_id) REFERENCES DiasSemanales(dia_id)
);

-- Tabla de Inscripciones de Campers a Rutas
CREATE TABLE InscripcionesCamperRuta (
    inscripcion_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL,
    ruta_id INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    estado ENUM('Pendiente', 'En curso', 'Finalizada', 'Cancelada') NOT NULL DEFAULT 'Pendiente',
    UNIQUE (camper_id, ruta_id, fecha_inscripcion),
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id),
    FOREIGN KEY (ruta_id) REFERENCES Rutas(ruta_id)
);

-- Tabla de Asignaciones de Campers a Áreas
CREATE TABLE AsignacionCamperArea (
    asignacion_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL,
    area_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id),
    FOREIGN KEY (area_id) REFERENCES AreasEntrenamiento(area_id)
);

-- Tabla de Evaluaciones por Módulo para cada Camper
CREATE TABLE Evaluaciones (
    evaluacion_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL,
    modulo_id INT NOT NULL,
    nota_teorica DECIMAL(5,2) NOT NULL CHECK (nota_teorica >= 0 AND nota_teorica <= 100),
    nota_practica DECIMAL(5,2) NOT NULL CHECK (nota_practica >= 0 AND nota_practica <= 100),
    nota_quizzes DECIMAL(5,2) NOT NULL CHECK (nota_quizzes >= 0 AND nota_quizzes <= 100),
    nota_final DECIMAL(5,2) GENERATED ALWAYS AS (
        (nota_teorica * 0.3) + (nota_practica * 0.6) + (nota_quizzes * 0.1)
    ) STORED,
    aprobado BOOLEAN GENERATED ALWAYS AS (
        ((nota_teorica * 0.3) + (nota_practica * 0.6) + (nota_quizzes * 0.1)) >= 60
    ) STORED,
    fecha_evaluacion DATE NOT NULL,
    comentarios TEXT,
    UNIQUE (camper_id, modulo_id, fecha_evaluacion),
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id),
    FOREIGN KEY (modulo_id) REFERENCES Modulos(modulo_id)
);

-- Tabla de Historial de Estados de Campers
CREATE TABLE HistorialEstadosCamper (
    historial_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL,
    estado_anterior ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado'),
    estado_nuevo ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado') NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    usuario_cambio VARCHAR(50),
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id)
);

-- Tabla de Asistencia
CREATE TABLE Asistencia (
    asistencia_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL,
    area_id INT NOT NULL,
    fecha DATE NOT NULL,
    horario_id INT NOT NULL,
    presente BOOLEAN NOT NULL DEFAULT TRUE,
    observaciones TEXT,
    UNIQUE (camper_id, area_id, fecha, horario_id),
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id),
    FOREIGN KEY (area_id) REFERENCES AreasEntrenamiento(area_id),
    FOREIGN KEY (horario_id) REFERENCES Horarios(horario_id)
);

-- Tabla de Egresados (para campers graduados)
CREATE TABLE Egresados (
    egresado_id INT AUTO_INCREMENT PRIMARY KEY,
    camper_id INT NOT NULL UNIQUE,
    fecha_graduacion DATE NOT NULL,
    ruta_id INT NOT NULL,
    promedio_final DECIMAL(5,2) NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (camper_id) REFERENCES Campers(camper_id),
    FOREIGN KEY (ruta_id) REFERENCES Rutas(ruta_id)
);
