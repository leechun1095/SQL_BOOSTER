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
CREATE USER ORA_SQL_TEST IDENTIFIED BY "비밀번호" DEFAULT TABLESPACE ORA_SQL_TEST;

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

-- ************************************************
-- PART I - 1.1.2 SQL4, SYS USER 사용 - TEMP 크기 확인(단위 메가바이트)
-- ************************************************
SELECT T1.FILE_NAME
    , (T1.BYTES / 1024 / 1024) TMP_MB
  FROM DBA_TEMP_FILES T1;


-- ************************************************
-- PART I - 1.1.2 SQL5, SYS USER 사용 - TEMP 크기 변경
-- ************************************************
ALTER DATABASE TEMPFILE 'D:\APP\82103\ORADATA\ORCL\TEMP01.DBF' RESIZE 5000M;


-- ************************************************
-- PART I - 1.2.1 SQL1, 여기서부터는 ORA_SQL_TEST 사용자를 사용합니다.
-- 테이블 생성.
-- ************************************************
	------------------------------------------------------------
	-- 기준코드(공통코드, 기초코드, 그룹코드 등으로 불린다)
	------------------------------------------------------------
	CREATE TABLE C_BAS_CD
	(
		BAS_CD_DV             VARCHAR2(40)  NOT NULL,
		LNG_CD                VARCHAR2(40)  NOT NULL,
		BAS_CD                VARCHAR2(40)  NOT NULL,
		BAS_CD_NM             VARCHAR2(100)  NULL,
		SRT_OD                NUMBER(18)  NULL
	);

	CREATE UNIQUE INDEX PK_C_BAS_CD ON C_BAS_CD(BAS_CD_DV  ASC,LNG_CD  ASC,BAS_CD  ASC);

	ALTER TABLE C_BAS_CD
		ADD CONSTRAINT  PK_C_BAS_CD PRIMARY KEY (BAS_CD_DV,LNG_CD,BAS_CD);


	------------------------------------------------------------
	-- 기준코드구분
	------------------------------------------------------------
	CREATE TABLE C_BAS_CD_DV
	(
		BAS_CD_DV             VARCHAR2(40)  NOT NULL,
		BAS_CD_DV_NM          VARCHAR2(100)  NULL
	);

	CREATE UNIQUE INDEX PK_C_BAS_CD_DV ON C_BAS_CD_DV(BAS_CD_DV  ASC);

	ALTER TABLE C_BAS_CD_DV
		ADD CONSTRAINT  PK_C_BAS_CD_DV PRIMARY KEY (BAS_CD_DV);


	------------------------------------------------------------
	-- 아이템 테이블.
	-- 아이템 = 실제 판매가 발생하거나 재고 관리가 되는 상품 단위.
	------------------------------------------------------------
	CREATE TABLE M_ITM
	(
		ITM_ID                VARCHAR2(40)  NOT NULL,
		ITM_NM                VARCHAR2(100)  NULL,
		ITM_TP                VARCHAR2(40)  NULL,
		UNT_PRC               NUMBER(18,3)  NULL
	);

	CREATE UNIQUE INDEX PK_M_ITM ON M_ITM(ITM_ID  ASC);

	ALTER TABLE M_ITM
		ADD CONSTRAINT  PK_M_ITM PRIMARY KEY (ITM_ID);


	------------------------------------------------------------
	-- 아이템 단가 이력 테이블.
	------------------------------------------------------------
	CREATE TABLE M_ITM_PRC_HIS
	(
		ITM_ID                VARCHAR2(40)  NOT NULL,
		TO_YMD                VARCHAR2(8)  NOT NULL,
		FR_YMD                VARCHAR2(8)  NULL,
		UNT_PRC               NUMBER(18,3)  NULL
	);

	CREATE UNIQUE INDEX PK_M_ITM_PRC_HIS ON M_ITM_PRC_HIS(ITM_ID  ASC,TO_YMD  ASC);

	ALTER TABLE M_ITM_PRC_HIS
		ADD CONSTRAINT  PK_M_ITM_PRC_HIS PRIMARY KEY (ITM_ID,TO_YMD);


	------------------------------------------------------------
	-- 지역 마스터 테이블
	------------------------------------------------------------
	CREATE TABLE M_RGN
	(
		RGN_ID                VARCHAR2(40)  NOT NULL,
		RGN_NM                VARCHAR2(100)  NULL,
		SRT_OD                NUMBER(18)  NULL
	);

	CREATE UNIQUE INDEX PK_M_RGN ON M_RGN(RGN_ID  ASC);

	ALTER TABLE M_RGN
		ADD CONSTRAINT  PK_M_RGN PRIMARY KEY (RGN_ID);


	------------------------------------------------------------
	-- 고객 마스터 테이블
	------------------------------------------------------------
	CREATE TABLE M_CUS
	(
		CUS_ID                VARCHAR2(40)  NOT NULL,
		CUS_NM                VARCHAR2(100)  NULL,
		MBL_NO                VARCHAR2(100)  NULL,
		EML_AD                VARCHAR2(100)  NULL,
		PWD                   VARCHAR2(200)  NULL,
		RGN_ID                VARCHAR2(40)  NULL,
		ADR_TXT               VARCHAR2(200)  NULL,
		GND_TP                VARCHAR2(40)  NULL,
		BTH_YMD               VARCHAR2(8)  NULL,
		CUS_GD                VARCHAR2(40)  NULL
	);

	CREATE UNIQUE INDEX PK_M_CUS ON M_CUS(CUS_ID  ASC);

	ALTER TABLE M_CUS
		ADD CONSTRAINT  PK_M_CUS PRIMARY KEY (CUS_ID);


	------------------------------------------------------------
	-- 아이템 평가
	-- 고객이 아이템에 평가를 수행한 기록.
	------------------------------------------------------------
	CREATE TABLE T_ITM_EVL
	(
		ITM_ID                VARCHAR2(40)  NOT NULL,
		EVL_LST_NO            NUMBER(18)  NOT NULL,
		CUS_ID                VARCHAR2(40)  NOT NULL,
		EVL_DSC               VARCHAR2(1000)  NULL,
		EVL_DT                DATE  NULL,
		EVL_PT                NUMBER(18,2)  NULL
	);

	CREATE UNIQUE INDEX PK_T_ITM_EVL ON T_ITM_EVL(ITM_ID  ASC,EVL_LST_NO  ASC);

	ALTER TABLE T_ITM_EVL
		ADD CONSTRAINT  PK_T_ITM_EVL PRIMARY KEY (ITM_ID,EVL_LST_NO);

	------------------------------------------------------------
	-- 주문
	------------------------------------------------------------
	CREATE TABLE T_ORD
	(
		ORD_SEQ               NUMBER(18)  NOT NULL,
		CUS_ID                VARCHAR2(40)  NOT NULL,
		ORD_DT                DATE  NULL,
		ORD_ST                VARCHAR2(40)  NULL,
		PAY_DT                DATE  NULL,
		PAY_TP                VARCHAR2(40)  NULL,
		ORD_AMT               NUMBER(18,3)  NULL,
		PAY_AMT               NUMBER(18,3)  NULL
	);

	CREATE UNIQUE INDEX PK_T_ORD ON T_ORD(ORD_SEQ  ASC);

	ALTER TABLE T_ORD
		ADD CONSTRAINT  PK_T_ORD PRIMARY KEY (ORD_SEQ);


	------------------------------------------------------------
	-- 주문상세
	------------------------------------------------------------
	CREATE TABLE T_ORD_DET
	(
		ORD_SEQ               NUMBER(18)  NOT NULL,
		ORD_DET_NO            NUMBER(18)  NOT NULL,
		ITM_ID                VARCHAR2(40)  NOT NULL,
		ORD_QTY               NUMBER(18)  NULL,
		UNT_PRC               NUMBER(18,3)  NULL
	);

	CREATE UNIQUE INDEX PK_T_ORD_DET ON T_ORD_DET(ORD_SEQ  ASC,ORD_DET_NO  ASC);

	ALTER TABLE T_ORD_DET
		ADD CONSTRAINT  PK_T_ORD_DET PRIMARY KEY (ORD_SEQ,ORD_DET_NO);


	------------------------------------------------------------
	-- FOREIGN KEY설정들.
	------------------------------------------------------------
	ALTER TABLE C_BAS_CD
		ADD (CONSTRAINT  FK_C_BAS_CD_DV_1 FOREIGN KEY (BAS_CD_DV) REFERENCES C_BAS_CD_DV(BAS_CD_DV));

	ALTER TABLE M_ITM_PRC_HIS
		ADD (CONSTRAINT FK_M_ITM_PRC_HIS FOREIGN KEY (ITM_ID) REFERENCES M_ITM(ITM_ID));

	ALTER TABLE M_CUS
		ADD (CONSTRAINT FK_CUS_1 FOREIGN KEY (RGN_ID) REFERENCES M_RGN(RGN_ID));

	ALTER TABLE T_ITM_EVL
		ADD (CONSTRAINT FK_T_ITM_EVL_1 FOREIGN KEY (CUS_ID) REFERENCES M_CUS(CUS_ID));

	ALTER TABLE T_ITM_EVL
		ADD (CONSTRAINT FK_T_ITM_EVL_2 FOREIGN KEY (ITM_ID) REFERENCES M_ITM(ITM_ID));

	ALTER TABLE T_ORD
		ADD (CONSTRAINT FK_T_ORD_1 FOREIGN KEY (CUS_ID) REFERENCES M_CUS(CUS_ID));

	ALTER TABLE T_ORD_DET
		ADD (CONSTRAINT FK_T_ORD_DET_1 FOREIGN KEY (ORD_SEQ) REFERENCES T_ORD(ORD_SEQ));




