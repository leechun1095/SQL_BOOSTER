-- ************************************************
-- PART II - 7.1.2 SQL1
-- ************************************************
-- NL 조인 SQL
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) */
		   T1.RGN_ID ,T1.CUS_ID ,T1.CUS_NM
		 , T2.ORD_DT ,T2.ORD_ST ,T2.ORD_AMT
  FROM M_CUS T1
		 , T_ORD T2
 WHERE T1.CUS_ID = T2.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) */
		   T1.RGN_ID
     , T1.CUS_ID
     , T1.CUS_NM
		 , T2.ORD_DT
     , T2.ORD_ST
     , T2.ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD T2
    ON T1.CUS_ID = T2.CUS_ID;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('2c1rjnnd119z9',0,'ALLSTATS LAST'));

/*
PLAN_TABLE_OUTPUT (HASH 조인)
-----------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |    101 |00:00:00.01 |      12 |       |       |          |
|*  1 |  HASH JOIN         |       |      1 |   3082 |    101 |00:00:00.01 |      12 |   990K|   990K| 1275K (0)|
|   2 |   TABLE ACCESS FULL| M_CUS |      1 |     90 |     90 |00:00:00.01 |       7 |       |       |          |
|   3 |   TABLE ACCESS FULL| T_ORD |      1 |   3047 |    101 |00:00:00.01 |       5 |       |       |          |
-----------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("T1"."CUS_ID"="T2"."CUS_ID")


PLAN_TABLE_OUTPUT (NL조인)
-----------------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |    101 |00:00:00.01 |      72 |     15 |
|   1 |  NESTED LOOPS      |       |      1 |   3082 |    101 |00:00:00.01 |      72 |     15 |
|   2 |   TABLE ACCESS FULL| M_CUS |      1 |     90 |      3 |00:00:00.01 |       4 |      0 |
|*  3 |   TABLE ACCESS FULL| T_ORD |      3 |     34 |    101 |00:00:00.01 |      68 |     15 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("T1"."CUS_ID"="T2"."CUS_ID")

PLAN_TABLE_OUTPUT (NL조인 스크롤 끝까지 내린 경우)
-- M_CUS 고객은 90명이다. 따라서 T_ORD에 90번 접근한다. (= 3번 단계에서 starts = 90과 동일한 의미)
--------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |   3047 |00:00:00.01 |    2139 |
|   1 |  NESTED LOOPS      |       |      1 |   3082 |   3047 |00:00:00.01 |    2139 |
|   2 |   TABLE ACCESS FULL| M_CUS |      1 |     90 |     90 |00:00:00.01 |      38 |
|*  3 |   TABLE ACCESS FULL| T_ORD |     90 |     34 |   3047 |00:00:00.01 |    2101 |
--------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.1.3 SQL1
-- ************************************************
-- M_CUS과 T_ORD의 머지 조인
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) */
       T1.RGN_ID ,T1.CUS_ID ,T1.CUS_NM
     , T2.ORD_DT ,T2.ORD_ST ,T2.ORD_AMT
  FROM M_CUS T1
		 , T_ORD T2
 WHERE T1.CUS_ID = T2.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) */
       T1.RGN_ID
     , T1.CUS_ID
     , T1.CUS_NM
     , T2.ORD_DT
     , T2.ORD_ST
     , T2.ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD T2
    ON T1.CUS_ID = T2.CUS_ID;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('2c1rjnnd119z9',0,'ALLSTATS LAST'));

/*
PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |          |      1 |        |    101 |00:00:00.01 |      27 |     30 |       |       |          |
|   1 |  MERGE JOIN                  |          |      1 |   3082 |    101 |00:00:00.01 |      27 |     30 |       |       |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| M_CUS    |      1 |     90 |      3 |00:00:00.01 |       4 |      9 |       |       |          |
|   3 |    INDEX FULL SCAN           | PK_M_CUS |      1 |     90 |      3 |00:00:00.01 |       2 |      1 |       |       |          |
|*  4 |   SORT JOIN                  |          |      3 |   3047 |    101 |00:00:00.01 |      23 |     21 |   178K|   178K|  158K (0)|
|   5 |    TABLE ACCESS FULL         | T_ORD    |      1 |   3047 |   3047 |00:00:00.01 |      23 |     21 |       |       |          |
---------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |          |      1 |        |    101 |00:00:00.01 |    1605 |     42 |       |       |          |
|   1 |  MERGE JOIN                   |          |      1 |   3082 |    101 |00:00:00.01 |    1605 |     42 |       |       |          |
|   2 |   TABLE ACCESS BY INDEX ROWID | M_CUS    |      1 |     90 |      3 |00:00:00.01 |       4 |      2 |       |       |          |
|   3 |    INDEX FULL SCAN            | PK_M_CUS |      1 |     90 |      3 |00:00:00.01 |       2 |      1 |       |       |          |
|*  4 |   SORT JOIN                   |          |      3 |   3047 |    101 |00:00:00.01 |    1601 |     40 |   160K|   160K|  142K (0)|
|   5 |    TABLE ACCESS BY INDEX ROWID| T_ORD    |      1 |   3047 |   3047 |00:00:00.01 |    1601 |     40 |       |       |          |
|   6 |     INDEX FULL SCAN           | X_T_ORD  |      1 |   3047 |   3047 |00:00:00.01 |      10 |     16 |       |       |          |
----------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")

*/

-- ************************************************
-- PART II - 7.1.4 SQL1
-- ************************************************
-- M_CUS과 T_ORD의 해시 조인
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_HASH(T2) */
		   T1.RGN_ID ,T1.CUS_ID ,T1.CUS_NM
		 , T2.ORD_DT ,T2.ORD_ST ,T2.ORD_AMT
  FROM M_CUS T1
		 , T_ORD T2
 WHERE T1.CUS_ID = T2.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_HASH(T2) */
       T1.RGN_ID
     , T1.CUS_ID
     , T1.CUS_NM
     , T2.ORD_DT
     , T2.ORD_ST
     , T2.ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD T2
    ON T1.CUS_ID = T2.CUS_ID;

/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |    101 |00:00:00.01 |      12 |     12 |       |       |          |
|*  1 |  HASH JOIN         |       |      1 |   3082 |    101 |00:00:00.01 |      12 |     12 |   990K|   990K| 1226K (0)|
|   2 |   TABLE ACCESS FULL| M_CUS |      1 |     90 |     90 |00:00:00.01 |       7 |      6 |       |       |          |
|   3 |   TABLE ACCESS FULL| T_ORD |      1 |   3047 |    101 |00:00:00.01 |       5 |      6 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.2.1 SQL1
-- ************************************************
-- T_ORD_JOIN 테이블을 만드는 SQL
CREATE TABLE T_ORD_JOIN AS
SELECT ROW_NUMBER() OVER(ORDER BY T1.ORD_SEQ, T2.ORD_DET_NO, T3.RNO) ORD_SEQ
     , T1.CUS_ID ,T1.ORD_DT ,T1.ORD_ST ,T1.PAY_TP
     , T2.ITM_ID ,T2.ORD_QTY ,T2.UNT_PRC ,TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
  FROM T_ORD T1
		 , T_ORD_DET T2
		 , (SELECT ROWNUM RNO
		      FROM DUAL CONNECT BY ROWNUM <= 1000
		   ) T3
 WHERE T1.ORD_SEQ = T2.ORD_SEQ;

ALTER TABLE T_ORD_JOIN ADD CONSTRAINT PK_T_ORD_JOIN PRIMARY KEY(ORD_SEQ) USING INDEX;
EXEC DBMS_STATS.GATHER_TABLE_STATS('ORA_SQL_TEST','T_ORD_JOIN');

