-- liquibase formatted sql

-- Удаление таблицы истории импорта
-- changeset petrov-va:FT_IMPORT_LOG#oracle dbms:oracle logicalFilePath:path-independent runOnChange:true splitStatements:true endDelimiter:/
DECLARE
    tableExists integer := 0;
BEGIN
    SELECT COUNT(*) INTO tableExists FROM DBA_TABLES WHERE TABLE_NAME = 'FT_IMPORT_LOG' AND OWNER = '${schema}';
    IF tableExists = 1 THEN
        EXECUTE IMMEDIATE
            'DROP TABLE ${schema}.FT_IMPORT_LOG';
    END IF;
END;
/