-- ************************************************
-- PART I - 2.1.1 SQL1
-- ************************************************

-- GROUP BY에 사용한 컬럼만 SELECT 절에서 그대로 사용할 수 있다.
-- GROUP BY에 사용하지 않은 컬럼은 SELECT 절에서 집계함수를 사용해야 한다.

-- 주문일시, 지불유형별 주문금액
SELECT T1.ORD_DT ,T1.PAY_TP
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_ST = 'COMP'
 GROUP BY T1.ORD_DT ,T1.PAY_TP
 ORDER BY T1.ORD_DT ,T1.PAY_TP;

-- ************************************************
-- PART I - 2.1.1 SQL2
-- ************************************************

-- 집계함수 - 정상적인 SQL, 에러가 발생하는 SQL
SELECT COUNT(*) CNT
     , SUM(T1.ORD_AMT) TTL_ORD_AMT
     , MIN(T1.ORD_SEQ) MIN_ORD_SEQ
     , MAX(T1.ORD_SEQ) MAX_ORD_SEQ
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD');


SELECT T1.ORD_ST
     , COUNT(*) CNT
     , SUM(T1.ORD_AMT) TTL_ORD_AMT
     , MIN(T1.ORD_SEQ) MIN_ORD_SEQ
     , MAX(T1.ORD_SEQ) MAX_ORD_SEQ
  FROM T_ORD T1
 WHERE T1.ORD_DT>= TO_DATE('20170101','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170201','YYYYMMDD');



