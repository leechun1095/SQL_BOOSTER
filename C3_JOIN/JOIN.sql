-- ************************************************
-- PART I - 3.1.1 SQL2
-- ************************************************
-- M_CUS와 T_ORD의 이너-조인
SELECT T1.CUS_ID ,T1.CUS_GD ,T2.ORD_SEQ ,T2.CUS_ID ,T2.ORD_DT
  FROM M_CUS T1
		 , T_ORD T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_GD = 'A'
   AND T2.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T2.ORD_DT < TO_DATE('20170201','YYYYMMDD');

-- ************************************************
-- PART I - 3.1.3 SQL1
-- ************************************************
-- 특정 고객의 17년 3월의 아이템평가(T_ITM_EVL)기록과 3월 주문(T_ORD)에 대해,
-- 고객ID, 고객명별 아이템평가 건수, 주문건수를 출력

SELECT T1.CUS_ID ,T1.CUS_NM
		 , COUNT(DISTINCT T2.ITM_ID||'-'||TO_CHAR(T2.EVL_LST_NO)) EVAL_CNT
		 , COUNT(DISTINCT T3.ORD_SEQ) ORD_CNT
  FROM M_CUS T1
		 , T_ITM_EVL T2
		 , T_ORD T3
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_ID = T3.CUS_ID
   AND T1.CUS_ID = 'CUS_0023'
   AND T2.EVL_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T2.EVL_DT < TO_DATE('20170401','YYYYMMDD')
   AND T3.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T3.ORD_DT < TO_DATE('20170401','YYYYMMDD')
 GROUP BY T1.CUS_ID ,T1.CUS_NM;

-- ************************************************
-- PART I - 3.1.3 SQL2
-- ************************************************
-- M:1:M의 관계를 UNION ALL로 해결
SELECT T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,SUM(T1.EVL_CNT) EVL_CNT ,SUM(T1.ORD_CNT) ORD_CNT
  FROM (
    		SELECT T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,COUNT(*) EVL_CNT ,NULL ORD_CNT
    		  FROM M_CUS T1
    				 , T_ITM_EVL T2
    		 WHERE T1.CUS_ID = T2.CUS_ID
    		   AND T2.CUS_ID = 'CUS_0023'
    		   AND T2.EVL_DT >= TO_DATE('20170301','YYYYMMDD')
    		   AND T2.EVL_DT < TO_DATE('20170401','YYYYMMDD')
    		 GROUP BY T1.CUS_ID ,T1.CUS_NM
    		 UNION ALL
    		SELECT T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,NULL EVL_CNT ,COUNT(*) ORD_CNT
    		  FROM M_CUS T1
    				 , T_ORD T3
    		 WHERE T1.CUS_ID = T3.CUS_ID
    		   AND T3.CUS_ID = 'CUS_0023'
    		   AND T3.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    		   AND T3.ORD_DT < TO_DATE('20170401','YYYYMMDD')
    		 GROUP BY T1.CUS_ID ,T1.CUS_NM
  ) T1
GROUP BY T1.CUS_ID;

-- ************************************************
-- PART I - 3.1.3 SQL3
-- ************************************************
-- M:1:M의 관계를 UNION ALL로 해결 – 성능을 고려, M_CUS를 인라인-뷰 바깥에서 한 번만 사용
SELECT T1.CUS_ID ,MAX(T1.CUS_NM) CUS_NM ,SUM(T4.EVL_CNT) EVL_CNT ,SUM(T4.ORD_CNT) ORD_CNT
  FROM M_CUS T1
		 , (
    		SELECT  T2.CUS_ID ,COUNT(*) EVL_CNT ,NULL ORD_CNT
    		FROM    T_ITM_EVL T2
    		WHERE   T2.CUS_ID = 'CUS_0023'
    		AND     T2.EVL_DT >= TO_DATE('20170301','YYYYMMDD')
    		AND     T2.EVL_DT < TO_DATE('20170401','YYYYMMDD')
    		GROUP BY T2.CUS_ID
    		UNION ALL
    		SELECT  T3.CUS_ID ,NULL EVL_CNT ,COUNT(*) ORD_CNT
    		FROM    T_ORD T3
    		WHERE   T3.CUS_ID = 'CUS_0023'
    		AND     T3.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    		AND     T3.ORD_DT < TO_DATE('20170401','YYYYMMDD')
    		GROUP BY T3.CUS_ID
      ) T4
 WHERE T1.CUS_ID = T4.CUS_ID
 GROUP BY T1.CUS_ID;

