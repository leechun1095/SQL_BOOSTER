-- ************************************************
-- PART II - 6.1.1 SQL1
-- ************************************************
-- 테스트를 위한 테이블 만들기
CREATE TABLE T_ORD_BIG AS
SELECT T1.* ,T2.RNO ,TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
  FROM T_ORD T1
     , (SELECT ROWNUM RNO
          FROM DUAL CONNECT BY ROWNUM <= 10000) T2;

-- 아래는 T_ORD_BIG 테이블의 통계를 생성하는 명령어다.
-- 첫 번째 파라미터에는 테이블 OWNER를, 두 번째 파라미터에는 테이블 명을 입력한다.
EXEC DBMS_STATS.GATHER_TABLE_STATS('ORA_SQL_TEST','T_ORD_BIG');

-- ************************************************
-- PART II - 6.1.1 SQL2
-- ************************************************
-- 인덱스가 없는 BIG테이블 조회
SELECT /*+ GATHER_PLAN_STATISTICS */
       COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_SEQ = 343;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('b4zhxqnjf4kvp',0,'ALLSTATS LAST'));
/*
-- 인덱스가 없는 BIG테이블 조회
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------
| Id  | Operation          | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |      1 |        |      1 |00:00:00.92 |     258K|
|   1 |  SORT AGGREGATE    |           |      1 |      1 |      1 |00:00:00.92 |     258K|
|*  2 |   TABLE ACCESS FULL| T_ORD_BIG |      1 |  10000 |  10000 |00:00:00.92 |     258K|
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
   2 - filter("T1"."ORD_SEQ"=343)
*/

-- ************************************************
-- PART II - 6.1.1 SQL3
-- ************************************************
-- ORD_SEQ 컬럼에 인덱스 구성
CREATE INDEX X_T_ORD_BIG_TEST ON T_ORD_BIG(ORD_SEQ);

-- 다시 위 쿼리 조회 후 실제 실행계획 확인
/*
-- 인덱스가 있는 BIG테이블 조회
PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------------------------
| Id  | Operation         | Name             | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |                  |      1 |        |      1 |00:00:00.01 |      24 |     27 |
|   1 |  SORT AGGREGATE   |                  |      1 |      1 |      1 |00:00:00.01 |      24 |     27 |
|*  2 |   INDEX RANGE SCAN| X_T_ORD_BIG_TEST |      1 |  10000 |  10000 |00:00:00.01 |      24 |     27 |
---------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("T1"."ORD_SEQ"=343)
*/

