-- ************************************************
-- PART III - 10.1.2 SQL1
-- ************************************************

-- 주문 리스트를 조회 (192,000건 조회됨)
SELECT T1.ORD_SEQ
     , T1.ORD_YMD
     , T1.CUS_ID
     , T2.CUS_NM
     , T3.RGN_NM
     , T1.ORD_ST
     , T1.ITM_ID
  FROM T_ORD_JOIN T1
     , M_CUS T2
     , M_RGN T3
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = T2.CUS_ID
   AND T3.RGN_ID = T2.RGN_ID
 ORDER BY T1.ORD_YMD DESC, T1.ORD_SEQ DESC;

-----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name           | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-----------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                |      1 |    192K|00:00:00.16 |    2108 |       |       |          |
|   1 |  SORT ORDER BY                 |                |      1 |    192K|00:00:00.16 |    2108 |    15M|  1494K|   14M (0)|
|*  2 |   HASH JOIN                    |                |      1 |    192K|00:00:00.11 |    2108 |   981K|   981K| 1226K (0)|
|   3 |    MERGE JOIN                  |                |      1 |     90 |00:00:00.01 |       9 |       |       |          |
|   4 |     TABLE ACCESS BY INDEX ROWID| M_RGN          |      1 |      5 |00:00:00.01 |       2 |       |       |          |
|   5 |      INDEX FULL SCAN           | PK_M_RGN       |      1 |      5 |00:00:00.01 |       1 |       |       |          |
|*  6 |     SORT JOIN                  |                |      5 |     90 |00:00:00.01 |       7 |  9216 |  9216 | 8192  (0)|
|   7 |      TABLE ACCESS FULL         | M_CUS          |      1 |     90 |00:00:00.01 |       7 |       |       |          |
|   8 |    TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN     |      1 |    192K|00:00:00.06 |    2099 |       |       |          |
|*  9 |     INDEX RANGE SCAN           | X_T_ORD_JOIN_3 |      1 |    192K|00:00:00.03 |     538 |       |       |          |
-----------------------------------------------------------------------------------------------------------------------------
-- ************************************************
-- PART III - 10.1.2 SQL2
-- ************************************************

-- 주문 리스트를 조회 – 첫 번째 페이지
SELECT *
  FROM (
        SELECT T1.ORD_SEQ
             , T1.ORD_YMD
             , T1.CUS_ID
             , T2.CUS_NM
             , T3.RGN_NM
             , T1.ORD_ST
             , T1.ITM_ID
          FROM T_ORD_JOIN T1
             , M_CUS T2
             , M_RGN T3
         WHERE T1.ORD_YMD LIKE '201703%'
           AND T1.CUS_ID = T2.CUS_ID
           AND T3.RGN_ID = T2.RGN_ID
         ORDER BY T1.ORD_YMD DESC, T1.ORD_SEQ DESC
       ) T_PG1
 WHERE ROWNUM <= 30;

-------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                        | Name           | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                 |                |      1 |     30 |00:00:00.13 |    2108 |       |       |          |
|*  1 |  COUNT STOPKEY                   |                |      1 |     30 |00:00:00.13 |    2108 |       |       |          |
|   2 |   VIEW                           |                |      1 |     30 |00:00:00.13 |    2108 |       |       |          |
|*  3 |    SORT ORDER BY STOPKEY         |                |      1 |     30 |00:00:00.13 |    2108 |   178K|   178K|  158K (0)|
|*  4 |     HASH JOIN                    |                |      1 |    192K|00:00:00.11 |    2108 |   981K|   981K| 1235K (0)|
|   5 |      MERGE JOIN                  |                |      1 |     90 |00:00:00.01 |       9 |       |       |          |
|   6 |       TABLE ACCESS BY INDEX ROWID| M_RGN          |      1 |      5 |00:00:00.01 |       2 |       |       |          |
|   7 |        INDEX FULL SCAN           | PK_M_RGN       |      1 |      5 |00:00:00.01 |       1 |       |       |          |
|*  8 |       SORT JOIN                  |                |      5 |     90 |00:00:00.01 |       7 |  9216 |  9216 | 8192  (0)|
|   9 |        TABLE ACCESS FULL         | M_CUS          |      1 |     90 |00:00:00.01 |       7 |       |       |          |
|  10 |      TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN     |      1 |    192K|00:00:00.06 |    2099 |       |       |          |
|* 11 |       INDEX RANGE SCAN           | X_T_ORD_JOIN_3 |      1 |    192K|00:00:00.03 |     538 |       |       |          |
-------------------------------------------------------------------------------------------------------------------------------