-- ************************************************
-- PART I - 2.1.2 SQL1
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
 ORDER BY 1 ,2;


-- ************************************************
-- PART I - 2.1.2 SQL2
-- ************************************************

-- TO_CHAR 변형을 이용한 주문년월, 지불유형별 주문건수
SELECT TO_CHAR(ORD_DT, 'YYYYMMDD') ORD_YM
     , PAY_TP
     , count(*) ORD_CNT
  FROM T_ORD
 WHERE ORD_ST = 'COMP'
 GROUP BY TO_CHAR(ORD_DT, 'YYYYMMDD'), PAY_TP
 ORDER BY TO_CHAR(ORD_DT, 'YYYYMMDD'), PAY_TP


-- ************************************************
-- PART I - 2.1.3 SQL1
-- ************************************************

-- 주문년월별 계좌이체(PAY_TP=BANK) 건수와 카드결제(PAY_TP=CARD) 건수
SELECT TO_CHAR(ORD_DT, 'YYYYMM') ORD_YM
     , SUM(CASE WHEN PAY_TP = 'BANK' THEN 1 END) BANK_PAY_CNT
     , SUM(CASE WHEN PAY_TP = 'CARD' THEN 1 END) CARD_PAY_CNT
  FROM T_ORD
 WHERE ORD_ST = 'COMP'
 GROUP BY TO_CHAR(ORD_DT, 'YYYYMM')
 ORDER BY TO_CHAR(ORD_DT, 'YYYYMM')
