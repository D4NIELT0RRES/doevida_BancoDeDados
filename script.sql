-- ==========================================
-- BANCO DE DADOS - DOEVIDA (com Seeds)
-- ==========================================

DROP DATABASE IF EXISTS db_doevida_tcc;
CREATE DATABASE db_doevida_tcc;
USE db_doevida_tcc;

drop database db_doevida_tcc;

show tables;

select * from tbl_tipo_sanguineo;
-- =========================
-- TABELA: Tipo Sanguíneo
-- =========================
CREATE TABLE tbl_tipo_sanguineo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(5) NOT NULL UNIQUE
);

DELIMITER //
CREATE TRIGGER before_tipo_sanguineo_insert
BEFORE INSERT ON tbl_tipo_sanguineo
FOR EACH ROW
BEGIN
    SET NEW.tipo = UPPER(NEW.tipo);
END//
DELIMITER ;

-- Seed tipos sanguíneos
INSERT INTO tbl_tipo_sanguineo (tipo) VALUES
('A+'),
('A-'),
('B+'),
('B-'),
('AB+'),
('AB-'),
('O+'),
('O-');

-- =========================
-- TABELA: Sexo
-- =========================
CREATE TABLE tbl_sexo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sexo VARCHAR(15) NOT NULL
);

SELECT * FROM tbl_sexo;

DELIMITER //
CREATE TRIGGER before_sexo_insert
BEFORE INSERT ON tbl_sexo
FOR EACH ROW
BEGIN
    SET NEW.sexo = UPPER(NEW.sexo);
END//
DELIMITER ;

-- Seed sexos
INSERT INTO tbl_sexo (sexo) VALUES
('MASCULINO'),
('FEMININO'),
('OUTRO');

-- =========================
-- TABELA: Usuário
-- =========================
CREATE TABLE tbl_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(70) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,

    -- Dados opcionais
    cpf VARCHAR(15) UNIQUE NULL,
    cep VARCHAR(10) NULL,
    logradouro VARCHAR(150) NULL,
    bairro VARCHAR(100) NULL,
    localidade VARCHAR(100) NULL,
    uf VARCHAR(2) NULL,
    numero VARCHAR(20) NULL,
    data_nascimento DATE NULL,
    foto_perfil VARCHAR(255) NULL,

    -- Relacionamentos opcionais
    id_tipo_sanguineo INT NULL,
    id_sexo INT NULL,

    -- Controle
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (id_tipo_sanguineo) REFERENCES tbl_tipo_sanguineo(id),
    FOREIGN KEY (id_sexo) REFERENCES tbl_sexo(id)
);

-- Triggers Usuário
DELIMITER //
CREATE TRIGGER before_usuario_email
BEFORE INSERT ON tbl_usuario
FOR EACH ROW
BEGIN
    SET NEW.email = LOWER(NEW.email);
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_usuario_cpf
BEFORE INSERT ON tbl_usuario
FOR EACH ROW
BEGIN
    IF NEW.cpf IS NOT NULL THEN
        SET NEW.cpf = REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '');
        IF LENGTH(NEW.cpf) = 11 THEN
            SET NEW.cpf = CONCAT(SUBSTRING(NEW.cpf, 1, 3), '.',
                                 SUBSTRING(NEW.cpf, 4, 3), '.',
                                 SUBSTRING(NEW.cpf, 7, 3), '-',
                                 SUBSTRING(NEW.cpf, 10, 2));
        END IF;
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_usuario_cep
BEFORE INSERT ON tbl_usuario
FOR EACH ROW
BEGIN
    IF NEW.cep IS NOT NULL THEN
        SET NEW.cep = REPLACE(REPLACE(NEW.cep, '-', ''), ' ', '');
        IF LENGTH(NEW.cep) = 8 THEN
            SET NEW.cep = CONCAT(SUBSTRING(NEW.cep, 1, 5), '-', SUBSTRING(NEW.cep, 6, 3));
        END IF;
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_usuario_nascimento
BEFORE INSERT ON tbl_usuario
FOR EACH ROW
BEGIN
    IF NEW.data_nascimento IS NOT NULL THEN
        IF NEW.data_nascimento > CURDATE() THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de nascimento não pode ser futura';
        END IF;
    END IF;
END//
DELIMITER ;

