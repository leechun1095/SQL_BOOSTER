-- ************************************************
-- PART I - 4.1.2 SQL1
-- ************************************************
-- 17년8월 총 주문금액 구하기 – SELECT절 단독 서브쿼리
SELECT TO_CHAR(T1.ORD_DT, 'YYYYMMDD') ORD_YMD
		 , SUM(T1.ORD_AMT) ORD_AMT
		 , (
        SELECT SUM(A.ORD_AMT)
        	FROM T_ORD A
         WHERE A.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
        	 AND A.ORD_DT < TO_DATE('20170901','YYYYMMDD')
		   ) TOTAL_ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMMDD');

-- ************************************************
-- PART I - 4.1.2 SQL2
-- ************************************************
-- 17년8월 총 주문금액, 주문일자의 주문금액비율 구하기 – SELECT절 단독 서브쿼리
-- 주문금액 비율 = 주문일자별 주문금액(ORD_AMT) / 17년8월 주문 총 금액(TOTAL_ORD_AMT) * 100.00
SELECT TO_CHAR(T1.ORD_DT, 'YYYYMMDD') ORD_YMD
     , SUM(T1.ORD_AMT) ORD_AMT
     , (
        SELECT SUM(A.ORD_AMT)
          FROM T_ORD A
         WHERE A.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
           AND A.ORD_DT < TO_DATE('20170901','YYYYMMDD')
       ) TOTAL_ORD_AMT
     , ROUND(SUM(T1.ORD_AMT) / (
                                SELECT  SUM(A.ORD_AMT)
                                FROM    T_ORD A
                                WHERE   A.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
                                AND     A.ORD_DT < TO_DATE('20170901','YYYYMMDD')
                               ) * 100,2
       ) ORD_AMT_RT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMMDD');

-- ************************************************
-- PART I - 4.1.2 SQL3
-- ************************************************
-- 인라인-뷰를 사용해 반복 서브쿼리를 제거하는 방법
SELECT T1.ORD_YMD
     , T1.ORD_AMT
     , T1.TOTAL_ORD_AMT
     , ROUND(T1.ORD_AMT / TOTAL_ORD_AMT * 100, 2) ORD_AMT_RATE
  FROM (
        SELECT TO_CHAR(T1.ORD_DT, 'YYYYMMDD') ORD_YMD
             , SUM(T1.ORD_AMT) ORD_AMT
             , (
                SELECT SUM(A.ORD_AMT)
                  FROM T_ORD A
                 WHERE A.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
                   AND A.ORD_DT < TO_DATE('20170901','YYYYMMDD')
               ) TOTAL_ORD_AMT
          FROM T_ORD T1
         WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
           AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
         GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMMDD')
  ) T1

-- ************************************************
-- PART I - 4.1.2 SQL4
-- ************************************************
-- 카테시안-조인을 사용해 반복 서브쿼리를 제거하는 방법
SELECT TO_CHAR(T1.ORD_DT, 'YYYYMMDD') ORD_YMD
     , SUM(T1.ORD_AMT) ORD_AMT
     , MAX(T2.TOTAL_ORD_AMT) TOTAL_ORD_AMT
     , ROUND(SUM(T1.ORD_AMT) / MAX(T2.TOTAL_ORD_AMT) * 100, 2) ORD_AMT_RT
  FROM T_ORD T1
     , (SELECT SUM(A.ORD_AMT) TOTAL_ORD_AMT
          FROM T_ORD A
         WHERE A.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
           AND A.ORD_DT < TO_DATE('20170901','YYYYMMDD')
       ) T2
 WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMMDD');

-- ************************************************
-- PART I - 4.1.3 SQL1
-- ************************************************
-- 코드값을 가져오는 SELECT 절 상관 서브쿼리
SELECT T1.ITM_TP
     , (SELECT A.BAS_CD_NM
          FROM C_BAS_CD A
         WHERE A.BAS_CD_DV = 'ITM_TP'
           AND A.BAS_CD = T1.ITM_TP  -- 기준코드 : KR
           AND A.LNG_CD = 'KO'
       ) ITM_TP_NM
     , T1.ITM_ID
     , T1.ITM_NM
  FROM M_ITM T1;

-- ************************************************
-- PART I - 4.1.3 SQL2
-- ************************************************
-- 고객정보를 가져오는 SELECT 절 상관 서브쿼리 -> (잘못된 사례)서브쿼리 2군데 사용됨
-- 불필요하게 M_CUS를 두번 접근할 필요가 없음
-- 해당 쿼리를 조인으로 변경하는 것이 좋다.
SELECT T1.CUS_ID
     , TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
     , (SELECT A.CUS_NM FROM M_CUS A WHERE A.CUS_ID = T1.CUS_ID) CUS_NM
     , (SELECT A.CUS_GD FROM M_CUS A WHERE A.CUS_ID = T1.CUS_ID) CUS_GD
     , T1.ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD');

