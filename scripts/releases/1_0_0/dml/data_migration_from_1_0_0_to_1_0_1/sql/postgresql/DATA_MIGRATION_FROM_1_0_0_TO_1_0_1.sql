-- liquibase formatted sql

/*** Migrate data from version 1.0.0 to 1.0.1 ***/
-- changeset petrov7-va:MIGRATION_1_0_0_TO_1_0_1#0001 dbms:postgresql logicalFilePath:path-independent runOnChange:true runInTransaction:false splitStatements:true endDelimiter:/

DO $$
    BEGIN
        CREATE TYPE pg_temp.log_row AS (process_id varchar(36), process_name VARCHAR(128), log_level_value VARCHAR(32), message_value varchar(512));
    EXCEPTION
        WHEN duplicate_object THEN null;
    END;
    $$;

CREATE OR REPLACE PROCEDURE pg_temp.logMessage(level_val VARCHAR, msg VARCHAR, INOUT log_array_val pg_temp.log_row[]) LANGUAGE plpgsql AS $$
DECLARE
    process_name_val VARCHAR(256):= 'Data migration 1.0.0 -> 1.0.1';
    proc_uuid VARCHAR;
BEGIN
    select random()::text into proc_uuid;
    select array_append(log_array_val, ROW(proc_uuid, process_name_val, level_val, msg)::pg_temp.log_row) into log_array_val;
END;
$$;

CREATE OR REPLACE PROCEDURE pg_temp.persistLogs(log_array_val pg_temp.log_row[]) LANGUAGE plpgsql AS $$
DECLARE
    l pg_temp.log_row;
BEGIN
    FOREACH l in ARRAY log_array_val LOOP
            INSERT INTO ${schema}.sm_log(process_id, process_name, log_level_value, message_value)
            select l.process_id, l.process_name, l.log_level_value, l.message_value;
        END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE pg_temp.migrateData(INOUT log_array pg_temp.log_row[]) LANGUAGE plpgsql AS $$
    DECLARE
        exists_uo        NUMERIC := 0;
    BEGIN
        SELECT 1;
    END;
    $$;

DO $$
    DECLARE
        migrate_row_number NUMERIC:=0;
        log_array pg_temp.log_row[];
    BEGIN
        -- Проверяем, что миграция еще не выполнялась
        SELECT sum(st.rn) INTO migrate_row_number FROM (
              SELECT count(*) rn FROM ${schema}.FT_NAMESPACE UNION ALL
              SELECT count(*) rn FROM ${schema}.FT_LOG
          ) as st;
        IF (migrate_row_number = 0) THEN
            ------------------------------------------------------------------------------------------------------------
            CALL pg_temp.logMessage('INFO', 'Data migration started', log_array);
            CALL pg_temp.migrateData();
            CALL pg_temp.logMessage('INFO', 'Data migration complete', log_array);
            ------------------------------------------------------------------------------------------------------------
        ELSE
            CALL pg_temp.logMessage('WARN', 'Новые таблицы 1.0.1 уже заполнены данными. Миграция не осуществлена',
                log_array);
        END IF;
        CALL pg_temp.persistLogs(log_array);
    EXCEPTION
        WHEN others THEN
            CALL pg_temp.logMessage('ERROR', SQLERRM, log_array);
            CALL pg_temp.persistLogs(log_array);
            COMMIT;
            RAISE;
    END;
    $$;
/