-- ************************************************
-- PART II - 6.1.5 SQL1
-- ************************************************
-- TABLE ACCESS FULL을 사용하는 SQL
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.CUS_ID ,COUNT(*) ORD_CNT
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD = '20170316'
 GROUP BY T1.CUS_ID
 ORDER BY T1.CUS_ID;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('1xz2d7m9hf1dd',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |      1 |        |      5 |00:00:01.37 |     258K|    258K|       |       |          |
|   1 |  SORT GROUP BY     |           |      1 |     90 |      5 |00:00:01.37 |     258K|    258K|  2048 |  2048 | 2048  (0)|
|*  2 |   TABLE ACCESS FULL| T_ORD_BIG |      1 |  87307 |  50000 |00:00:01.44 |     258K|    258K|       |       |          |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("T1"."ORD_YMD"='20170316')
*/

-- ************************************************
-- PART II - 6.1.6 SQL1
-- ************************************************
-- INDEX RANGE SCAN을 사용하는 SQL
CREATE INDEX X_T_ORD_BIG_1 ON T_ORD_BIG(ORD_YMD);

SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_1) */
       T1.CUS_ID ,COUNT(*) ORD_CNT
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD = '20170316'
 GROUP BY T1.CUS_ID
 ORDER BY T1.CUS_ID;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('1xz2d7m9hf1dd',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      5 |00:00:00.37 |   11727 |   3494 |       |       |          |
|   1 |  SORT GROUP BY               |               |      1 |     90 |      5 |00:00:00.37 |   11727 |   3494 |  2048 |  2048 | 2048  (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |  87307 |  50000 |00:00:00.35 |   11727 |   3494 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_1 |      1 |  87307 |  50000 |00:00:00.01 |     142 |    142 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."ORD_YMD"='20170316')
*/

-- ************************************************
-- PART II - 6.1.7 SQL1
-- ************************************************
-- INDEX RANGE SCAN을 사용하는 SQL - 총 3천만건 중 5만건 조회(빠르다)
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.CUS_ID ,COUNT(*) ORD_CNT
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD = '20170316'
 GROUP BY T1.CUS_ID
 ORDER BY T1.CUS_ID;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9v5w3andkwmpv',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      5 |00:00:00.21 |   11727 |    252 |       |       |          |
|   1 |  SORT GROUP BY               |               |      1 |     90 |      5 |00:00:00.21 |   11727 |    252 |  2048 |  2048 | 2048  (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |  87307 |  50000 |00:00:00.22 |   11727 |    252 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_1 |      1 |  87307 |  50000 |00:00:00.01 |     142 |      0 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."ORD_YMD"='20170316')
*/

-- ************************************************
-- PART II - 6.1.7 SQL2
-- ************************************************
-- 3개월간의 주문을 조회(총 3천만건 중 750만건 조회) – ORD_YMD컬럼 인덱스를 사용
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_1) */
       T1.ORD_ST ,SUM(T1.ORD_AMT)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD BETWEEN '20170401' AND '20170630'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('b1z3xbkj909sf',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      2 |00:00:08.23 |    1001K|  98565 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      2 |00:00:08.23 |    1001K|  98565 |   934K|   934K| 3491K (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |   6354K|   7650K|00:00:07.33 |    1001K|  98565 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_1 |      1 |   6354K|   7650K|00:00:01.04 |   21312 |  21359 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."ORD_YMD">='20170401' AND "T1"."ORD_YMD"<='20170630')
*/

-- ************************************************
-- PART II - 6.1.7 SQL3
-- ************************************************
-- 3개월간의 주문을 조회 – FULL(T1) 힌트 사용
SELECT /*+ GATHER_PLAN_STATISTICS FULL(T1) */
       T1.ORD_ST ,SUM(T1.ORD_AMT)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD BETWEEN '20170401' AND '20170630'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('1xz2d7m9hf1dd',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |      1 |        |      2 |00:00:01.36 |     258K|    258K|       |       |          |
|   1 |  HASH GROUP BY     |           |      1 |      2 |      2 |00:00:01.36 |     258K|    258K|   934K|   934K| 3491K (0)|
|*  2 |   TABLE ACCESS FULL| T_ORD_BIG |      1 |   6354K|   7650K|00:00:01.24 |     258K|    258K|       |       |          |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("T1"."ORD_YMD"<='20170630' AND "T1"."ORD_YMD">='20170401'))
*/

-- ************************************************
-- PART II - 6.2.1 SQL1
-- ************************************************
-- 인덱스가 필요한 SQL
SELECT /*+ GATHER_PLAN_STATISTICS */
       TO_CHAR(T1.ORD_DT,'YYYYMM') ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.CUS_ID = 'CUS_0064'
   AND T1.PAY_TP = 'BANK'
   AND T1.RNO = 2
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM');

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |      1 |        |      2 |00:00:01.10 |     258K|    258K|       |       |          |
|   1 |  HASH GROUP BY     |           |      1 |     15 |      2 |00:00:01.10 |     258K|    258K|  1064K|  1064K|  593K (0)|
|*  2 |   TABLE ACCESS FULL| T_ORD_BIG |      1 |     15 |      2 |00:00:00.01 |     258K|    258K|       |       |          |
------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("T1"."RNO"=2 AND "T1"."CUS_ID"='CUS_0064' AND "T1"."PAY_TP"='BANK'))
*/

-- ************************************************
-- PART II - 6.2.1 SQL2
-- ************************************************
-- 효율적인 단일 인덱스 찾기
-- 인덱스 컬럼 선정의 규칙 중 하나는 선택성(Selctivity)이 좋은 컬럼을 사용하는 것이다.
-- 즉 주어진 조건에 해당하는 데이터가 적을수록 선택성이 좋고, 조건에 해당하는 데이터가 많을수록 선택성이 나쁘다.

SELECT  'CUS_ID' COL ,COUNT(*) CNT FROM T_ORD_BIG T1 WHERE T1.CUS_ID = 'CUS_0064'
UNION ALL
SELECT  'PAY_TP' COL ,COUNT(*) CNT FROM T_ORD_BIG T1 WHERE T1.PAY_TP = 'BANK'
UNION ALL
SELECT  'RNO' COL ,COUNT(*) CNT FROM T_ORD_BIG T1 WHERE T1.RNO = 2;
/*
------------------------
| COL	    | CNT        |
------------------------
| CUS_ID	|   340,000건|
| PAY_TP	| 9,150,000건|
| RNO	    |     3,047건|
------------------------
*/