-- =========================
-- TABELA: Hospitais
-- =========================
CREATE TABLE tbl_hospital (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(70) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    cnpj VARCHAR(20) UNIQUE NOT NULL,
    crm VARCHAR(255) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    capacidade_maxima INT NOT NULL DEFAULT 10,
    convenios VARCHAR(255) NOT NULL,
    horario_abertura TIME NOT NULL DEFAULT '08:00:00',
    horario_fechamento TIME NOT NULL DEFAULT '18:00:00',
    foto VARCHAR(255) NOT NULL,
    complemento VARCHAR(255) NULL
);

-- Triggers Hospital
DELIMITER //
CREATE TRIGGER before_hospital_email
BEFORE INSERT ON tbl_hospital
FOR EACH ROW
BEGIN
    SET NEW.email = LOWER(NEW.email);
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_hospital_cnpj
BEFORE INSERT ON tbl_hospital
FOR EACH ROW
BEGIN
    SET NEW.cnpj = REPLACE(REPLACE(REPLACE(REPLACE(NEW.cnpj, '.', ''), '/', ''), '-', ''), ' ', '');
    IF LENGTH(NEW.cnpj) = 14 THEN
        SET NEW.cnpj = CONCAT(SUBSTRING(NEW.cnpj, 1, 2), '.',
                              SUBSTRING(NEW.cnpj, 3, 3), '.',
                              SUBSTRING(NEW.cnpj, 6, 3), '/',
                              SUBSTRING(NEW.cnpj, 9, 4), '-',
                              SUBSTRING(NEW.cnpj, 13, 2));
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_hospital_cep
BEFORE INSERT ON tbl_hospital
FOR EACH ROW
BEGIN
    SET NEW.cep = REPLACE(REPLACE(NEW.cep, '-', ''), ' ', '');
    IF LENGTH(NEW.cep) = 8 THEN
        SET NEW.cep = CONCAT(SUBSTRING(NEW.cep, 1, 5), '-', SUBSTRING(NEW.cep, 6, 3));
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_hospital_telefone
BEFORE INSERT ON tbl_hospital
FOR EACH ROW
BEGIN
    SET NEW.telefone = REPLACE(REPLACE(REPLACE(REPLACE(NEW.telefone, '(', ''), ')', ''), '-', ''), ' ', '');
    IF LENGTH(NEW.telefone) = 11 THEN
        SET NEW.telefone = CONCAT('(', SUBSTRING(NEW.telefone, 1, 2), ') ',
                                  SUBSTRING(NEW.telefone, 3, 5), '-',
                                  SUBSTRING(NEW.telefone, 8, 4));
    END IF;
END//
DELIMITER ;

-- =========================
-- TABELA: Banco de Sangue (estoque)
-- =========================
CREATE TABLE tbl_banco_sangue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_hospital INT NOT NULL,
    id_tipo_sanguineo INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,

    FOREIGN KEY (id_hospital) REFERENCES tbl_hospital(id),
    FOREIGN KEY (id_tipo_sanguineo) REFERENCES tbl_tipo_sanguineo(id)
);

-- =========================
-- TABELA: Doação
-- =========================
CREATE TABLE tbl_doacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data DATE NOT NULL,
    observacao TEXT NULL,
    foto VARCHAR(255) NULL
);

-- =========================
-- TABELA: Agendamento
-- =========================
CREATE TABLE tbl_agendamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('Agendado', 'Em espera', 'Concluído') NOT NULL DEFAULT 'Agendado',
    data DATE NOT NULL,
    hora TIME NOT NULL,
    id_usuario INT NOT NULL,
    id_doacao INT NULL,
    id_hospital INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id),
    FOREIGN KEY (id_doacao) REFERENCES tbl_doacao(id),
    FOREIGN KEY (id_hospital) REFERENCES tbl_hospital(id)
);

-- =========================
-- TABELA: Registro de Doação
-- =========================
CREATE TABLE tbl_registro_doacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_agendamento INT NOT NULL UNIQUE,
    id_usuario INT NOT NULL,
    id_hospital INT NOT NULL,
    data_doacao DATE NOT NULL,
    local_doacao VARCHAR(255) NOT NULL,
    observacao TEXT NULL,
    foto_comprovante VARCHAR(500) NULL,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agendamento) REFERENCES tbl_agendamento(id),
    FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id),
    FOREIGN KEY (id_hospital) REFERENCES tbl_hospital(id)
);
UPDATE tbl_agendamento SET status = 'Concluído' WHERE id = 1;
-- =========================
-- TABELA: Telefone
-- =========================
CREATE TABLE tbl_telefone (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(30) NOT NULL,
    numero VARCHAR(15) NOT NULL,
    id_usuario INT NULL,
    FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id)
);