-- ************************************************
-- PART II - 7.2.2 SQL1
-- ************************************************
-- 특정 고객의 특정 일자 주문
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.CUS_ID  ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
		 , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

/*
PLAN_TABLE_OUTPUT (T_ORD_JOIN 테이블의 index가 없어서 full scan 하는 비효율적인 부분이 보인다. )
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |            |      1 |        |      1 |00:00:00.08 |   26468 |     77 |
|   1 |  SORT GROUP BY NOSORT         |            |      1 |      1 |      1 |00:00:00.08 |   26468 |     77 |
|   2 |   NESTED LOOPS                |            |      1 |    105 |   2000 |00:00:00.01 |   26468 |     77 |
|   3 |    TABLE ACCESS BY INDEX ROWID| M_CUS      |      1 |      1 |      1 |00:00:00.01 |       2 |      1 |
|*  4 |     INDEX UNIQUE SCAN         | PK_M_CUS   |      1 |      1 |      1 |00:00:00.01 |       1 |      1 |
|*  5 |    TABLE ACCESS FULL          | T_ORD_JOIN |      1 |    105 |   2000 |00:00:00.01 |   26466 |     76 |
---------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."CUS_ID"='CUS_0009')
   5 - filter(("T2"."ORD_YMD"='20170218' AND "T2"."CUS_ID"='CUS_0009'))
*/

-- ************************************************
-- PART II - 7.2.2 SQL2
-- ************************************************
-- 특정 고객의 특정일자 주문 – T_ORD_JOIN(CUS_ID)인덱스 사용
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

CREATE INDEX X_T_ORD_JOIN_1 ON T_ORD_JOIN(CUS_ID);

SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_1) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
		 , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
		 , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_1) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

/*
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
-------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                |      1 |        |      1 |00:00:00.02 |     646 |    160 |
|   1 |  SORT GROUP BY NOSORT         |                |      1 |      1 |      1 |00:00:00.02 |     646 |    160 |
|   2 |   NESTED LOOPS                |                |      1 |    105 |   2000 |00:00:00.01 |     646 |    160 |
|   3 |    TABLE ACCESS BY INDEX ROWID| M_CUS          |      1 |      1 |      1 |00:00:00.01 |       2 |      0 |
|*  4 |     INDEX UNIQUE SCAN         | PK_M_CUS       |      1 |      1 |      1 |00:00:00.01 |       1 |      0 |
|*  5 |    TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |      1 |    105 |   2000 |00:00:00.01 |     644 |    160 |
|*  6 |     INDEX RANGE SCAN          | X_T_ORD_JOIN_1 |      1 |  35822 |  55000 |00:00:00.05 |     156 |    160 |
-------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."CUS_ID"='CUS_0009')
   5 - filter("T2"."ORD_YMD"='20170218')
   6 - access("T2"."CUS_ID"='CUS_0009')

*/

-- ************************************************
-- PART II - 7.2.2 SQL3
-- ************************************************
--버퍼캐시 비우기
ALTER SYSTEM FLUSH BUFFER_CACHE;

-- 특정 고객의 특정일자 주문 – T_ORD_JOIN(CUS_ID,ORD_YMD)인덱스 사용
CREATE INDEX X_T_ORD_JOIN_2 ON T_ORD_JOIN(CUS_ID, ORD_YMD);

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

/*
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
-------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                |      1 |        |      1 |00:00:00.01 |      29 |     20 |
|   1 |  SORT GROUP BY NOSORT         |                |      1 |      1 |      1 |00:00:00.01 |      29 |     20 |
|   2 |   NESTED LOOPS                |                |      1 |   1243 |   2000 |00:00:00.01 |      29 |     20 |
|   3 |    TABLE ACCESS BY INDEX ROWID| M_CUS          |      1 |      1 |      1 |00:00:00.01 |       2 |      9 |
|*  4 |     INDEX UNIQUE SCAN         | PK_M_CUS       |      1 |      1 |      1 |00:00:00.01 |       1 |      1 |
|   5 |    TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |      1 |   1243 |   2000 |00:00:00.01 |      27 |     11 |
|*  6 |     INDEX RANGE SCAN          | X_T_ORD_JOIN_2 |      1 |   1243 |   2000 |00:00:00.01 |      11 |     11 |
-------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."CUS_ID"='CUS_0009')
   6 - access("T2"."CUS_ID"='CUS_0009' AND "T2"."ORD_YMD"='20170218')
*/

-- ************************************************
-- PART II - 7.2.3 SQL1
-- ************************************************
-- 특정 고객의 특정일자 주문 – T_ORD_JOIN을 선행 집합으로 사용
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
	   , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T1.CUS_ID = 'CUS_0009'
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      1 |00:00:00.01 |    2031 |     58 |
|   1 |  SORT GROUP BY NOSORT          |                |      1 |      1 |      1 |00:00:00.01 |    2031 |     58 |
|   2 |   NESTED LOOPS                 |                |      1 |        |   2000 |00:00:00.01 |    2031 |     58 |
|   3 |    NESTED LOOPS                |                |      1 |   1243 |   2000 |00:00:00.01 |      31 |     50 |
|   4 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |      1 |   1243 |   2000 |00:00:00.01 |      27 |     49 |
|*  5 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_2 |      1 |   1243 |   2000 |00:00:00.01 |      11 |     25 |
|*  6 |     INDEX UNIQUE SCAN          | PK_M_CUS       |   2000 |      1 |   2000 |00:00:00.01 |       4 |      1 |
|   7 |    TABLE ACCESS BY INDEX ROWID | M_CUS          |   2000 |      1 |   2000 |00:00:00.01 |    2000 |      8 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("T2"."CUS_ID"='CUS_0009' AND "T2"."ORD_YMD"='20170218')
   6 - access("T1"."CUS_ID"='CUS_0009')
*/

-- ************************************************
-- PART II - 7.2.3 SQL2
-- ************************************************
-- 특정 고객의 특정일자 주문 – T_ORD_JOIN을 선행 집합으로 사용 – SQL 자동 변형
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
	   , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_ID = 'CUS_0009'
   AND T2.CUS_ID = 'CUS_0009' -- 자동 추가된 조건
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T1.CUS_ID = 'CUS_0009'
   AND T2.CUS_ID = 'CUS_0009' -- 자동 추가된 조건
   AND T2.ORD_YMD = '20170218'
 GROUP BY T1.CUS_ID;

/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      1 |00:00:00.01 |    2031 |
|   1 |  SORT GROUP BY NOSORT          |                |      1 |      1 |      1 |00:00:00.01 |    2031 |
|   2 |   NESTED LOOPS                 |                |      1 |        |   2000 |00:00:00.01 |    2031 |
|   3 |    NESTED LOOPS                |                |      1 |     14 |   2000 |00:00:00.01 |      31 |
|   4 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |      1 |   1243 |   2000 |00:00:00.01 |      27 |
|*  5 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_2 |      1 |   1243 |   2000 |00:00:00.01 |      11 |
|*  6 |     INDEX UNIQUE SCAN          | PK_M_CUS       |   2000 |      1 |   2000 |00:00:00.01 |       4 |
|   7 |    TABLE ACCESS BY INDEX ROWID | M_CUS          |   2000 |      1 |   2000 |00:00:00.01 |    2000 |
-----------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("T2"."CUS_ID"='CUS_0009' AND "T2"."ORD_YMD"='20170218')
   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"='CUS_0009')
*/

-- ************************************************
-- PART II - 7.2.4 SQL1
-- ************************************************
-- CUS_GD가 A, ORD_YMD가 20170218인 주문 조회 – T_ORD_JOIN이 선행 집합
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
		 , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD = '20170218'
   AND T1.CUS_GD = 'A'
 GROUP BY T1.CUS_ID;

-- ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD = '20170218'
   AND T1.CUS_GD = 'A'
 GROUP BY T1.CUS_ID;

/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      6 |00:00:00.02 |   12389 |    567 |
|   1 |  SORT GROUP BY NOSORT          |                |      1 |     60 |      6 |00:00:00.02 |   12389 |    567 |
|   2 |   NESTED LOOPS                 |                |      1 |        |   9000 |00:00:00.04 |   12389 |    567 |
|   3 |    NESTED LOOPS                |                |      1 |   6303 |  12000 |00:00:00.03 |     389 |    559 |
|   4 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |      1 |   9455 |  12000 |00:00:00.03 |     384 |    558 |
|*  5 |      INDEX SKIP SCAN           | X_T_ORD_JOIN_2 |      1 |   9455 |  12000 |00:00:00.03 |     285 |    454 |
|*  6 |     INDEX UNIQUE SCAN          | PK_M_CUS       |  12000 |      1 |  12000 |00:00:00.01 |       5 |      1 |
|*  7 |    TABLE ACCESS BY INDEX ROWID | M_CUS          |  12000 |      1 |   9000 |00:00:00.01 |   12000 |      8 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("T2"."ORD_YMD"='20170218')
       filter("T2"."ORD_YMD"='20170218')
   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
   7 - filter("T1"."CUS_GD"='A')
*/

-- ************************************************
-- PART II - 7.2.4 SQL2
-- ************************************************
-- 조회 조건 각가의 데이터 건수
SELECT COUNT(*) FROM M_CUS T1 WHERE T1.CUS_GD = 'A'; -- 60건

SELECT COUNT(*) FROM T_ORD_JOIN T2 WHERE T2.ORD_YMD = '20170218'; -- 12,000건

-- ************************************************
-- PART II - 7.2.4 SQL3
-- ************************************************
-- CUS_GD가 A, ORD_YMD가 20170218인 주문 조회 – M_CUS을 선행 집합으로 처리
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
		 , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD = '20170218'
   AND T1.CUS_GD = 'A'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD = '20170218'
   AND T1.CUS_GD = 'A'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      6 |00:00:00.02 |     240 |    320 |
|   1 |  SORT GROUP BY NOSORT          |                |      1 |     60 |      6 |00:00:00.02 |     240 |    320 |
|   2 |   NESTED LOOPS                 |                |      1 |        |   9000 |00:00:00.02 |     240 |    320 |
|   3 |    NESTED LOOPS                |                |      1 |   6303 |   9000 |00:00:00.02 |     165 |    232 |
|*  4 |     TABLE ACCESS BY INDEX ROWID| M_CUS          |      1 |     60 |     60 |00:00:00.01 |       5 |      9 |
|   5 |      INDEX FULL SCAN           | PK_M_CUS       |      1 |     90 |     90 |00:00:00.01 |       2 |      1 |
|*  6 |     INDEX RANGE SCAN           | X_T_ORD_JOIN_2 |     60 |   1243 |   9000 |00:00:00.02 |     160 |    223 |
|   7 |    TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN     |   9000 |    105 |   9000 |00:00:00.01 |      75 |     88 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter("T1"."CUS_GD"='A')
   6 - access("T1"."CUS_ID"="T2"."CUS_ID" AND "T2"."ORD_YMD"='20170218')
*/

-- ************************************************
-- PART II - 7.2.5 SQL1
-- ************************************************
-- T_ORD_JOIN에 범위조건(LIKE) 사용
CREATE INDEX X_T_ORD_JOIN_3 ON T_ORD_JOIN(ORD_YMD);

SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_3) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
		 , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) INDEX(T2 X_T_ORD_JOIN_3) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |     72 |00:00:00.34 |     211K|   2318 |       |       |          |
|   1 |  HASH GROUP BY                 |                |      1 |     90 |     72 |00:00:00.34 |     211K|   2318 |   726K|   726K| 2486K (0)|
|   2 |   NESTED LOOPS                 |                |      1 |        |    209K|00:00:00.38 |     211K|   2318 |       |       |          |
|   3 |    NESTED LOOPS                |                |      1 |  22780 |    209K|00:00:00.27 |    2289 |   2310 |       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |      1 |  22780 |    209K|00:00:00.17 |    2285 |   2309 |       |       |          |
|*  5 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_3 |      1 |  22780 |    209K|00:00:00.08 |     585 |    584 |       |       |          |
|*  6 |     INDEX UNIQUE SCAN          | PK_M_CUS       |    209K|      1 |    209K|00:00:00.06 |       4 |      1 |       |       |          |
|   7 |    TABLE ACCESS BY INDEX ROWID | M_CUS          |    209K|      1 |    209K|00:00:00.06 |     209K|      8 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.2.5 SQL2
-- ************************************************
-- 각각의 테이블을 카운트
SELECT COUNT(*) FROM M_CUS; --90

SELECT COUNT(*) FROM T_ORD_JOIN WHERE ORD_YMD LIKE '201702%'; --209000

-- ************************************************
-- PART II - 7.2.5 SQL3
-- ************************************************
-- T_ORD_JOIN에 범위조건(LIKE) 사용 – M_CUS을 선행 집합으로 사용
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
		 , T_ORD_JOIN T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |     72 |00:00:00.01 |    2894 |   3629 |
|   1 |  SORT GROUP BY NOSORT          |                |      1 |     90 |     72 |00:00:00.01 |    2894 |   3629 |
|   2 |   NESTED LOOPS                 |                |      1 |        |    209K|00:00:00.52 |    2894 |   3629 |
|   3 |    NESTED LOOPS                |                |      1 |  22780 |    209K|00:00:00.43 |    1031 |   1895 |
|   4 |     TABLE ACCESS BY INDEX ROWID| M_CUS          |      1 |     90 |     90 |00:00:00.01 |       5 |      9 |
|   5 |      INDEX FULL SCAN           | PK_M_CUS       |      1 |     90 |     90 |00:00:00.01 |       2 |      1 |
|*  6 |     INDEX RANGE SCAN           | X_T_ORD_JOIN_2 |     90 |    253 |    209K|00:00:00.07 |    1026 |   1886 |
|   7 |    TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN     |    209K|    253 |    209K|00:00:00.09 |    1863 |   1734 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
*/

-- ************************************************
-- PART II - 7.2.6 SQL1
-- ************************************************
-- 3개 테이블의 조인
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST ,COUNT(*) ORD_QTY
  FROM M_ITM T1
		 , T_ORD_JOIN T2
		 , M_CUS T3
 WHERE T1.ITM_ID = T2.ITM_ID
   AND T3.CUS_ID = T2.CUS_ID
   AND T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;

-- ANSI
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ITM_ID
     , T1.ITM_NM
     , T2.ORD_ST
     , COUNT(*) ORD_QTY
  FROM M_ITM T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.ITM_ID = T2.ITM_ID
 INNER JOIN M_CUS T3
    ON T3.CUS_ID = T2.CUS_ID
 WHERE T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      7 |00:00:00.08 |     986 |   1532 |       |       |          |