-- ************************************************
-- PART II - 6.2.1 SQL3
-- ************************************************
-- RNO 에 대한 단일 인덱스 생성
CREATE INDEX X_T_ORD_BIG_2 ON T_ORD_BIG(RNO);

-- ************************************************
-- PART II - 6.2.1 SQL4
-- ************************************************
-- RNO에 대한 단일 인덱스 생성 후 SQL수행
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_2) */
       TO_CHAR(T1.ORD_DT,'YYYYMM') ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.CUS_ID = 'CUS_0064'
   AND T1.PAY_TP = 'BANK'
   AND T1.RNO = 2
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM');

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      2 |00:00:00.01 |      35 |      8 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |     15 |      2 |00:00:00.01 |      35 |      8 |  1064K|  1064K|  571K (0)|
|*  2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |     15 |      2 |00:00:00.01 |      35 |      8 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_2 |      1 |   3047 |   3047 |00:00:00.01 |       9 |      8 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("T1"."CUS_ID"='CUS_0064' AND "T1"."PAY_TP"='BANK'))
   3 - access("T1"."RNO"=2)
*/

-- ************************************************
-- PART II - 6.2.1 SQL5
-- ************************************************
-- CUS_ID 에 대한 단일 인덱스 생성
CREATE INDEX X_T_ORD_BIG_3 ON T_ORD_BIG(CUS_ID);

-- ************************************************
-- PART II - 6.2.1 SQL6
-- ************************************************
-- CUS_ID에 대한 단일 인덱스 생성 후 SQL수행
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_3) */
       TO_CHAR(T1.ORD_DT,'YYYYMM') ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.CUS_ID = 'CUS_0064'
   AND T1.PAY_TP = 'BANK'
   AND T1.RNO = 2
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM');

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      2 |00:00:04.12 |     245K|    162K|       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |     15 |      2 |00:00:04.12 |     245K|    162K|  1064K|  1064K|  572K (0)|
|*  2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |     15 |      2 |00:00:00.01 |     245K|    162K|       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_3 |      1 |    338K|    340K|00:00:00.09 |     950 |    950 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("T1"."RNO"=2 AND "T1"."PAY_TP"='BANK'))
   3 - access("T1"."CUS_ID"='CUS_0064')
*/

-- ************************************************
-- PART II - 6.2.2 SQL1
-- ************************************************
-- CUS_ID 에 대한 단일 인덱스 제거
DROP INDEX X_T_ORD_BIG_3;

-- ************************************************
-- PART II - 6.2.2 SQL2
-- ************************************************
-- 2개의 조건이 사용된 SQL – ORD_YMD인덱스를 사용
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_1) */
       T1.ORD_ST, COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = 'CUS_0075'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:01.14 |     338K|   6123 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      1 |00:00:01.14 |     338K|   6123 |  1096K|  1096K|  448K (0)|
|*  2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |   2081 |  30000 |00:00:00.28 |     338K|   6123 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_1 |      1 |    187K|   1850K|00:00:00.59 |    5156 |   5013 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("T1"."CUS_ID"='CUS_0075')
   3 - access("T1"."ORD_YMD" LIKE '201703%')
       filter("T1"."ORD_YMD" LIKE '201703%')
*/

-- ************************************************
-- PART II - 6.2.2 SQL3
-- ************************************************
-- ORD_YMD, CUS_ID순으로 복합 인덱스를 생성
CREATE INDEX X_T_ORD_BIG_3 ON T_ORD_BIG(ORD_YMD, CUS_ID);

-- ************************************************
-- PART II - 6.2.2 SQL4
-- ************************************************
-- ORD_YMD, CUS_ID 복합 인덱스를 사용하도록 SQL을 수행
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_3) */
       T1.ORD_ST ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = 'CUS_0075'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:02.99 |   37494 |  27494 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      1 |00:00:02.99 |   37494 |  27494 |  1096K|  1096K|  468K (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |   2081 |  30000 |00:00:02.68 |   37494 |  27494 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_3 |      1 |   2081 |  30000 |00:00:00.10 |    7494 |   7494 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."ORD_YMD" LIKE '201703%' AND "T1"."CUS_ID"='CUS_0075')
       filter(("T1"."CUS_ID"='CUS_0075' AND "T1"."ORD_YMD" LIKE '201703%'))
*/