-- ************************************************
-- PART III - 10.1.2 SQL3
-- ************************************************

-- 주문 리스트를 조회 – 첫 번째 페이지, ROWNUM을 잘못 사용
SELECT T1.ORD_SEQ, T1.ORD_YMD, T1.CUS_ID, T2.CUS_NM
     , T3.RGN_NM, T1.ORD_ST, T1.ITM_ID
  FROM T_ORD_JOIN T1 ,M_CUS T2 ,M_RGN T3
 WHERE T1.ORD_YMD LIKE '201703%'
   AND T1.CUS_ID = T2.CUS_ID
   AND T3.RGN_ID = T2.RGN_ID
   AND ROWNUM <= 30
 ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC;



-- ************************************************
-- PART III - 10.1.2 SQL4
-- ************************************************

-- 주문 리스트를 조회 – 두 번째 페이지 조회, 잘못된 처리
SELECT *
  FROM (
        SELECT T1.ORD_SEQ, T1.ORD_YMD, T1.CUS_ID, T2.CUS_NM
             , T3.RGN_NM, T1.ORD_ST, T1.ITM_ID
          FROM T_ORD_JOIN T1 ,M_CUS T2 ,M_RGN T3
         WHERE T1.ORD_YMD LIKE '201703%'
           AND T1.CUS_ID = T2.CUS_ID
           AND T3.RGN_ID = T2.RGN_ID
         ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
       ) T_PG1
 WHERE ROWNUM >= 31
   AND ROWNUM <= 60;


-- ************************************************
-- PART III - 10.1.2 SQL5
-- ************************************************

-- 조회가 가능한 ROWNUM
SELECT * FROM T_ORD_JOIN T1 WHERE ROWNUM = 1; --조회 가능
SELECT * FROM T_ORD_JOIN T1 WHERE ROWNUM = 2; --조회 불가능
SELECT * FROM T_ORD_JOIN T1 WHERE ROWNUM <= 2; --조회 가능
SELECT * FROM T_ORD_JOIN T1 WHERE ROWNUM >= 2; --조회 불가능


-- ************************************************
-- PART III - 10.1.2 SQL6
-- ************************************************

-- 주문 리스트를 조회 – 두 번째 페이지 조회
SELECT *
  FROM (
        SELECT ROWNUM RNO
             , T1.*
          FROM (
                SELECT T1.ORD_SEQ  ,T1.ORD_YMD  ,T1.CUS_ID  ,T2.CUS_NM
                     , T3.RGN_NM  ,T1.ORD_ST  ,T1.ITM_ID
                  FROM T_ORD_JOIN T1 ,M_CUS T2 ,M_RGN T3
                 WHERE T1.ORD_YMD LIKE '201703%'
                   AND T1.CUS_ID = T2.CUS_ID
                   AND T3.RGN_ID = T2.RGN_ID
                 ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
              ) T1
         WHERE ROWNUM <= 60
       ) T2
 WHERE T2.RNO >= 31;