|   1 |  HASH GROUP BY                 |                |      1 |    101 |      7 |00:00:00.08 |     986 |   1532 |   915K|   915K|  834K (0)|
|*  2 |   HASH JOIN                    |                |      1 |    933 |  10000 |00:00:00.02 |     986 |   1532 |  1063K|  1063K| 1138K (0)|
|*  3 |    TABLE ACCESS FULL           | M_ITM          |      1 |     10 |     10 |00:00:00.01 |       7 |      6 |       |       |          |
|   4 |    NESTED LOOPS                |                |      1 |        |  70000 |00:00:00.10 |     979 |   1526 |       |       |          |
|   5 |     NESTED LOOPS               |                |      1 |   7467 |  70000 |00:00:00.02 |     352 |    686 |       |       |          |
|*  6 |      TABLE ACCESS FULL         | M_CUS          |      1 |     30 |     30 |00:00:00.01 |       7 |      6 |       |       |          |
|*  7 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_2 |     30 |    253 |  70000 |00:00:00.02 |     345 |    680 |       |       |          |
|   8 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |  70000 |    253 |  70000 |00:00:00.04 |     627 |    840 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."ITM_ID"="T2"."ITM_ID")
   3 - filter("T1"."ITM_TP"='ELEC')
   6 - filter("T3"."CUS_GD"='B')
   7 - access("T3"."CUS_ID"="T2"."CUS_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
*/

-- ************************************************
-- PART II - 7.2.6 SQL2
-- ************************************************
--M_CUS : 30건
SELECT COUNT(*) FROM M_CUS
 WHERE CUS_GD = 'B';

-- ************************************************
-- PART II - 7.2.6 SQL3
-- ************************************************
--M_ITM : 10건
SELECT COUNT(*) FROM M_ITM
 WHERE ITM_TP = 'ELEC';

-- ************************************************
-- PART II - 7.2.6 SQL4
-- ************************************************
-- 3개 테이블의 조인 – 각 조인 상황별로 카운트
-- M_CUS, T_ORD_JOIN : 70,000건
SELECT COUNT(*) CNT
  FROM M_CUS T3
 INNER JOIN T_ORD_JOIN T2
    ON T3.CUS_ID = T2.CUS_ID
 WHERE T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%';

-- M_ITM, T_ORD_JOIN : 26,000건
SELECT COUNT(*) CNT
  FROM M_ITM T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.ITM_ID = T2.ITM_ID
 WHERE T1.ITM_TP = 'ELEC'
   AND T2.ORD_YMD LIKE '201702%';

-- ************************************************
-- PART II - 7.2.6 SQL5
-- ************************************************
-- 3개 테이블의 조인 – M_ITM과 T_ORD_JOIN을 먼저 처리
CREATE INDEX X_T_ORD_JOIN_4 ON T_ORD_JOIN(ITM_ID,ORD_YMD);

-- M_ITM, T_ORD_JOIN 먼저 조인 : T_ORD_JOIN 의 인덱스 필요(ITM_ID, ORD_YMD)
-- ANSI
SELECT /*+ GATHER_PLAN_STATISTICS USE_NL(T2) INDEX(T2 X_T_ORD_JOIN_4) */
       T1.ITM_ID
     , T1.ITM_NM
     , T2.ORD_ST
     , COUNT(*) ORD_QTY
  FROM M_ITM T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.ITM_ID = T2.ITM_ID
 INNER JOIN M_CUS T3
    ON T3.CUS_ID = T2.CUS_ID
 WHERE T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;
/*
해석 : M_ITM(10건) <-> M_CUS & T_ORD_JOIN(70,000건)을 HASH JOIN 함
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      7 |00:00:00.08 |     986 |   1532 |       |       |          |
|   1 |  HASH GROUP BY                 |                |      1 |    101 |      7 |00:00:00.08 |     986 |   1532 |   915K|   915K|  834K (0)|
|*  2 |   HASH JOIN                    |                |      1 |    933 |  10000 |00:00:00.02 |     986 |   1532 |  1063K|  1063K| 1138K (0)|
|*  3 |    TABLE ACCESS FULL           | M_ITM          |      1 |     10 |     10 |00:00:00.01 |       7 |      6 |       |       |          |
|   4 |    NESTED LOOPS                |                |      1 |        |  70000 |00:00:00.10 |     979 |   1526 |       |       |          |
|   5 |     NESTED LOOPS               |                |      1 |   7467 |  70000 |00:00:00.02 |     352 |    686 |       |       |          |
|*  6 |      TABLE ACCESS FULL         | M_CUS          |      1 |     30 |     30 |00:00:00.01 |       7 |      6 |       |       |          |
|*  7 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_2 |     30 |    253 |  70000 |00:00:00.02 |     345 |    680 |       |       |          |
|   8 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |  70000 |    253 |  70000 |00:00:00.04 |     627 |    840 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------
*/
/*
PLAN_TABLE_OUTPUT 해석 : M_CUS(30건) <-> M_ITM & T_ORD_JOIN(26,000건)을 HASH JOIN 함
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      7 |00:00:00.04 |     370 |    445 |       |       |          |
|   1 |  HASH GROUP BY                 |                |      1 |    101 |      7 |00:00:00.04 |     370 |    445 |   915K|   915K|  816K (0)|
|*  2 |   HASH JOIN                    |                |      1 |    933 |  10000 |00:00:00.02 |     370 |    445 |  1236K|  1236K| 1233K (0)|
|*  3 |    TABLE ACCESS FULL           | M_CUS          |      1 |     30 |     30 |00:00:00.01 |       7 |      6 |       |       |          |
|   4 |    NESTED LOOPS                |                |      1 |        |  26000 |00:00:00.02 |     363 |    439 |       |       |          |
|   5 |     NESTED LOOPS               |                |      1 |   2847 |  26000 |00:00:00.01 |     125 |    159 |       |       |          |
|*  6 |      TABLE ACCESS FULL         | M_ITM          |      1 |     10 |     10 |00:00:00.01 |       7 |      6 |       |       |          |
|*  7 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_4 |     10 |    285 |  26000 |00:00:00.01 |     118 |    153 |       |       |          |
|   8 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |  26000 |    285 |  26000 |00:00:00.01 |     238 |    280 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T3"."CUS_ID"="T2"."CUS_ID")
   3 - filter("T3"."CUS_GD"='B')
   6 - filter("T1"."ITM_TP"='ELEC')
   7 - access("T1"."ITM_ID"="T2"."ITM_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
*/

-- ************************************************
-- PART II - 7.2.7 SQL1
-- ************************************************
-- 3개 테이블의 조인 – 필요한 인덱스를 모두 생성
/*
M_CUS(30건) <-> M_ITM & T_ORD_JOIN(26,000건)을 HASH JOIN 함
TABLE ACCESS FULL         | M_CUS  INDEX(CUS_GD)
TABLE ACCESS FULL         | M_ITM  INDEX(ITM_TP)
*/
CREATE INDEX X_M_CUS_1 ON M_CUS(CUS_GD);
CREATE INDEX X_M_ITM_1 ON M_ITM(ITM_TP);
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name             | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |                  |      1 |        |      7 |00:00:00.04 |     363 |    475 |       |       |          |
|   1 |  HASH GROUP BY                  |                  |      1 |    101 |      7 |00:00:00.04 |     363 |    475 |   915K|   915K|  837K (0)|
|*  2 |   HASH JOIN                     |                  |      1 |    933 |  10000 |00:00:00.02 |     363 |    475 |  1236K|  1236K| 1268K (0)|
|*  3 |    VIEW                         | index$_join$_004 |      1 |     30 |     30 |00:00:00.01 |       5 |      6 |       |       |          |
|*  4 |     HASH JOIN                   |                  |      1 |        |     30 |00:00:00.01 |       5 |      6 |  1114K|  1114K| 1509K (0)|
|*  5 |      INDEX RANGE SCAN           | X_M_CUS_1        |      1 |     30 |     30 |00:00:00.01 |       1 |      0 |       |       |          |
|   6 |      INDEX FAST FULL SCAN       | PK_M_CUS         |      1 |     30 |     90 |00:00:00.01 |       4 |      6 |       |       |          |
|   7 |    NESTED LOOPS                 |                  |      1 |        |  26000 |00:00:00.02 |     358 |    469 |       |       |          |
|   8 |     NESTED LOOPS                |                  |      1 |   2847 |  26000 |00:00:00.01 |     120 |    176 |       |       |          |
|   9 |      TABLE ACCESS BY INDEX ROWID| M_ITM            |      1 |     10 |     10 |00:00:00.01 |       2 |      0 |       |       |          |
|* 10 |       INDEX RANGE SCAN          | X_M_ITM_1        |      1 |     10 |     10 |00:00:00.01 |       1 |      0 |       |       |          |
|* 11 |      INDEX RANGE SCAN           | X_T_ORD_JOIN_4   |     10 |    285 |  26000 |00:00:00.01 |     118 |    176 |       |       |          |
|  12 |     TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN       |  26000 |    285 |  26000 |00:00:00.01 |     238 |    293 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T3"."CUS_ID"="T2"."CUS_ID")
   3 - filter("T3"."CUS_GD"='B')
   4 - access(ROWID=ROWID)
   5 - access("T3"."CUS_GD"='B')
  10 - access("T1"."ITM_TP"='ELEC')
  11 - access("T1"."ITM_ID"="T2"."ITM_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')

*/

/*
TABLE ACCESS FULL         | M_CUS  INDEX(CUS_GD, CUS_ID)
TABLE ACCESS FULL         | M_ITM  INDEX(ITM_TP, ITM_ID, ITM_NM)
*/
CREATE INDEX X_M_CUS_1 ON M_CUS(CUS_GD, CUS_ID);
CREATE INDEX X_M_ITM_1 ON M_ITM(ITM_TP,ITM_ID,ITM_NM);
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      7 |00:00:00.04 |     360 |    470 |       |       |          |
|   1 |  HASH GROUP BY                 |                |      1 |      2 |      7 |00:00:00.04 |     360 |    470 |   915K|   915K|  816K (0)|
|   2 |   NESTED LOOPS                 |                |      1 |    933 |  10000 |00:00:00.02 |     360 |    470 |       |       |          |
|   3 |    NESTED LOOPS                |                |      1 |   2847 |  26000 |00:00:00.02 |     357 |    462 |       |       |          |
|*  4 |     INDEX RANGE SCAN           | X_M_ITM_1      |      1 |     10 |     10 |00:00:00.01 |       1 |      8 |       |       |          |
|   5 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |     10 |    285 |  26000 |00:00:00.01 |     356 |    454 |       |       |          |
|*  6 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_4 |     10 |    285 |  26000 |00:00:00.01 |     118 |    165 |       |       |          |
|*  7 |    INDEX RANGE SCAN            | X_M_CUS_1      |  26000 |      1 |  10000 |00:00:00.01 |       3 |      8 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."ITM_TP"='ELEC')
   6 - access("T1"."ITM_ID"="T2"."ITM_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
   7 - access("T3"."CUS_GD"='B' AND "T3"."CUS_ID"="T2"."CUS_ID")

*/

-- ************************************************
-- PART II - 7.2.7 SQL2
-- ************************************************
-- 3개 테이블의 조인 – TABLE ACCESS BY INDEX ROWID를 제거

CREATE INDEX X_T_ORD_JOIN_5 ON T_ORD_JOIN(ITM_ID, ORD_YMD, CUS_ID, ORD_ST);

-- ANSI
SELECT /*+ GATHER_PLAN_STATISTICS INDEX(T1 X_M_ITM_1) INDEX(T3 X_M_CUS_1) INDEX(T2 X_T_ORD_JOIN_5) */
       T1.ITM_ID
     , T1.ITM_NM
     , T2.ORD_ST
     , COUNT(*) ORD_QTY
  FROM M_ITM T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.ITM_ID = T2.ITM_ID
 INNER JOIN M_CUS T3
    ON T3.CUS_ID = T2.CUS_ID
 WHERE T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation           | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |                |      1 |        |      7 |00:00:00.04 |     177 |    218 |       |       |          |
|   1 |  HASH GROUP BY      |                |      1 |      2 |      7 |00:00:00.04 |     177 |    218 |   915K|   915K|  837K (0)|
|   2 |   NESTED LOOPS      |                |      1 |    933 |  10000 |00:00:00.02 |     177 |    218 |       |       |          |
|   3 |    NESTED LOOPS     |                |      1 |   2847 |  26000 |00:00:00.01 |     174 |    210 |       |       |          |
|*  4 |     INDEX RANGE SCAN| X_M_ITM_1      |      1 |     10 |     10 |00:00:00.01 |       1 |      8 |       |       |          |
|*  5 |     INDEX RANGE SCAN| X_T_ORD_JOIN_5 |     10 |    285 |  26000 |00:00:00.01 |     173 |    202 |       |       |          |
|*  6 |    INDEX RANGE SCAN | X_M_CUS_1      |  26000 |      1 |  10000 |00:00:00.01 |       3 |      8 |       |       |          |
------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("T1"."ITM_TP"='ELEC')
   5 - access("T1"."ITM_ID"="T2"."ITM_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
   6 - access("T3"."CUS_GD"='B' AND "T3"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.2.7 SQL3
-- ************************************************
-- 불필요 인덱스 제거
DROP INDEX X_M_ITM_1;
DROP INDEX X_M_CUS_1;
DROP INDEX X_T_ORD_JOIN_5;

-- ************************************************
-- PART II - 7.2.8 SQL1
-- ************************************************
-- NL 조인 성능 테스트 – M_CUS를 선행으로 NL 조인
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_BIG_4) */
       T1.CUS_ID, T1.CUS_NM, SUM(T2.ORD_AMT)
  FROM M_CUS T1
		 , T_ORD_BIG T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD LIKE '201701%'
 GROUP BY T1.CUS_ID, T1.CUS_NM
 ORDER BY SUM(T2.ORD_AMT) DESC;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_NL(T2) INDEX(T2 X_T_ORD_BIG_4) */
       T1.CUS_ID
     , T1.CUS_NM
     , SUM(T2.ORD_AMT)
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD LIKE '201701%'
 GROUP BY T1.CUS_ID, T1.CUS_NM
 ORDER BY SUM(T2.ORD_AMT) DESC;
/*
PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |               |      1 |        |     81 |00:00:08.01 |    2441K|  74993 |       |       |          |
|   1 |  SORT ORDER BY                 |               |      1 |   5728 |     81 |00:00:08.01 |    2441K|  74993 |  9216 |  9216 | 8192  (0)|
|   2 |   HASH GROUP BY                |               |      1 |   5728 |     81 |00:00:08.01 |    2441K|  74993 |   862K|   862K| 2580K (0)|
|   3 |    NESTED LOOPS                |               |      1 |        |   2430K|00:00:08.64 |    2441K|  74993 |       |       |          |
|   4 |     NESTED LOOPS               |               |      1 |    100K|   2430K|00:00:01.59 |   11795 |  12028 |       |       |          |
|   5 |      TABLE ACCESS FULL         | M_CUS         |      1 |     90 |     90 |00:00:00.01 |       7 |      6 |       |       |          |
|*  6 |      INDEX RANGE SCAN          | X_T_ORD_BIG_4 |     90 |   1111 |   2430K|00:00:00.96 |   11788 |  12022 |       |       |          |
|   7 |     TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |   2430K|   1111 |   2430K|00:00:06.58 |    2430K|  62965 |       |       |          |
----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID" AND "T2"."ORD_YMD" LIKE '201701%')
       filter("T2"."ORD_YMD" LIKE '201701%')
*/

-- ************************************************
-- PART II - 7.2.8 SQL2
-- ************************************************
-- NL 조인 성능 테스트 – T_ORD_BIG을 선행으로 NL 조인
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) FULL(T2) */
       T1.CUS_ID, T1.CUS_NM, SUM(T2.ORD_AMT)
  FROM M_CUS T1
		 , T_ORD_BIG T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD LIKE '201701%'
 GROUP BY T1.CUS_ID, T1.CUS_NM
 ORDER BY SUM(T2.ORD_AMT) DESC;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) FULL(T2) */
       T1.CUS_ID
     , T1.CUS_NM
     , SUM(T2.ORD_AMT)
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD LIKE '201701%'
 GROUP BY T1.CUS_ID, T1.CUS_NM
 ORDER BY SUM(T2.ORD_AMT) DESC;
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |      1 |        |     81 |00:00:05.14 |    2688K|    258K|       |       |          |
|   1 |  SORT ORDER BY                 |           |      1 |   5728 |     81 |00:00:05.14 |    2688K|    258K|  9216 |  9216 | 8192  (0)|
|   2 |   HASH GROUP BY                |           |      1 |   5728 |     81 |00:00:05.14 |    2688K|    258K|   862K|   862K| 2580K (0)|
|   3 |    NESTED LOOPS                |           |      1 |        |   2430K|00:00:05.30 |    2688K|    258K|       |       |          |
|   4 |     NESTED LOOPS               |           |      1 |    100K|   2430K|00:00:04.15 |     258K|    258K|       |       |          |
|*  5 |      TABLE ACCESS FULL         | T_ORD_BIG |      1 |    100K|   2430K|00:00:02.97 |     258K|    258K|       |       |          |
|*  6 |      INDEX UNIQUE SCAN         | PK_M_CUS  |   2430K|      1 |   2430K|00:00:00.66 |       4 |      1 |       |       |          |
|   7 |     TABLE ACCESS BY INDEX ROWID| M_CUS     |   2430K|      1 |   2430K|00:00:00.65 |    2430K|      8 |       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - filter("T2"."ORD_YMD" LIKE '201701%')
   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.3.1 SQL1
-- ************************************************
-- 고객별 2월 전체 주문금액 조회 – T_ORD_BIG,NL 조인 사용
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) FULL(T2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
     , SUM(T2.ORD_AMT) ORD_AMT
		 , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
		 , T_ORD_BIG T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_NL(T1) FULL(T2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_AMT) ORD_AMT
		 , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |      1 |        |     72 |00:00:04.93 |    2238K|    258K|       |       |          |
|   1 |  WINDOW BUFFER                 |           |      1 |     90 |     72 |00:00:04.93 |    2238K|    258K|  6144 |  6144 | 6144  (0)|
|   2 |   HASH GROUP BY                |           |      1 |     90 |     72 |00:00:04.93 |    2238K|    258K|   726K|   726K| 2653K (0)|
|   3 |    NESTED LOOPS                |           |      1 |        |   1980K|00:00:07.13 |    2238K|    258K|       |       |          |
|   4 |     NESTED LOOPS               |           |      1 |    213K|   1980K|00:00:06.16 |     258K|    258K|       |       |          |
|*  5 |      TABLE ACCESS FULL         | T_ORD_BIG |      1 |    213K|   1980K|00:00:05.18 |     258K|    258K|       |       |          |
|*  6 |      INDEX UNIQUE SCAN         | PK_M_CUS  |   1980K|      1 |   1980K|00:00:00.55 |       4 |      8 |       |       |          |
|   7 |     TABLE ACCESS BY INDEX ROWID| M_CUS     |   1980K|      1 |   1980K|00:00:00.56 |    1980K|      8 |       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - filter("T2"."ORD_YMD" LIKE '201702%')
   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.3.1 SQL2
-- ************************************************
-- 고객별 2월 전체 주문금액 조회 – T_ORD_BIG, 머지 조인 사용
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) FULL(T2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
     , SUM(T2.ORD_AMT) ORD_AMT
		 , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |      1 |        |     72 |00:00:03.57 |     258K|    258K|       |       |          |
|   1 |  WINDOW BUFFER                 |           |      1 |     90 |     72 |00:00:03.57 |     258K|    258K|  6144 |  6144 | 6144  (0)|
|   2 |   SORT GROUP BY NOSORT         |           |      1 |     90 |     72 |00:00:03.62 |     258K|    258K|       |       |          |
|   3 |    MERGE JOIN                  |           |      1 |    213K|   1980K|00:00:03.71 |     258K|    258K|       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID| M_CUS     |      1 |     90 |     90 |00:00:00.01 |       3 |     13 |       |       |          |
|   5 |      INDEX FULL SCAN           | PK_M_CUS  |      1 |     90 |     90 |00:00:00.01 |       1 |      8 |       |       |          |
|*  6 |     SORT JOIN                  |           |     90 |    213K|   1980K|00:00:03.55 |     258K|    258K|    66M|  2819K|   58M (0)|
|*  7 |      TABLE ACCESS FULL         | T_ORD_BIG |      1 |    213K|   1980K|00:00:04.99 |     258K|    258K|       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")
   7 - filter("T2"."ORD_YMD" LIKE '201702%')
*/

-- ************************************************
-- PART II - 7.3.2 SQL1
-- ************************************************
-- 머지 조인 – T_ORD_BIG을 FULL SCAN으로 처리
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) FULL(T2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD ,COUNT(*) ORD_CNT
		 , SUM(T2.ORD_AMT) ORD_AMT ,SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
		 , T_ORD_BIG T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_YMD BETWEEN '20170201' AND '20170210'
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) FULL(T2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
		 , SUM(T2.ORD_AMT) ORD_AMT
     , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD BETWEEN '20170201' AND '20170210'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |      1 |        |     72 |00:00:01.38 |     258K|    258K|       |       |          |
|   1 |  WINDOW BUFFER                 |           |      1 |     90 |     72 |00:00:01.38 |     258K|    258K|  6144 |  6144 | 6144  (0)|
|   2 |   SORT GROUP BY NOSORT         |           |      1 |     90 |     72 |00:00:01.34 |     258K|    258K|       |       |          |
|   3 |    MERGE JOIN                  |           |      1 |    417K|    720K|00:00:01.42 |     258K|    258K|       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID| M_CUS     |      1 |     90 |     90 |00:00:00.01 |       3 |      6 |       |       |          |
|   5 |      INDEX FULL SCAN           | PK_M_CUS  |      1 |     90 |     90 |00:00:00.01 |       1 |      1 |       |       |          |
|*  6 |     SORT JOIN                  |           |     90 |    417K|    720K|00:00:01.36 |     258K|    258K|    23M|  1785K|   21M (0)|
|*  7 |      TABLE ACCESS FULL         | T_ORD_BIG |      1 |    417K|    720K|00:00:08.69 |     258K|    258K|       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")
   7 - filter(("T2"."ORD_YMD"<='20170210' AND "T2"."ORD_YMD">='20170201'))
*/

-- ************************************************
-- PART II - 7.3.2 SQL2
-- ************************************************
-- 머지 조인 – T_ORD_BIG의 인덱스 별 테스트

-- 1. X_T_ORD_BIG_1(ORD_YMD) 인덱스 사용.
-- SELECT  /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) INDEX(T2 X_T_ORD_BIG_1) */