-- 조인으로 변경한 쿼리
SELECT T1.CUS_ID
     , TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
     , A.CUS_NM
     , A.CUS_GD
     , T1.ORD_AMT
  FROM T_ORD T1
 INNER JOIN M_CUS A
    ON T1.CUS_ID = A.CUS_ID
 WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD');

-- ************************************************
-- PART I - 4.1.3 SQL3
-- ************************************************
-- 인라인-뷰 안에서 SELECT 절 서브쿼리를 사용한 예 -> (잘못된 사례)
-- 인라인-뷰가 1000건이고 바깥 GROUP 결과가 100건이면, 서브쿼리가 1000번 실행된다는 얘기임
-- SELECT 절의 상관 서브쿼리는 가능하면 인라인-뷰 바깥에서 사용해야 한다.
SELECT T1.CUS_ID
     , SUBSTR(T1.ORD_YMD,1,6) ORD_YM
     , MAX(T1.CUS_NM)
     , MAX(T1.CUS_GD)
     , T1.ORD_ST_NM
     , T1.PAY_TP_NM
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM (
        SELECT T1.CUS_ID
             , TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
             , T2.CUS_NM
             , T2.CUS_GD
             , (SELECT A.BAS_CD_NM
                  FROM C_BAS_CD A
                 WHERE A.BAS_CD_DV = 'ORD_ST'
                   AND A.BAS_CD = T1.ORD_ST
                   AND A.LNG_CD = 'KO'
               ) ORD_ST_NM
             , (SELECT A.BAS_CD_NM
                  FROM C_BAS_CD A
                 WHERE A.BAS_CD_DV = 'PAY_TP'
                   AND A.BAS_CD = T1.PAY_TP
                   AND A.LNG_CD = 'KO'
               ) PAY_TP_NM
             , T1.ORD_AMT
          FROM T_ORD T1, M_CUS T2 -- INNER JOIN
         WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
           AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
           AND T1.CUS_ID = T2.CUS_ID
       ) T1
 GROUP BY T1.CUS_ID, SUBSTR(T1.ORD_YMD,1,6), T1.ORD_ST_NM, T1.PAY_TP_NM;

-- SELECT 절의 상관 서브쿼리 인라인-뷰 바깥으로 빼기
-- 스칼라 서브쿼리 사용 시 GROUP BY에 스칼라 서브쿼리의 조건값을 꼭 넣어줘야한다.
-- GROUP BY에 서브쿼리 전체 넣으면 에러난다.
SELECT T1.CUS_ID
     , SUBSTR(T1.ORD_YMD,1,6) ORD_YM
     , MAX(T1.CUS_NM)
     , MAX(T1.CUS_GD)
     , (SELECT BAS_CD_NM
          FROM C_BAS_CD
         WHERE BAS_CD_DV = 'ORD_ST'
           AND BAS_CD = T1.ORD_ST
           AND LNG_CD = 'KO'
       ) ORD_ST_NM
     , (SELECT BAS_CD_NM
          FROM C_BAS_CD
         WHERE BAS_CD_DV = 'PAY_TP'
           AND BAS_CD = T1.PAY_TP
           AND LNG_CD = 'KO'
       ) PAY_TP_NM
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM (
        SELECT T1.CUS_ID
             , TO_CHAR(T1.ORD_DT,'YYYYMMDD') ORD_YMD
             , T2.CUS_NM
             , T2.CUS_GD
             , T1.ORD_AMT
             , T1.ORD_ST
             , T1.PAY_TP
          FROM T_ORD T1, M_CUS T2 -- INNER JOIN
         WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
           AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
           AND T1.CUS_ID = T2.CUS_ID
       ) T1
 GROUP BY T1.CUS_ID, SUBSTR(T1.ORD_YMD,1,6), T1.ORD_ST, T1.PAY_TP;

-- ************************************************
-- PART I - 4.1.3 SQL4
-- ************************************************
-- 서브쿼리 안에서 조인을 사용한 예
SELECT T1.ORD_DT
     , T2.ORD_QTY
     , T2.ITM_ID
     , T3.ITM_NM
     , (SELECT SUM(B.EVL_PT) / COUNT(*)
			    FROM M_ITM A
					   , T_ITM_EVL B
			   WHERE A.ITM_TP = T3.ITM_TP
			     AND B.ITM_ID = A.ITM_ID
			     AND B.EVL_DT < T1.ORD_DT
		   ) ITM_TP_EVL_PT_AVG
  FROM T_ORD T1
		 , T_ORD_DET T2
		 , M_ITM T3
 WHERE T1.ORD_DT >= TO_DATE('20170801','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170901','YYYYMMDD')
   AND T3.ITM_ID = T2.ITM_ID
   AND T1.ORD_SEQ = T2.ORD_SEQ
 ORDER BY T1.ORD_DT, T2.ITM_ID;