/*
--------------------------------------
	  ORD_YM	BANK_PAY_CNT	CARD_PAY_CNT
--------------------------------------
1	  201701	73	          145
2	  201702	59	          119
3	  201703	57	          110
4	  201704	63	          131
5	  201705	84	          167
6	  201706	81	          162
7	  201707	84	          168
8	  201708	84	          167
9	  201709	81	          162
10	201710	84	          167
11	201711	81	          162
12	201712	84	          167
*/

-- ************************************************
-- PART I - 2.1.3 SQL2
-- ************************************************

-- 지불유형(PAY_TP)별 주문건수(주문 건수를 주문년월별로 컬럼으로 표시)
SELECT T1.PAY_TP
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201701' THEN 'A' END) ORD_CNT_1701
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201702' THEN 'A' END) ORD_CNT_1702
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201703' THEN 'A' END) ORD_CNT_1703
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201704' THEN 'A' END) ORD_CNT_1704
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201705' THEN 'A' END) ORD_CNT_1705
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201706' THEN 'A' END) ORD_CNT_1706
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201707' THEN 'A' END) ORD_CNT_1707
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201708' THEN 'A' END) ORD_CNT_1708
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201709' THEN 'A' END) ORD_CNT_1709
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201710' THEN 'A' END) ORD_CNT_1710
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201711' THEN 'A' END) ORD_CNT_1711
     , COUNT(CASE WHEN TO_CHAR(T1.ORD_DT,'YYYYMM') = '201712' THEN 'A' END) ORD_CNT_1712
  FROM T_ORD T1
 WHERE T1.ORD_ST = 'COMP'
 GROUP BY T1.PAY_TP
 ORDER BY T1.PAY_TP;
/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PAY_TP	ORD_CNT_1701	ORD_CNT_1702	ORD_CNT_1703	ORD_CNT_1704	ORD_CNT_1705	ORD_CNT_1706	ORD_CNT_1707	ORD_CNT_1708	ORD_CNT_1709	ORD_CNT_1710	ORD_CNT_1711	ORD_CNT_1712
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	BANK	  73	          59	          57	          63	          84	          81	          84	          84	          81	          84	          81	          84
	CARD	  145	          119	          110	          131	          167	          162	          168	          167	          162	          167	          162	          167
*/

-- ************************************************
-- PART I - 2.1.3 SQL3
-- ************************************************

-- 지불유형(PAY_TP)별 주문건수(주문 건수를 주문년월별로 컬럼으로 표시) – 인라인-뷰 활용
SELECT T1.PAY_TP
     , MAX(CASE WHEN T1.ORD_YM = '201701' THEN T1.ORD_CNT END) ORD_CNT_1701
     , MAX(CASE WHEN T1.ORD_YM = '201702' THEN T1.ORD_CNT END) ORD_CNT_1702
     , MAX(CASE WHEN T1.ORD_YM = '201703' THEN T1.ORD_CNT END) ORD_CNT_1703
     , MAX(CASE WHEN T1.ORD_YM = '201704' THEN T1.ORD_CNT END) ORD_CNT_1704
     , MAX(CASE WHEN T1.ORD_YM = '201705' THEN T1.ORD_CNT END) ORD_CNT_1705
     , MAX(CASE WHEN T1.ORD_YM = '201706' THEN T1.ORD_CNT END) ORD_CNT_1706
     , MAX(CASE WHEN T1.ORD_YM = '201707' THEN T1.ORD_CNT END) ORD_CNT_1707
     , MAX(CASE WHEN T1.ORD_YM = '201708' THEN T1.ORD_CNT END) ORD_CNT_1708
     , MAX(CASE WHEN T1.ORD_YM = '201709' THEN T1.ORD_CNT END) ORD_CNT_1709
     , MAX(CASE WHEN T1.ORD_YM = '201710' THEN T1.ORD_CNT END) ORD_CNT_1710
     , MAX(CASE WHEN T1.ORD_YM = '201711' THEN T1.ORD_CNT END) ORD_CNT_1711
     , MAX(CASE WHEN T1.ORD_YM = '201712' THEN T1.ORD_CNT END) ORD_CNT_1712
  FROM (
        SELECT T1.PAY_TP
             , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
             , COUNT(*) ORD_CNT
          FROM T_ORD T1
         WHERE T1.ORD_ST = 'COMP'
         GROUP BY T1.PAY_TP ,TO_CHAR(T1.ORD_DT,'YYYYMM')
       ) T1
 GROUP BY T1.PAY_TP;
