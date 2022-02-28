-- liquibase formatted sql

/*** Rollback migration data from version 1.0.0 to 1.0.1 ***/
-- changeset petrov7-va:MIGRATION_1_0_0_TO_1_0_1_ROLLBACK#0001 dbms:oracle logicalFilePath:path-independent runOnChange:true splitStatements:true endDelimiter:/
DECLARE
    process_id_val VARCHAR2(64 BYTE):= SYS_GUID();
    process_name_val VARCHAR2(256 BYTE):= 'Data rollback 1.0.1 -> 1.0.0';
    v_code NUMBER;
    v_errm VARCHAR2(256);

    PROCEDURE logMessage(level_val VARCHAR2, msg VARCHAR2) AS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO ${schema}.SM_LOG(PROCESS_ID, PROCESS_NAME, LOG_LEVEL_VALUE, MESSAGE_VALUE)
        VALUES (process_id_val, process_name_val, level_val, msg);
        COMMIT;
    END;

BEGIN
    -- ROLLBACK OPERATION
    SELECT 1 FROM DUAL;
    COMMIT;
    -- Перехватываем исключения
    EXCEPTION
        WHEN OTHERS THEN
            v_code := SQLCODE;
            v_errm := SUBSTR(SQLERRM, 1 , 450);
            logMessage('ERROR', 'Error code ' || v_code || ': ' || v_errm);
            raise_application_error(SQLCODE, SQLERRM);
END ;
/