-- ************************************************
-- PART I - 3.1.3 SQL4
-- ************************************************
-- M:1:M의 관계에서 M 집합들을  1집합으로 만들어서 처리
SELECT T1.CUS_ID
		 , T1.CUS_NM
		 , T2.EVL_CNT
		 , T3.ORD_CNT
  FROM M_CUS T1
		 , (
    		SELECT  T2.CUS_ID
    				,COUNT(*) EVL_CNT
    		FROM    T_ITM_EVL T2
    		WHERE   T2.CUS_ID = 'CUS_0023'
    		AND     T2.EVL_DT >= TO_DATE('20170301','YYYYMMDD')
    		AND     T2.EVL_DT < TO_DATE('20170401','YYYYMMDD')
    		GROUP BY T2.CUS_ID
		   ) T2
		 , (
    		SELECT  T3.CUS_ID
    				,COUNT(*) ORD_CNT
    		FROM    T_ORD T3
    		WHERE   T3.CUS_ID = 'CUS_0023'
    		AND     T3.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    		AND     T3.ORD_DT < TO_DATE('20170401','YYYYMMDD')
    		GROUP BY T3.CUS_ID
    	 ) T3
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T1.CUS_ID = T3.CUS_ID
   AND T1.CUS_ID = 'CUS_0023';

-- ************************************************
-- PART I - 3.1.4 SQL1
-- ************************************************
-- CASE를 이용해 가격유형(ORD_AMT_TP)별로 주문 건수를 카운트
SELECT T1.ORD_ST
		 , CASE WHEN T1.ORD_AMT >= 5000 THEN 'High Order'
			      WHEN T1.ORD_AMT >= 3000 THEN 'Middle Order'
			 ELSE 'Low Order'
			 END ORD_AMT_TP
		 , COUNT(*) ORD_CNT
  FROM T_ORD T1
GROUP BY T1.ORD_ST
		 , CASE WHEN T1.ORD_AMT >= 5000 THEN 'High Order'
			      WHEN T1.ORD_AMT >= 3000 THEN 'Middle Order'
			 ELSE 'Low Order'
			 END
 ORDER BY 1, 2;

-- ************************************************
-- PART I - 3.1.4 SQL2
-- ************************************************
--주문금액유형 테이블 생성
CREATE TABLE M_ORD_AMT_TP
(
	ORD_AMT_TP VARCHAR2(40) NOT NULL,
	FR_AMT NUMBER(18,3) NULL,
	TO_AMT NUMBER(18,3) NULL
);

CREATE UNIQUE INDEX PK_M_ORD_AMT_TP ON M_ORD_AMT_TP(ORD_AMT_TP);

ALTER TABLE M_ORD_AMT_TP
	ADD CONSTRAINT PK_M_ORD_AMT_TP PRIMARY KEY(ORD_AMT_TP) USING INDEX;

-- 테스트 데이터 생성.
INSERT INTO M_ORD_AMT_TP(ORD_AMT_TP ,FR_AMT ,TO_AMT)
SELECT 'Low Order' ,0 ,3000 FROM DUAL UNION ALL
SELECT 'Middle Order' ,3000 ,5000 FROM DUAL UNION ALL
SELECT 'High Order' ,5000 ,999999999999 FROM DUAL;
COMMIT;

