-- liquibase formatted sql

-- Удаление таблицы истории импорта
-- changeset petrov-va:FT_IMPORT_LOG#postgesql dbms:postgesql logicalFilePath:path-independent runOnChange:true splitStatements:true endDelimiter:/
DROP TABLE IF EXISTS ${schema}.FT_IMPORT_LOG;
/
