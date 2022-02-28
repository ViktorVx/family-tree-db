-- liquibase formatted sql

-- Создание новой таблицы истории импорта
-- changeset petrov-va:FT_IMPORT_LOG#oracle dbms:oracle logicalFilePath:path-independent runOnChange:true splitStatements:true endDelimiter:/
declare
    tableExists integer := 0;
begin
    SELECT COUNT(*) INTO tableExists FROM DBA_TABLES WHERE TABLE_NAME = 'FT_IMPORT_LOG' AND OWNER = '${schema}';
    if tableExists = 0 then
        execute immediate
            'CREATE TABLE ${schema}.FT_IMPORT_LOG
             (IMPORT_ID VARCHAR2(64 BYTE) NOT NULL,
              PROCESS_DATA CLOB,
              ERROR_TEXT CLOB,
              PROCESS_STATUS VARCHAR2(64 BYTE),
              SUBSYSTEM_CODE VARCHAR2(64 BYTE),
              TENANT_CODE VARCHAR2(512 BYTE),
              START_DATE TIMESTAMP(6) NOT NULL,
              END_DATE TIMESTAMP(6),
              ROW_VERSION NUMBER(22, 0) NOT NULL,
              LOCKED_FLAG VARCHAR2(1),
              MODIFIED_DATE TIMESTAMP(6) NOT NULL)
            LOB (PROCESS_DATA, ERROR_TEXT) STORE AS SECUREFILE ( TABLESPACE ${lob_ts}
                                                               COMPRESS HIGH DEDUPLICATE )
            ROW STORE COMPRESS ADVANCED TABLESPACE ${data_ts}';
-- Ограничения и индексы
        execute immediate 'ALTER TABLE ${schema}.FT_IMPORT_LOG ADD CONSTRAINT SM_PK_IMPORT_LOG_IMPORT_ID PRIMARY KEY (IMPORT_ID)
    USING INDEX TABLESPACE ${idx_ts} ';
        execute immediate 'CREATE INDEX ${schema}.SM_IDX_FT_IMPORT_LOG_START_DATE ON ${schema}.FT_IMPORT_LOG (START_DATE) ONLINE TABLESPACE ${idx_ts}';
        execute immediate 'CREATE INDEX ${schema}.SM_IDX_FT_IMPORT_LOG_END_DATE ON ${schema}.FT_IMPORT_LOG (END_DATE) ONLINE TABLESPACE ${idx_ts}';
        execute immediate 'CREATE INDEX ${schema}.SM_IDX_FT_IMPORT_LOG_TENANT_CODE ON ${schema}.FT_IMPORT_LOG (TENANT_CODE) ONLINE TABLESPACE ${idx_ts}';
        execute immediate 'CREATE INDEX ${schema}.SM_IDX_FT_IMPORT_LOG_SUBSYSTEM_CODE ON ${schema}.FT_IMPORT_LOG (SUBSYSTEM_CODE) ONLINE TABLESPACE ${idx_ts}';

        execute immediate ' COMMENT ON TABLE ${schema}.FT_IMPORT_LOG IS '' Таблица логирования импорта ''';
-- Комментарии на поля
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.IMPORT_ID IS '' Идентификатор процесса в рамках которого прогружается сущность ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.PROCESS_DATA IS '' json, с импортируемой сущностью ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.ERROR_TEXT IS '' Ошибка, полученная при импорте сущности ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.PROCESS_STATUS IS '' Статус процесса ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.SUBSYSTEM_CODE IS '' Код системы в канале ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.TENANT_CODE IS '' Код неймспейса ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.START_DATE IS '' Дата запуска процесса ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.END_DATE IS '' Дата завершения процесса ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.ROW_VERSION IS '' Количество изменений ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.LOCKED_FLAG IS '' Признак блокировки ''';
        execute immediate ' COMMENT ON COLUMN ${schema}.FT_IMPORT_LOG.MODIFIED_DATE IS '' Дата последнего изменения ''';
    end if;
end;
/