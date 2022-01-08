-- ************************************************
-- PART I - 1.1.1 SQL1, SYS USER 사용 - Tablespace 위치 확인
-- ************************************************
SELECT SUBSTRB(TABLESPACE_NAME, 1, 10) AS "테이블스페이스"
    ,SUBSTRB(FILE_NAME, 1, 50) AS "파일명"
    ,TO_CHAR(BLOCKS, '999,999,990') AS "블럭수"
    ,TO_CHAR(BYTES, '99,999,999') AS "크기"
FROM DBA_DATA_FILES
ORDER BY TABLESPACE_NAME, FILE_NAME;

-- ************************************************
-- PART I - 1.1.1 SQL1, SYS USER 사용 - 테이블스페이스 생성
-- ************************************************
CREATE TABLESPACE ORA_SQL_TEST DATAFILE 'D:\app\82103\oradata\orcl\ORA_SQL_TEST_TS.DBA' SIZE 10G
EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO

-- ************************************************
-- PART I - 1.1.2 SQL1, SYS USER 사용 - 사용자 생성
-- ************************************************
CREATE USER ORA_SQL_TEST IDENTIFIED BY "1234" DEFAULT TABLESPACE ORA_SQL_TEST;

-- ************************************************
-- PART I - 1.1.2 SQL2, SYS USER 사용 - 사용자 접속 권한 설정
-- ************************************************
ALTER USER ORA_SQL_TEST ACCOUNT UNLOCK;
GRANT CONNECT, RESOURCE TO ORA_SQL_TEST;

-- ************************************************
-- PART I - 1.1.2 SQL3, SYS USER 사용 - 사용자 성능 뷰 권한 설정
-- ************************************************
-- sys 계정으로 접속해야함, cmd -> sqlplus -> sys /as sysdba -> sys (비번)
-- SELECT * From DBA_USERS where username LIKE 'SYS%';
-- alter user sys identified by sys;
-- ALTER USER sys ACCOUNT UNLOCK;
GRANT ALTER SYSTEM TO ORA_SQL_TEST;
GRANT SELECT ON V_$SQL TO ORA_SQL_TEST;
GRANT SELECT ON V_$SQL_PLAN_STATISTICS_ALL TO ORA_SQL_TEST;
GRANT SELECT ON V_$SQL_PLAN TO ORA_SQL_TEST;
GRANT SELECT ON V_$SESSION TO ORA_SQL_TEST;
GRANT EXECUTE ON DBMS_STATS TO ORA_SQL_TEST;
GRANT SELECT ON DBA_SEGMENTS TO ORA_SQL_TEST;
