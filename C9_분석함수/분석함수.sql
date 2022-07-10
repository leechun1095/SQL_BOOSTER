-- ************************************************
-- PART III - 9.1.1 SQL1
-- ************************************************

-- 조회된 주문 건수를 마지막 컬럼에 추가하는 SQL
SELECT T1.ORD_SEQ ,T1.CUS_ID ,T1.ORD_DT
     , COUNT(*) ALL_CNT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170302','YYYYMMDD');



-- ************************************************
-- PART III - 9.1.1 SQL2
-- ************************************************

-- 조회된 주문 건수를 마지막 컬럼에 추가하는 SQL – 분석함수 사용
SELECT T1.ORD_SEQ ,T1.CUS_ID ,T1.ORD_DT
     , COUNT(*) OVER() ALL_CNT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170302','YYYYMMDD');


-- ************************************************
-- PART III - 9.1.2 SQL1
-- ************************************************

-- GROUP BY가 없는 SQL과 GROUP BY가 존재하는 SQL의 결과
SELECT T1.ORD_SEQ ,T1.CUS_ID
     , COUNT(*) OVER() ALL_CNT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 ORDER BY T1.ORD_SEQ;

SELECT T1.CUS_ID
     , COUNT(*) OVER() ALL_CNT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID;


-- ************************************************
-- PART III - 9.1.2 SQL2
-- ************************************************

-- 왼쪽 SQL은 에러가 발생, 오른쪽 SQL은 정상
SELECT T1.CUS_ID
     , T1.ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID;
-- ORA-00979: not a GROUP BY expression


SELECT T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID;

-- ************************************************
-- PART III - 9.1.2 SQL3
-- ************************************************

-- SUM() OVER()를 적용
SELECT T1.CUS_ID
     , SUM(T1.ORD_AMT) OVER() TTL_ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID;
-- ORA-00979: not a GROUP BY expression

SELECT T1.CUS_ID
     , SUM(SUM(T1.ORD_AMT)) OVER() OVER_ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID;



-- ************************************************
-- PART III - 9.1.2 SQL4
-- ************************************************

-- 분석함수와 집계함수의 차이

SELECT  T1.CUS_ID
     , COUNT(*) BY_CUS_ORD_CNT --집계함수: 고객별 주문건수
     , COUNT(*) OVER() ALL_CUST_CNT  --분석함수: 조회된 고객 수(두 명이 나온다.)
     , SUM(COUNT(*)) OVER() ALL_ORD_CNT  -- 분석함수: 2번 라인의 고객별 주문건수에 대한 합.
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID;



-- ************************************************
-- PART III - 9.1.3 SQL1
-- ************************************************

-- CUS_ID별로 PARTITION BY를 사용
SELECT T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , SUM(T1.ORD_AMT) ORD_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID) BY_CUST_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
 GROUP BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM')
 ORDER BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM');



-- ************************************************
-- PART III - 9.1.3 SQL2
-- ************************************************

-- 다양하게 PARTITION BY를 사용
SELECT T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM ,T1.ORD_ST
     , SUM(T1.ORD_AMT) ORD_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID) BY_CUST_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.ORD_ST) BY_ORD_ST_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID, TO_CHAR(T1.ORD_DT,'YYYYMM')) BY_CUST_YM_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
 GROUP BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.ORD_ST
 ORDER BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.ORD_ST;



-- ************************************************
-- PART III - 9.1.3 SQL3
-- ************************************************

-- ROLLUP과 PARTITION BY의 비교
SELECT T1.CUS_ID
     , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
WHERE  T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
 GROUP BY
ROLLUP(T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM'))
 ORDER BY T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM');

SELECT T1.CUS_ID
     , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , SUM(T1.ORD_AMT) ORD_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID) BY_CUST_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER() ALL_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
 GROUP BY T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM')
 ORDER BY T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM');




-- ************************************************
-- PART III - 9.1.3 SQL4
-- ************************************************

-- 고객별로 주문금액 비율 구하기 – PARTITION BY를 사용

SELECT T1.CUS_ID
     , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , SUM(T1.ORD_AMT) ORD_AMT
     , ROUND(SUM(T1.ORD_AMT) / (SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID)) * 100.00,2) ORD_AMT_RT_BY_CUST
     , ROUND(SUM(T1.ORD_AMT) / (SUM(SUM(T1.ORD_AMT)) OVER()) * 100.00,2) ORD_AMT_RT_BY_ALL_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
 GROUP BY T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM')
 ORDER BY T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM');



