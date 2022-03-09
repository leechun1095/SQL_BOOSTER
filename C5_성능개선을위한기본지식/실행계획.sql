-- ************************************************
-- PART II - 1.1.3 SQL1
-- ************************************************
-- 실행계획 만들기
EXPLAIN PLAN FOR
SELECT * FROM T_ORD WHERE ORD_SEQ = 4;


-- ************************************************
-- PART II - 5.1.3 SQL2
-- ************************************************
-- 실행계획 확인하기
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
- Id : 실행계획의 오퍼레이션 ID (구분자, 순서아님)
- Operation : 해당 단계에 수행한 작업 내용
- Name : 해당 단계에 작업을 수행한 대상 오브젝트(테이블 또는 인덱스)
- Rows : 해당 단계 수행 시 조회될 예상 데이터 건수
- Bytes : 해당 단계까지 사용될 예상 데이터양(누적)
- Cost (%CPU) : 해당 단계까지 사용될 예상 비용(누적)

PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)|
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |     1 |    44 |     2   (0)|
|   1 |  TABLE ACCESS BY INDEX ROWID| T_ORD    |     1 |    44 |     2   (0)|
|*  2 |   INDEX UNIQUE SCAN         | PK_T_ORD |     1 |       |     1   (0)|
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("ORD_SEQ"=4)
*/

-- ************************************************
-- PART II - 5.1.4 SQL1
-- ************************************************
-- 실행계획 생성 및 조회
EXPLAIN PLAN FOR
SELECT *
  FROM T_ORD T1
     , M_CUS T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
   AND T2.CUS_GD = 'A';

SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY());

-- ************************************************
-- PART II - 5.1.4 SQL2
-- ************************************************
-- 좀 더 복잡한 실행계획 생성 및 조회
EXPLAIN PLAN FOR
SELECT T3.ITM_ID, SUM(T2.ORD_QTY) ORD_QTY
  FROM T_ORD T1
     , T_ORD_DET T2
     , M_ITM T3
 WHERE T1.ORD_SEQ = T2.ORD_SEQ
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
   AND T2.ITM_ID = T3.ITM_ID
   AND T3.ITM_TP = 'ELEC'
 GROUP BY T3.ITM_ID;

SELECT  * FROM TABLE(DBMS_XPLAN.DISPLAY());

-- ANSI, 실제 실행계획 조회하기
SELECT /*+ GATHER_PLAN_STATISTICS */ T3.ITM_ID, SUM(T2.ORD_QTY) ORD_QTY
  FROM T_ORD T1
 INNER JOIN T_ORD_DET T2
    ON T1.ORD_SEQ = T2.ORD_SEQ
 INNER JOIN M_ITM T3
    ON T2.ITM_ID = T3.ITM_ID
 WHERE T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
   AND T3.ITM_TP = 'ELEC'
 GROUP BY T3.ITM_ID;

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('gcpbtrs2p8qtp',0,'ALLSTATS LAST'));

/*
--------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name      | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |           |      1 |        |     10 |00:00:00.01 |      43 |       |       |          |
|   1 |  SORT GROUP BY NOSORT         |           |      1 |      1 |     10 |00:00:00.01 |      43 |       |       |          |
|   2 |   MERGE JOIN                  |           |      1 |     10 |     10 |00:00:00.01 |      43 |       |       |          |
|*  3 |    TABLE ACCESS BY INDEX ROWID| M_ITM     |      1 |     10 |     10 |00:00:00.01 |       4 |       |       |          |
|   4 |     INDEX FULL SCAN           | PK_M_ITM  |      1 |    100 |    100 |00:00:00.01 |       2 |       |       |          |
|*  5 |    SORT JOIN                  |           |     10 |     80 |     10 |00:00:00.01 |      39 |  9216 |  9216 | 8192  (0)|
|   6 |     VIEW                      | VW_GBC_9  |      1 |     80 |     80 |00:00:00.01 |      39 |       |       |          |
|   7 |      HASH GROUP BY            |           |      1 |     80 |     80 |00:00:00.01 |      39 |   921K|   921K| 1335K (0)|
|*  8 |       HASH JOIN               |           |      1 |    313 |    267 |00:00:00.01 |      39 |  1517K|  1517K| 1253K (0)|
|*  9 |        TABLE ACCESS FULL      | T_ORD     |      1 |    252 |    243 |00:00:00.01 |      23 |       |       |          |
|  10 |        TABLE ACCESS FULL      | T_ORD_DET |      1 |   3224 |   3224 |00:00:00.01 |      16 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------
*/

-- ************************************************
-- PART II - 5.1.5 SQL1
-- ************************************************
-- 실제 실행계획 만들기
SELECT /*+ GATHER_PLAN_STATISTICS */
       *
  FROM T_ORD T1
     , M_CUS T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
   AND T2.CUS_GD = 'A';

-- ************************************************
-- PART II - 5.1.5 SQL2
-- ************************************************
-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- ************************************************
-- PART II - 5.1.5 SQL3
-- ************************************************
-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('bmjjk7adpg82g',0,'ALLSTATS LAST'));