-- ************************************************
-- PART I - 4.1.4 SQL1
-- ************************************************
-- 실행이 불가능한 SELECT 절의 서브쿼리
--SELECT 절의 서브쿼리에서 두 컬럼을 지정.(오류남)
SELECT T1.ORD_DT ,T1.CUS_ID
		 , (SELECT A.CUS_NM ,A.CUS_GD FROM M_CUS A WHERE A.CUS_ID = T1.CUS_ID) CUS_NM_GD
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170401','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD');

--SELECT 절의 서브쿼리에서 두 건 이상의 데이터가 나오는 경우.(오류남)
SELECT T1.ORD_DT ,T1.CUS_ID
		 , (SELECT A.ITM_ID FROM T_ORD_DET A WHERE A.ORD_SEQ = T1.ORD_SEQ) ITM_LIST
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170401','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD');

-- ************************************************
-- PART I - 4.1.4 SQL2
-- ************************************************
-- 고객 이름과 등급을 합쳐서 하나의 컬럼으로 처리
-- 단가(UNT_PRC)와 주문수량(ORD_QTY)를 곱해서 주문금액으로 처리.
SELECT T1.ORD_DT
     , T1.CUS_ID
		 , (SELECT A.CUS_NM||'('||CUS_GD||')' FROM M_CUS A WHERE A.CUS_ID = T1.CUS_ID) CUS_NM_GD
		 , (SELECT SUM(A.UNT_PRC * A.ORD_QTY) FROM T_ORD_DET A WHERE A.ORD_SEQ = T1.ORD_SEQ) ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170401','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD');

-- ************************************************
-- PART I - 4.1.4 SQL3
-- ************************************************
-- 고객별 마지막 ORD_SEQ의 주문금액
SELECT T1.CUS_ID
		 , T1.CUS_NM
     -- 문자열로 연결하여(||) MAX() 하면 가장 나중의 SEQ가 구해짐.
		 , (SELECT TO_NUMBER(SUBSTR(MAX(LPAD(TO_CHAR(A.ORD_SEQ),8,'0')||TO_CHAR(A.ORD_AMT)),9))
					FROM T_ORD A
         WHERE A.CUS_ID = T1.CUS_ID
       ) LAST_ORD_AMT
  FROM M_CUS T1
 ORDER BY T1.CUS_ID;

-- ************************************************
-- PART I - 4.1.4 SQL4
-- ************************************************
-- 고객별 마지막 ORD_SEQ의 주문금액 – 중첩된 서브쿼리
SELECT T1.CUS_ID
		 , T1.CUS_NM
		 , (
  			SELECT B.ORD_AMT
  			  FROM T_ORD B
  			 WHERE B.ORD_SEQ = (SELECT MAX(A.ORD_SEQ) FROM T_ORD A WHERE A.CUS_ID = T1.CUS_ID)
			 ) LAST_ORD_AMT
  FROM M_CUS T1
 ORDER BY T1.CUS_ID;

-- ************************************************
-- PART I - 4.1.4 SQL5
-- ************************************************
-- 잠재적인 오류가 존재하는 서브쿼리 – 정상 실행
-- T_ORD 테이블의 PK(ORD_SEQ,	ORD_DET_NO)
SELECT T1.ORD_DT
		 , T1.CUS_ID
		 , (SELECT A.ORD_QTY FROM T_ORD_DET A WHERE A.ORD_SEQ = T1.ORD_SEQ) ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_SEQ = 2297;

-- ************************************************
-- PART I - 4.1.4 SQL6
-- ************************************************
-- 잠재적인 오류가 존재하는 서브쿼리 – 오류 발생
--1. 오류가 발생하는 서브쿼리(ORD_SEQ = 2291)
-- T_ORD 테이블의 PK(ORD_SEQ,	ORD_DET_NO)
SELECT T1.ORD_DT
		 , T1.CUS_ID
		 , (SELECT A.ORD_QTY FROM T_ORD_DET A WHERE A.ORD_SEQ = T1.ORD_SEQ) ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_SEQ = 2291;

--2. T_ORD_DET에 ORD_SEQ가 2291인 데이터는 두 건이 존재한다.
SELECT T1.*
  FROM T_ORD_DET T1
 WHERE T1.ORD_SEQ = 2291;