--------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                         | Name           | Starts | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                  |                |      1 |     30 |00:00:00.13 |    2108 |       |       |          |
|*  1 |  VIEW                             |                |      1 |     30 |00:00:00.13 |    2108 |       |       |          |
|*  2 |   COUNT STOPKEY                   |                |      1 |     60 |00:00:00.13 |    2108 |       |       |          |
|   3 |    VIEW                           |                |      1 |     60 |00:00:00.13 |    2108 |       |       |          |
|*  4 |     SORT ORDER BY STOPKEY         |                |      1 |     60 |00:00:00.13 |    2108 |   178K|   178K|  158K (0)|
|*  5 |      HASH JOIN                    |                |      1 |    192K|00:00:00.11 |    2108 |   981K|   981K| 1279K (0)|
|   6 |       MERGE JOIN                  |                |      1 |     90 |00:00:00.01 |       9 |       |       |          |
|   7 |        TABLE ACCESS BY INDEX ROWID| M_RGN          |      1 |      5 |00:00:00.01 |       2 |       |       |          |
|   8 |         INDEX FULL SCAN           | PK_M_RGN       |      1 |      5 |00:00:00.01 |       1 |       |       |          |
|*  9 |        SORT JOIN                  |                |      5 |     90 |00:00:00.01 |       7 |  9216 |  9216 | 8192  (0)|
|  10 |         TABLE ACCESS FULL         | M_CUS          |      1 |     90 |00:00:00.01 |       7 |       |       |          |
|  11 |       TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN     |      1 |    192K|00:00:00.06 |    2099 |       |       |          |
|* 12 |        INDEX RANGE SCAN           | X_T_ORD_JOIN_3 |      1 |    192K|00:00:00.03 |     538 |       |       |          |
--------------------------------------------------------------------------------------------------------------------------------


-- ************************************************
-- PART III - 10.1.3 SQL1
-- ************************************************

-- 주문 리스트를 조회 – DB-INDEX 페이징
--페이징 처리를 위한 인덱스를 추가
CREATE INDEX X_T_ORD_JOIN_6 ON T_ORD_JOIN(ORD_YMD, ORD_SEQ);

SELECT *
  FROM (
        SELECT ROWNUM RNO
             , T1.*
          FROM (
                SELECT T1.ORD_SEQ, T1.ORD_YMD, T1.CUS_ID, T2.CUS_NM
                     , T3.RGN_NM, T1.ORD_ST, T1.ITM_ID
                  FROM T_ORD_JOIN T1, M_CUS T2, M_RGN T3
                 WHERE T1.ORD_YMD LIKE '201703%'
                   AND T1.CUS_ID = T2.CUS_ID
                   AND T3.RGN_ID = T2.RGN_ID
                 ORDER BY T1.ORD_YMD DESC, T1.ORD_SEQ DESC
              ) T1
         WHERE ROWNUM <= 60
      ) T2
 WHERE T2.RNO >= 31;