-- 2. X_T_ORD_BIG_3(ORD_YMD, CUS_ID) 인덱스 사용.
-- SELECT  /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) INDEX(T2 X_T_ORD_BIG_3) */

-- 3. X_T_ORD_BIG_4(CUS_ID, ORD_YMD, ORD_ST) 인덱스 사용.
-- SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) INDEX(T2 X_T_ORD_BIG_4) */

SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) INDEX(T2 X_T_ORD_BIG_4) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
     , COUNT(*) ORD_CNT
		 , SUM(T2.ORD_AMT) ORD_AMT
     , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T2.ORD_YMD BETWEEN '20170201' AND '20170210'
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |      1 |        |     72 |00:00:03.48 |   88591 |  77882 |       |       |          |
|   1 |  WINDOW BUFFER                  |               |      1 |     90 |     72 |00:00:03.48 |   88591 |  77882 |  6144 |  6144 | 6144  (0)|
|   2 |   SORT GROUP BY NOSORT          |               |      1 |     90 |     72 |00:00:03.48 |   88591 |  77882 |       |       |          |
|   3 |    MERGE JOIN                   |               |      1 |    417K|    720K|00:00:03.50 |   88591 |  77882 |       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID | M_CUS         |      1 |     90 |     90 |00:00:00.01 |       3 |     16 |       |       |          |
|   5 |      INDEX FULL SCAN            | PK_M_CUS      |      1 |     90 |     90 |00:00:00.01 |       1 |      8 |       |       |          |
|*  6 |     SORT JOIN                   |               |     90 |    417K|    720K|00:00:03.44 |   88588 |  77866 |    23M|  1785K|   21M (0)|
|   7 |      TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |    417K|    720K|00:00:03.24 |   88588 |  77866 |       |       |          |
|*  8 |       INDEX RANGE SCAN          | X_T_ORD_BIG_1 |      1 |    417K|    720K|00:00:00.14 |    2009 |   2042 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")
   8 - access("T2"."ORD_YMD">='20170201' AND "T2"."ORD_YMD"<='20170210')
