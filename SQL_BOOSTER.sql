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

-- ************************************************
-- PART I - 2.2.1 SQL1
-- ************************************************
-- GROUP BY와 GROUP BY~ROLLUP의 비교
SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM'),T1.CUS_ID
 ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM'),T1.CUS_ID
;

SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY
ROLLUP (TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID)
 ORDER BY TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID
;
/*
ORD_YM	CUS_ID	  ORD_AMT
201703	CUS_0001	  2800
201703	CUS_0002  	4300
201703		          7100(ORD_YM별 합계)
201704	CUS_0001	  5000
201704	CUS_0002	  1900
201704		          6900(ORD_YM별 합계)
		               14000(전체 합계)
*/

-- ************************************************
-- PART I - 2.2.2 SQL1
-- ************************************************
-- 주문상태, 주문년월, 고객ID 순서로 ROLLUP
SELECT T1.ORD_ST
     , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY ROLLUP(T1.ORD_ST, TO_CHAR(T1.ORD_DT,'YYYYMM'), T1.CUS_ID)
 ORDER BY T1.ORD_ST ,TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID
;
/*
ORD_ST	ORD_YM	CUS_ID	  ORD_AMT
COMP	  201703	CUS_0001	   2800
COMP	  201703	CUS_0002	   4300
COMP	  201703		           7100
COMP	  201704	CUS_0001	   4100
COMP	  201704	CUS_0002	   1900
COMP	  201704		           6000
COMP			                  13100(ORD_ST별 합계)
WAIT	  201704	CUS_0001	    900
WAIT	  201704		            900
WAIT			                    900(ORD_ST별 합계)
			                      14000(전체 합계)
*/

-- ************************************************
-- PART I - 2.2.2 SQL2
-- ************************************************
-- 주문년월, 주문상태, 고객ID 순서로 ROLLUP(위 SQL에서 ROLLUP부분만 변경해서 수행한다.)
SELECT T1.ORD_ST
     , TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY ROLLUP(TO_CHAR(T1.ORD_DT,'YYYYMM'), T1.ORD_ST, T1.CUS_ID)
 ORDER BY T1.ORD_ST ,TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID
;
/*
ORD_ST	ORD_YM	CUS_ID	  ORD_AMT
COMP	  201703	CUS_0001	   2800
COMP	  201703	CUS_0002	   4300
COMP	  201703		           7100
COMP	  201704	CUS_0001	   4100
COMP	  201704	CUS_0002	   1900
COMP	  201704		           6000
WAIT	  201704	CUS_0001	    900
WAIT	  201704		            900
	      201703		           7100(ORD_YM별 합계)
	      201704		           6900(ORD_YM별 합계)
			                      14000(전체 합계)
*/

-- ************************************************
-- PART I - 2.2.3 SQL1
-- ************************************************
-- NULL이 존재하는 컬럼인 PAY_TP에 대해 ROLLUP을 수행
SELECT T1.ORD_ST
     , T1.PAY_TP -- null 값 존재하는 컬럼
     , COUNT(*) ORD_CNT
	FROM T_ORD T1
 GROUP BY T1.ORD_ST ,T1.PAY_TP;
/*
ORD_ST	PAY_TP	ORD_CNT
COMP	  CARD	     1827
WAIT		(null)      305
COMP	  BANK	      915
*/

-- WAIT 부분에서 중간 소계인지 값이 null인지 분간이 안된다.
SELECT T1.ORD_ST
     , T1.PAY_TP -- null 값 존재하는 컬럼
     , COUNT(*) ORD_CNT
	FROM T_ORD T1
 GROUP BY ROLLUP(T1.ORD_ST ,T1.PAY_TP);
/*
ORD_ST	PAY_TP	ORD_CNT
COMP	  BANK	      915
COMP	  CARD	     1827
COMP		(null)     2742
WAIT		(null)      305
WAIT		(null)      305
(null)  (null)		 3047
*/

-- ************************************************
-- PART I - 2.2.3 SQL2
-- ************************************************
-- NULL이 존재하는 컬럼인 PAY_TP에 대해 ROLLUP을 수행. GROUPING함수 사용
SELECT T1.ORD_ST
     , GROUPING(T1.ORD_ST) GR_ORD_ST  --GROUPING : 해당 컬럼이 ROLLUP 처리되었으면 1 반환, 그렇지 않으면 0 반환
     , T1.PAY_TP
     , GROUPING(T1.PAY_TP) GR_PAY_TP
     , COUNT(*) ORD_CNT
  FROM T_ORD T1
 GROUP BY ROLLUP(T1.ORD_ST, T1.PAY_TP);
/*
ORD_ST	GR_ORD_ST	  PAY_TP	GR_PAY_TP	ORD_CNT
COMP	          0	  BANK	          0	    915
COMP	          0	  CARD	          0	   1827
COMP	          0		                1	   2742
WAIT	          0		                0	    305
WAIT	          0		                1	    305
	              1		                1	   3047(전체 합계)
*/