-- ************************************************
-- PART I - 3.1.4 SQL3
-- ************************************************
-- RANGE-JOIN을 이용해 가격유형(ORD_AMT_TP)별로 주문 건수를 카운트
SELECT T1.ORD_ST ,T2.ORD_AMT_TP ,COUNT(*) ORD_CNT
  FROM T_ORD T1
		 , M_ORD_AMT_TP T2
 WHERE NVL(T1.ORD_AMT,0) >= T2.FR_AMT
   AND NVL(T1.ORD_AMT,0) < T2.TO_AMT
 GROUP BY T1.ORD_ST ,T2.ORD_AMT_TP
 ORDER BY 1, 2;

-- ************************************************
-- PART I - 3.2.1 SQL1
-- ************************************************
-- 이너-조인과 아우터-조인의 비교
SELECT T1.CUS_ID
		 , T1.CUS_NM
		 , T2.CUS_ID
		 , T2.ITM_ID
		 , T2.EVL_LST_NO
  FROM M_CUS T1
		 , T_ITM_EVL T2
 WHERE T1.CUS_ID = 'CUS_0002'
   AND T1.CUS_ID = T2.CUS_ID;

SELECT T1.CUS_ID
		 , T1.CUS_NM
		 , T2.CUS_ID
		 , T2.ITM_ID
		 , T2.EVL_LST_NO
  FROM M_CUS T1
		 , T_ITM_EVL T2
 WHERE T1.CUS_ID = 'CUS_0002'
   AND T1.CUS_ID = T2.CUS_ID(+);

-- ************************************************
-- PART I - 3.2.1 SQL2
-- ************************************************
-- 아우터-조인, 한 명은 평가가 있음, 한 명은 평가가 없음
SELECT T1.CUS_ID ,T1.CUS_NM
		 , T2.CUS_ID ,T2.ITM_ID ,T2.EVL_LST_NO
  FROM M_CUS T1
		 , T_ITM_EVL T2
 WHERE T1.CUS_ID IN ('CUS_0002','CUS_0011')
   AND T1.CUS_ID = T2.CUS_ID(+)
 ORDER BY T1.CUS_ID;

-- ************************************************
-- PART I - 3.2.2 SQL1
-- ************************************************
-- 필터 조건에 (+)표시 유무에 따른 결과 비교
SELECT T1.CUS_ID ,T1.CUS_NM
		 , T2.CUS_ID ,T2.ITM_ID
		 , T2.EVL_LST_NO ,T2.EVL_DT
  FROM M_CUS T1
		 , T_ITM_EVL T2
 WHERE T1.CUS_ID IN ('CUS_0073')
   AND T1.CUS_ID = T2.CUS_ID(+)
   AND T2.EVL_DT >= TO_DATE('20170201','YYYYMMDD')
   AND T2.EVL_DT < TO_DATE('20170301','YYYYMMDD');

SELECT T1.CUS_ID ,T1.CUS_NM
		 , T2.CUS_ID ,T2.ITM_ID
		 , T2.EVL_LST_NO ,T2.EVL_DT
  FROM M_CUS T1
		 , T_ITM_EVL T2
 WHERE T1.CUS_ID IN ('CUS_0073')
   AND T1.CUS_ID = T2.CUS_ID(+)
   AND T2.EVL_DT(+) >= TO_DATE('20170201','YYYYMMDD')
   AND T2.EVL_DT(+) < TO_DATE('20170301','YYYYMMDD');

-- ************************************************
-- PART I - 3.2.3 SQL1
-- ************************************************
-- 불가능한 아우터-조인
SELECT T1.CUS_ID ,T2.ITM_ID ,T1.ORD_DT ,T3.ITM_ID ,T3.EVL_PT
  FROM T_ORD T1
		 , T_ORD_DET T2
		 , T_ITM_EVL T3
 WHERE T1.ORD_SEQ = T2.ORD_SEQ
   AND T1.CUS_ID = 'CUS_0002'
   AND T1.ORD_DT >= TO_DATE('20170122','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170123','YYYYMMDD')
   AND T3.CUS_ID(+) = T1.CUS_ID
   AND T3.ITM_ID(+) = T2.ITM_ID;

-- ORA-01417: a table may be outer joined to at most one other table