/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PAY_TP	ORD_CNT_1701	ORD_CNT_1702	ORD_CNT_1703	ORD_CNT_1704	ORD_CNT_1705	ORD_CNT_1706	ORD_CNT_1707	ORD_CNT_1708	ORD_CNT_1709	ORD_CNT_1710	ORD_CNT_1711	ORD_CNT_1712
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	BANK	  73	          59	          57	          63	          84	          81	          84	          84	          81	          84	          81	          84
	CARD	  145	          119	          110	          131	          167	          162	          168	          167	          162	          167	          162	          167
*/

-- ************************************************
-- PART I - 2.1.4 SQL1
-- ************************************************

-- NULL에 대한 COUNT #1
SELECT COUNT(COL1) CNT_COL1
     , COUNT(COL2) CNT_COL2
     , COUNT(COL3) CNT_COL3
  FROM (
        SELECT 'A' COL1
             , NULL COL2
             , 'C' COL3
          FROM DUAL
        UNION ALL
        SELECT 'B' COL1
             , NULL COL2
             , NULL COL3
          FROM DUAL
       ) T1;

/*
------------------
	COL1	COL2	COL3
------------------
	   A	         C
	   B

------------------------------
	CNT_COL1	CNT_COL2	CNT_COL3
------------------------------
	       2	       0       	 1
*/

-- ************************************************
-- PART I - 2.1.4 SQL2
-- ************************************************

-- NULL에 대한 COUNT #2
-- count(col1) : null이기 때문에 0 이지만,
-- count(*) : 2가 나온다, row 자체의 건수를 카운트하기 때문이다.

SELECT COUNT(COL1) CNT_COL1
     , COUNT(*) CNT_ALL
  FROM (
        SELECT NULL COL1
          FROM DUAL
         UNION ALL
        SELECT NULL COL1
          FROM DUAL
       ) T1

/*
--------------------
	COL1
--------------------
 (null)
 (null)

--------------------
	CNT_COL1	CNT_ALL
--------------------
	       0	      2
*/

-- ************************************************
-- PART I - 2.1.5 SQL1
-- ************************************************

-- 주문년월별 주문고객 수(중복을 제거해서 카운트), 주문건수
SELECT TO_CHAR(T1.ORD_DT, 'YYYYMM') ORD_YM
     , COUNT(DISTINCT T1.CUS_ID) CUS_CNT
     , COUNT(*) ORD_CNT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170101', 'YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170401', 'YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT, 'YYYYMM')
 ORDER BY TO_CHAR(T1.ORD_DT, 'YYYYMM')

 /*
 ------------------------
 	ORD_YM	CUS_CNT	ORD_CNT
 ------------------------
1	201701	     81	    243
2	201702	     72	    198
3	201703	     60	    185
 */

 -- ************************************************
 -- PART I - 2.1.5 SQL2
 -- ************************************************

-- 주문상태(ORD_ST)와 지불유형(PAY_TP)의 조합에 대한 종류 수
--ERROR
SELECT COUNT(DISTINCT T1.ORD_ST ,T1.PAY_TP)
  FROM T_ORD T1;
--ORA-00909: invalid number of arguments

