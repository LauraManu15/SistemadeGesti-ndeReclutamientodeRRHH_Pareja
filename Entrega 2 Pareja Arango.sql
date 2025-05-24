-- ====================================================================================================================
-- CREACIÓN DE TABLAS PARA SISTEMA DE GESTIÓN DE RECLUTAMIENTO DE RRHH
-- ====================================================================================================================

CREATE TABLE candidato (
    id_candidato INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    correo VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    fecha_postulacion DATE
);

CREATE TABLE vacante (
    id_vacante INT PRIMARY KEY,
    titulo VARCHAR(100),
    descripcion TEXT,
    departamento VARCHAR(50),
    fecha_publicacion DATE
);

CREATE TABLE estado_postulacion (
    id_estado INT PRIMARY KEY,
    estado_nombre VARCHAR(50)
);

CREATE TABLE postulacion (
    id_postulacion INT PRIMARY KEY,
    id_candidato INT,
    id_vacante INT,
    fecha_aplicacion DATE,
    id_estado INT,
    FOREIGN KEY (id_candidato) REFERENCES candidato(id_candidato),
    FOREIGN KEY (id_vacante) REFERENCES vacante(id_vacante),
    FOREIGN KEY (id_estado) REFERENCES estado_postulacion(id_estado)
);

CREATE TABLE entrevista (
    id_entrevista INT PRIMARY KEY,
    id_postulacion INT,
    fecha_entrevista DATETIME,
    evaluador VARCHAR(100),
    observaciones TEXT,
    FOREIGN KEY (id_postulacion) REFERENCES postulacion(id_postulacion)
);

CREATE TABLE evaluacion (
    id_evaluacion INT PRIMARY KEY,
    id_entrevista INT,
    puntaje INT,
    comentarios TEXT,
    FOREIGN KEY (id_entrevista) REFERENCES entrevista(id_entrevista)
);

-- ====================================================================================================================
-- VISTAS
-- ====================================================================================================================

CREATE OR REPLACE VIEW vista_postulaciones_detalle AS
SELECT
    p.id_postulacion,
    c.nombre,
    c.apellido,
    c.correo,
    v.titulo AS puesto,
    v.departamento,
    e.estado_nombre,
    p.fecha_aplicacion
FROM postulacion p
JOIN candidato c ON p.id_candidato = c.id_candidato
JOIN vacante v ON p.id_vacante = v.id_vacante
JOIN estado_postulacion e ON p.id_estado = e.id_estado;

CREATE OR REPLACE VIEW vista_entrevistas_evaluacion AS
SELECT
    ent.id_entrevista,
    c.nombre,
    c.apellido,
    ent.fecha_entrevista,
    ent.evaluador,
    ent.observaciones AS observaciones_entrevista,
    ev.puntaje,
    ev.comentarios AS comentarios_evaluacion
FROM entrevista ent
JOIN evaluacion ev ON ent.id_entrevista = ev.id_entrevista
JOIN postulacion p ON ent.id_postulacion = p.id_postulacion
JOIN candidato c ON p.id_candidato = c.id_candidato;

-- FUNCIONES

DELIMITER $$

CREATE FUNCTION fn_calcular_promedio_puntaje(p_id_candidato INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE promedio FLOAT DEFAULT 0;
    
    SELECT AVG(ev.puntaje) INTO promedio
    FROM evaluacion ev
    JOIN entrevista ent ON ev.id_entrevista = ent.id_entrevista
    JOIN postulacion p ON ent.id_postulacion = p.id_postulacion
    WHERE p.id_candidato = p_id_candidato;

    RETURN IFNULL(promedio, 0);
END $$

CREATE FUNCTION fn_contar_postulaciones_estado(p_estado_nombre VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cantidad INT DEFAULT 0;

    SELECT COUNT(*) INTO cantidad
    FROM postulacion p
    JOIN estado_postulacion e ON p.id_estado = e.id_estado
    WHERE e.estado_nombre = p_estado_nombre;

    RETURN cantidad;
END $$

DELIMITER ;

-- Stored Procedure

DELIMITER $$

CREATE PROCEDURE sp_actualizar_estado_postulacion(
    IN p_id_postulacion INT,
    IN p_id_estado INT
)
BEGIN
    UPDATE postulacion
    SET id_estado = p_id_estado
    WHERE id_postulacion = p_id_postulacion;
END $$

CREATE PROCEDURE sp_insertar_entrevista_con_evaluacion(
    IN p_id_postulacion INT,
    IN p_fecha_entrevista DATETIME,
    IN p_evaluador VARCHAR(100),
    IN p_observaciones TEXT,
    IN p_puntaje INT,
    IN p_comentarios TEXT
)
BEGIN
    DECLARE v_id_entrevista INT;

    INSERT INTO entrevista (id_postulacion, fecha_entrevista, evaluador, observaciones)
    VALUES (p_id_postulacion, p_fecha_entrevista, p_evaluador, p_observaciones);

    SET v_id_entrevista = LAST_INSERT_ID();

    INSERT INTO evaluacion (id_entrevista, puntaje, comentarios)
    VALUES (v_id_entrevista, p_puntaje, p_comentarios);
END $$

DELIMITER ;

-- TRIGGERS

DELIMITER $$

CREATE TRIGGER trg_postulacion_insert
BEFORE INSERT ON postulacion
FOR EACH ROW
BEGIN
    IF NEW.id_estado IS NULL THEN
        SET NEW.id_estado = 1; -- Asigna estado 'En revisión' por defecto
    END IF;
END $$

DELIMITER ;