*/
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |      1 |        |     72 |00:00:03.60 |     722K|  80361 |       |       |          |
|   1 |  WINDOW BUFFER                  |               |      1 |     90 |     72 |00:00:03.60 |     722K|  80361 |  6144 |  6144 | 6144  (0)|
|   2 |   SORT GROUP BY NOSORT          |               |      1 |     90 |     72 |00:00:03.60 |     722K|  80361 |       |       |          |
|   3 |    MERGE JOIN                   |               |      1 |    417K|    720K|00:00:03.60 |     722K|  80361 |       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID | M_CUS         |      1 |     90 |     90 |00:00:00.01 |       3 |     16 |       |       |          |
|   5 |      INDEX FULL SCAN            | PK_M_CUS      |      1 |     90 |     90 |00:00:00.01 |       1 |      8 |       |       |          |
|*  6 |     SORT JOIN                   |               |     90 |    417K|    720K|00:00:03.54 |     722K|  80345 |    23M|  1785K|   21M (0)|
|   7 |      TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |    417K|    720K|00:00:03.33 |     722K|  80345 |       |       |          |
|*  8 |       INDEX RANGE SCAN          | X_T_ORD_BIG_3 |      1 |    417K|    720K|00:00:00.26 |    2919 |   2933 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")
   8 - access("T2"."ORD_YMD">='20170201' AND "T2"."ORD_YMD"<='20170210')