-- ************************************************
-- PART I - 3.2.3 SQL2
-- ************************************************
-- 인라인-뷰를 사용한 아우터-조인
SELECT T0.CUS_ID ,T0.ITM_ID ,T0.ORD_DT
		 , T3.ITM_ID ,T3.EVL_PT
  FROM (
    		SELECT  T1.CUS_ID ,T2.ITM_ID ,T1.ORD_DT
    		FROM    T_ORD T1
    				,T_ORD_DET T2
    		WHERE   T1.ORD_SEQ = T2.ORD_SEQ
    		AND     T1.CUS_ID = 'CUS_0002'
    		AND     T1.ORD_DT >= TO_DATE('20170122','YYYYMMDD')
    		AND     T1.ORD_DT < TO_DATE('20170123','YYYYMMDD')
  ) T0
		 , T_ITM_EVL T3
 WHERE T3.CUS_ID(+) = T0.CUS_ID
   AND T3.ITM_ID(+) = T0.ITM_ID
 ORDER BY T0.CUS_ID;

-- ************************************************
-- PART I - 3.2.3 SQL3
-- ************************************************
-- ANSI 구문을 사용해 불가능한 아우터-조인 해결
SELECT T1.CUS_ID ,T2.ITM_ID ,T1.ORD_DT
		 , T3.ITM_ID ,T3.EVL_PT
  FROM T_ORD T1
 INNER JOIN T_ORD_DET T2
	  ON (T1.ORD_SEQ = T2.ORD_SEQ
	 AND T1.CUS_ID = 'CUS_0002'
	 AND T1.ORD_DT >= TO_DATE('20170122','YYYYMMDD')
	 AND T1.ORD_DT < TO_DATE('20170123','YYYYMMDD'))
  LEFT OUTER JOIN T_ITM_EVL T3
		ON (T3.CUS_ID = T1.CUS_ID
	 AND T3.ITM_ID = T2.ITM_ID)
;

-- ************************************************
-- PART I - 3.2.4 SQL1
-- ************************************************
-- 아우터-조인과 이너-조인을 동시에 사용하는 SQL
SELECT T1.CUS_ID ,T2.ORD_SEQ ,T2.ORD_DT ,T3.ORD_SEQ ,T3.ITM_ID
  FROM M_CUS T1
		 , T_ORD T2
		 , T_ORD_DET T3
 WHERE T1.CUS_ID = 'CUS_0073'
   AND T1.CUS_ID = T2.CUS_ID(+)
   AND T2.ORD_DT(+) >= TO_DATE('20170122','YYYYMMDD')
   AND T2.ORD_DT(+) < TO_DATE('20170123','YYYYMMDD')
   AND T3.ORD_SEQ = T2.ORD_SEQ;

-- ************************************************
-- PART I - 3.2.5 SQL1
-- ************************************************
-- 고객ID별 주문건수, 주문이 없는 고객도 나오도록 처리
SELECT T1.CUS_ID
		 , COUNT(*) ORD_CNT_1
		 , COUNT(T2.ORD_SEQ) ORD_CNT_2
  FROM M_CUS T1
		 , T_ORD T2
 WHERE T1.CUS_ID = T2.CUS_ID(+)
   AND T2.ORD_DT(+) >= TO_DATE('20170101','YYYYMMDD')
   AND T2.ORD_DT(+) < TO_DATE('20170201','YYYYMMDD')
 GROUP BY T1.CUS_ID
 ORDER BY COUNT(*) ,T1.CUS_ID;

-- ************************************************
-- PART I - 3.2.5 SQL2
-- ************************************************
-- 아이템ID별 주문수량
-- 'PC, ELEC' 아이템 유형의 아이템별 주문수량 조회 (주문이 없어도 0으로 나와야 한다.)
SELECT T1.ITM_ID ,T1.ITM_NM ,NVL(T2.ORD_QTY,0)
  FROM M_ITM T1
		 , ( SELECT B.ITM_ID ,SUM(B.ORD_QTY) ORD_QTY
			     FROM T_ORD A
					    , T_ORD_DET B
			    WHERE A.ORD_SEQ = B.ORD_SEQ
			      AND A.ORD_ST = 'COMP' --주문상태=완료
			      AND A.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
			      AND A.ORD_DT < TO_DATE('20170201','YYYYMMDD')
			    GROUP BY B.ITM_ID
       ) T2
 WHERE T1.ITM_ID = T2.ITM_ID(+)
   AND T1.ITM_TP IN ('PC','ELEC')
 ORDER BY T1.ITM_TP ,T1.ITM_ID;