-- CREATE INDEX X_T_ORD_JOIN_5 ON T_ORD_JOIN(CUS_ID, ORD_YMD, ORD_SEQ);
---------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                          | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |  OMem |  1Mem | Used-Mem |
---------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                   |                |      1 |        |     30 |00:00:00.17 |    2823 |   1101 |       |       |          |
|*  1 |  VIEW                              |                |      1 |     60 |     30 |00:00:00.17 |    2823 |   1101 |       |       |          |
|*  2 |   COUNT STOPKEY                    |                |      1 |        |     60 |00:00:00.17 |    2823 |   1101 |       |       |          |
|   3 |    VIEW                            |                |      1 |  20036 |     60 |00:00:00.17 |    2823 |   1101 |       |       |          |
|*  4 |     SORT ORDER BY STOPKEY          |                |      1 |  20036 |     60 |00:00:00.17 |    2823 |   1101 | 11264 | 11264 |10240  (0)|
|   5 |      NESTED LOOPS                  |                |      1 |        |    192K|00:00:00.42 |    2823 |   1101 |       |       |          |
|   6 |       NESTED LOOPS                 |                |      1 |  20036 |    192K|00:00:00.33 |    1112 |   1101 |       |       |          |
|   7 |        MERGE JOIN                  |                |      1 |     90 |     90 |00:00:00.01 |       9 |      0 |       |       |          |
|   8 |         TABLE ACCESS BY INDEX ROWID| M_RGN          |      1 |      5 |      5 |00:00:00.01 |       2 |      0 |       |       |          |
|   9 |          INDEX FULL SCAN           | PK_M_RGN       |      1 |      5 |      5 |00:00:00.01 |       1 |      0 |       |       |          |
|* 10 |         SORT JOIN                  |                |      5 |     90 |     90 |00:00:00.01 |       7 |      0 |  9216 |  9216 | 8192  (0)|
|  11 |          TABLE ACCESS FULL         | M_CUS          |      1 |     90 |     90 |00:00:00.01 |       7 |      0 |       |       |          |
|* 12 |        INDEX RANGE SCAN            | X_T_ORD_JOIN_5 |     90 |    223 |    192K|00:00:00.20 |    1103 |   1101 |       |       |          |
|  13 |       TABLE ACCESS BY INDEX ROWID  | T_ORD_JOIN     |    192K|    223 |    192K|00:00:00.04 |    1711 |      0 |       |       |          |
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
| Id  | Operation                          | Name           | Starts | A-Rows |   A-Time   | Buffers | Reads  |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                   |                |      1 |     30 |00:00:00.01 |     138 |      6 |
|*  1 |  VIEW                              |                |      1 |     30 |00:00:00.01 |     138 |      6 |
|*  2 |   COUNT STOPKEY                    |                |      1 |     60 |00:00:00.01 |     138 |      6 |
|   3 |    VIEW                            |                |      1 |     60 |00:00:00.01 |     138 |      6 |
|   4 |     NESTED LOOPS                   |                |      1 |     60 |00:00:00.01 |     138 |      6 |
|   5 |      NESTED LOOPS                  |                |      1 |     60 |00:00:00.01 |      78 |      6 |
|   6 |       NESTED LOOPS                 |                |      1 |     60 |00:00:00.01 |      73 |      6 |
|   7 |        TABLE ACCESS BY INDEX ROWID | T_ORD_JOIN     |      1 |     60 |00:00:00.01 |       8 |      5 |
|*  8 |         INDEX RANGE SCAN DESCENDING| X_T_ORD_JOIN_6 |      1 |     60 |00:00:00.01 |       5 |      5 |
|   9 |        TABLE ACCESS BY INDEX ROWID | M_CUS          |     60 |     60 |00:00:00.01 |      65 |      1 |
|* 10 |         INDEX UNIQUE SCAN          | PK_M_CUS       |     60 |     60 |00:00:00.01 |       5 |      1 |
|* 11 |       INDEX UNIQUE SCAN            | PK_M_RGN       |     60 |     60 |00:00:00.01 |       5 |      0 |
|  12 |      TABLE ACCESS BY INDEX ROWID   | M_RGN          |     60 |     60 |00:00:00.01 |      60 |      0 |
---------------------------------------------------------------------------------------------------------------

-- ************************************************
-- PART III - 10.1.3 SQL2
-- ************************************************

-- DB-INDEX 페이징 - 100번째 페이지 조회
SELECT *
  FROM (
        SELECT ROWNUM RNO
             , T1.*
          FROM (
                SELECT T1.ORD_SEQ  ,T1.ORD_YMD  ,T1.CUS_ID  ,T2.CUS_NM
                     , T3.RGN_NM  ,T1.ORD_ST  ,T1.ITM_ID
                  FROM T_ORD_JOIN T1 ,M_CUS T2 ,M_RGN T3
                 WHERE T1.ORD_YMD LIKE '201703%'
                   AND T1.CUS_ID = T2.CUS_ID
                   AND T3.RGN_ID = T2.RGN_ID
                 ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
               ) T1
         WHERE ROWNUM <= 100 * 30 --페이지번호 * 페이지당 로우수
       ) T2
 WHERE T2.RNO >= (100 * 30) - (30-1) --(페이지번호 * 페이지당 로우수) - (페이지당로우수-1)



-- ************************************************
-- PART III - 10.1.3 SQL3
-- ************************************************

-- DB-INDEX 페이징 - 100번째 페이지 조회 힌트 사용
SELECT *
  FROM (
        SELECT ROWNUM RNO
             , T1.*
          FROM (
                SELECT /*+ LEADING(T1) USE_NL(T2 T3) */
                       T1.ORD_SEQ  ,T1.ORD_YMD  ,T1.CUS_ID  ,T2.CUS_NM
                     , T3.RGN_NM  ,T1.ORD_ST  ,T1.ITM_ID
                  FROM T_ORD_JOIN T1 ,M_CUS T2 ,M_RGN T3
                 WHERE T1.ORD_YMD LIKE '201703%'
                   AND T1.CUS_ID = T2.CUS_ID
                   AND T3.RGN_ID = T2.RGN_ID
                 ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
               ) T1
         WHERE ROWNUM <= 100 * 30 --페이지번호 * 페이지당 로우수
      ) T2
 WHERE T2.RNO >= (100 * 30) - (30-1) --(페이지번호 * 페이지당 로우수) - (페이지당로우수-1)