*/
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |      1 |        |     72 |00:00:03.95 |     723K|  81007 |       |       |          |
|   1 |  WINDOW BUFFER                  |               |      1 |     90 |     72 |00:00:03.95 |     723K|  81007 |  6144 |  6144 | 6144  (0)|
|   2 |   SORT GROUP BY NOSORT          |               |      1 |     90 |     72 |00:00:03.97 |     723K|  81007 |       |       |          |
|   3 |    MERGE JOIN                   |               |      1 |    417K|    720K|00:00:03.93 |     723K|  81007 |       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID | M_CUS         |      1 |     90 |     90 |00:00:00.01 |       3 |     16 |       |       |          |
|   5 |      INDEX FULL SCAN            | PK_M_CUS      |      1 |     90 |     90 |00:00:00.01 |       1 |      8 |       |       |          |
|*  6 |     SORT JOIN                   |               |     90 |    417K|    720K|00:00:03.87 |     723K|  80991 |    23M|  1785K|   21M (0)|
|   7 |      TABLE ACCESS BY INDEX ROWID| T_ORD_BIG     |      1 |    417K|    720K|00:00:03.72 |     723K|  80991 |       |       |          |
|*  8 |       INDEX SKIP SCAN           | X_T_ORD_BIG_4 |      1 |    382K|    720K|00:00:00.63 |    3741 |   5010 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")
   8 - access("T2"."ORD_YMD">='20170201' AND "T2"."ORD_YMD"<='20170210')
       filter(("T2"."ORD_YMD"<='20170210' AND "T2"."ORD_YMD">='20170201'))
*/