/*
- Starts : 해당 단계를 수행한 횟수
- E-Rows : 해당 단계의 예상 데이터 건수
- A-Rows : 해당 단계의 실제 데이터 건수
- A-Time : 해당 단계까지 수행된 실제 시간(누적)
- Buffers : 해당 단계까지 메모리 버퍼에서 읽은 블록 수(논리적 IO 횟수, 누적)
- Reads : 해당 단계까지 디스크에서 읽은 블록 수(물리적 IO 횟수, 누적)
- OMem : SQL 처리를 위해 사용한 메모리 수치
- 1Mem : SQL 처리를 위해 사용한 메모리 수치
- Used-Mem : SQL 처리를 위해 사용한 메모리 수치

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |    101 |00:00:00.01 |      12 |       |       |          |
|*  1 |  HASH JOIN         |       |      1 |    170 |    101 |00:00:00.01 |      12 |   779K|   779K| 1234K (0)|
|*  2 |   TABLE ACCESS FULL| M_CUS |      1 |     60 |     60 |00:00:00.01 |       7 |       |       |          |
|*  3 |   TABLE ACCESS FULL| T_ORD |      1 |    252 |    146 |00:00:00.01 |       5 |       |       |          |
-----------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("T1"."CUS_ID"="T2"."CUS_ID")
   2 - filter("T2"."CUS_GD"='A')
   3 - filter(("T1"."ORD_DT"<TO_DATE(' 2017-02-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
              "T1"."ORD_DT">=TO_DATE(' 2017-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))
*/

-- ************************************************
-- PART II - 5.2.2 SQL1
-- ************************************************
-- 각각 하드 파싱이 수행되는 SQL.
SELECT * FROM T_ORD T1 WHERE T1.CUS_ID = 'CUS_0001';
SELECT * FROM T_ORD T1 WHERE T1.CUS_ID = 'CUS_0002';

-- ************************************************
-- PART II - 5.2.2 SQL2
-- ************************************************
-- 바인드 변수로 처리된 SQL
SELECT * FROM T_ORD T1 WHERE T1.CUS_ID = :v_CUS_ID;

-- ************************************************
-- PART II - 5.2.4 SQL1
-- ************************************************
-- IO 블록 확인하기
SELECT /*+ GATHER_PLAN_STATISTICS */
       COUNT(*)
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD');

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('5mhz2x9x5jzk2',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |      1 |00:00:00.01 |      23 |
|   1 |  SORT AGGREGATE    |       |      1 |      1 |      1 |00:00:00.01 |      23 |
|*  2 |   TABLE ACCESS FULL| T_ORD |      1 |    252 |    243 |00:00:00.01 |      23 |
--------------------------------------------------------------------------------------

=> 전체 논리적 IO(Buffers)는 23번 발생했다. (=버퍼캐시에서 총 23번 블록을 읽었다.)
*/

-- ************************************************
-- PART II - 5.2.6 SQL1
-- ************************************************
-- 부분 범위 처리 확인 SQL
SELECT /*+ GATHER_PLAN_STATISTICS */
       T1.*
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD');

-- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
  FROM V$SQL T1
 WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
 ORDER BY T1.LAST_ACTIVE_TIME DESC;

-- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('5mhz2x9x5jzk2',0,'ALLSTATS LAST'));

/*
SELECT 결과 나오자마자 실행계획 결과 (A-Rows : 101번)
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------
| Id  | Operation         | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |       |      1 |        |    101 |00:00:00.01 |       7 |
|*  1 |  TABLE ACCESS FULL| T_ORD |      1 |   2569 |    101 |00:00:00.01 |       7 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("T1"."ORD_DT">=TO_DATE(' 2017-03-01 00:00:00', 'syyyy-mm-dd
              hh24:mi:ss'))
*/
/*
SELECT 결과의 스크롤을 모두 내린 후 실행계획 결과 (A-Rows : 2606번)
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------
| Id  | Operation         | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |       |      1 |        |   2606 |00:00:00.01 |      50 |
|*  1 |  TABLE ACCESS FULL| T_ORD |      1 |   2569 |   2606 |00:00:00.01 |      50 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("T1"."ORD_DT">=TO_DATE(' 2017-03-01 00:00:00', 'syyyy-mm-dd
              hh24:mi:ss'))
*/

-- ************************************************
-- PART II - 5.2.6 SQL2
-- ************************************************
-- GROUP BY가 포함된 SQL
SELECT /*+ GATHER_PLAN_STATISTICS */
       TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMMDD'), T1.CUS_ID;

 -- 실제 실행계획을 만든 SQL의 SQL_ID찾아내기
 SELECT T1.SQL_ID ,T1.CHILD_NUMBER ,T1.SQL_TEXT
   FROM V$SQL T1
  WHERE T1.SQL_TEXT LIKE '%GATHER_PLAN_STATISTICS%'
  ORDER BY T1.LAST_ACTIVE_TIME DESC;

 -- 실제 실행계획 조회하기(각자의 SQL_ID를 사용할 것)
 SELECT *
   FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('5mhz2x9x5jzk2',0,'ALLSTATS LAST'));
/*
PLAN_TABLE_OUTPUT
-----------------------------------------------------------------------------------------------------------------
| Id  | Operation          | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |       |      1 |        |    101 |00:00:00.01 |      23 |       |       |          |
|   1 |  HASH GROUP BY     |       |      1 |   2569 |    101 |00:00:00.01 |      23 |   927K|   927K|          |
|*  2 |   TABLE ACCESS FULL| T_ORD |      1 |   2569 |   2606 |00:00:00.01 |      23 |       |       |          |
-----------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("T1"."ORD_DT">=TO_DATE(' 2017-03-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))
*/