-- ************************************************
-- PART III - 9.1.4 SQL1
-- ************************************************

-- 특정 고객의 3월부터 8월까지의 6개월 간의 주문 조회, 월별 누적주문금액을 같이 표시
-- 누적 금액: 아래 예를 참고
		-- 3월의 누적금액은 3월 주문 금액과 동일
		-- 4월의 누적금액은 3월과 4월 주문금액 합계
		-- ...
		-- 8월의 누적금액은 3~8월의 주문금액 합계


SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , SUM(T1.ORD_AMT) ORD_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM')) ORD_YM_SUM
  FROM T_ORD T1
 WHERE T1.CUS_ID = 'CUS_0002'
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
 ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM');


-- ************************************************
-- PART III - 9.1.4 SQL2
-- ************************************************

-- 특정 고객의 두 명의 3월부터 5월까지의 월별 주문금액 조회, 고객별 누적주문금액을 같이 표시
SELECT T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , SUM(T1.ORD_AMT) ORD_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID) BY_CUST_AMT
     , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM')) BY_CUS_ORD_YM_SUM
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
 GROUP BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM')
 ORDER BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM');


 -- ************************************************
 -- PART III - 9.2.1 SQL1
 -- ************************************************

 -- RANK 분석함수
 SELECT T1.CUS_ID
      , SUM(T1.ORD_AMT) ORD_AMT
      , RANK() OVER(ORDER BY SUM(T1.ORD_AMT) DESC) RNK
   FROM T_ORD T1
  GROUP BY T1.CUS_ID;



 -- ************************************************
 -- PART III - 9.2.1 SQL2
 -- ************************************************

 -- RANK와 DENSE_RANK의 비교
 SELECT T1.ID ,T1.AMT
      , RANK() OVER(ORDER BY T1.AMT DESC) RANK_RES
      , DENSE_RANK() OVER(ORDER BY T1.AMT DESC) DENSE_RANK_RES
   FROM (
         SELECT  'A' ID ,300 AMT FROM DUAL UNION ALL
         SELECT  'B' ID ,150 AMT FROM DUAL UNION ALL
         SELECT  'C' ID ,150 AMT FROM DUAL UNION ALL
         SELECT  'D' ID ,100 AMT FROM DUAL
        ) T1;