-- ************************************************
-- PART I - 4.1.5 SQL1
-- ************************************************
-- 마지막 주문 한 건을 조회하는 SQL, ORD_SEQ가 가장 큰 데이터가 마지막 주문이다.
SELECT *
  FROM T_ORD T1
 WHERE T1.ORD_SEQ = (SELECT MAX(A.ORD_SEQ) FROM T_ORD A);

-- ************************************************
-- PART I - 4.1.5 SQL2
-- ************************************************
-- 마지막 주문 한 건을 조회하는 SQL, ORDER BY와 ROWNUM을 사용
SELECT *
  FROM (
    		SELECT *
    		  FROM T_ORD T1
    		 ORDER BY T1.ORD_SEQ DESC
		   ) A
 WHERE ROWNUM <= 1;

-- ************************************************
-- PART I - 4.1.5 SQL3
-- ************************************************
-- 마지막 주문 일자의 데이터를 가져오는 SQL
SELECT *
  FROM T_ORD T1
 WHERE T1.ORD_DT = (SELECT MAX(A.ORD_DT) FROM T_ORD A);

-- ************************************************
-- PART I - 4.1.5 SQL4
-- ************************************************
-- 3월 주문 건수가 4건 이상인 고객의 3월달 주문 리스트
SELECT *
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170401','YYYYMMDD')
   AND T1.CUS_ID IN (
              			 SELECT A.CUS_ID
              			   FROM T_ORD A
              			  WHERE A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
              			    AND A.ORD_DT < TO_DATE('20170401','YYYYMMDD')
              			  GROUP BY A.CUS_ID
              			 HAVING COUNT(*)>=4
              			);

-- ************************************************
-- PART I - 4.1.5 SQL5
-- ************************************************
-- 3월 주문 건수가 4건 이상인 고객의 3월달 주문 리스트 – 조인으로 처리
-- 4건 이상인 고객이 5명이므로 전체(T_DRD A)에서 고객 5명에 대한 데이터만 이너 조인되므로 조건절과 동일한 결과를 가져옴
SELECT T1.*
  FROM T_ORD T1
		 , (
  			SELECT A.CUS_ID
  			  FROM T_ORD A
  			 WHERE A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
  			   AND A.ORD_DT < TO_DATE('20170401','YYYYMMDD')
  			 GROUP BY A.CUS_ID
  			HAVING COUNT(*)>=4
  		 ) T2
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170401','YYYYMMDD')
   AND T1.CUS_ID = T2.CUS_ID;

-- ANSI
SELECT T1.*
  FROM T_ORD T1
 INNER JOIN (
             SELECT A.CUS_ID
               FROM T_ORD A
              WHERE A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
                AND A.ORD_DT < TO_DATE('20170401','YYYYMMDD')
              GROUP BY A.CUS_ID
             HAVING COUNT(*)>=4
            ) T2
    ON T1.CUS_ID = T2.CUS_ID
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170401','YYYYMMDD');

-- ************************************************
-- PART I - 4.1.6 SQL1
-- ************************************************
-- 3월에 주문이 존재하는 고객들을 조회
SELECT *
  FROM M_CUS T1
 WHERE EXISTS(
              SELECT *
                FROM T_ORD A
               WHERE A.CUS_ID = T1.CUS_ID
                 AND A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
                 AND A.ORD_DT < TO_DATE('20170401','YYYYMMDD')
             );

-- ************************************************
-- PART I - 4.1.6 SQL2
-- ************************************************
-- 3월에 ELEC 아이템유형의 주문이 존재하는 고객들을 조회
SELECT *
  FROM M_CUS T1
 WHERE EXISTS(
        		  SELECT *
        		    FROM T_ORD A
        				   , T_ORD_DET B
        				   , M_ITM C
        		   WHERE A.CUS_ID = T1.CUS_ID
        		     AND A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
        		     AND A.ORD_DT < TO_DATE('20170401','YYYYMMDD')
        		     AND A.ORD_SEQ = B.ORD_SEQ
        		     AND B.ITM_ID = C.ITM_ID
        		     AND C.ITM_TP = 'ELEC'
        		 );

-- ************************************************
-- PART I - 4.1.6 SQL3
-- ************************************************
-- 전체 고객을 조회, 3월에 주문이 존재하는지 여부를 같이 보여줌
SELECT T1.CUS_ID ,T1.CUS_NM
		 , (CASE WHEN
				  EXISTS(
    					   SELECT *
    					     FROM T_ORD A
    					    WHERE A.CUS_ID = T1.CUS_ID
    					      AND A.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
    					      AND A.ORD_DT < TO_DATE('20170401','YYYYMMDD')
    					  )
		    THEN 'Y'
		    ELSE 'N' END
       ) ORD_YN_03
  FROM M_CUS T1;