-- ************************************************
-- PART I - 3.3.1 SQL1
-- ************************************************
-- 고객등급(M_CUS.CUS_GD)과 아이템유형(M_ITM.ITM_TP)의 조합 가능한 모든 데이터
SELECT T1.CUS_GD ,T2.ITM_TP
  FROM (SELECT DISTINCT A.CUS_GD FROM M_CUS A) T1
		 , (SELECT DISTINCT A.ITM_TP FROM M_ITM A ) T2
 ORDER BY T1.CUS_GD ,T2.ITM_TP;

-- ************************************************
-- PART I - 3.3.2 SQL1
-- ************************************************
-- 조인 조건의 누락
SELECT COUNT(*)
  FROM T_ORD T1
		 , T_ORD_DET T2;

-- ************************************************
-- PART I - 3.3.2 SQL2
-- ************************************************
-- 조인 조건의 별칭 실수
SELECT COUNT(*)
  FROM T_ORD T1
		 , T_ORD_DET T2
 WHERE T1.ORD_SEQ = T1.ORD_SEQ;

-- ************************************************
-- PART I - 3.3.3 SQL1
-- ************************************************
-- 특정 고객 두 명의 2월, 3월, 4월의 월별 주문 건수
SELECT T1.CUS_ID ,T1.CUS_NM ,T2.ORD_YM ,T2.ORD_CNT
  FROM M_CUS T1
		 , ( SELECT A.CUS_ID
					    , TO_CHAR(A.ORD_DT,'YYYYMM') ORD_YM
					    , COUNT(*) ORD_CNT
			     FROM T_ORD A
			    WHERE A.CUS_ID IN ('CUS_0003','CUS_0004')
			      AND A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
			      AND A.ORD_DT < TO_DATE('20170501','YYYYMMDD')
			    GROUP BY A.CUS_ID
					       , TO_CHAR(A.ORD_DT,'YYYYMM')
		   ) T2
 WHERE T1.CUS_ID IN ('CUS_0003','CUS_0004')
   AND T1.CUS_ID = T2.CUS_ID(+)
 ORDER BY T1.CUS_ID ,T2.ORD_YM;

-- ************************************************
-- PART I - 3.3.3 SQL2
-- ************************************************
-- 특정 고객 두 명의 2월, 3월, 4월의 월별 주문 건수 – 주문이 없는 월도 0으로 나오게 처리
SELECT T0.CUS_ID ,T0.CUS_NM ,T0.BASE_YM ,NVL(T2.ORD_CNT,0) ORD_CNT
  FROM ( SELECT T1.CUS_ID
					    , T1.CUS_NM
					    , T4.BASE_YM
			     FROM M_CUS T1
					    , (
    					  SELECT TO_CHAR(ADD_MONTHS(TO_DATE('20170201','YYYYMMDD'),ROWNUM-1),'YYYYMM') BASE_YM
    					  FROM   DUAL
    					  CONNECT BY ROWNUM <= 3
					      ) T4
			    WHERE T1.CUS_ID IN ('CUS_0003','CUS_0004')
  ) T0
		 , ( SELECT A.CUS_ID
					    , TO_CHAR(A.ORD_DT,'YYYYMM') ORD_YM
					    , COUNT(*) ORD_CNT
			     FROM T_ORD A
			    WHERE A.CUS_ID IN ('CUS_0003','CUS_0004')
			      AND A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
			      AND A.ORD_DT < TO_DATE('20170501','YYYYMMDD')
			    GROUP BY A.CUS_ID
					       , TO_CHAR(A.ORD_DT,'YYYYMM')
  ) T2
 WHERE T0.CUS_ID = T2.CUS_ID(+)
   AND T0.BASE_YM = T2.ORD_YM(+)
 ORDER BY T0.CUS_ID ,T0.BASE_YM;