--USE CONCAT
SELECT COUNT(DISTINCT T1.ORD_ST || '-' || T1.PAY_TP)
  FROM T_ORD T1;
/*
==========================================
  COUNT(DISTINCTT1.ORD_ST||'-'||T1.PAY_TP)
==========================================
1	                                       3
*/

-- 왜 아래 쿼리는 0건일까..?
SELECT * FROM T_ORD
 WHERE ORD_ST = 'WAIT'
   AND PAY_TP IS NULL

-- ORD_ST(2가지) : WAIT, COMP
SELECT COUNT(DISTINCT ORD_ST) FROM T_ORD

-- PAY_TP(2가지) : CARD, BANK
SELECT COUNT(DISTINCT PAY_TP) FROM T_ORD

/*
===============
 ORD_ST  PAY_TP => 3개의 경우의 수
===============
1  WAIT    NULL = 305건
2  COMP    CARD = 1827건
3  COMP    BANK = 915건
4  WAIT    CARD = 0건
5  WAIT    BANK = 0건
*/

-- ************************************************
-- PART I - 2.1.5 SQL3
-- ************************************************

-- 주문상태(ORD_ST)와 지불유형(PAY_TP)의 조합에 대한 종류 수 – 인라인-뷰로 해결
SELECT COUNT(*)
  FROM (
        SELECT DISTINCT T1.ORD_ST
             , T1.PAY_TP
          FROM T_ORD T1
       ) T2

-- ************************************************
-- PART I - 2.1.6 SQL1
-- ************************************************

-- WHERE - GROUP BY - HAVING - ORDER BY

-- 고객ID, 지불유형(PAY_TP)별 주문금액이 10,000 이상인 데이터만 조회
SELECT T1.CUS_ID
     , T1.PAY_TP
     , SUM(T1.ORD_AMT) ORD_TTL_AMT
  FROM T_ORD T1
 WHERE T1.ORD_ST = 'COMP'
 GROUP BY T1.CUS_ID, T1.PAY_TP
HAVING SUM(T1.ORD_AMT) >= 10000
 ORDER BY SUM(T1.ORD_AMT) ASC

-- ************************************************
-- PART I - 2.1.6 SQL2
-- ************************************************
-- HAVING 절에는 GROUP BY에 사용한 컬럼 또는 집계함수를 사용한 컬럼만 사용 가능하다.
SELECT T1.CUS_ID ,T1.PAY_TP ,SUM(T1.ORD_AMT) ORD_TTL_MT
  FROM T_ORD T1
 GROUP BY T1.CUS_ID ,T1.PAY_TP
HAVING T1.ORD_ST = 'COMP' --ERROR
 ORDER BY SUM(T1.ORD_AMT) ASC;
-- 에러 발생: ORA-00979: not a GROUP BY expression

-- 1. ORD_ST 에 대한 조건은 HAVING 절이 아닌 WHERE 절에서 사용해야 한다.
-- 2. ORD_ST 컬럼을 HAVING 절에서 사용하려면 ORD_ST 컬럼이 GROUP BY 절에 있어야 한다.
-- 3. 또는 ORD_ST 컬럼을 MAX, MIN과 같은 집계함수 처리한 후에 HAVING 절에 사용할 수 있다.
-- 4. HAVING 조건 대신 GROUP BY 결과를 인라인-뷰로 처리하고 바깥에서 WHERE 절로 처리할 수 있다.(2.1.6 SQL3 참고)

-- ************************************************
-- PART I - 2.1.6 SQL3
-- ************************************************
-- HAVING절 대신 인라인-뷰를 사용
SELECT T0.*
  FROM (
    		SELECT  T1.CUS_ID ,T1.PAY_TP ,SUM(T1.ORD_AMT) ORD_TTL_AMT
    		FROM    T_ORD T1
    		WHERE   T1.ORD_ST = 'COMP'
    		GROUP BY T1.CUS_ID ,T1.PAY_TP
		   ) T0
 WHERE T0.ORD_TTL_AMT >= 10000
 ORDER BY T0.ORD_TTL_AMT ASC;
