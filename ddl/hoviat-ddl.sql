-- 1. schema ddl scripts
CREATE DATABASE IF NOT EXISTS hoviat collate utf8mb4_0900_ai_ci;
DROP DATABASE IF EXISTS hoviat;

use hoviat;
-- 2. creating tables scripts
CREATE TABLE IF NOT EXISTS country_division
(
    code   INT NOT NULL UNIQUE,
    parent INT NOT NULL,

    PRIMARY KEY (code),
    CONSTRAINT FOREIGN KEY CNT_DIV_SELF_FK_IDX (parent) REFERENCES country_division (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS central_guild
(
    code   SMALLINT     NOT NULL UNIQUE,
    name   NVARCHAR(30) NOT NULL,
    uid    BIGINT       NOT NULL UNIQUE COMMENT 'unique id',
    p_code BIGINT(10)   NOT NULL COMMENT 'postal code',
    m_name NVARCHAR(30) NOT NULL COMMENT 'manager name',
    phone  VARCHAR(11)  NOT NULL UNIQUE,
    mobile VARCHAR(11)  NOT NULL UNIQUE,
    active BIT          NOT NULL DEFAULT FALSE,

    PRIMARY KEY (code)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS province_guild
(
    code   INT          NOT NULL UNIQUE,
    name   NVARCHAR(30) NOT NULL,
    uid    BIGINT       NOT NULL UNIQUE COMMENT 'unique id',
    p_code BIGINT(10)   NOT NULL COMMENT 'postal code',
    m_name NVARCHAR(30) NOT NULL COMMENT 'manager name',
    phone  VARCHAR(11)  NOT NULL UNIQUE,
    mobile VARCHAR(11)  NOT NULL UNIQUE,
    active BIT          NOT NULL DEFAULT FALSE,
    div_fk INT          NOT NULL COMMENT 'country division foreign key',
    cg_fk  SMALLINT     NOT NULL COMMENT 'central guild foreign key',

    PRIMARY KEY (code),
    CONSTRAINT FOREIGN KEY C_GUILD_CNT_DIV_FK_IDX (div_fk) REFERENCES country_division (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT FOREIGN KEY P_GUILD_C_GUILD_FK_IDX (cg_fk) REFERENCES central_guild (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS contractor
(
    n_code   BIGINT(11)   NOT NULL UNIQUE COMMENT 'national code',
    fname    NVARCHAR(20) NOT NULL COMMENT 'first name',
    lname    NVARCHAR(30) NOT NULL COMMENT 'last name',
    code     INT          NOT NULL UNIQUE,
    phone    VARCHAR(11)  NOT NULL UNIQUE,
    b_dt     DATE         NOT NULL COMMENT 'birth date',
    uid      BIGINT       NOT NULL UNIQUE COMMENT 'unique id',
    p_code   BIGINT(10)   NOT NULL COMMENT 'postal code',
    email    VARCHAR(50)  NULL,
    cmp_name NVARCHAR(50) NULL COMMENT 'company name',
    div_fk   INT          NOT NULL COMMENT 'country division foreign key',
    guild_fk INT          NOT NULL COMMENT 'province guild foreign key',

    PRIMARY KEY (n_code),
    CONSTRAINT FOREIGN KEY CONTRACTOR_CNT_DIV_FK_IDX (div_fk) REFERENCES country_division (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT FOREIGN KEY CONTRACTOR_P_GUILD_FK_IDX (guild_fk) REFERENCES province_guild (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS agent
(
    n_code  BIGINT(11)   NOT NULL UNIQUE COMMENT 'national code',
    uid     BIGINT       NOT NULL UNIQUE COMMENT 'unique id',
    p_code  BIGINT(10)   NOT NULL COMMENT 'postal code',
    b_dt    DATE         NOT NULL COMMENT 'birth date',
    fname   NVARCHAR(20) NOT NULL COMMENT 'first name',
    lname   NVARCHAR(30) NOT NULL COMMENT 'last name',
    phone   VARCHAR(11)  NOT NULL UNIQUE,
    mobile  VARCHAR(11)  NOT NULL UNIQUE,
    grade   SMALLINT     NOT NULL,
    cntr_fk BIGINT(11)   NOT NULL COMMENT 'contractor foreign key',
    div_fk  INT          NOT NULL COMMENT 'country division foreign key',

    PRIMARY KEY (n_code),
    CONSTRAINT FOREIGN KEY AGENT_CNT_DIV_FK_IDX (div_fk) REFERENCES country_division (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT FOREIGN KEY AGENT_CONTRACTOR_FK_IDX (cntr_fk) REFERENCES contractor (n_code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT

) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS tag_company
(
    id       INT AUTO_INCREMENT PRIMARY KEY,
    cmp_name NVARCHAR(50) NULL COMMENT 'company name',
    uid      BIGINT       NOT NULL UNIQUE COMMENT 'unique id',
    p_code   BIGINT(10)   NOT NULL COMMENT 'postal code',
    e_year   YEAR         NULL COMMENT 'established year',
    m_name   NVARCHAR(30) NOT NULL COMMENT 'manager name',
    is_pdcr  BIT          NULL     DEFAULT FALSE COMMENT 'is producer?',
    is_imptr BIT          NULL     DEFAULT FALSE COMMENT 'is importer?',
    p_visual BIT          NULL     DEFAULT FALSE COMMENT 'produce Visual tag?',
    p_rfid   BIT          NULL     DEFAULT FALSE COMMENT 'produce Electronic tag(RFID)?',
    p_mchip  BIT          NULL     DEFAULT FALSE COMMENT 'produce Microchip?',
    p_bol    BIT          NULL     DEFAULT FALSE COMMENT 'produce Boluses?',
    active   BIT          NOT NULL DEFAULT FALSE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS rancher
(
    n_code   BIGINT(11)   NOT NULL UNIQUE COMMENT 'national code',
    b_dt     DATE         NOT NULL COMMENT 'birth date',
    fname    NVARCHAR(20) NOT NULL COMMENT 'first name',
    lname    NVARCHAR(30) NOT NULL COMMENT 'last name',
    phone    VARCHAR(11)  NULL UNIQUE,
    mobile   VARCHAR(11)  NOT NULL UNIQUE,
    div_fk   INT          NOT NULL COMMENT 'country division foreign key',
    islg     BIT          NOT NULL COMMENT 'is_legal. Is this record a legal rancher? Otherwise it is national.',
    cnid     VARCHAR(30)  NULL COMMENT 'company national id. this is required if rancher is legal',
    cmp_name NVARCHAR(50) NULL COMMENT 'company name. This is required if rancher is legal',

    PRIMARY KEY (n_code),
    CONSTRAINT FOREIGN KEY RANCHER_CNT_DIV_FK_IDX (div_fk) REFERENCES country_division (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT CHECK ( (islg = 1 AND cnid IS NOT NULL) OR
                       (islg = 0 AND cnid IS NULL AND cmp_name IS NULL))

) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS herd
(
    code    INT          NOT NULL COMMENT 'herd code',
    epdm    VARCHAR(11)  NOT NULL COMMENT 'epidemiologic code',
    div_fk  INT          NOT NULL COMMENT 'country division foreign key',
    p_code  BIGINT(10)   NOT NULL COMMENT 'postal code',
    cont_fk BIGINT(11)   NOT NULL COMMENT 'contractor foreign key',
    name    NVARCHAR(30) NOT NULL COMMENT 'herd name',
    lng     FLOAT        NOT NULL COMMENT 'long',
    lat     FLOAT        NOT NULL,
    PRIMARY KEY (code),
    CONSTRAINT FOREIGN KEY HERD_CNT_DIV_FK_IDX (div_fk) REFERENCES country_division (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT FOREIGN KEY HERD_CONTRACTOR_FK_IDX (cont_fk) REFERENCES contractor (n_code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT

) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS sub_unit_activity
(
    code INT          NOT NULL,
    name NVARCHAR(50) NOT NULL UNIQUE,

    PRIMARY KEY (code)
) ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS sub_unit
(
    id         INT         NOT NULL AUTO_INCREMENT,
    uid        BIGINT      NOT NULL UNIQUE COMMENT 'unique id',
    hc_fk      INT         NOT NULL COMMENT 'herd foreign key',
    ac_fk      INT         NOT NULL COMMENT 'sub_unit_activity foreign key',
    active     BIT         NOT NULL DEFAULT FALSE,
    capacity   SMALLINT    NOT NULL,
    lic_st     BIT         NOT NULL COMMENT 'license status. 1 if has, 0 otherwise.',
    lic_nu     VARCHAR(10) NULL COMMENT 'license number. If has license.',
    lic_is_dt  DATE        NULL COMMENT 'license issue date. If has license.',
    lic_exp_dt DATE        NULL COMMENT 'license expire date. If has license.',

    PRIMARY KEY (id),
    CONSTRAINT FOREIGN KEY SUB_UNIT_HERD_FK_IDX (hc_fk) REFERENCES herd (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,

    CONSTRAINT FOREIGN KEY SUB_UNIT_ACTIVITY_FK_IDX (ac_fk) REFERENCES sub_unit_activity (code)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT

) ENGINE = InnoDB;



-- 3. dropping tables scripts
DROP TABLE IF EXISTS sub_unit;
DROP TABLE IF EXISTS sub_unit_activity;
DROP TABLE IF EXISTS agent;
DROP TABLE IF EXISTS herd;
DROP TABLE IF EXISTS rancher;
DROP TABLE IF EXISTS contractor;
DROP TABLE IF EXISTS province_guild;
DROP TABLE IF EXISTS central_guild;
DROP TABLE IF EXISTS country_division;
DROP TABLE IF EXISTS tag_company;