-- ************************************************
-- PART I - 4.2.1 SQL1
-- ************************************************
-- MERGE 문을 위한 테스트 테이블 생성
CREATE TABLE M_CUS_CUD_TEST AS
SELECT *
  FROM M_CUS T1;

ALTER TABLE M_CUS_CUD_TEST
	ADD CONSTRAINT PK_M_CUS_CUD_TEST PRIMARY KEY(CUS_ID) USING INDEX;

-- ************************************************
-- PART I - 4.2.1 SQL2
-- ************************************************
-- CUS_0090 고객을 입력하거나 변경하는 PL/SQL
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE v_EXISTS_YN varchar2(1);

BEGIN
	SELECT NVL(MAX('Y'),'N')
	  INTO v_EXISTS_YN
	  FROM DUAL A
	 WHERE EXISTS(
        			  SELECT *
        			    FROM M_CUS_CUD_TEST T1
        			   WHERE T1.CUS_ID = 'CUS_0090'
			         );

  IF v_EXISTS_YN = 'N' THEN
    INSERT INTO M_CUS_CUD_TEST (CUS_ID ,CUS_NM ,CUS_GD)
		VALUES ('CUS_0090' ,'NAME_0090' ,'A');
		DBMS_OUTPUT.PUT_LINE('INSERT NEW CUST');
	ELSE
		UPDATE M_CUS_CUD_TEST T1
		   SET T1.CUS_NM = 'NAME_0090'
				 , T1.CUS_GD = 'A'
		 WHERE CUS_ID = 'CUS_0090';
		DBMS_OUTPUT.PUT_LINE('UPDATE OLD CUST');
	END IF;
	COMMIT;
END;

-- ************************************************
-- PART I - 4.2.1 SQL3
-- ************************************************
-- 고객을 입력하거나 변경하는 SQL – MERGE 문으로 처리
 MERGE INTO M_CUS_CUD_TEST T1
 USING (
  	    SELECT 'CUS_0090' CUS_ID
  		       , 'NAME_0090' CUS_NM
  		       , 'A' CUS_GD
	        FROM DUAL
  	   ) T2
	  ON (T1.CUS_ID = T2.CUS_ID)
  WHEN MATCHED THEN
UPDATE SET T1.CUS_NM = T2.CUS_NM
				 , T1.CUS_GD = T2.CUS_GD
  WHEN NOT MATCHED THEN
INSERT (T1.CUS_ID ,T1.CUS_NM ,T1.CUS_GD)
VALUES (T2.CUS_ID ,T2.CUS_NM ,T2.CUS_GD);
COMMIT;

-- ************************************************
-- PART I - 4.2.2 SQL1
-- ************************************************
-- 월별고객주문 테이블 생성 및 기조 데이터 입력
CREATE TABLE S_CUS_YM
(
	BAS_YM	VARCHAR2(6) NOT NULL,
	CUS_ID 	VARCHAR2(40) NOT NULL,
	ITM_TP 	VARCHAR2(40) NOT NULL,
	ORD_QTY NUMBER(18,3) NULL,
	ORD_AMT NUMBER(18,3) NULL
);

CREATE UNIQUE INDEX PK_S_CUS_YM ON S_CUS_YM(BAS_YM, CUS_ID, ITM_TP);

ALTER TABLE S_CUS_YM
	ADD CONSTRAINT PK_S_CUM_YM PRIMARY KEY (BAS_YM, CUS_ID, ITM_TP);

INSERT INTO S_CUS_YM (BAS_YM ,CUS_ID ,ITM_TP ,ORD_QTY ,ORD_AMT)
SELECT '201702' BAS_YM ,T1.CUS_ID ,T2.BAS_CD ITM_TP ,NULL ORD_QTY ,NULL ORD_AMT
  FROM M_CUS T1
		 , C_BAS_CD T2
 WHERE T2.BAS_CD_DV = 'ITM_TP'
   AND T2.LNG_CD = 'KO';

COMMIT;

