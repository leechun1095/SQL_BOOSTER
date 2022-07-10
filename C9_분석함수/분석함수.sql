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