-- ************************************************
-- PART I - 2.2.3 SQL3
-- ************************************************
-- ROLLUP되는 컬럼을 Total로 표시
SELECT CASE WHEN GROUPING(T1.ORD_ST) = 1 THEN 'Total' ELSE T1.ORD_ST END ORD_ST
     , CASE WHEN GROUPING(T1.PAY_TP) = 1 THEN 'Total' ELSE T1.PAY_TP END PAY_TP
     , COUNT(*) ORD_CNT
	FROM T_ORD T1
 GROUP BY ROLLUP(T1.ORD_ST ,T1.PAY_TP)
 ORDER BY T1.ORD_ST ,T1.PAY_TP;
/*
ORD_ST	PAY_TP	ORD_CNT
COMP	  BANK	      915
COMP	  CARD	     1827
COMP	  Total	     2742
WAIT		            305
WAIT	  Total	      305
Total	  Total	     3047(전체 합계)
*/

-- ************************************************
-- PART I - 2.2.4 SQL1
-- ************************************************
-- 주문년월, 지역ID, 고객등급별 주문금액 - ROLLUP
SELECT CASE WHEN GROUPING(TO_CHAR(T2.ORD_DT,'YYYYMM'))=1 THEN 'Total'
       ELSE TO_CHAR(T2.ORD_DT,'YYYYMM') END ORD_YM
     , CASE WHEN GROUPING(T1.RGN_ID) = 1 THEN 'Total' ELSE T1.RGN_ID END RGN_ID
     , CASE WHEN GROUPING(T1.CUS_GD) = 1 THEN 'Total' ELSE T1.CUS_GD END CUS_GD
     , SUM(T2.ORD_AMT) ORD_AMT
  FROM M_CUS T1
     , T_ORD T2
 WHERE T1.CUS_ID = T2.CUS_ID
   AND T2.ORD_DT >= TO_DATE('20170201','YYYYMMDD')
   AND T2.ORD_DT < TO_DATE('20170401','YYYYMMDD')
   AND T1.RGN_ID IN ('A','B')
-- GROUP BY TO_CHAR(T2.ORD_DT,'YYYYMM') ,T1.RGN_ID ,T1.CUS_GD
-- GROUP BY ROLLUP(TO_CHAR(T2.ORD_DT,'YYYYMM') ,T1.RGN_ID ,T1.CUS_GD)
 GROUP BY ROLLUP((TO_CHAR(T2.ORD_DT,'YYYYMM') ,T1.RGN_ID ,T1.CUS_GD))
-- GROUP BY TO_CHAR(T2.ORD_DT,'YYYYMM'), ROLLUP(T1.RGN_ID ,T1.CUS_GD)
-- GROUP BY T1.RGN_ID, T1.CUS_GD, ROLLUP(TO_CHAR(T2.ORD_DT,'YYYYMM'))
 ORDER BY TO_CHAR(T2.ORD_DT,'YYYYMM') ,T1.RGN_ID ,T1.CUS_GD
;
/* 전체 합계만 구하기
ORD_YM	RGN_ID	CUS_GD	ORD_AMT
201702	  A	      A	      72040
201702	  A	      B	      33760
201702	  B     	A	      59620
201702	  B	      B	      28720
201703	  A	      A	      88720
201703	  B	      A	      82740
Total	  Total	  Total	   365600(전체 합계)
*/

-- ************************************************
-- PART I - 2.3.1 SQL1
-- ************************************************
-- 주문년월, 고객ID별 주문금액 – ROLLUP 사용
SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY ROLLUP(TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID);
/*
ORD_YM	CUS_ID	  ORD_AMT
201703	CUS_0001  	2800
201703	CUS_0002	  4300
201703		          7100
201704	CUS_0001	  5000
201704	CUS_0002	  1900
201704		          6900
		               14000(전체 합계)
*/
-- ************************************************
-- PART I - 2.3.1 SQL2
-- ************************************************
-- ROLLUP을 UNION ALL로 대신하기
SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID
/*
ORD_YM	CUS_ID	ORD_AMT
201704	CUS_0002	1900
201704	CUS_0001	5000
201703	CUS_0001	2800
201703	CUS_0002	4300
*/
 UNION ALL
SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , 'Total' CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM')
/*
ORD_YM	CUS_ID	ORD_AMT
201703	Total	  7100
201704	Total	  6900
*/
 UNION ALL
SELECT 'Total' ORD_YM
     , 'Total' CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD');
/*
ORD_YM	CUS_ID	ORD_AMT
Total	  Total	  14000
*/