DELIMITER //
CREATE TRIGGER before_telefone_format
BEFORE INSERT ON tbl_telefone
FOR EACH ROW
BEGIN
    SET NEW.numero = REPLACE(REPLACE(REPLACE(REPLACE(NEW.numero, '(', ''), ')', ''), '-', ''), ' ', '');
    IF LENGTH(NEW.numero) = 11 THEN
        SET NEW.numero = CONCAT('(', SUBSTRING(NEW.numero, 1, 2), ') ',
                                 SUBSTRING(NEW.numero, 3, 5), '-',
                                 SUBSTRING(NEW.numero, 8, 4));
    END IF;
END//
DELIMITER ;

-- =========================
-- TABELA: Certificado
-- =========================
CREATE TABLE tbl_certificado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL,
    organizacao VARCHAR(60) NOT NULL,
    data_emissao DATE NOT NULL,
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id)
);

CREATE TABLE tbl_recuperacao_senha (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    codigo VARCHAR(50) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usado BOOLEAN DEFAULT 0,

    FOREIGN KEY (id_usuario) REFERENCES tbl_usuario(id)
);


-- =========================
-- SEED AUTOMÁTICA DO ESTOQUE
-- =========================
-- Para cada hospital cadastrado, cria registros de estoque (0) para todos os tipos sanguíneos
INSERT INTO tbl_banco_sangue (id_hospital, id_tipo_sanguineo, quantidade)
SELECT h.id, t.id, 0
FROM tbl_hospital h
CROSS JOIN tbl_tipo_sanguineo t;

-- =========================
-- ÍNDICES PARA PERFORMANCE
-- =========================
-- Índice para otimizar consultas de agendamento por hospital, data e hora
CREATE INDEX idx_agendamento_hospital_data_hora ON tbl_agendamento (id_hospital, data, hora);

-- Índice para otimizar consultas de agendamento por usuário
CREATE INDEX idx_agendamento_usuario ON tbl_agendamento (id_usuario, data, hora);

-- =========================
-- DADOS DE TESTE (SEEDS)
-- =========================

-- Inserir hospital de teste
INSERT INTO tbl_hospital (
    nome, email, senha, cnpj, crm, cep, telefone, 
    capacidade_maxima, convenios, horario_abertura, 
    horario_fechamento, foto, complemento
) VALUES (
    'Hospital Central',
    'contato@hospitalcentral.com.br',
    '$2b$10$hash_exemplo_senha',
    '12.345.678/0001-90',
    'CRM12345SP',
    '01234-567',
    '(11) 99999-9999',
    5,
    'SUS, Unimed, Bradesco Saúde',
    '08:00:00',
    '18:00:00',
    'https://exemplo.com/hospital.jpg',
    'Próximo ao metrô'
);

INSERT INTO tbl_hospital (
    nome, email, senha, cnpj, crm, cep, telefone, 
    capacidade_maxima, convenios, horario_abertura, 
    horario_fechamento, foto, complemento
) VALUES (
    'Hospital Regional',
    'atendimento@hospitalregional.com.br',
    '$2b$10$hash_exemplo_senha2',
    '98.765.432/0001-10',
    'CRM67890SP',
    '04567-890',
    '(11) 88888-8888',
    3,
    'SUS, Porto Seguro, Amil',
    '07:00:00',
    '19:00:00',
    'https://exemplo.com/hospital2.jpg',
    'Estacionamento gratuito'
);

INSERT INTO tbl_hospital (
    nome, email, senha, cnpj, crm, cep, telefone, 
    capacidade_maxima, convenios, horario_abertura, 
    horario_fechamento, foto, complemento
) VALUES (
    'Centro Médico',
    'info@centromedico.com.br',
    '$2b$10$hash_exemplo_senha3',
    '11.222.333/0001-44',
    'CRM11111SP',
    '05678-901',
    '(11) 77777-7777',
    8,
    'SUS, Sul América, Golden Cross',
    '06:00:00',
    '20:00:00',
    'https://exemplo.com/centro.jpg',
    'Atendimento 24h emergência'
);

-- =========================
-- TESTES
-- =========================
SELECT * FROM tbl_usuario;
SELECT * FROM tbl_tipo_sanguineo;
SELECT * FROM tbl_banco_sangue;
SELECT * FROM tbl_hospital;
ALTER TABLE tbl_hospital MODIFY COLUMN foto MEDIUMTEXT;
