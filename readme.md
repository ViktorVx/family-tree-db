# Локальтая настройка Docker с PostgreSql

Качаем образ Postgres командой

```shell script
docker pull postgres
```

Затем запускаем контейнер командой

```shell script
docker run -d \
    --name sm_db \
    -e POSTGRES_PASSWORD=postgres \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -p 5432:5432 \
    -v /Users/USER_HOME_FOLDER/Documents/DBs/SM_DB:/var/lib/postgresql/data \
    postgres
```

В параметре -v необходимо указать папку, в которой будут храниться файлы базы данных на локальной машине

Для просмотра списка существующих контейнеров используйте команду

```shell script
docker ps -a
```

Для повторного запуска контейнера необходима команда

```shell script
docker start CONTAINER_ID
```

Установка postgres-клиента psql на macos:

```shell script
brew install libpq 
brew link --force libpq
```

Для запуска psql (postgres/postgres)

```shell script
psql -U postgres -h localhost -p 5432
```

Команды psql

```shell script
\l - получить список баз данных
\h - справка по командам plpg/sql
\? - справка по командам psql
\c DATABASE_NAME - подключение к БД
\dt - показать список таблиц БД
```

Создаем базу данных, схему и табличные пространства (используя файловую систему контейнера)

```shell script
CREATE DATABASE sm_db;
CREATE SCHEMA ufs_stman1;
CREATE TABLESPACE ufs_ts_stman_data LOCATION '';
CREATE TABLESPACE ufs_ts_stman_idx LOCATION '';
CREATE TABLESPACE ufs_ts_stman_lob LOCATION '';
```

# Проливка liquibase-скриптов

Для проливки liquibase-скриптов вводим в командной строке

```shell script
mvn \
    liquibase:update \
    -Dliquibase.url=jdbc:postgresql://localhost:5432/ufs_sm \
    -Dliquibase.username=postgres \
    -Dliquibase.password=postgres \
    -Dliquibase.driver=org.postgresql.Driver \
    -Dliquibase.changelogSchemaName=UFS_SM \
    -Dliquibase.changeLogFile=$PROJECT_DIR$/scripts/0001_changelog.xml \
    -Dschema=UFS_SM
```