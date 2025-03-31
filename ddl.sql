-- DROP DATABASE IF EXISTS CampusDB;
CREATE DATABASE CampusDB;
USE CampusDB;

CREATE TABLE RutasEntrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    sgdb_principal VARCHAR(50) NOT NULL,
    sgdb_alternativo VARCHAR(50) NOT NULL
);

CREATE TABLE Modulos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE RutasModulos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ruta_id INT NOT NULL,
    modulo_id INT NOT NULL,
    FOREIGN KEY (ruta_id) REFERENCES RutasEntrenamiento(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES Modulos(id) ON DELETE CASCADE,
    UNIQUE KEY (ruta_id, modulo_id)
);

CREATE TABLE Grupos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Campers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    direccion TEXT,
    acudiente VARCHAR(100),
    telefono VARCHAR(20),
    nivel_riesgo VARCHAR(50)
);

CREATE TABLE Trainers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL
);

CREATE TABLE Estados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado') NOT NULL UNIQUE
);

CREATE TABLE CampersEstados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    estado_id INT NOT NULL,
    FOREIGN KEY (camper_id) REFERENCES Campers(id) ON DELETE CASCADE,
    FOREIGN KEY (estado_id) REFERENCES Estados(id) ON DELETE CASCADE,
    UNIQUE KEY (camper_id, estado_id)
);

CREATE TABLE CampersGrupos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    grupo_id INT NOT NULL,
    FOREIGN KEY (camper_id) REFERENCES Campers(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES Grupos(id) ON DELETE CASCADE
);

CREATE TABLE TrainersGrupos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    grupo_id INT NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES Grupos(id) ON DELETE CASCADE
);

CREATE TABLE Evaluaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    modulo_id INT NOT NULL,
    teorica FLOAT CHECK (teorica BETWEEN 0 AND 100),
    practica FLOAT CHECK (practica BETWEEN 0 AND 100),
    quizzes FLOAT CHECK (quizzes BETWEEN 0 AND 100),
    nota_final FLOAT GENERATED ALWAYS AS ((teorica * 0.3) + (practica * 0.6) + (quizzes * 0.1)) STORED,
    aprobado BOOLEAN GENERATED ALWAYS AS (nota_final >= 60),
    FOREIGN KEY (camper_id) REFERENCES Campers(id) ON DELETE CASCADE,
    FOREIGN KEY (modulo_id) REFERENCES Modulos(id) ON DELETE CASCADE
);

CREATE TABLE AreasEntrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    capacidad_maxima INT DEFAULT 33
);

CREATE TABLE Horario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    trainers_grupos_id INT NOT NULL,
    area_id INT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    FOREIGN KEY (trainers_grupos_id) REFERENCES TrainersGrupos(id) ON DELETE CASCADE,
    FOREIGN KEY (area_id) REFERENCES AreasEntrenamiento(id) ON DELETE CASCADE,
    UNIQUE KEY (`trainers_grupos_id`, `area_id`, `hora_inicio`, `hora_fin`)
);
