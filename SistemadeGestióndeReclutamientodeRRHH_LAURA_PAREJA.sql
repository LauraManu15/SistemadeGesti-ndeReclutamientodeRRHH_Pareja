-- SISTEMA DE GESTIÓN DE RECLUTAMIENTO DE RRHH
-- Creación y carga de datos para entorno de prueba

-- Eliminar tablas existentes (en orden inverso para evitar conflictos de llaves foráneas)
DROP TABLE IF EXISTS evaluacion, entrevista, postulacion, estado_postulacion, vacante, candidato;

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS sistema_reclutamiento;

-- Seleccionar la base de datos para trabajar
USE sistema_reclutamiento;


-- TABLA DE CANDIDATOS
-- Almacena los datos personales del postulante

CREATE TABLE candidato (
    id_candidato INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único del candidato
    nombre VARCHAR(50) NOT NULL,                 -- Nombre del candidato
    apellido VARCHAR(50) NOT NULL,               -- Apellido del candidato
    correo VARCHAR(150) UNIQUE NOT NULL,         -- Correo electrónico (único)
    telefono VARCHAR(20),                        -- Teléfono de contacto
    fecha_postulacion DATE                       -- Fecha en la que postuló
);

-- Registros de candidatos
INSERT INTO candidato (nombre, apellido, correo, telefono, fecha_postulacion)
VALUES 
('Juan', 'Pérez', 'juan.perez@email.com', '987654321', '2025-04-01'),
('María', 'González', 'maria.gonzalez@email.com', '912345678', '2025-04-02'),
('Carlos', 'Martínez', 'carlos.martinez@email.com', '923456789', '2025-04-03'),
('Ana', 'López', 'ana.lopez@email.com', '934567890', '2025-04-04'),
('Laura', 'Sánchez', 'laura.sanchez@email.com', '945678901', '2025-04-05');
SELECT * FROM candidato;


-- TABLA VACANTE
-- Representa una oferta laboral disponible

CREATE TABLE vacante (
    id_vacante INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único de la vacante
    titulo VARCHAR(100) NOT NULL,              -- Título del cargo ofrecido
    descripcion TEXT,                          -- Descripción de la vacante
    departamento VARCHAR(50),                  -- Área o departamento
    fecha_publicacion DATE                     -- Fecha en que se publicó la vacante
);

-- Registros de vacantes
INSERT INTO vacante (titulo, descripcion, departamento, fecha_publicacion)
VALUES 
('Desarrollador Web', 'Encargado del desarrollo y mantenimiento de aplicaciones web.', 'Tecnología', '2025-04-01'),
('Analista de Datos', 'Responsable de análisis y visualización de datos en el área comercial.', 'Comercial', '2025-04-02'),
('Gerente de Marketing', 'Gestiona las estrategias de marketing y comunicación.', 'Marketing', '2025-04-03'),
('Asistente Administrativo', 'Apoyo en las tareas administrativas y de gestión de oficina.', 'Administración', '2025-04-04'),
('Contador', 'Encargado de la contabilidad y registros financieros de la empresa.', 'Finanzas', '2025-04-05');
SELECT * FROM vacante;


-- TABLA ESTADO DE POSTULACION
-- Define los posibles estados de una postulación

CREATE TABLE estado_postulacion (
    id_estado INT AUTO_INCREMENT PRIMARY KEY, -- Identificador del estado
    estado_nombre VARCHAR(50)                 -- Nombre del estado 
);

-- registros de estado de postulacion
INSERT INTO estado_postulacion (estado_nombre)
VALUES 
('En revisión'),
('Entrevistado'),
('Rechazado'),
('Aprobado');
SELECT * FROM estado_postulacion;


-- TABLA DE POSTULACION
-- Relaciona candidatos con vacantes

CREATE TABLE postulacion (
    id_postulacion INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único de la postulación
    id_candidato INT NOT NULL,                     -- Relación con el candidato
    id_vacante INT NOT NULL,                       -- Relación con la vacante
    fecha_aplicacion DATE,                         -- Fecha en que se aplicó
    id_estado INT DEFAULT 1,                       -- Estado de la postulación, por defecto “En revisión”
    
    FOREIGN KEY (id_candidato) REFERENCES candidato(id_candidato),
    FOREIGN KEY (id_vacante) REFERENCES vacante(id_vacante),
    FOREIGN KEY (id_estado) REFERENCES estado_postulacion(id_estado)
);

-- Registros de postulacion
INSERT INTO postulacion (id_candidato, id_vacante, fecha_aplicacion, id_estado)
VALUES 
(1, 1, '2025-04-01', 1),
(2, 2, '2025-04-02', 1),
(3, 3, '2025-04-03', 2),
(4, 4, '2025-04-04', 3),
(5, 5, '2025-04-05', 4);
SELECT * FROM postulacion;


-- TABLA DE ENTREVISTA
-- Guarda los datos de entrevistas realizadas

CREATE TABLE entrevista (
    id_entrevista INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único de la entrevista
    id_postulacion INT NOT NULL,                  -- Relación con la postulación
    fecha_entrevista DATETIME,                    -- Fecha y hora de la entrevista
    evaluador VARCHAR(100),                       -- Nombre del entrevistador
    observaciones TEXT,                           -- Comentarios del evaluador
    
    FOREIGN KEY (id_postulacion) REFERENCES postulacion(id_postulacion)
);

-- registro de entrevistas
INSERT INTO entrevista (id_postulacion, fecha_entrevista, evaluador, observaciones)
VALUES 
(1, '2025-04-06 10:00:00', 'Pedro Gómez', 'Buen candidato, tiene experiencia en desarrollo web.'),
(2, '2025-04-07 11:00:00', 'Ana Ramírez', 'Buen perfil analítico, con conocimiento en SQL.'),
(3, '2025-04-08 09:30:00', 'Luis Fernández', 'Necesita mejorar sus habilidades de comunicación.'),
(4, '2025-04-09 14:00:00', 'Carla Martínez', 'Necesita más experiencia administrativa.'),
(5, '2025-04-10 16:00:00', 'Javier Sánchez', 'Excelente conocimiento en contabilidad.');
SELECT * FROM entrevista;


-- TABLA DE EVALUCION
-- Guarda puntajes o evaluaciones realizadas al candidato

CREATE TABLE evaluacion (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único de la evaluación
    id_entrevista INT NOT NULL,                   -- Relación con la entrevista
    puntaje INT CHECK (puntaje BETWEEN 0 AND 100),-- Puntaje obtenido en la evaluación
    comentarios TEXT,                             -- Observaciones generales
    
    FOREIGN KEY (id_entrevista) REFERENCES entrevista(id_entrevista)
);

-- Registros de evaluacion
INSERT INTO evaluacion (id_entrevista, puntaje, comentarios)
VALUES 
(1, 85, 'Buen desempeño técnico, pero debe mejorar en comunicación.'),
(2, 90, 'Excelente análisis de datos, puede mejorar en presentaciones.'),
(3, 70, 'Buen candidato, pero la comunicación es clave para el puesto.'),
(4, 60, 'Falta de experiencia administrativa, necesita más formación.'),
(5, 95, 'Excelente desempeño, gran potencial para el puesto de contador.');
SELECT * FROM evaluacion;