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
  -- PART I - 1.2.2 SQL1
  -- ************************************************
  	-- 아이템 데이터 생성
  	INSERT INTO M_ITM (ITM_ID ,ITM_NM ,ITM_TP ,UNT_PRC)
  	SELECT  'ITM'||LPAD(TO_CHAR(ROWNUM),3,'0') ITM_ID ,T1.ITM_NM ,T1.ITM_TP ,T1.UNT_PRC
  	FROM    (
  			SELECT  T1.ITM_TP||'_'||LPAD(TO_CHAR(RNO),3,'0') ITM_NM
  					,T1.ITM_TP
  					,T1.RNO * 100 UNT_PRC
  			FROM    (
  					SELECT  ROWNUM RNO ,'ELEC' ITM_TP FROM DUAL --가전제품
  					CONNECT BY ROWNUM <= 10
  					UNION ALL
  					SELECT  ROWNUM RNO ,'PC' ITM_TP FROM DUAL --컴퓨터
  					CONNECT BY ROWNUM <= 20
  					UNION ALL
  					SELECT  ROWNUM RNO ,'COOK' ITM_TP FROM DUAL ---주방용품
  					CONNECT BY ROWNUM <= 30
  					UNION ALL
  					SELECT  ROWNUM RNO ,'CLOTHES' ITM_TP FROM DUAL --옷
  					CONNECT BY ROWNUM <= 40
  					) T1
  			ORDER BY T1.ITM_TP
  					,T1.RNO
  			) T1
  			;
  	COMMIT;


  -- ************************************************
  -- PART I - 1.2.2 SQL2
  -- ************************************************
  	-- 아이템단가 이력 생성
  	INSERT INTO M_ITM_PRC_HIS (ITM_ID ,TO_YMD ,FR_YMD ,UNT_PRC)
  	SELECT  T1.ITM_ID ,T2.TO_YMD ,T2.FR_YMD ,T1.UNT_PRC * T2.PRC_RT UNT_PRC
  	FROM    M_ITM T1
  			,(
  				SELECT  '20170310' TO_YMD ,'20170101' FR_YMD ,0.7 PRC_RT FROM DUAL UNION ALL
  				SELECT  '20170320' TO_YMD ,'20170311' FR_YMD ,0.8 PRC_RT FROM DUAL UNION ALL
  				SELECT  '99991231' TO_YMD ,'20170321' FR_YMD ,1 PRC_RT FROM DUAL
  			) T2
  	WHERE   T1.ITM_ID LIKE '%9'
  	UNION ALL
  	SELECT  T1.ITM_ID ,'99991231' TO_YMD ,'20170101' FR_YMD ,T1.UNT_PRC UNT_PRC
  	FROM    M_ITM T1
  	WHERE   T1.ITM_ID NOT LIKE '%9'
  	;
  	COMMIT;


  -- ************************************************
  -- PART I - 1.2.2 SQL3
  -- ************************************************
  	-- 지역 데이터 생성
  	INSERT INTO M_RGN  (RGN_ID ,RGN_NM ,SRT_OD)
  	SELECT  T1.RGN_ID ,T1.RGN_NM ,ROW_NUMBER() OVER(ORDER BY T1.RGN_ID) SRT_OD
  	FROM    (
  			SELECT  CHR(ASCII('A') + (ROWNUM-1)) RGN_ID
  					,CHR(ASCII('A') + (ROWNUM-1)) RGN_NM
  			FROM    DUAL
  			CONNECT BY ROWNUM <= 5
  			) T1
  	;
  	COMMIT;



  -- ************************************************
  -- PART I - 1.2.2 SQL4
  -- ************************************************
  	-- 고객 데이터 생성
  	INSERT INTO M_CUS(CUS_ID ,CUS_NM ,MBL_NO ,EML_AD ,PWD ,RGN_ID ,ADR_TXT ,GND_TP ,BTH_YMD ,CUS_GD)
  	SELECT  'CUS_'||LPAD(TO_CHAR(T1.ID_SEQ),4,'0') CUS_ID
  			,'NAME_'||LPAD(TO_CHAR(T1.ID_SEQ),4,'0') CUS_NM
  			,LPAD(TO_CHAR(T1.ID_SEQ),4,'0')||'-'||LPAD(TO_CHAR(T1.ID_SEQ),4,'0') MBL_NO
  			,RPAD(TO_CHAR(T1.ID_SEQ),5,'0')||'@abc.com' EML_AD
  			,'******' PWD
  			,T1.RGN_ID
  			,T1.RGN_ID||' Region' ADR_TXT
  			,T1.GND_TP
  			,TO_CHAR(ADD_MONTHS(TO_DATE('19900101','YYYYMMDD'),T1.ADD_BTH_MM)+T1.ID_SEQ,'YYYYMMDD') BTH_YMD
  			,T1.CUS_GD
  	FROM    (
  			SELECT  T_RGN_ID.RGN_ID
  					,T_GND_TP.GND_TP
  					,T_CUS_GD.CUS_GD
  					,T_RGN_ID.SRT_OD ADD_BTH_MM
  					,ROW_NUMBER() OVER(ORDER BY T_GND_TP.GND_TP ,T_RGN_ID.RGN_ID ,T_CUS_GD.CUS_GD) ID_SEQ
  			FROM    (
  						SELECT  A.RGN_ID
  								,A.SRT_OD
  						FROM    M_RGN A
  								,M_RGN B
  						WHERE   B.SRT_OD >= A.SRT_OD
  					) T_RGN_ID
  					,(
  						SELECT 'MALE' GND_TP FROM DUAL UNION ALL
  						SELECT 'FEMLE' GND_TP FROM DUAL
  					) T_GND_TP
  					,(
  						SELECT  'A' CUS_GD FROM DUAL CONNECT BY ROWNUM <= 2 UNION ALL
  						SELECT  'B' CUS_GD FROM DUAL CONNECT BY ROWNUM <= 1
  					) T_CUS_GD
  			ORDER BY T_RGN_ID.RGN_ID
  					,T_GND_TP.GND_TP
  					,T_CUS_GD.CUS_GD
  			) T1
  			;
  	COMMIT;


  -- ************************************************
  -- PART I - 1.2.2 SQL5
  -- ************************************************
  	-- 주문 데이터 생성
  	INSERT INTO T_ORD (ORD_SEQ ,CUS_ID ,ORD_DT ,ORD_ST ,PAY_DT ,PAY_TP ,ORD_AMT ,PAY_AMT)
  	SELECT  T4.RNO ORD_SEQ ,T4.CUS_ID ,T4.ORD_DT
  			,CASE WHEN MOD(T4.RNO, 10) = 1 THEN 'WAIT' ELSE 'COMP' END ORD_ST
  			,CASE WHEN MOD(T4.RNO, 10) = 1 THEN NULL ELSE T4.ORD_DT END PAY_DT
  			,CASE WHEN MOD(T4.RNO, 10) = 1 THEN NULL
  				  WHEN MOD(T4.RNO, 10) IN (3,4,5) THEN 'BANK'
  				  ELSE 'CARD' END PAY_TP
  			,NULL ORD_AMT
  			,NULL PAY_AMT
  	FROM    (
  			SELECT  ROW_NUMBER() OVER(ORDER BY T3.ORD_DT ,T3.CUS_ID) RNO
  					,T3.CUS_ID ,T3.ORD_DT
  			FROM    (
  					SELECT  T1.CUS_ID ,TO_DATE(T2.YMD,'YYYYMMDD') ORD_DT
  					FROM    M_CUS T1
  							,(
  								SELECT  TO_CHAR(TO_DATE('20161231','YYYYMMDD') + ROWNUM,'YYYYMMDD') YMD
  										,ROWNUM RNK
  								FROM    DUAL T1
  								CONNECT BY ROWNUM <= 365
  							) T2
  					WHERE   SUBSTR(T1.CUS_ID,-1,1) = SUBSTR(TO_CHAR(T2.RNK),-1,1)
  					AND     NOT(T2.YMD LIKE '201701%' AND T1.CUS_ID LIKE '%1')   --일부 고객 제외 처리.
  					AND     NOT(T2.YMD LIKE '201702%' AND (T1.CUS_ID LIKE '%2' OR T1.CUS_ID LIKE '%3'))
  					AND     NOT(T2.YMD LIKE '201704%' AND (T1.CUS_ID LIKE '%4' OR T1.CUS_ID LIKE '%5'))
  					AND     NOT(T2.YMD LIKE '201703%' AND (T1.CUS_GD = 'B'))
  					ORDER BY T2.YMD
  							,T1.CUS_ID
  					) T3
  			) T4
  			;
  	COMMIT;


  -- ************************************************
  -- PART I - 1.2.2 SQL6
  -- ************************************************
  	-- 주문 디테일 데이터 생성
  	INSERT INTO T_ORD_DET (ORD_SEQ ,ORD_DET_NO ,ITM_ID ,ORD_QTY ,UNT_PRC)
  	SELECT  T0.ORD_SEQ ,T0.ORD_DET_NO ,T0.ITM_ID ,T0.ORD_QTY ,T9.UNT_PRC
  	FROM    (
  			SELECT  T1.ORD_SEQ ,1 ORD_DET_NO ,T2.ITM_ID ,1 ORD_QTY,T1.ORD_DT
  			FROM    T_ORD T1
  					,(
  						SELECT  A.UNT_PRC ,A.ITM_ID
  								,ROW_NUMBER() OVER(ORDER BY A.ITM_ID) RNK
  						FROM    M_ITM A
  						WHERE   A.ITM_ID <> 'ITM100'
  						AND     A.ITM_TP <> 'PC'
  					) T2
  			WHERE   MOD(T1.ORD_SEQ,(SELECT COUNT(*) FROM M_ITM C WHERE C.ITM_ID <> 'ITM100')) + 1 = T2.RNK
  			UNION ALL
  			SELECT  T1.ORD_SEQ ,2 ORD_DET_NO ,T2.ITM_ID ,1 ORD_QTY,T1.ORD_DT
  			FROM    T_ORD T1
  					,(
  						SELECT  A.UNT_PRC ,A.ITM_ID
  								,ROW_NUMBER() OVER(ORDER BY A.ITM_ID DESC) RNK
  						FROM    M_ITM A
  						WHERE   A.ITM_ID NOT IN ('ITM100','ITM099')
  						AND     A.ITM_TP <> 'PC'
  					) T2
  			WHERE   MOD(T1.ORD_SEQ,
  	(SELECT COUNT(*) FROM M_ITM C WHERE C.ITM_ID NOT IN ('ITM100','ITM099'))) + 1 = T2.RNK
  			AND     MOD(T1.ORD_SEQ,10) IN (1,3,5)
  			) T0
  			,M_ITM_PRC_HIS T9
  	WHERE   T0.ITM_ID = T9.ITM_ID
  	AND     TO_CHAR(T0.ORD_DT,'YYYYMMDD') BETWEEN T9.FR_YMD AND T9.TO_YMD
  			;
  	COMMIT;

  -- ************************************************
  -- PART I - 1.2.2 SQL7
  -- ************************************************
  	-- 주문 금액 업데이트
  	MERGE INTO T_ORD T1
  	USING   (
  			SELECT  A.ORD_SEQ ,SUM(A.ORD_QTY * A.UNT_PRC) ORD_AMT
  			FROM    T_ORD_DET A
  			GROUP BY A.ORD_SEQ
  			) T2
  			ON (T1.ORD_SEQ = T2.ORD_SEQ)
  	WHEN MATCHED THEN UPDATE SET T1.ORD_AMT = T2.ORD_AMT
  								,T1.PAY_AMT = CASE WHEN T1.ORD_ST = 'COMP' THEN T2.ORD_AMT ELSE NULL END;

  	COMMIT;


  -- ************************************************
  -- PART I - 1.2.2 SQL8
  -- ************************************************
  	-- 아이템 평가 데이터 생성
  	INSERT INTO T_ITM_EVL(ITM_ID ,EVL_LST_NO ,CUS_ID ,EVL_DSC ,EVL_DT ,EVL_PT)
  	SELECT  T0.ITM_ID
  			,ROW_NUMBER() OVER(PARTITION BY T0.ITM_ID ORDER BY T0.ORD_DT) EVL_LST_NO
  			,T0.CUS_ID
  			,CASE WHEN T0.EVL_PT >= 4 THEN 'Great'
  				  WHEN T0.EVL_PT >= 2 THEN 'Not bad'
  				  ELSE 'Bad' END EVL_DSC
  			,T0.ORD_DT EVL_DT
  			,T0.EVL_PT
  	FROM    (
  			SELECT  T2.ITM_ID ,T1.CUS_ID ,T1.ORD_DT
  					,MOD(TO_NUMBER(SUBSTR(T1.CUS_ID,-2,2)) + TO_NUMBER(SUBSTR(T2.ITM_ID,-2,2)),5) + 1 EVL_PT
  			FROM    T_ORD T1
  					,T_ORD_DET T2
  			WHERE   T1.ORD_SEQ = T2.ORD_SEQ
  			AND     TO_CHAR(T1.ORD_DT,'YYYYMMDD') NOT LIKE '%2'
  			AND     T1.CUS_ID LIKE '%3'
  			UNION ALL
  			SELECT  T2.ITM_ID ,T1.CUS_ID ,TO_DATE('20170301','YYYYMMDD') ORD_DT
  					,1 EVL_PT
  			FROM    M_CUS T1
  					,M_ITM T2
  			WHERE   T1.CUS_ID LIKE '%1'
  			AND     T2.ITM_ID LIKE '%1'
  			) T0
  			;
  	COMMIT;

  -- ************************************************
  -- PART I - 1.2.2 SQL9
  -- ************************************************
  	-- 기준코드구분 데이터 생성
  	INSERT INTO C_BAS_CD_DV(BAS_CD_DV ,BAS_CD_DV_NM)
  	SELECT  'LNG_CD' BAS_CD_DV ,'언어코드' BAS_CD_DV_NM FROM DUAL UNION ALL
  	SELECT  'ITM_TP' BAS_CD_DV ,'아이템유형' BAS_CD_DV_NM FROM DUAL UNION ALL
  	SELECT  'ORD_ST' BAS_CD_DV ,'주문상태' BAS_CD_DV_NM FROM DUAL UNION ALL
  	SELECT  'PAY_TP' BAS_CD_DV ,'지불유형' BAS_CD_DV_NM FROM DUAL UNION ALL
  	SELECT  'GND_TP' BAS_CD_DV ,'성별구분' BAS_CD_DV_NM FROM DUAL UNION ALL
  	SELECT  'CUS_GD' BAS_CD_DV ,'고객등급' BAS_CD_DV_NM FROM DUAL;

  	COMMIT;


  -- ************************************************
  -- PART I - 1.2.2 SQL10
  -- ************************************************
  	-- 기준코드 데이터 생성
  	INSERT INTO C_BAS_CD (BAS_CD_DV ,LNG_CD ,BAS_CD ,BAS_CD_NM ,SRT_OD)
  	SELECT  'LNG_CD' BAS_CD_DV ,'KO' LNG_CD ,'KO' BAS_CD ,'한국어' BAS_CD_NM ,10 SRT_OD FROM DUAL UNION ALL
  	SELECT  'LNG_CD' ,'KO' ,'EN' ,'영어' ,20 FROM DUAL UNION ALL
  	SELECT  'LNG_CD' ,'KO' ,'CN' ,'중국어' ,30 FROM DUAL UNION ALL

  	SELECT  'ITM_TP' ,'KO' ,'ELEC' ,'가전제품' ,10 FROM DUAL UNION ALL
  	SELECT  'ITM_TP' ,'KO' ,'PC' ,'컴퓨터' ,20 FROM DUAL UNION ALL
  	SELECT  'ITM_TP' ,'KO' ,'COOK' ,'주방도구' ,30 FROM DUAL UNION ALL
  	SELECT  'ITM_TP' ,'KO' ,'CLOTHES' ,'옷' ,40 FROM DUAL UNION ALL

  	SELECT  'ORD_ST' ,'KO' ,'WAIT' ,'대기' ,10 FROM DUAL UNION ALL
  	SELECT  'ORD_ST' ,'KO' ,'COMP' ,'완료' ,20 FROM DUAL UNION ALL

  	SELECT  'PAY_TP' ,'KO' ,'BANK' ,'계좌이체' ,10 FROM DUAL UNION ALL
  	SELECT  'PAY_TP' ,'KO' ,'CARD' ,'카드' ,20 FROM DUAL UNION ALL

  	SELECT  'GND_TP' ,'KO' ,'FEMLE' ,'여성' ,10 FROM DUAL UNION ALL
  	SELECT  'GND_TP' ,'KO' ,'MALE' ,'남성' ,20 FROM DUAL UNION ALL

  	SELECT  'CUS_GD' ,'KO' ,'A' ,'A' ,10 FROM DUAL UNION ALL
  	SELECT  'CUS_GD' ,'KO' ,'B' ,'B' ,20 FROM DUAL;
  	COMMIT;