-- ************************************************
-- PART I - 3.3.3 SQL3
-- ************************************************
-- 고객등급, 아이템유형별 주문수량
SELECT A.CUS_GD ,D.ITM_TP
		 , SUM(C.ORD_QTY) ORD_QTY
  FROM M_CUS A
		 , T_ORD B
		 , T_ORD_DET C
		 , M_ITM D
 WHERE A.CUS_ID = B.CUS_ID
   AND C.ORD_SEQ = B.ORD_SEQ
   AND D.ITM_ID = C.ITM_ID
   AND B.ORD_ST = 'COMP'
 GROUP BY A.CUS_GD ,D.ITM_TP
 ORDER BY A.CUS_GD ,D.ITM_TP;

-- ************************************************
-- PART I - 3.3.3 SQL4
-- ************************************************
-- 고객등급, 아이템유형별 주문수량 – 주문이 없는 아이템유형도 나오도록 처리
SELECT T0.CUS_GD ,T0.ITM_TP ,NVL(T3.ORD_QTY,0) ORD_QTY
  FROM ( SELECT T1.CUS_GD ,T2.ITM_TP
				   FROM ( SELECT  A.BAS_CD CUS_GD FROM C_BAS_CD A WHERE A.BAS_CD_DV = 'CUS_GD') T1
						  , (SELECT  A.BAS_CD ITM_TP FROM C_BAS_CD A WHERE A.BAS_CD_DV = 'ITM_TP') T2
	) T0
		 , ( SELECT A.CUS_GD ,D.ITM_TP
						  , SUM(C.ORD_QTY) ORD_QTY
				   FROM M_CUS A
						  , T_ORD B
						  , T_ORD_DET C
						  , M_ITM D
				  WHERE A.CUS_ID = B.CUS_ID
				    AND C.ORD_SEQ = B.ORD_SEQ
				    AND D.ITM_ID = C.ITM_ID
				    AND B.ORD_ST = 'COMP'
				  GROUP BY A.CUS_GD ,D.ITM_TP
	) T3
 WHERE T0.CUS_GD = T3.CUS_GD(+)
   AND T0.ITM_TP = T3.ITM_TP(+)
 ORDER BY T0.CUS_GD ,T0.ITM_TP;

-- ************************************************
-- PART I - 3.3.4 SQL1
-- ************************************************
-- 테스트 주문데이터를 만들기 위한 SQL
SELECT ROWNUM ORD_NO ,T1.CUS_ID ,T2.ORD_ST ,T3.PAY_TP ,T4.ORD_DT
  FROM M_CUS T1
		 , ( SELECT 'WAIT' ORD_ST FROM DUAL UNION ALL
			   SELECT 'COMP' ORD_ST FROM DUAL ) T2
		 , ( SELECT  'CARD' PAY_TP FROM DUAL UNION ALL
			   SELECT  'BANK' PAY_TP FROM DUAL UNION ALL
			   SELECT  NULL PAY_TP FROM DUAL ) T3
		 , (
			   SELECT TO_DATE('20170101','YYYYMMDD') + (ROWNUM-1) ORD_DT
			     FROM DUAL
			  CONNECT BY ROWNUM <= 365 ) T4;

-- ************************************************
-- PART I - 3.3.4 SQL2
-- ************************************************
-- 의미 없는 숫자 집합
SELECT ROWNUM RNO FROM DUAL A CONNECT BY ROWNUM <= 10;

-- ************************************************
-- PART I - 3.3.4 SQL3
-- ************************************************
-- 데이터 값별로 분포도 조정
SELECT 'WAIT' ORD_ST FROM DUAL CONNECT BY ROWNUM <= 2 UNION ALL
SELECT 'COMP' ORD_ST FROM DUAL CONNECT BY ROWNUM <= 3