-- ************************************************
-- PART II - 6.3.1 SQL2
-- ************************************************
-- CUS_ID, ORD_YMD로 구성된 인덱스
CREATE INDEX X_T_ORD_BIG_4 ON T_ORD_BIG(CUS_ID, ORD_YMD);

-- ************************************************
-- PART II - 6.3.1 SQL3
-- ************************************************
-- CUS_ID, ORD_YMD인덱스를 사용하는 SQL
-- WHERE절의 조건 순서가 중요한게 아니라, INDEX를 구성하는 컬럼순서가 중요하다.
-- 즉 INDEX 구성하는 컬럼순서만 올바르면, WHERE절에 LIKE가 선두로 와도 무관함.

SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_4) */
       T1.ORD_ST ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = 'CUS_0075'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:02.64 |   30125 |  20125 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      1 |00:00:02.64 |   30125 |  20125 |  1096K|  1096K|  468K (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |   2081 |  30000 |00:00:02.63 |   30125 |  20125 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_4 |      1 |   2081 |  30000 |00:00:00.03 |     125 |    125 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."CUS_ID"='CUS_0075' AND "T1"."ORD_YMD" LIKE '201703%')
       filter("T1"."ORD_YMD" LIKE '201703%')
*/

-- ************************************************
-- PART II - 6.3.2 SQL1
-- ************************************************
-- ORD_YMD가 같다(=)조건으로 CUS_ID가 LIKE조건으로 사용하는 SQL
-- ORD_YMD가 선두 컬럼인 T1 X_T_ORD_BIG_3
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_3) */
       T1.ORD_ST, COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD = '20170301'
   AND T1.CUS_ID LIKE 'CUS_001%'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('28rt220r7kung',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:01.78 |   10206 |  10206 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      1 |00:00:01.78 |   10206 |  10206 |  1096K|  1096K|  712K (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |  86337 |  10000 |00:00:01.82 |   10206 |  10206 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_3 |      1 |  86337 |  10000 |00:00:00.02 |     206 |    206 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."ORD_YMD"='20170301' AND "T1"."CUS_ID" LIKE 'CUS_001%')
       filter("T1"."CUS_ID" LIKE 'CUS_001%')
*/
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

-- CUS_ID가 선두 컬럼인 T1 X_T_ORD_BIG_4
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_4) */
       T1.ORD_ST, COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD = '20170301'
   AND T1.CUS_ID LIKE 'CUS_001%'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:06.89 |     133K|    133K|       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      1 |00:00:06.89 |     133K|    133K|  1096K|  1096K|  727K (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |  86337 |  10000 |00:00:01.12 |     133K|    133K|       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_4 |      1 |  86337 |  10000 |00:00:00.69 |     123K|    123K|       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."CUS_ID" LIKE 'CUS_001%' AND "T1"."ORD_YMD"='20170301')
       filter(("T1"."ORD_YMD"='20170301' AND "T1"."CUS_ID" LIKE 'CUS_001%'))
*/

-- ************************************************
-- PART II - 6.3.3 SQL1
-- ************************************************
-- 세 개의 조건이 사용된 SQL

-- 최적의 인덱스 구성 방법 (아래 쿼리는 성능개선을 위해 1, 2번 인덱스를 사용해도 둘다 괜찮다.)
-- 1번 : CUS_ID, PAY_TY, ORD_YMD
-- 2번 : PAY_TY, CUS_ID, ORD_YMD
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ORD_ST ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD LIKE '201704%'
   AND T1.CUS_ID = 'CUS_0042'
   AND T1.PAY_TP = 'BANK'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));

-- ************************************************
-- PART II - 6.3.3 SQL2
-- ************************************************
-- 특정 고객ID에 주문이 존재하는지 확인하는 SQL
-- 최적의 인덱스 구성 방법 (아래 쿼리 쿼리까지 같이 사용해야 한다면 더 좋은 성능개선을 위해 1번 인덱스를 사용하는 것이 좋다.
-- 1번 : CUS_ID, PAY_TY, ORD_YMD
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;
SELECT 'X'
  FROM DUAL A
 WHERE EXISTS(
        SELECT *
          FROM T_ORD_BIG T1
         WHERE T1.CUS_ID = 'CUS_0042'
       );

-- ************************************************
-- PART II - 6.3.4 SQL1
-- ************************************************
-- 많은 조건(5개)이 걸리는 SQL
-- 이러한 경우 컬럼 5개 모두 INDEX로 구성하면 빠르지만, 인덱스를 구성하는 컬럼이 너무 많아진다.
-- 성능향상에 도움이 되는 조건 컬럼만 선별하여 인덱스를 만들 필요가 있다.
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS */
       COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_AMT = 2400
   AND T1.PAY_TP = 'CARD'
   AND T1.ORD_YMD = '20170406'
   AND T1.ORD_ST = 'COMP'
   AND T1.CUS_ID = 'CUS_0036';

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));