-- ************************************************
-- PART I - 4.2.2 SQL2
-- ************************************************
-- 월별고객주문의 주문수량, 주문금액 업데이트 (서브쿼리 2번 사용으로 성능 안좋음)
 UPDATE S_CUS_YM T1
    SET T1.ORD_QTY = (
              				SELECT SUM(B.ORD_QTY)
              				  FROM T_ORD A
              						 , T_ORD_DET B
              						 , M_ITM C
              				 WHERE A.ORD_SEQ = B.ORD_SEQ
              				   AND C.ITM_ID = B.ITM_ID
              				   AND C.ITM_TP = T1.ITM_TP
              				   AND A.CUS_ID = T1.CUS_ID
              				   AND A.ORD_DT >= TO_DATE(T1.BAS_YM||'01','YYYYMMDD')
              				   AND A.ORD_DT < ADD_MONTHS(TO_DATE(T1.BAS_YM||'01','YYYYMMDD'), 1)
              				)
		  , T1.ORD_AMT = (
              				SELECT SUM(B.UNT_PRC * B.ORD_QTY)
              				  FROM T_ORD A
              						 , T_ORD_DET B
              						 , M_ITM C
              				 WHERE A.ORD_SEQ = B.ORD_SEQ
              				   AND C.ITM_ID = B.ITM_ID
              				   AND C.ITM_TP = T1.ITM_TP
              				   AND A.CUS_ID = T1.CUS_ID
              				   AND A.ORD_DT >= TO_DATE(T1.BAS_YM||'01','YYYYMMDD')
              				   AND A.ORD_DT < ADD_MONTHS(TO_DATE(T1.BAS_YM||'01','YYYYMMDD'), 1)
              				)
 WHERE T1.BAS_YM = '201702';

COMMIT;

-- ************************************************
-- PART I - 4.2.2 SQL3
-- ************************************************
-- 월별고객주문의 주문금액, 주문수량 업데이트 – 머지 사용
 MERGE INTO S_CUS_YM T1
 USING (
  		  SELECT A.CUS_ID
  				   , C.ITM_TP
  				   , SUM(B.ORD_QTY) ORD_QTY
  				   , SUM(B.UNT_PRC * B.ORD_QTY) ORD_AMT
  		    FROM T_ORD A
  				   , T_ORD_DET B
  				   , M_ITM C
  		   WHERE A.ORD_SEQ = B.ORD_SEQ
  		     AND C.ITM_ID = B.ITM_ID
  		     AND A.ORD_DT >= TO_DATE('201702'||'01','YYYYMMDD')
  		     AND A.ORD_DT < ADD_MONTHS(TO_DATE('201702'||'01','YYYYMMDD'), 1)
  		   GROUP BY A.CUS_ID
  				      , C.ITM_TP
  		 ) T2
	  ON (T1.BAS_YM = '201702'
   AND T1.CUS_ID = T2.CUS_ID
   AND T1.ITM_TP = T2.ITM_TP)
  WHEN MATCHED THEN
UPDATE SET T1.ORD_QTY = T2.ORD_QTY
				 , T1.ORD_AMT = T2.ORD_AMT;
COMMIT;

-- ************************************************
-- PART I - 4.2.2 SQL4
-- ************************************************
-- 월별고객주문의 주문금액, 주문수량 업데이트 – 반복 서브쿼리 제거
 UPDATE S_CUS_YM T1
    SET (T1.ORD_QTY ,T1.ORD_AMT) =
		(
		 SELECT SUM(B.ORD_QTY) ORD_QTY
				  , SUM(B.UNT_PRC * B.ORD_QTY) ORD_AMT
		   FROM T_ORD A
				  , T_ORD_DET B
				  , M_ITM C
		  WHERE A.ORD_SEQ = B.ORD_SEQ
		    AND C.ITM_ID = B.ITM_ID
		    AND A.ORD_DT >= TO_DATE('201702'||'01','YYYYMMDD')
		    AND A.ORD_DT < ADD_MONTHS(TO_DATE('201702'||'01','YYYYMMDD'), 1)
		    AND C.ITM_TP = T1.ITM_TP
		    AND A.CUS_ID = T1.CUS_ID
		  GROUP BY A.CUS_ID, C.ITM_TP
		)
 WHERE T1.BAS_YM = '201702';
COMMIT;

-- ANSI
UPDATE S_CUS_YM T1
   SET (T1.ORD_QTY ,T1.ORD_AMT) =
   (
    SELECT SUM(B.ORD_QTY) ORD_QTY
         , SUM(B.UNT_PRC * B.ORD_QTY) ORD_AMT
          FROM T_ORD A
         INNER JOIN T_ORD_DET B
            ON A.ORD_SEQ = B.ORD_SEQ
         INNER JOIN M_ITM C
            ON C.ITM_ID = B.ITM_ID
         WHERE A.ORD_DT >= TO_DATE('201702'||'01','YYYYMMDD')
           AND A.ORD_DT < ADD_MONTHS(TO_DATE('201702'||'01','YYYYMMDD'), 1);
           AND C.ITM_TP = T1.ITM_TP
           AND A.CUS_ID = T1.CUS_ID
         GROUP BY A.CUS_ID, C.ITM_TP
   )
 WHERE T1.BAS_YM = '201702';