-- ************************************************
-- PART II - 7.4.1 SQL1
-- ************************************************
-- T_ORD_BIG 전체를 조인 – 머지 조인으로 처리
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) */
       T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,MAX(T1.CUS_GD) CUS_GD
		 , COUNT(*) ORD_CNT ,SUM(T2.ORD_AMT) ORD_AMT ,SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
		 , T_ORD_BIG T2
 WHERE T1.CUS_ID = T2.CUS_ID
 GROUP BY T1.CUS_ID;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_MERGE(T2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
		 , COUNT(*) ORD_CNT
     , SUM(T2.ORD_AMT) ORD_AMT
     , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  | Writes |  OMem |  1Mem | Used-Mem | Used-Tmp|
-------------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |      1 |        |     90 |00:00:17.56 |     258K|    404K|    146K|       |       |          |         |
|   1 |  WINDOW BUFFER                 |           |      1 |     90 |     90 |00:00:17.56 |     258K|    404K|    146K|  6144 |  6144 | 6144  (0)|         |
|   2 |   SORT GROUP BY NOSORT         |           |      1 |     90 |     90 |00:00:17.33 |     258K|    404K|    146K|       |       |          |         |
|   3 |    MERGE JOIN                  |           |      1 |     30M|     30M|00:00:16.39 |     258K|    404K|    146K|       |       |          |         |
|   4 |     TABLE ACCESS BY INDEX ROWID| M_CUS     |      1 |     90 |     90 |00:00:00.01 |       3 |     16 |      0 |       |       |          |         |
|   5 |      INDEX FULL SCAN           | PK_M_CUS  |      1 |     90 |     90 |00:00:00.01 |       1 |      8 |      0 |       |       |          |         |
|*  6 |     SORT JOIN                  |           |     90 |     30M|     30M|00:00:13.86 |     258K|    404K|    146K|   643M|  8326K|  264M (1)|     575K|
|   7 |      TABLE ACCESS FULL         | T_ORD_BIG |      1 |     30M|     30M|00:00:01.84 |     258K|    258K|      0 |       |       |          |         |
-------------------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("T1"."CUS_ID"="T2"."CUS_ID")
       filter("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.4.1 SQL2
-- ************************************************
-- T_ORD_BIG 전체를 조인 – 해시 조인으로 처리
--ANSI
SELECT  /*+ GATHER_PLAN_STATISTICS LEADING(T1) USE_HASH(T2) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
		 , COUNT(*) ORD_CNT
     , SUM(T2.ORD_AMT) ORD_AMT
     , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT (전체 소요된 시간이 개선됐고, Used-Mem 사용량이 확실히 줄었다.)
--------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |           |      1 |        |     90 |00:00:10.58 |     258K|    258K|       |       |          |
|   1 |  WINDOW BUFFER       |           |      1 |     90 |     90 |00:00:10.58 |     258K|    258K|  6144 |  6144 | 6144  (0)|
|   2 |   HASH GROUP BY      |           |      1 |     90 |     90 |00:00:10.58 |     258K|    258K|   726K|   726K| 5034K (0)|
|*  3 |    HASH JOIN         |           |      1 |     30M|     30M|00:00:10.09 |     258K|    258K|   990K|   990K| 1253K (0)|
|   4 |     TABLE ACCESS FULL| M_CUS     |      1 |     90 |     90 |00:00:00.01 |       7 |      6 |       |       |          |
|   5 |     TABLE ACCESS FULL| T_ORD_BIG |      1 |     30M|     30M|00:00:02.05 |     258K|    258K|       |       |          |
--------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.4.2 SQL1
-- ************************************************
-- T_ORD_BIG 전체를 조인 – T_ORD_BIG을 선행 집합으로 처리
--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T2) USE_HASH(T1) */
       T1.CUS_ID
     , MAX(T1.CUS_NM) CUS_NM
     , MAX(T1.CUS_GD) CUS_GD
		 , COUNT(*) ORD_CNT
     , SUM(T2.ORD_AMT) ORD_AMT
     , SUM(SUM(T2.ORD_AMT)) OVER() TTL_ORD_AMT
  FROM M_CUS T1
 INNER JOIN T_ORD_BIG T2
    ON T1.CUS_ID = T2.CUS_ID
 GROUP BY T1.CUS_ID;
/*
PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  | Writes |  OMem |  1Mem | Used-Mem | Used-Tmp|
---------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |           |      1 |        |     90 |00:00:12.38 |     258K|    333K|  75175 |       |       |          |         |
|   1 |  WINDOW BUFFER       |           |      1 |     90 |     90 |00:00:12.38 |     258K|    333K|  75175 |  6144 |  6144 | 6144  (0)|         |
|   2 |   HASH GROUP BY      |           |      1 |     90 |     90 |00:00:12.38 |     258K|    333K|  75175 |   726K|   726K| 5027K (0)|         |
|*  3 |    HASH JOIN         |           |      1 |     30M|     30M|00:00:08.48 |     258K|    333K|  75175 |  1022M|    24M|  128M (1)|     607K|
|   4 |     TABLE ACCESS FULL| T_ORD_BIG |      1 |     30M|     30M|00:00:02.14 |     258K|    258K|      0 |       |       |          |         |
|   5 |     TABLE ACCESS FULL| M_CUS     |      1 |     90 |     90 |00:00:00.01 |       7 |      6 |      0 |       |       |          |         |
---------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("T1"."CUS_ID"="T2"."CUS_ID")
*/

-- ************************************************
-- PART II - 7.4.3 SQL1
-- ************************************************
-- 3개 테이블의 조인. – M_ITM과 T_ORD_JOIN을 먼저 처리
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST ,COUNT(*) ORD_QTY
  FROM M_ITM T1
		 , T_ORD_JOIN T2
		 , M_CUS T3
 WHERE T1.ITM_ID = T2.ITM_ID
   AND T3.CUS_ID = T2.CUS_ID
   AND T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;

--ANSI
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.ITM_ID
     , T1.ITM_NM
     , T2.ORD_ST
     , COUNT(*) ORD_QTY
  FROM M_ITM T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.ITM_ID = T2.ITM_ID
 INNER JOIN M_CUS T3
    ON T3.CUS_ID = T2.CUS_ID
 WHERE T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |        |      7 |00:00:00.04 |     370 |    477 |       |       |          |
|   1 |  HASH GROUP BY                 |                |      1 |    101 |      7 |00:00:00.04 |     370 |    477 |   915K|   915K|  826K (0)|
|*  2 |   HASH JOIN                    |                |      1 |    933 |  10000 |00:00:00.01 |     370 |    477 |  1236K|  1236K| 1238K (0)|
|*  3 |    TABLE ACCESS FULL           | M_CUS          |      1 |     30 |     30 |00:00:00.01 |       7 |      6 |       |       |          |
|   4 |    NESTED LOOPS                |                |      1 |        |  26000 |00:00:00.02 |     363 |    471 |       |       |          |
|   5 |     NESTED LOOPS               |                |      1 |   2847 |  26000 |00:00:00.01 |     125 |    182 |       |       |          |
|*  6 |      TABLE ACCESS FULL         | M_ITM          |      1 |     10 |     10 |00:00:00.01 |       7 |      6 |       |       |          |
|*  7 |      INDEX RANGE SCAN          | X_T_ORD_JOIN_4 |     10 |    285 |  26000 |00:00:00.01 |     118 |    176 |       |       |          |
|   8 |     TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |  26000 |    285 |  26000 |00:00:00.02 |     238 |    289 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T3"."CUS_ID"="T2"."CUS_ID")
   3 - filter("T3"."CUS_GD"='B')
   6 - filter("T1"."ITM_TP"='ELEC')
   7 - access("T1"."ITM_ID"="T2"."ITM_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
*/

-- ************************************************
-- PART II - 7.4.3 SQL2
-- ************************************************
-- 3개 테이블의 조인 – NL 조인으로만 처리
SELECT /*+ GATHER_PLAN_STATISTICS LEADING(T1 T2 T3) USE_NL(T2 T3) */
       T1.ITM_ID
     , T1.ITM_NM
     , T2.ORD_ST
     , COUNT(*) ORD_QTY
  FROM M_ITM T1
 INNER JOIN T_ORD_JOIN T2
    ON T1.ITM_ID = T2.ITM_ID
 INNER JOIN M_CUS T3
    ON T3.CUS_ID = T2.CUS_ID
 WHERE T1.ITM_TP = 'ELEC'
   AND T3.CUS_GD = 'B'
   AND T2.ORD_YMD LIKE '201702%'
 GROUP BY T1.ITM_ID ,T1.ITM_NM ,T2.ORD_ST;
/*
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |                |      1 |        |      7 |00:00:00.05 |   26367 |    483 |       |       |          |
|   1 |  HASH GROUP BY                  |                |      1 |    101 |      7 |00:00:00.05 |   26367 |    483 |   915K|   915K|  826K (0)|
|   2 |   NESTED LOOPS                  |                |      1 |        |  10000 |00:00:00.02 |   26367 |    483 |       |       |          |
|   3 |    NESTED LOOPS                 |                |      1 |    933 |  26000 |00:00:00.04 |     367 |    475 |       |       |          |
|   4 |     NESTED LOOPS                |                |      1 |   2847 |  26000 |00:00:00.02 |     363 |    467 |       |       |          |
|*  5 |      TABLE ACCESS FULL          | M_ITM          |      1 |     10 |     10 |00:00:00.01 |       7 |      6 |       |       |          |
|   6 |      TABLE ACCESS BY INDEX ROWID| T_ORD_JOIN     |     10 |    285 |  26000 |00:00:00.02 |     356 |    461 |       |       |          |
|*  7 |       INDEX RANGE SCAN          | X_T_ORD_JOIN_4 |     10 |    285 |  26000 |00:00:00.01 |     118 |    176 |       |       |          |
|*  8 |     INDEX UNIQUE SCAN           | PK_M_CUS       |  26000 |      1 |  26000 |00:00:00.01 |       4 |      8 |       |       |          |
|*  9 |    TABLE ACCESS BY INDEX ROWID  | M_CUS          |  26000 |      1 |  10000 |00:00:00.01 |   26000 |      8 |       |       |          |
------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - filter("T1"."ITM_TP"='ELEC')
   7 - access("T1"."ITM_ID"="T2"."ITM_ID" AND "T2"."ORD_YMD" LIKE '201702%')
       filter("T2"."ORD_YMD" LIKE '201702%')
   8 - access("T3"."CUS_ID"="T2"."CUS_ID")
   9 - filter("T3"."CUS_GD"='B')
*/
