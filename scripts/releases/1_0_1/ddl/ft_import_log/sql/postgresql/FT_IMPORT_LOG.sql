-- liquibase formatted sql

-- Создание новой таблицы истории импорта
-- changeset petrov-va:FT_IMPORT_LOG#postgesql dbms:postgesql logicalFilePath:path-independent runOnChange:true splitStatements:true endDelimiter:/
CREATE TABLE IF NOT EXISTS ${schema}.FT_IMPORT_LOG
(
    IMPORT_ID      VARCHAR(64)  NOT NULL,
    PROCESS_DATA   TEXT,
    ERROR_TEXT     TEXT,
    PROCESS_STATUS VARCHAR(64),
    SUBSYSTEM_CODE VARCHAR(64),
    TENANT_CODE    VARCHAR(512),
    START_DATE     TIMESTAMP(6) NOT NULL,
    END_DATE       TIMESTAMP(6),
    ROW_VERSION    BIGINT       NOT NULL DEFAULT 1,
    LOCKED_FLAG    VARCHAR(1)   NOT NULL DEFAULT 'N',
    MODIFIED_DATE  TIMESTAMP(6) NOT NULL DEFAULT NOW(),
    CONSTRAINT SM_PK_IMPORT_LOG_IMPORT_ID PRIMARY KEY (IMPORT_ID) USING INDEX TABLESPACE ${idx_ts}
) TABLESPACE ${data_ts};

-- Выставляем индексы и ограничения
CREATE INDEX IF NOT EXISTS SM_IDX_FT_IMPORT_LOG_START_DATE ON ${schema}.FT_IMPORT_LOG (START_DATE) TABLESPACE ${idx_ts};
CREATE INDEX IF NOT EXISTS SM_IDX_FT_IMPORT_LOG_END_DATE ON ${schema}.FT_IMPORT_LOG (END_DATE) TABLESPACE ${idx_ts};
CREATE INDEX IF NOT EXISTS SM_IDX_FT_IMPORT_LOG_TENANT_CODE ON ${schema}.FT_IMPORT_LOG (TENANT_CODE) TABLESPACE ${idx_ts};
CREATE INDEX IF NOT EXISTS SM_IDX_FT_IMPORT_LOG_SUBSYSTEM_CODE ON ${schema}.FT_IMPORT_LOG (SUBSYSTEM_CODE) TABLESPACE ${idx_ts};

COMMENT ON TABLE ${schema}.FT_IMPORT_LOG IS 'Таблица логирования импорта';
-- Комментарии на поля
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.IMPORT_ID IS 'Идентификатор процесса в рамках которого прогружается сущность';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.PROCESS_DATA IS 'json, с импортируемой сущностью';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.ERROR_TEXT IS 'Ошибка, полученная при импорте сущности';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.PROCESS_STATUS IS 'Статус процесса';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.SUBSYSTEM_CODE IS 'Код системы в канале';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.TENANT_CODE IS 'Код тенанта';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.START_DATE IS 'Дата запуска процесса';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.END_DATE IS 'Дата завершения процесса';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.ROW_VERSION IS 'Количество изменений';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.LOCKED_FLAG IS 'Признак блокировки';
COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.MODIFIED_DATE IS 'Дата последнего изменения';
/