-- ************************************************
-- PART III - 10.2.1 SQL1
-- ************************************************

-- 페이징을 위한 카운트
SELECT COUNT(*)
  FROM (
        SELECT T1.ORD_SEQ  ,T1.ORD_YMD  ,T1.CUS_ID  ,T2.CUS_NM
             , T3.RGN_NM  ,T1.ORD_ST  ,T1.ITM_ID
          FROM T_ORD_JOIN T1 ,M_CUS T2 ,M_RGN T3
         WHERE T1.ORD_YMD LIKE '201703%'
           AND T1.CUS_ID = T2.CUS_ID
           AND T3.RGN_ID = T2.RGN_ID
         ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
       ) T1;


-- ************************************************
-- PART III - 10.2.1 SQL2
-- ************************************************

-- 페이징을 위한 카운트 최적화
SELECT COUNT(*)
  FROM (
        SELECT *
          FROM (
                SELECT T1.ORD_SEQ  ,T1.ORD_YMD
                  FROM T_ORD_JOIN T1
                 WHERE T1.ORD_YMD LIKE '201703%'
                 ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
               ) T1
         WHERE ROWNUM <= (30 * 10) + 1
      ) T1;


-- ************************************************
-- PART III - 10.2.2 SQL1
-- ************************************************

-- DB-INDEX 페이징 - 100번째 페이지 조회 성능 개선
SELECT T_PG.RNO
     , T_PG.ORD_SEQ ,T_PG.ORD_YMD ,T_PG.CUS_ID ,T2.CUS_NM
     , T3.RGN_NM ,T_PG.ORD_ST ,T_PG.ITM_ID
  FROM (
        SELECT ROWNUM RNO
             , T1.*
          FROM (
                SELECT T1.ORD_SEQ ,T1.ORD_YMD  ,T1.CUS_ID
                     , T1.ORD_ST ,T1.ITM_ID
                  FROM T_ORD_JOIN T1
                 WHERE T1.ORD_YMD LIKE '201703%'
                 ORDER BY T1.ORD_YMD DESC ,T1.ORD_SEQ DESC
               ) T1
         WHERE ROWNUM <= 100 * 30 --페이지번호 * 페이지당 로우수
      ) T_PG
     , M_CUS T2
     , M_RGN T3
 WHERE T_PG.RNO >= (100 * 30) - (30-1) --(페이지번호 * 페이지당 로우수) - (페이지당로우수-1)
   AND T2.CUS_ID = T_PG.CUS_ID
   AND T3.RGN_ID = T2.RGN_ID
 ORDER BY T_PG.RNO;


-- ************************************************
-- PART III - 10.2.3 SQL1
-- ************************************************

-- DB-INDEX 페이징이 되지 않는 SQL
SELECT *
  FROM (
        SELECT ROWNUM RNO ,A.*
          FROM (
                SELECT T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM
                     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
                  FROM M_CUS T1
                     , T_ORD_JOIN T2
                 WHERE T2.CUS_ID(+) = T1.CUS_ID
                   AND T2.ORD_YMD(+) LIKE '201703%'
                 GROUP BY T1.CUS_ID
                 ORDER BY T1.CUS_ID
               ) A
         WHERE ROWNUM <= 30
       ) B
 WHERE B.RNO >= 1;



-- ************************************************
-- PART III - 10.2.3 SQL2
-- ************************************************

-- DB-INDEX 페이징이 되지 않는 SQL, M_CUS만 사용해서 DB-INDEX 페이징을 구현
SELECT *
  FROM (
        SELECT ROWNUM RNO ,A.*
          FROM (
                SELECT  T1.CUS_ID ,T1.CUS_NM
                  FROM    M_CUS T1
                 ORDER BY T1.CUS_ID
               ) A
         WHERE ROWNUM <= 30
       ) B
 WHERE B.RNO >= 1;