-- ************************************************
-- PART I - 2.3.1 SQL3
-- ************************************************
-- ROLLUP을 카테시안 조인으로 대신하기
SELECT CASE WHEN T2.RNO = 1 THEN TO_CHAR(T1.ORD_DT,'YYYYMM')
       WHEN T2.RNO = 2 THEN TO_CHAR(T1.ORD_DT,'YYYYMM')
       WHEN T2.RNO = 3 THEN 'Total' END ORD_YM
     , CASE WHEN T2.RNO = 1 THEN T1.CUS_ID
       WHEN T2.RNO = 2 THEN 'Total'
       WHEN T2.RNO = 3 THEN 'Total' END CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
     , (SELECT ROWNUM RNO FROM DUAL CONNECT BY ROWNUM <= 3
       ) T2
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY CASE WHEN T2.RNO = 1 THEN TO_CHAR(T1.ORD_DT,'YYYYMM')
               WHEN T2.RNO = 2 THEN TO_CHAR(T1.ORD_DT,'YYYYMM')
               WHEN T2.RNO = 3 THEN 'Total' END
     , CASE WHEN T2.RNO = 1 THEN T1.CUS_ID
            WHEN T2.RNO = 2 THEN 'Total'
            WHEN T2.RNO = 3 THEN 'Total' END;

-- ************************************************
-- PART I - 2.3.1 SQL4
-- ************************************************
-- ROLLUP을 WITH 절과 UNION ALL로 대체
WITH T_RES AS (
               SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
                    , T1.CUS_ID
                    , SUM(T1.ORD_AMT) ORD_AMT
                 FROM T_ORD T1
                WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
                  AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
                  AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
                GROUP BY TO_CHAR(T1.ORD_DT,'YYYYMM') ,T1.CUS_ID
)
SELECT T1.ORD_YM ,T1.CUS_ID ,T1.ORD_AMT
  FROM T_RES T1

 UNION ALL
SELECT T1.ORD_YM
     , 'Total'
     , SUM(T1.ORD_AMT)
  FROM T_RES T1
 GROUP BY T1.ORD_YM

 UNION ALL
SELECT 'Total'
     , 'Total'
     , SUM(T1.ORD_AMT)
  FROM T_RES T1;

-- ************************************************
-- PART I - 2.3.2 SQL1
-- ************************************************
-- 주문상태(ORD_ST), 주문년월, 고객ID별 주문금액 – CUBE로 가능한 모든 소계를 추가
SELECT CASE  WHEN GROUPING(T1.ORD_ST)=1 THEN 'Total' ELSE T1.ORD_ST END ORD_ST
     , CASE WHEN GROUPING(TO_CHAR(T1.ORD_DT,'YYYYMM'))=1 THEN 'Total'
            ELSE TO_CHAR(T1.ORD_DT,'YYYYMM') END ORD_YM
     , CASE WHEN GROUPING(T1.CUS_ID)=1 THEN 'Total' ELSE T1.CUS_ID END CUS_ID
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.CUS_ID IN ('CUS_0001','CUS_0002')
   AND T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
 GROUP BY CUBE(T1.ORD_ST, TO_CHAR(T1.ORD_DT,'YYYYMM'), T1.CUS_ID)
 ORDER BY T1.ORD_ST, TO_CHAR(T1.ORD_DT,'YYYYMM'), T1.CUS_ID;

-- ************************************************
-- PART I - 2.3.3 SQL1
-- ************************************************
-- 주문년월, 고객ID별 주문건수와 주문 금액 – GROUPING SETS 활용
SELECT TO_CHAR(T1.ORD_DT,'YYYYMM') ORD_YM
     , T1.CUS_ID
     , COUNT(*) ORD_CNT
     , SUM(T1.ORD_AMT) ORD_AMT
  FROM T_ORD T1
 WHERE T1.ORD_DT >= TO_DATE('20170301','YYYYMMDD')
   AND T1.ORD_DT < TO_DATE('20170501','YYYYMMDD')
   AND T1.CUS_ID IN ('CUS_0061','CUS_0062')
 GROUP BY GROUPING SETS(
       (TO_CHAR(T1.ORD_DT,'YYYYMM'),T1.CUS_ID)  --GROUP BY기본 데이터
--     , (TO_CHAR(T1.ORD_DT,'YYYYMM'))  --주문년월별 소계
--     , (T1.CUS_ID)  --고객ID별 소계
     , ()   --전체합계
 );
/*
ORD_YM	CUS_ID	  ORD_CNT	ORD_AMT
201703	CUS_0061	  3	       7620
201703	CUS_0062	  3	       4300
201704	CUS_0061	  3	      10900
201704	CUS_0062	  3	       3100
		               12	      25920
*/

-- ************************************************
-- PART I - 3.1.1 SQL1
-- ************************************************
-- 이너-조인을 이해하는 SQL
SELECT T1.COL_1 ,T2.COL_1
  FROM ( SELECT  'A' COL_1 FROM DUAL UNION ALL
			   SELECT  'B' COL_1 FROM DUAL UNION ALL
			   SELECT  'C' COL_1 FROM DUAL ) T1
		 , ( SELECT  'A' COL_1 FROM DUAL UNION ALL
			   SELECT  'B' COL_1 FROM DUAL UNION ALL
			   SELECT  'B' COL_1 FROM DUAL UNION ALL
         SELECT  'D' COL_1 FROM DUAL ) T2
 WHERE T1.COL_1 = T2.COL_1;

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