-- ************************************************
-- PART II - 6.3.4 SQL2
-- ************************************************
-- 각 조건별로 카운트 해보기
SELECT 'ORD_AMT' COL ,COUNT(*) FROM T_ORD_BIG T1 WHERE T1.ORD_AMT = 2400
 UNION ALL
SELECT 'PAY_TP' COL ,COUNT(*) FROM T_ORD_BIG T1 WHERE T1.PAY_TP = 'CARD'
 UNION ALL
SELECT 'ORD_YMD' COL ,COUNT(*) FROM T_ORD_BIG T1 WHERE T1.ORD_YMD = '20170406'
 UNION ALL
SELECT 'ORD_ST' COL ,COUNT(*) FROM T_ORD_BIG T1 WHERE T1.ORD_ST = 'COMP'
 UNION ALL
SELECT 'CUS_ID' COL ,COUNT(*)  FROM T_ORD_BIG T1 WHERE T1.CUS_ID = 'CUS_0036';
/*
------------------------
| COL	    |  COUNT(*)  |
------------------------
| ORD_AMT	|    630,000 |
| PAY_TP	| 18,270,000 |
| ORD_YMD	|     90,000 |
| ORD_ST	| 27,420,000 |
| CUS_ID	|    330,000 |
------------------------
| TOTAL   | 30,470,000 |
------------------------
*/

/* X_T_ORD_BIG_3(ORD_YMD, CUS_ID) 인덱스가 자동으로 선택된다.
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:00.41 |   10045 |  11374 |
|   1 |  SORT AGGREGATE              |               |      1 |      1 |      1 |00:00:00.41 |   10045 |  11374 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |     22 |  10000 |00:00:00.66 |   10045 |  11374 |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_3 |      1 |  10000 |  10000 |00:00:00.01 |      45 |     51 |
-----------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("T1"."ORD_AMT"=2400 AND "T1"."PAY_TP"='CARD' AND "T1"."ORD_ST"='COMP'))
   3 - access("T1"."ORD_YMD"='20170406' AND "T1"."CUS_ID"='CUS_0036')
*/

-- ************************************************
-- PART II - 6.4.1 SQL1
-- ************************************************
-- CUS_ID, ORD_YMD인덱스를 사용하는 SQL
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_T_ORD_BIG_4) */
       T1.ORD_ST ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = 'CUS_0075'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('9uyc4c83yv4j1',0,'ALLSTATS LAST'));

/*
PLAN_TABLE_OUTPUT (X_T_ORD_BIG_4 인덱스 : CUS_ID, ORD_YMD)
--------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |      1 |        |      1 |00:00:00.74 |   30125 |  21529 |       |       |          |
|   1 |  HASH GROUP BY               |               |      1 |      2 |      1 |00:00:00.74 |   30125 |  21529 |  1096K|  1096K|  442K (0)|
|   2 |   TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |   2081 |  30000 |00:00:00.74 |   30125 |  21529 |       |       |          |
|*  3 |    INDEX RANGE SCAN          | X_T_ORD_BIG_4 |      1 |   2081 |  30000 |00:00:00.03 |     125 |    152 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."CUS_ID"='CUS_0075' AND "T1"."ORD_YMD" LIKE '201703%')
       filter("T1"."ORD_YMD" LIKE '201703%')
*/

-- ************************************************
-- PART II - 6.4.1 SQL2
-- ************************************************
-- X_T_ORD_BIG_4인덱스의 재생성
DROP INDEX X_T_ORD_BIG_4;
CREATE INDEX X_T_ORD_BIG_4 ON T_ORD_BIG(CUS_ID, ORD_YMD, ORD_ST);