COMMIT;

-- ************************************************
-- PART I - 4.3.1 SQL1
-- ************************************************
-- 고객, 아이템유형별 주문금액 구하기 – 인라인-뷰 이용
SELECT T0.CUS_ID ,T1.CUS_NM ,T0.ITM_TP
		 , (SELECT A.BAS_CD_NM
          FROM C_BAS_CD A
         WHERE A.LNG_CD = 'KO' AND A.BAS_CD_DV = 'ITM_TP' AND A.BAS_CD = T0.ITM_TP
       ) ITM_TP_NM
		 , T0.ORD_AMT
  FROM (
    		SELECT A.CUS_ID ,C.ITM_TP ,SUM(B.ORD_QTY * B.UNT_PRC) ORD_AMT
    		  FROM T_ORD A
    				 , T_ORD_DET B
    				 , M_ITM C
    		 WHERE A.ORD_SEQ = B.ORD_SEQ
    		   AND B.ITM_ID = C.ITM_ID
    		   AND A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
    		   AND A.ORD_DT < TO_DATE('20170301','YYYYMMDD')
    		 GROUP BY A.CUS_ID ,C.ITM_TP
       ) T0
		 , M_CUS T1
 WHERE T1.CUS_ID = T0.CUS_ID
 ORDER BY T0.CUS_ID ,T0.ITM_TP;

-- ANSI
SELECT T0.CUS_ID ,T1.CUS_NM ,T0.ITM_TP
		 , (SELECT A.BAS_CD_NM
          FROM C_BAS_CD A
         WHERE A.LNG_CD = 'KO' AND A.BAS_CD_DV = 'ITM_TP' AND A.BAS_CD = T0.ITM_TP
       ) ITM_TP_NM
		 , T0.ORD_AMT
  FROM (
    		SELECT A.CUS_ID
             , C.ITM_TP
             , SUM(B.ORD_QTY * B.UNT_PRC) ORD_AMT
    		  FROM T_ORD A
         INNER JOIN T_ORD_DET B
    				ON A.ORD_SEQ = B.ORD_SEQ
         INNER JOIN M_ITM C
            ON B.ITM_ID = C.ITM_ID
    		 WHERE A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
    		   AND A.ORD_DT < TO_DATE('20170301','YYYYMMDD')
    		 GROUP BY A.CUS_ID ,C.ITM_TP
       ) T0
 INNER JOIN M_CUS T1
		ON T1.CUS_ID = T0.CUS_ID
 ORDER BY T0.CUS_ID ,T0.ITM_TP;

-- ************************************************
-- PART I - 4.3.1 SQL2
-- ************************************************
-- 고객, 아이템유형별 주문금액 구하기 – WITH~AS 이용
  WITH T_CUS_ITM_AMT AS (
    SELECT A.CUS_ID
         , C.ITM_TP
         , SUM(B.ORD_QTY * B.UNT_PRC) ORD_AMT
		  FROM T_ORD A
				 , T_ORD_DET B
				 , M_ITM C
		 WHERE A.ORD_SEQ = B.ORD_SEQ
		   AND B.ITM_ID = C.ITM_ID
		   AND A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
		   AND A.ORD_DT < TO_DATE('20170301','YYYYMMDD')
		 GROUP BY A.CUS_ID ,C.ITM_TP
  )
SELECT T0.CUS_ID
     , T1.CUS_NM
     , T0.ITM_TP
		 , (SELECT A.BAS_CD_NM
          FROM C_BAS_CD A
         WHERE A.LNG_CD = 'KO' AND A.BAS_CD_DV = 'ITM_TP' AND A.BAS_CD = T0.ITM_TP
       ) ITM_TP_NM
		 , T0.ORD_AMT
  FROM T_CUS_ITM_AMT T0
		 , M_CUS T1
 WHERE T1.CUS_ID = T0.CUS_ID
 ORDER BY T0.CUS_ID ,T0.ITM_TP;

-- ANSI
  WITH T_CUS_ITM_AMT AS (
    SELECT A.CUS_ID
         , C.ITM_TP
         , SUM(B.ORD_QTY * B.UNT_PRC) ORD_AMT
      FROM T_ORD A
     INNER JOIN T_ORD_DET B
        ON A.ORD_SEQ = B.ORD_SEQ
     INNER JOIN M_ITM C
        ON B.ITM_ID = C.ITM_ID
     WHERE A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
       AND A.ORD_DT < TO_DATE('20170301','YYYYMMDD')
     GROUP BY A.CUS_ID ,C.ITM_TP
  )