-- ************************************************
-- PART III - 10.2.3 SQL3
-- ************************************************

-- 페이징 후 T_ORD_JOIN을 서브쿼리로 처리
SELECT B.*
     , (
        SELECT SUM(C.ORD_QTY * C.UNT_PRC) ORD_AMT
          FROM T_ORD_JOIN C
         WHERE C.CUS_ID = B.CUS_ID
           AND C.ORD_YMD LIKE '201703%') ORD_AMT
  FROM (
        SELECT ROWNUM RNO ,A.*
          FROM (
                SELECT T1.CUS_ID ,T1.CUS_NM
                  FROM M_CUS T1
                 ORDER BY T1.CUS_ID
               ) A
         WHERE ROWNUM <= 30
       ) B
 WHERE B.RNO >= 1


-- ************************************************
-- PART III - 10.2.3 SQL4
-- ************************************************

-- 페이징 후 T_ORD_JOIN을 아우터-조인으로 처리
SELECT T1.RNO ,T1.CUS_ID ,MAX(T1.CUS_NM)
     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
  FROM (
        SELECT B.*
          FROM (
                SELECT ROWNUM RNO ,A.*
                  FROM (
                        SELECT T1.CUS_ID ,T1.CUS_NM
                          FROM M_CUS T1
                         ORDER BY T1.CUS_ID
                       ) A
                 WHERE ROWNUM <= 30
               ) B
         WHERE B.RNO >= 1
       ) T1
     , T_ORD_JOIN T2
 WHERE T2.CUS_ID(+) = T1.CUS_ID
   AND T2.ORD_YMD(+) LIKE '201703%'
 GROUP BY T1.RNO ,T1.CUS_ID
 ORDER BY T1.RNO ,T1.CUS_ID;



-- ************************************************
-- PART III - 10.2.4 SQL1
-- ************************************************

-- 주문 리스트를 조회 – DB-INDEX 페이징, 요건 변경
SELECT T_PG.RNO
     , T_PG.ORD_SEQ ,T_PG.ORD_YMD ,T_PG.CUS_ID ,T2.CUS_NM
     , T3.RGN_NM ,T_PG.ORD_ST ,T_PG.ITM_ID
  FROM (
        SELECT ROWNUM RNO
             , T1.*
          FROM (
                SELECT T1.ORD_SEQ ,T1.ORD_YMD  ,T1.CUS_ID
                     , T1.ORD_ST ,T1.ITM_ID
                  FROM T_ORD_JOIN T1
                 WHERE T1.ORD_YMD LIKE '201703%'
                 ORDER BY T1.ORD_YMD DESC , T1.CUS_ID DESC, T1.ORD_SEQ DESC
               ) T1
         WHERE ROWNUM <= 100 * 30 --페이지번호 * 페이지당 로우수
       ) T_PG
     , M_CUS T2
     , M_RGN T3
 WHERE T_PG.RNO >= (100 * 30) - (30-1) --(페이지번호 * 페이지당 로우수) - (페이지당로우수-1)
   AND T2.CUS_ID = T_PG.CUS_ID
   AND T3.RGN_ID = T2.RGN_ID
 ORDER BY T_PG.RNO;


-- ************************************************
-- PART III - 10.2.4 SQL2
-- ************************************************

-- DB-INDEX 페이징이 불가능한 경우
SELECT *
  FROM (
        SELECT ROWNUM RNO ,T1.*
          FROM (
                SELECT T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM
                     , SUM(T2.ORD_QTY * T2.UNT_PRC) ORD_AMT
                  FROM M_CUS T1
                     , T_ORD_JOIN T2
                 WHERE T1.CUS_ID = T2.CUS_ID(+)
                   AND T2.ORD_YMD(+) LIKE '201703%'
                 GROUP BY T1.CUS_ID
                 ORDER BY SUM(T2.ORD_QTY * T2.UNT_PRC) DESC ,T1.CUS_ID
               ) T1
         WHERE ROWNUM <= 60
       ) T2
 WHERE T2.RNO >= 31;