/*
ID	AMT	RANK_RES	DENSE_RANK_RES
================================
A	  300	 	1	 	 	 	 	1
B	 	150	 	2		 	 	 	2
C	 	150	 	2	 	 	 	 	2
D	 	100	 	4	 	 	 	 	3
*/


 -- ************************************************
 -- PART III - 9.2.2 SQL1
 -- ************************************************

 -- ROW_NUMBER()를 이용한 순위 구하기
 -- ROW_NUMBER() : 중복된 순위를 내보내지 않는다.
 -- ROWNUM 과 비슷해 보이지만, OVER절에 PARTITION BY와 ORDER BY를 사용하여 세밀한 설정이 가능함.
 -- 대체로 ROWNUM 이 ROW_NUMBER()보다 성능이 좋다.
 SELECT T1.ID ,T1.AMT
      , RANK() OVER(ORDER BY T1.AMT DESC) RANK_RES
      , ROW_NUMBER() OVER(ORDER BY T1.AMT DESC) ROW_NUM_RES
   FROM (
         SELECT  'A' ID ,300 AMT FROM DUAL UNION ALL
         SELECT  'B' ID ,150 AMT FROM DUAL UNION ALL
         SELECT  'C' ID ,150 AMT FROM DUAL UNION ALL
         SELECT  'D' ID ,100 AMT FROM DUAL
        ) T1;


 -- ************************************************
 -- PART III - 9.2.2 SQL2
 -- ************************************************

 -- 3월, 4월 주문에 대해, 월별로 주문금액 Top-3 고객 구하기
 SELECT T0.ORD_YM ,T0.CUS_ID ,T0.ORD_AMT ,T0.BY_YM_RANK
   FROM (
         SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM ,T1.CUS_ID ,SUM(T1.ORD_AMT) ORD_AMT
              , ROW_NUMBER()	OVER(PARTITION BY TO_CHAR(T1.ORD_DT,'YYYYMM') ORDER BY SUM(T1.ORD_AMT) DESC) BY_YM_RANK
           FROM T_ORD T1
          WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
            AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
          GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM'),T1.CUS_ID
        ) T0
  WHERE T0.BY_YM_RANK <= 3
  ORDER BY T0.ORD_YM ,T0.BY_YM_RANK;




 -- ************************************************
 -- PART III - 9.2.2 SQL3
 -- ************************************************

 -- ROW_NUMBER()를 이용한 데이터 선택
 SELECT T2.*
   FROM (
         SELECT T1.*
              , ROW_NUMBER() OVER(PARTITION BY T1.CUS_ID ORDER BY T1.ORD_DT DESC ,T1.ORD_SEQ DESC) ORD_RNK
           FROM T_ORD T1
         ) T2
  WHERE T2.ORD_RNK = 1;


 -- ************************************************
 -- PART III - 9.2.3 SQL1
 -- ************************************************

 -- LEAD와 LAG의 사용 예제
 SELECT T1.CUS_ID
      , SUM(T1.ORD_AMT) ORD_AMT
      , ROW_NUMBER() OVER(ORDER BY SUM(T1.ORD_AMT) DESC) RNK
      , LAG(T1.CUS_ID,1) OVER(ORDER BY SUM(T1.ORD_AMT) DESC) LAG_1
      , LEAD(T1.CUS_ID,1) OVER(ORDER BY SUM(T1.ORD_AMT) DESC) LEAD_1
   FROM T_ORD T1
  WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    AND T1.ORD_DT < TO_DATE('20170401','YYYYMMDD')
    AND T1.CUS_ID IN ('CUS_0020','CUS_0021','CUS_0022','CUS_0023')
  GROUP BY T1.CUS_ID;


 -- ************************************************
 -- PART III - 9.2.3 SQL2
 -- ************************************************

 -- 주문년월 별 주문금액에, 전월 주문금액을 같이 표시 – LAG를 활용
 SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) ORD_AMT
      , LAG(SUM(T1.ORD_AMT), 1) OVER(ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM') ASC) BF_YM_ORD_AMT
   FROM T_ORD T1
  WHERE T1.ORD_ST = 'COMP'
  GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM');


 -- ************************************************
 -- PART III - 9.3.1 SQL1
 -- ************************************************

 -- 특정 고객의 주문년월별 주문금액, 특정 고객의 총 주문금액을 같이 표시
 SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) YM_ORD_AMT
      , SUM(SUM(T1.ORD_AMT)) OVER() TTL_ORD_AMT
   FROM T_ORD T1
  WHERE T1.CUS_ID = 'CUS_0002'
  GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
  ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM');


 -- ************************************************
 -- PART III - 9.3.1 SQL2
 -- ************************************************

 -- 특정 고객의 총 주문금액 – 서브쿼리로 해결
 SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) YM_ORD_AMT
      , (SELECT SUM(A.ORD_AMT)
           FROM T_ORD A
          WHERE A.CUS_ID = 'CUS_0002'
        ) TTL_ORD_AMT
   FROM T_ORD T1
  WHERE T1.CUS_ID = 'CUS_0002'
  GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
  ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM');



 -- ************************************************
 -- PART III - 9.3.1 SQL3
 -- ************************************************

 -- 특정 고객의 총 주문금액 – 인라인-뷰로 해결
 SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) YM_ORD_AMT
      , MAX(T2.TTL_ORD_AMT) TTL_ORD_AMT
   FROM T_ORD T1
      , (
         SELECT  SUM(A.ORD_AMT) TTL_ORD_AMT
           FROM    T_ORD A
          WHERE   A.CUS_ID = 'CUS_0002'
        ) T2
  WHERE T1.CUS_ID = 'CUS_0002'
  GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
  ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM');



 -- ************************************************
 -- PART III - 9.3.2 SQL1
 -- ************************************************

 -- 고객별 총 주문금액 – PARTITION BY 사용
 SELECT T1.CUS_ID
      , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) ORD_AMT
      , SUM(SUM(T1.ORD_AMT)) OVER(PARTITION BY T1.CUS_ID) BY_USR_AMT
   FROM T_ORD T1
  WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
    AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
  GROUP BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM')
  ORDER BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM');


 -- ************************************************
 -- PART III - 9.3.2 SQL2
 -- ************************************************

 -- 고객별 총 주문금액 – 서브쿼리로 해결
 SELECT T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) ORD_AMT
      , (SELECT SUM(A.ORD_AMT)
           FROM T_ORD A
          WHERE A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
            AND A.ORD_DT < TO_DATE('20170601','YYYYMMDD')
            AND A.CUS_ID = T1.CUS_ID
         ) BY_USR_AMT
   FROM T_ORD T1
  WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
    AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
  GROUP BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM')
  ORDER BY T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM');



 -- ************************************************
 -- PART III - 9.3.2 SQL3
 -- ************************************************

 -- 고객별 총 주문금액 – 인라인-뷰로 해결
 SELECT T0.CUS_ID ,T0.ORD_YM ,T0.ORD_AMT ,T2.BY_USR_AMT
   FROM (
         SELECT T1.CUS_ID ,TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM ,SUM(T1.ORD_AMT) ORD_AMT
           FROM T_ORD T1
          WHERE T1.CUS_ID IN ('CUS_0002','CUS_0003')
            AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
            AND T1.ORD_DT < TO_DATE('20170601','YYYYMMDD')
          GROUP BY T1.CUS_ID,TO_CHAR(T1.ORD_DT,'YYYYMM')
        ) T0
      , (
         SELECT A.CUS_ID ,SUM(A.ORD_AMT) BY_USR_AMT
           FROM T_ORD A
          WHERE A.CUS_ID IN ('CUS_0002','CUS_0003')
            AND A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
            AND A.ORD_DT < TO_DATE('20170601','YYYYMMDD')
         GROUP BY A.CUS_ID
        ) T2
  WHERE T0.CUS_ID = T2.CUS_ID
  ORDER BY T0.CUS_ID ,T0.ORD_YM;



 -- ************************************************
 -- PART III - 9.3.3 SQL1
 -- ************************************************

 -- 주문년월별 주문금액 순위 구하기 – ROW_NUMBER 사용
 SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
      , SUM(T1.ORD_AMT) ORD_AMT
      , ROW_NUMBER() OVER(ORDER BY SUM(T1.ORD_AMT) DESC) ORD_AMT_RANK
   FROM T_ORD T1
  GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
  ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM');


 -- ************************************************
 -- PART III - 9.3.3 SQL2
 -- ************************************************

 -- 주문년월별 주문금액 순위 구하기 – ROWNUM으로 해결
 SELECT T0.ORD_YM
      , T0.ORD_AMT
      , ROWNUM ORD_AMT_RANK
   FROM (
         SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
              , SUM(T1.ORD_AMT) ORD_AMT
           FROM T_ORD T1
          GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
          ORDER BY SUM(T1.ORD_AMT) DESC
         ) T0
  ORDER BY T0.ORD_YM;


 -- ************************************************
 -- PART III - 9.3.3 SQL3
 -- ************************************************

 -- 주문년월별 주문금액 순위 구하기 – 서브쿼리로 해결
 SELECT T2.ORD_YM
      , T2.ORD_AMT
      , (
         SELECT COUNT(*)
           FROM (
                 SELECT TO_CHAR(A.ORD_DT,'YYYYMM') ORD_YM
                      , SUM(A.ORD_AMT) ORD_AMT
                   FROM T_ORD A
                  GROUP BY TO_CHAR(A.ORD_DT,'YYYYMM')) B
                  WHERE B.ORD_AMT >= T2.ORD_AMT
         ) ORD_AMT_RANK
   FROM (
         SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
              , SUM(T1.ORD_AMT) ORD_AMT
           FROM T_ORD T1
          GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
          ORDER BY SUM(T1.ORD_AMT) DESC
        ) T2
 ORDER BY T2.ORD_YM;


 -- ************************************************
 -- PART III - 9.3.3 SQL4
 -- ************************************************

 -- 주문년월별 주문금액 순위 구하기 – 인라인-뷰와 셀프-조인으로 해결
 SELECT T0.ORD_YM ,MAX(T0.ORD_AMT) ORD_AMT ,COUNT(*) ORD_AMT_RANK
   FROM (
         SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
              , SUM(T1.ORD_AMT) ORD_AMT
           FROM T_ORD T1
          GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
         ) T0
      , (
         SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
              , SUM(T1.ORD_AMT) ORD_AMT
           FROM T_ORD T1
          GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
         ) T3
  WHERE T3.ORD_AMT >= T0.ORD_AMT
  GROUP BY T0.ORD_YM
  ORDER BY T0.ORD_YM;