SELECT T0.CUS_ID
     , T1.CUS_NM
     , T0.ITM_TP
		 , (SELECT A.BAS_CD_NM
          FROM C_BAS_CD A
         WHERE A.LNG_CD = 'KO' AND A.BAS_CD_DV = 'ITM_TP' AND A.BAS_CD = T0.ITM_TP
       ) ITM_TP_NM
		 , T0.ORD_AMT
  FROM T_CUS_ITM_AMT T0
 INNER JOIN M_CUS T1
    ON T1.CUS_ID = T0.CUS_ID
 ORDER BY T0.CUS_ID ,T0.ITM_TP;

-- ************************************************
-- PART I - 4.3.1 SQL3
-- ************************************************
-- 고객, 아이템유형별 주문금액 구하기, 전체주문 대비 주문금액비율 추가 – WITH~AS 이용
  WITH T_CUS_ITM_AMT AS (
    SELECT A.CUS_ID
         , C.ITM_TP
         , SUM(B.ORD_QTY * B.UNT_PRC) ORD_AMT
		  FROM T_ORD A
				 , T_ORD_DET B
				 , M_ITM C
		 WHERE A.ORD_SEQ = B.ORD_SEQ
		   AND B.ITM_ID = C.ITM_ID
		   AND A.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
		   AND A.ORD_DT < TO_DATE('20170301','YYYYMMDD')
		 GROUP BY A.CUS_ID ,C.ITM_TP
  )
, T_TTL_AMT AS (
    SELECT SUM(A.ORD_AMT) ORD_AMT
		  FROM T_CUS_ITM_AMT A
  )

SELECT T0.CUS_ID
     , T1.CUS_NM
     , T0.ITM_TP
		 , (SELECT A.BAS_CD_NM
          FROM C_BAS_CD A
			   WHERE A.LNG_CD = 'KO'
           AND A.BAS_CD_DV = 'ITM_TP'
           AND A.BAS_CD = T0.ITM_TP
       ) ITM_TP_NM
		 , T0.ORD_AMT
		 , TO_CHAR(ROUND(T0.ORD_AMT / T2.ORD_AMT * 100,2)) || '%' ORD_AMT_RT
  FROM T_CUS_ITM_AMT T0
		 , M_CUS T1
		 , T_TTL_AMT T2
 WHERE T1.CUS_ID = T0.CUS_ID
 ORDER BY ROUND(T0.ORD_AMT / T2.ORD_AMT * 100,2) DESC;

-- ************************************************
-- PART I - 4.3.2 SQL1
-- ************************************************
-- 주문금액 비율 컬럼 추가
ALTER TABLE S_CUS_YM ADD ORD_AMT_RT NUMBER(18,3);

-- ************************************************
-- PART I - 4.3.2 SQL2
-- ************************************************
-- WITH~AS 절을 사용한 INSERT문
INSERT INTO S_CUS_YM (BAS_YM ,CUS_ID ,ITM_TP ,ORD_QTY ,ORD_AMT ,ORD_AMT_RT)
  WITH T_CUS_ITM_AMT AS (
		SELECT TO_CHAR(A.ORD_DT,'YYYYMM') BAS_YM
         , A.CUS_ID
         , C.ITM_TP
				 , SUM(B.ORD_QTY) ORD_QTY
         , SUM(B.ORD_QTY * B.UNT_PRC) ORD_AMT
		  FROM T_ORD A
				 , T_ORD_DET B
				 , M_ITM C
		 WHERE   A.ORD_SEQ = B.ORD_SEQ
		   AND     B.ITM_ID = C.ITM_ID
		   AND     A.ORD_DT >= TO_DATE('20170401','YYYYMMDD')
		   AND     A.ORD_DT < TO_DATE('20170501','YYYYMMDD')
	   GROUP BY TO_CHAR(A.ORD_DT,'YYYYMM') ,A.CUS_ID ,C.ITM_TP
  )
, T_TTL_AMT AS (
    SELECT SUM(A.ORD_AMT) ORD_AMT
		  FROM T_CUS_ITM_AMT A
  )

SELECT T0.BAS_YM
     , T0.CUS_ID
     , T0.ITM_TP
     , T0.ORD_QTY
     , T0.ORD_AMT
		 , ROUND(T0.ORD_AMT / T2.ORD_AMT * 100,2) ORD_AMT_RT
  FROM T_CUS_ITM_AMT T0
	 	 , M_CUS T1
		 , T_TTL_AMT T2
 WHERE T1.CUS_ID = T0.CUS_ID;