/* 커버드 INDEX 실행계획
PLAN_TABLE_OUTPUT (X_T_ORD_BIG_4 인덱스 : CUS_ID, ORD_YMD, ORD_ST)
---------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation         | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |               |      1 |        |      1 |00:00:00.02 |     146 |    169 |       |       |          |
|   1 |  HASH GROUP BY    |               |      1 |      2 |      1 |00:00:00.02 |     146 |    169 |  1096K|  1096K|  472K (0)|
|*  2 |   INDEX RANGE SCAN| X_T_ORD_BIG_4 |      1 |   2081 |  30000 |00:00:00.01 |     146 |    169 |       |       |          |
---------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."CUS_ID"='CUS_0075' AND "T1"."ORD_YMD" LIKE '201703%')
       filter("T1"."ORD_YMD" LIKE '201703%')
*/

-- ************************************************
-- PART II - 6.4.2 SQL1
-- ************************************************
-- CUS_0075의 201703주문을 조회하는 SQL
-- ORD_YMD 컬럼을 변형하여 access 조건이 아닌 필터조건으로 실행되었음을 확인 가능하다.
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ORD_ST ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE SUBSTR(T1.ORD_YMD,1,6) = '201703'
   AND T1.CUS_ID = 'CUS_0075'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('5zs48c63hfrzw',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT (X_T_ORD_BIG_4 인덱스 : CUS_ID, ORD_YMD, ORD_ST)
---------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation         | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |               |      1 |        |      1 |00:00:00.07 |    1616 |   1641 |       |       |          |
|   1 |  HASH GROUP BY    |               |      1 |      2 |      1 |00:00:00.07 |    1616 |   1641 |  1096K|  1096K|  453K (0)|
|*  2 |   INDEX RANGE SCAN| X_T_ORD_BIG_4 |      1 |   3386 |  30000 |00:00:00.02 |    1616 |   1641 |       |       |          |
---------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."CUS_ID"='CUS_0075')
       filter(SUBSTR("T1"."ORD_YMD",1,6)='201703')
*/

-- ************************************************
-- PART II - 6.4.2 SQL2
-- ************************************************
-- CUS_0075의 201703주문을 조회하는 SQL – LIKE로 처리
-- ORD_YMD 컬럼을 변형하지 않고, LIKE로 범위 처리하여 access 조건으로 실행하였다.(성능 개선됨)
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ORD_ST ,COUNT(*)
  FROM T_ORD_BIG T1
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = 'CUS_0075'
 GROUP BY T1.ORD_ST;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('2c1rjnnd119z9',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT (X_T_ORD_BIG_4 인덱스 : CUS_ID, ORD_YMD, ORD_ST)
---------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation         | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |               |      1 |        |      1 |00:00:00.01 |     146 |    169 |       |       |          |
|   1 |  HASH GROUP BY    |               |      1 |      2 |      1 |00:00:00.01 |     146 |    169 |  1096K|  1096K|  453K (0)|
|*  2 |   INDEX RANGE SCAN| X_T_ORD_BIG_4 |      1 |   2081 |  30000 |00:00:00.01 |     146 |    169 |       |       |          |
---------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."CUS_ID"='CUS_0075' AND "T1"."ORD_YMD" LIKE '201703%')
       filter("T1"."ORD_YMD" LIKE '201703%')
*/

-- ************************************************
-- PART II - 6.4.3 SQL1
-- ************************************************
-- 테이블 및 인덱스 크기 확인
SELECT T1.SEGMENT_NAME
     , T1.SEGMENT_TYPE
     , T1.BYTES / 1024 / 1024 as SIZE_MB
     , T1.BYTES / T2.CNT BYTE_PER_ROW
  FROM DBA_SEGMENTS T1
     , (SELECT COUNT(*) CNT
          FROM ORA_SQL_TEST.T_ORD_BIG
       ) T2
 WHERE T1.SEGMENT_NAME LIKE '%ORD_BIG%'
 ORDER BY T1.SEGMENT_NAME;
/*
----------------------------------------------------------------
| SEGMENT_NAME	    | SEGMENT_TYPE	| SIZE_MB	  | BYTE_PER_ROW |
----------------------------------------------------------------
| T_ORD_BIG	        | TABLE	        |   2048	  |     70.48    |
| X_T_ORD_BIG_1	    | INDEX	        |    672	  |     23.13    |
| X_T_ORD_BIG_2	    | INDEX	        |    504	  |     17.34    |
| X_T_ORD_BIG_3	    | INDEX	        |    974	  |     33.52    |
| X_T_ORD_BIG_4	    | INDEX	        |   1152	  |     39.64    |
| X_T_ORD_BIG_TEST	| INDEX	        |    504	  |     17.34    |
----------------------------------------------------------------
*/
