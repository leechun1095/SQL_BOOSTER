-- ************************************************
-- PART III - 8.1.2 SQL1
-- ************************************************
-- 계좌 테이블 및 계좌 데이터 생성
-- 계좌 테이블을 생성
CREATE TABLE M_ACC
(
	ACC_NO VARCHAR2(40)  NOT NULL,
	ACC_NM VARCHAR2(100)  NULL,
	BAL_AMT NUMBER(18,3)  NULL
);

ALTER TABLE M_ACC
	ADD CONSTRAINT  PK_M_ACC PRIMARY KEY (ACC_NO) USING INDEX;

-- 테스트 데이터를 생성.
INSERT INTO M_ACC(ACC_NO ,ACC_NM ,BAL_AMT)
SELECT 'ACC1' ,'1번계좌' ,3000 FROM DUAL UNION ALL
SELECT 'ACC2' ,'2번계좌' ,500 FROM DUAL UNION ALL
SELECT 'ACC3' ,'3번계좌' ,0 FROM DUAL;


-- ************************************************
-- PART III - 8.1.2 SQL2
-- ************************************************
-- 계좌이체 – ACC1에서 ACC2로 500원 이체
-- 두 개의 UPDATE문을 실행한 다음에 COMMIT 했으므로, 두 UPDATE 문장은 하나의 트랜잭션으로 처리된다.
UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT - 500
 WHERE T1.ACC_NO = 'ACC1';

UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT + 500
 WHERE T1.ACC_NO = 'ACC2';

COMMIT;

-- ************************************************
-- PART III - 8.1.2 SQL3
-- ************************************************
-- 계좌이체 – ACC1에서 ACC4로 500원 이체
UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT - 500
 WHERE T1.ACC_NO = 'ACC1';

-- 존재하지 않는 계좌이지만 에러가 발생하지 않고, 0 rows Updated 가 된다.
UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT + 500
 WHERE T1.ACC_NO = 'ACC4';

SELECT * FROM M_ACC;

-- ************************************************
-- PART III - 8.1.2 SQL4
-- ************************************************
-- 계좌이체 – ACC1에서 ACC4로 500원 이체, ROLLBACK 처리
ROLLBACK;

SELECT * FROM M_ACC;

-- ************************************************
-- PART III - 8.1.2 SQL5
-- ************************************************
-- 계좌이체 – 계좌존재여부 검증
SELECT NVL(MAX('Y'),'N')
  FROM DUAL T1
 WHERE EXISTS(
		          SELECT * FROM M_ACC A WHERE A.ACC_NO = 'ACC4');

-- ************************************************
-- PART III - 8.1.2 SQL6
-- ************************************************
-- 계좌이체 – ACC1에서 ACC3로 5000원 이체
UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT - 5000
 WHERE T1.ACC_NO = 'ACC1';

UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT + 5000
 WHERE T1.ACC_NO = 'ACC3';

SELECT  * FROM M_ACC;

-- ************************************************
-- PART III - 8.1.2 SQL7
-- ************************************************
ROLLBACK;

SELECT  * FROM M_ACC;

-- ************************************************
-- PART III - 8.1.2 SQL8
-- ************************************************
-- 새로운 계좌를 INSERT
INSERT INTO M_ACC(ACC_NO ,ACC_NM ,BAL_AMT)
VALUES('ACC4' ,'4번계좌' ,0);

INSERT INTO M_ACC(ACC_NO ,ACC_NM ,BAL_AMT)
VALUES('ACC1' ,'1번계좌' ,0); --ACC1은 이미 존재하므로 에러가 발생한다.

-- ORA-00001: unique constraint (TEST.PK_M_ACC) violated
SELECT  * FROM M_ACC;

ROLLBACK;

-- ************************************************
-- PART III - 8.1.3 SQL1
-- ************************************************
-- UPDATE-SELECT 테스트 – 첫 번째 세션 SQL
SELECT  * FROM M_ACC T1 WHERE T1.ACC_NO = 'ACC1'; --ACC1의 잔액은 2500원

UPDATE M_ACC T1
   SET T1.BAL_AMT = 5000
 WHERE T1.ACC_NO = 'ACC1';

SELECT  * FROM M_ACC T1 WHERE T1.ACC_NO = 'ACC1'; --ACC1의 잔액 5000원

-- ************************************************
-- PART III - 8.1.3 SQL2
-- ************************************************
-- UPDATE-SELECT 테스트 – 두 번째 세션 SQL
SELECT  * FROM M_ACC T1 WHERE T1.ACC_NO = 'ACC1'; --ACC1의 잔액은 2500원


-- ************************************************
-- PART III - 8.1.3 SQL3
-- ************************************************
-- UPDATE-SELECT 테스트 – 첫 번째 세션 COMMIT 처리
-- READ COMMITTED : COMMIT 된 데이터만 읽을 수 있다.
-- 커밋하면 두 번째 세션에서 조회해도 동일하게 5000원으로 조회된다.
COMMIT;

-- ************************************************
-- PART III - 8.1.3 SQL4
-- ************************************************
-- UPDATE – UPDATE 테스트 – 첫 번째 세션 SQL
-- 현재 ACC1의 잔액은 5,000
UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT - 500
 WHERE T1.ACC_NO = 'ACC1';

SELECT  * FROM M_ACC T1 WHERE T1.ACC_NO = 'ACC1'; --ACC1의 잔액은 4,500원

-- ************************************************
-- PART III - 8.1.3 SQL5
-- ************************************************
--UPDATE – UPDATE 테스트 – 두 번째 세션 SQL
-- 아직 첫 번째 세션의 UPDATE 문이 COMMIT 되지 않았으므로
-- 두 번째 세션에서는 첫 번째 세션의 UPDATE 이전 데이터가 조회된다.
SELECT  * FROM M_ACC T1 WHERE T1.ACC_NO = 'ACC1'; --ACC1의 잔액은 5,000원

-- 아래 SQL은 첫 번째 세션에 막혀 진행되지 못한다.
UPDATE M_ACC T1
   SET T1.BAL_AMT = T1.BAL_AMT - 500
 WHERE T1.ACC_NO = 'ACC1';

-- ************************************************
-- PART III - 8.1.3 SQL6
-- ************************************************
-- UPDATE – UPDATE 테스트 – 첫 번째 세션 COMMIT
COMMIT;

-- ************************************************
-- PART III - 8.1.3 SQL7
-- ************************************************
-- UPDATE – UPDATE 테스트 – 두 번째 세션 확인
COMMIT;

SELECT  * FROM M_ACC T1 WHERE T1.ACC_NO = 'ACC1'; --ACC1의 잔액은 4,000원

-- ************************************************
-- PART III - 8.1.3 SQL8
-- ************************************************
-- INSERT – INSERT 테스트 – 첫 번째 세션 ACC4 생성
INSERT INTO M_ACC(ACC_NO, ACC_NM, BAL_AMT) VALUES('ACC4','4번계좌',0);

-- ************************************************
-- PART III - 8.1.3 SQL9
-- ************************************************
-- INSERT – INSERT 테스트 – 두 번째 세션 ACC4 생성
INSERT INTO M_ACC(ACC_NO, ACC_NM, BAL_AMT) VALUES('ACC4','4번계좌',0);

-- ************************************************
-- PART III - 8.1.3 SQL10
-- ************************************************
-- INSERT – INSERT 테스트 – 첫 번째 세션 COMMIT
COMMIT;

-- ************************************************
-- PART III - 8.1.3 SQL11
-- ************************************************
-- INSERT – INSERT 테스트 – 첫 번째 세션 ACC5 생성
INSERT INTO M_ACC(ACC_NO, ACC_NM, BAL_AMT) VALUES('ACC5','5번계좌',0);

-- ************************************************
-- PART III - 8.1.3 SQL12
-- ************************************************
-- INSERT – INSERT 테스트 – 두 번째 세션 ACC99 생성
INSERT INTO M_ACC(ACC_NO, ACC_NM, BAL_AMT) VALUES('ACC99','99번계좌',0);

-- ************************************************
-- PART III - 8.1.3 SQL13
-- ************************************************
-- INSERT – INSERT 테스트 – 두 번째 세션 ACC5 생성
INSERT INTO M_ACC(ACC_NO ,ACC_NM ,BAL_AMT) VALUES('ACC5' ,'5번계좌' ,0);

-- ************************************************
-- PART III - 8.1.3	 SQL14
-- ************************************************
-- INSERT – INSERT 테스트 – 첫 번째 세션 COMMIT
COMMIT;

-- ************************************************
-- PART III - 8.2.2 SQL1
-- ************************************************
-- 동시에 두 개의 세션이 ACC1의 잔액에서 4,000원씩을 출금하려고 한다.
--첫 번째 세션
--1.ACC1에서 4,000원을 출금하려고 한다.
SELECT T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO = 'ACC1'; --4,000원이 조회된다.

		--두 번째 세션
		--2.ACC1에서 4,000원을 출금하려고 한다.
		SELECT T1.BAL_AMT FROM M_ACC T1
		WHERE T1.ACC_NO = 'ACC1'; --4,000원이 조회된다.

--첫 번째 세션
--IF BAL_AMT >= 4,000 THEN UPDATE
--3.잔액이 4,000원이 있으므로 4,000원을 출금처리.
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 4000
WHERE T1.ACC_NO = 'ACC1';


--첫 번째 세션
--4.잔액이 0원이 되어 있다.
SELECT T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO = 'ACC1';

		--두 번째 세션
		--IF BAL_AMT >= 4,000 THEN UPDATE
		--5.잔액이 4,000원이 있으므로 4,000원을 출금처리.
		--첫 번째 세션에 의해 대기 상태에 빠진다.
		UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 4000
		WHERE T1.ACC_NO = 'ACC1';

--첫 번째 세션
--6.COMMIT처리.
COMMIT;

		--두 번째 세션
		--7. 잔액이 마이너스 4,000원이 되어 있다.
		SELECT T1.BAL_AMT FROM M_ACC T1
		WHERE T1.ACC_NO = 'ACC1';

		--두 번째 세션
		--8. COMMIT처리
		COMMIT;

-- ************************************************
-- PART III - 8.2.2 SQL2
-- ************************************************
-- ACC1의 잔액을 4,000원으로 변경
UPDATE M_ACC SET BAL_AMT = 4000 WHERE ACC_NO = 'ACC1';

COMMIT;

-- ************************************************
-- PART III - 8.2.2 SQL3
-- ************************************************
--동시에 두 개의 세션이 ACC1의 계좌에서 4,000원씩을 출금하려고 한다. – SELECT ~ FOR UPDATE사용.

-- 첫 번째 세션
--1. ACC1에서 4,000원을 출금하려고 한다.
SELECT T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO = 'ACC1'
FOR UPDATE; --4,000원이 조회된다.

		--두 번째 세션
		--2. ACC1에서 4,000원을 출금하려고 한다.
		SELECT T1.BAL_AMT FROM M_ACC T1
		WHERE T1.ACC_NO = 'ACC1'
		FOR UPDATE;
		-- 대기 상태에 빠졌다가 첫 번째 세션이 COMMIT된 후
		-- 0원이 조회된다.

-- 첫 번째 세션
--3. 잔액이 4,000원이 있으므로 4,000원을 출금처리.
-- IF BAL_AMT >= 4,000 THEN UPDATE
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 4000
WHERE T1.ACC_NO = 'ACC1';


-- 첫 번째 세션
--4. 잔액이 0원이 되어 있다.
SELECT T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO = 'ACC1';


-- 첫 번째 세션
--5. COMMIT처리.
COMMIT;


		--두 번째 세션
		-- IF BAL_AMT >= 4,000 THEN UPDATE
		-- 잔액이 4,000보다 작으므로 출금 불가.

		--두 번째 세션
		ROLLBACK;

-- ************************************************
-- PART III - 8.2.3 SQL1
-- ************************************************
-- 계좌조회 프로세스
SELECT  T1.* FROM M_ACC T1 FOR UPDATE;

-- ************************************************
-- PART III - 8.2.4 SQL1
-- ************************************************
-- ACC1, ACC2의 잔액 초기화
UPDATE M_ACC SET BAL_AMT = 5000 WHERE ACC_NO IN ('ACC1','ACC2');
COMMIT;

-- ************************************************
-- PART III - 8.2.4 SQL2
-- ************************************************
-- 데드락 테스트 – 두 개의 세션에서 계좌이체 실행
--첫 번째 세션, ACC1->ACC2 2,000원 이체
--1.ACC1의 잔액 확인
SELECT T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO = 'ACC1' FOR UPDATE;

--첫 번째 세션
--2.ACC1에서 잔액 마이너스
--(잔액이 이체금액 이상이면 이체 수행)
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 2000
WHERE T1.ACC_NO = 'ACC1';


		--두 번째 세션, ACC2->ACC1 3,000원 이체
		--두 번째 세션
		--3.ACC2의 잔액 확인
		SELECT T1.BAL_AMT FROM M_ACC T1
		WHERE T1.ACC_NO = 'ACC2' FOR UPDATE;


		--두 번째 세션
		--4. ACC2에서 잔액 마이너스
		--IF BAL_AMT >= 3,000 THEN UPDATE
		UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 3000
		WHERE T1.ACC_NO = 'ACC2';


--첫 번째 세션
--5. ACC2의 잔액 플러스
--두 번째 세션 3번,4번 SQL에 의해 대기에 빠진다.
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT + 2000
WHERE T1.ACC_NO = 'ACC2';


		--두 번째 세션
		--6.ACC1의 잔액 플러스
		--첫 번째 세션 1번,5번 SQL에 의해 대기에 빠진다.
		UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT + 3000
		WHERE T1.ACC_NO = 'ACC1';


--첫 번째 세션
--7. 약간의 시간 후에 아래와 같이 데드락이 발생
-- SQL 오류: ORA-00060: deadlock detected while waiting for resource


--첫 번째 세션
-- 8. 데드락이 나왔으므로 ROLLBACK처리한다.
ROLLBACK;


		--두 번째 세션
		-- 9. 두 번째 세션도 ROLLBACK처리한다.
		ROLLBACK;

-- ************************************************
-- PART III - 8.2.4 SQL3
-- ************************************************
-- 데드락 피하기 – 두 개의 세션에서 계좌이체 실행
-- 첫 번째 세션, ACC1->ACC2 2,000원 이체
-- 1.ACC1, ACC2의 잔액 확인
SELECT T1.ACC_NO ,T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO IN ('ACC1','ACC2') FOR UPDATE;

-- 첫 번째 세션
-- 2.ACC1에서 잔액 마이너스
-- (잔액이 이체금액 이상이면 이체 수행)
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 2000
WHERE T1.ACC_NO = 'ACC1';


		-- 두 번째 세션, ACC2->ACC1 3,000원 이체

		-- 두 번째 세션
		-- 3.ACC1, ACC2의 잔액 확인
		-- 첫 번째 세션 1번 SQL로 인해 대기 상태에 빠진다.
		SELECT T1.ACC_NO ,T1.BAL_AMT FROM M_ACC T1
		WHERE T1.ACC_NO IN ('ACC2','ACC1') FOR UPDATE;


-- 첫 번째 세션
-- 4. ACC2의 잔액 플러스
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT + 2000
WHERE T1.ACC_NO = 'ACC2';

-- 첫 번째 세션
COMMIT;


		-- 두 번째 세션
		-- 5. ACC2에서 잔액 마이너스
		-- IF BAL_AMT >= 3,000 THEN UPDATE
		UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 3000
		WHERE T1.ACC_NO = 'ACC2';

		-- 두 번째 세션
		-- 6.ACC1의 잔액 플러스
		UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT + 3000
		WHERE T1.ACC_NO = 'ACC1';

		-- 두 번째 세션
		COMMIT;

-- ************************************************
-- PART III - 8.2.5 SQL1
-- ************************************************
-- ACC1->ACC2 2,000원 계좌이체 트랜잭션 SQL
-- 1.ACC1, ACC2의 잔액 확인
SELECT T1.ACC_NO ,T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO IN ('ACC1','ACC2') FOR UPDATE;

-- 2.ACC1의 잔액이 이체금액 이상이면 이체 수행
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT - 2000
WHERE T1.ACC_NO = 'ACC1';

-- 3. ACC2의 잔액 플러스
UPDATE M_ACC T1 SET T1.BAL_AMT = T1.BAL_AMT + 2000
WHERE T1.ACC_NO = 'ACC2';
COMMIT;

-- ************************************************
-- PART III - 8.2.5 SQL2
-- ************************************************
-- ACC1->ACC2 2,000원 계좌이체 트랜잭션 SQL
-- 1.ACC1, ACC2의 잔액 확인
SELECT T1.ACC_NO ,T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO IN ('ACC1','ACC2') FOR UPDATE;

-- 2.ACC1의 BAL_AMT가 이체 금액보다 작으면 ROLLBACK처리(잔액이 부족합니다.)

-- 3.ACC2가 존재하지 않는다면 ROLLBACK처리(수신 계좌가 존재하지 않습니다.)

-- 4.ACC1과 ACC2의 잔액을 동시에 처리
UPDATE M_ACC T1
SET     T1.BAL_AMT = T1.BAL_AMT +
			   CASE  WHEN T1.ACC_NO = 'ACC1' THEN -1 * 2000
					 WHEN T1.ACC_NO = 'ACC2' THEN 1 * 2000 END
WHERE T1.ACC_NO IN ('ACC1','ACC2');
COMMIT;

-- ************************************************
-- PART III - 8.2.5 SQL3
-- ************************************************
-- ACC1->ACC2 2,000원 계좌이체 트랜잭션 SQL – 한 문장으로 처리
UPDATE  M_ACC T1
SET     T1.BAL_AMT = T1.BAL_AMT +
						CASE  WHEN T1.ACC_NO = 'ACC1' THEN -1 * 2000
							  WHEN T1.ACC_NO = 'ACC2' THEN 1 * 2000 END
WHERE   T1.ACC_NO IN ('ACC1','ACC2')
AND     T1.BAL_AMT >= CASE WHEN   T1.ACC_NO = 'ACC1' THEN 2000
							WHEN T1.ACC_NO = 'ACC2' THEN 0 END;

-- UPDATE된 건수가 두 건이면 COMMIT.
-- UPDATE된 건수가 두 건이 아니면 ROLLBACK
COMMIT;

-- ************************************************
-- PART III - 8.2.6 SQL1
-- ************************************************
UPDATE  M_ACC T1 SET T1.BAL_AMT = 3000;
COMMIT;

-- ************************************************
-- PART III - 8.2.6 SQL2
-- ************************************************
-- 1.ACC1, ACC2의 잔액 확인(ACC1과 ACC2 모두 3000원이 조회된다.)
-- ACC1의 잔액은 @FROM_BAL_AMT에, ACC2의 잔약은 @TO_BAL_AMT에 저장한다.
SELECT T1.ACC_NO ,T1.BAL_AMT FROM M_ACC T1
WHERE T1.ACC_NO IN ('ACC1','ACC2'); -- SELECT~FOR UPDATE를 사용하지 않는다.

-- 2.ACC1의 BAL_AMT가 이체 금액보다 작으면 ROLLBACK처리(잔액이 부족합니다.)

-- 3.ACC2가 존재하지 않는다면 ROLLBACK처리(수신 계좌가 존재하지 않습니다.)

-- 4.ACC1과 ACC2의 잔액을 동시에 처리
UPDATE  M_ACC T1
SET     T1.BAL_AMT = T1.BAL_AMT +
			   CASE  WHEN T1.ACC_NO = 'ACC1' THEN -1 * 2000
					 WHEN T1.ACC_NO = 'ACC2' THEN 1 * 2000 END
WHERE   T1.ACC_NO IN ('ACC1','ACC2')
AND     T1.BAL_AMT = CASE WHEN T1.ACC_NO = 'ACC1' THEN 3000 --@FROM_BAL_AMT 값을 사용
						  WHEN T1.ACC_NO = 'ACC2' THEN 3000 --@TO_BAL_AMT  값을 사용
						  END
;

-- 5. UPDATE된 건수가 2건 일때만 COMMIT처리.
COMMIT;

-- ************************************************
-- PART III - 8.3.1 SQL1
-- ************************************************
-- 구매오더(T_PO)테이블 생성
CREATE TABLE T_PO
(
	PO_NO                 VARCHAR2(40)  NOT NULL,
	TIT                   VARCHAR2(100) NULL,
	SUP_ID                VARCHAR2(40)  NULL,
	PO_ST                 VARCHAR2(40)  NULL,
	REQ_DT                DATE  NULL,
	REQ_UID               VARCHAR2(40)  NULL,
	CNF_DT                DATE  NULL,
	CNF_UID               VARCHAR2(40)  NULL,
	CMP_DT                DATE  NULL,
	CMP_UID               VARCHAR2(40)  NULL
);

CREATE UNIQUE INDEX PK_T_PO ON T_PO (PO_NO);

ALTER TABLE T_PO
	ADD CONSTRAINT  PK_T_PO PRIMARY KEY (PO_NO) USING INDEX;

-- ************************************************
-- PART III - 8.3.1 SQL2
-- ************************************************
-- PO + YYYYMMDD + NNNNNNNN 형태 채번 SQL
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_NEW_PO_NO VARCHAR2(40);
  v_REQ_DT DATE;
  v_REQ_YMD VARCHAR2(8);
BEGIN
  v_REQ_DT := sysdate;
  v_REQ_YMD := TO_CHAR(sysdate, 'yyyymmdd');

  SELECT 'PO' || v_REQ_YMD ||
          LPAD(
            TO_CHAR(
              TO_NUMBER(
                  NVL(SUBSTR(
                    MAX(T1.PO_NO)
                  ,-8),'0')
              ) + 1
            )
          ,8,'0')
    INTO    v_NEW_PO_NO
    FROM    T_PO T1
   WHERE   T1.REQ_DT >= TO_DATE(v_REQ_YMD,'yyyymmddhh24miss')
     AND     T1.REQ_DT < TO_DATE(v_REQ_YMD,'yyyymmddhh24miss') + 1;

  INSERT INTO T_PO (PO_NO ,TIT ,REQ_DT ,REQ_UID)
	VALUES (v_NEW_PO_NO ,'TEST_'||v_NEW_PO_NO ,v_REQ_DT ,'TEST');

	COMMIT;
END;

-- ************************************************
-- PART III - 8.3.2 SQL1
-- ************************************************
-- 백만 건의 PO 데이터를 생성
TRUNCATE TABLE T_PO;

INSERT INTO T_PO
		(PO_NO ,TIT ,REQ_DT ,REQ_UID)
SELECT  'PO'||T2.REQ_YMD||LPAD(TO_CHAR(T1.RNO),8,'0') PO_NO
		,'TEST PO' TIT
		,TO_DATE(T2.REQ_YMD,'YYYYMMDD') REQ_DT
		,'TEST' REQ_UID
FROM    (SELECT ROWNUM RNO FROM DUAL CONNECT BY ROWNUM <= 10000) T1 --하루에 만 건의 PO 데이터 생성.
		,(
		  SELECT TO_CHAR(TO_DATE('20170101','YYYYMMDD') + (ROWNUM -1 ),'YYYYMMDD') REQ_YMD
		  FROM DUAL A
		  CONNECT BY ROWNUM <= 100 --100일간의 데이터를 생성.
		) T2;

COMMIT;

-- ************************************************
-- PART III - 8.3.2 SQL2
-- ************************************************
-- SELECT~MAX의 성능 측정
SELECT /*+ GATHER_PLAN_STATISTICS */
		   MAX(T1.PO_NO)
  FROM T_PO T1
 WHERE T1.REQ_DT >= TO_DATE('20170302','YYYYMMDD')
   AND T1.REQ_DT < TO_DATE('20170302','YYYYMMDD') + 1;

-------------------------------------------------------------------------------------
| Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |      1 |        |      1 |00:00:00.02 |    6553 |
|   1 |  SORT AGGREGATE    |      |      1 |      1 |      1 |00:00:00.02 |    6553 |
|*  2 |   TABLE ACCESS FULL| T_PO |      1 |   9141 |  10000 |00:00:00.02 |    6553 |
-------------------------------------------------------------------------------------

-- ************************************************
-- PART III - 8.3.2 SQL3
-- ************************************************
-- SELECT~MAX의 성능 측정 – 인덱스 추가
CREATE INDEX X_T_PO_1 ON T_PO(REQ_DT, PO_NO);

SELECT /*+ GATHER_PLAN_STATISTICS */
		   MAX(T1.PO_NO)
  FROM T_PO T1
 WHERE T1.REQ_DT >= TO_DATE('20170302','YYYYMMDD')
   AND T1.REQ_DT < TO_DATE('20170302','YYYYMMDD') + 1;

-------------------------------------------------------------------------------------------------
| Id  | Operation         | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |      1 |        |      1 |00:00:00.01 |      56 |     40 |
|   1 |  SORT AGGREGATE   |          |      1 |      1 |      1 |00:00:00.01 |      56 |     40 |
|*  2 |   INDEX RANGE SCAN| X_T_PO_1 |      1 |   9141 |  10000 |00:00:00.01 |      56 |     40 |
-------------------------------------------------------------------------------------------------

-- ************************************************
-- PART III - 8.3.2 SQL4
-- ************************************************
-- REQ_YMD, PO_NO복합 인덱스 추가
ALTER TABLE T_PO ADD REQ_YMD VARCHAR(8);

UPDATE T_PO
   SET REQ_YMD = TO_CHAR(REQ_DT,'YYYYMMDD');

COMMIT;

CREATE INDEX X_T_PO_2 ON T_PO(REQ_YMD, PO_NO);

-- ************************************************
-- PART III - 8.3.2 SQL5
-- ************************************************
-- SELECT~MAX의 성능 측정 – REQ_YMD컬럼 사용
SELECT /*+ GATHER_PLAN_STATISTICS */
       MAX(T1.PO_NO)
  FROM T_PO T1
 WHERE T1.REQ_YMD = '20170302';

------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |          |      1 |        |      1 |00:00:00.01 |       3 |      1 |
|   1 |  SORT AGGREGATE              |          |      1 |      1 |      1 |00:00:00.01 |       3 |      1 |
|   2 |   FIRST ROW                  |          |      1 |      1 |      1 |00:00:00.01 |       3 |      1 |
|*  3 |    INDEX RANGE SCAN (MIN/MAX)| X_T_PO_2 |      1 |      1 |      1 |00:00:00.01 |       3 |      1 |
------------------------------------------------------------------------------------------------------------

-- ************************************************
-- PART III - 8.3.3 SQL1
-- ************************************************
-- 동시에 두 개의 세션에서 채번과 INSERT 작업을 실행
--첫 번째 세션
--1.채번을 실행(PO2017030200010001가 조회된다.)
SELECT  'PO' || '20170302' ||
		LPAD(TO_CHAR(TO_NUMBER(
		  NVL(SUBSTR(MAX(T1.PO_NO),-8),'0')) + 1
		  ),8,'0')
FROM    T_PO T1
WHERE   T1.PO_NO >= 'PO'||'20170302'
AND     T1.PO_NO <
	  'PO'||TO_CHAR(TO_DATE('20170302','YYYYMMDD')+1
			  ,'YYYYMMDD');

--첫 번째 세션
--2.채번된 번호를 이용 INSERT처리.
INSERT INTO T_PO (PO_NO ,TIT ,REQ_DT ,REQ_UID)
VALUES('PO2017030200010001','TEST',
TO_DATE('20170302','YYYYMMDD'),'TEST');

		--두 번째 세션
		--3.채번을 실행(PO2017030200010001가 조회된다.)
		--첫 번째 세션과 같은 번호가 채번된다.
		SELECT  'PO' || '20170302' ||
				LPAD(TO_CHAR(TO_NUMBER(
				  NVL(SUBSTR(MAX(T1.PO_NO),-8),'0')) + 1
				  ),8,'0')
		FROM    T_PO T1
		WHERE   T1.PO_NO >= 'PO'||'20170302'
		AND     T1.PO_NO <
			'PO'||TO_CHAR(TO_DATE('20170302','YYYYMMDD')+1
					  ,'YYYYMMDD');

		--두 번째 세션
		--4.채번된 번호를 이용 INSERT처리.
		--'PO2017030200010001'를 첫 번째 세션에서 이미
		--INSERT중이므로 대기 상태에 빠진다.
		--첫 번째 세션이 COMMIT처리하면 중복 오류가 발생.
		INSERT INTO T_PO (PO_NO ,TIT ,REQ_DT ,REQ_UID)
		VALUES('PO2017030200010001','TEST',
		TO_DATE('20170302','YYYYMMDD'),'TEST');



--첫 번째 세션
--5.COMMIT처리.
COMMIT;

		--두 번째 세션
		--6.오류가 발생했으므로 ROLLBACK한다.
		ROLLBACK;

-- ************************************************
-- PART III - 8.3.4 SQL1
-- ************************************************
-- 구매오더(T_PO)테이블 비우기
TRUNCATE TABLE T_PO;

-- ************************************************
-- PART III - 8.3.4 SQL2
-- ************************************************
-- 구매오더채번(T_PO_NUM)테이블 생성
CREATE TABLE T_PO_NUM
(
	BAS_YMD VARCHAR(8) NOT NULL,
	LST_PO_NO VARCHAR2(40)  NOT NULL
);

CREATE UNIQUE INDEX PK_T_PO_NUM ON T_PO_NUM (BAS_YMD);

ALTER TABLE T_PO_NUM
	ADD CONSTRAINT PK_T_PO_NUM PRIMARY KEY (BAS_YMD) USING INDEX;

-- ************************************************
-- PART III - 8.3.4 SQL3
-- ************************************************
-- 구매오더채번(T_PO_NUM)테이블을 이용한 채번
DECLARE
	v_NEW_PO_NO VARCHAR2(40);
	v_REQ_DT DATE;
	v_REQ_YMD VARCHAR2(8);
BEGIN
	v_REQ_DT := TO_DATE('20170301 23:59:59','YYYYMMDD HH24:MI:SS');
	v_REQ_YMD := TO_CHAR(v_REQ_DT,'YYYYMMDD'); -- 입력받은 v_REQ_DT를 v_REQ_YMD로 변환

	MERGE INTO T_PO_NUM T1
	USING (
		  SELECT  'PO' || v_REQ_YMD ||
						LPAD(TO_CHAR(
						  TO_NUMBER(
							NVL(SUBSTR(MAX(A.LST_PO_NO),-8),'0'))
						  + 1
						),8,'0') NEW_PO_NO
		  FROM    T_PO_NUM A
		  WHERE   A.BAS_YMD = v_REQ_YMD
		  ) T2
		  ON (T1.BAS_YMD = v_REQ_YMD)
	WHEN MATCHED THEN UPDATE SET T1.LST_PO_NO = T2.NEW_PO_NO
	WHEN NOT MATCHED THEN INSERT (BAS_YMD ,LST_PO_NO)
						VALUES(v_REQ_YMD ,T2.NEW_PO_NO)
	;

	SELECT  T1.LST_PO_NO
	INTO    v_NEW_PO_NO
	FROM    T_PO_NUM T1
	WHERE   T1.BAS_YMD = v_REQ_YMD;

	INSERT INTO T_PO (PO_NO ,TIT ,REQ_DT ,REQ_UID)
	VALUES (v_NEW_PO_NO ,'TEST_'||v_NEW_PO_NO ,v_REQ_DT ,'TEST');

	COMMIT;
END;

-- ************************************************
-- PART III - 8.3.5 SQL1
-- ************************************************
-- 채번함수
CREATE OR REPLACE FUNCTION UFN_GET_PO_NO
(    v_BAS_YMD IN VARCHAR2
)
RETURN VARCHAR2 IS PRAGMA AUTONOMOUS_TRANSACTION;
	v_NEW_PO_NO VARCHAR2(40);
BEGIN
	--채번 실행.
	UPDATE  T_PO_NUM T1
	SET     T1.LST_PO_NO = 'PO' || v_BAS_YMD ||
				LPAD(TO_CHAR(TO_NUMBER(
						NVL(SUBSTR(T1.LST_PO_NO,-8),'0')
			) + 1),8,'0')
	WHERE   T1.BAS_YMD = v_BAS_YMD;

	--업데이트 데이터가 없으면, 최초 채번이므로 INSERT수행.
	IF SQL%ROWCOUNT=0 THEN
		INSERT INTO T_PO_NUM (BAS_YMD, LST_PO_NO) VALUES  (v_BAS_YMD, 'PO'||v_BAS_YMD||'00000001');
	END IF;

	--채번값 GET
	SELECT  T1.LST_PO_NO
	INTO    v_NEW_PO_NO
	FROM    T_PO_NUM T1
	WHERE   T1.BAS_YMD = v_BAS_YMD;


	COMMIT; --트랜잭션 COMMIT처리.

	RETURN v_NEW_PO_NO;

END;

-- ************************************************
-- PART III - 8.3.5 SQL2
-- ************************************************
-- 채번함수를 사용한 채번
DECLARE
	v_NEW_PO_NO VARCHAR2(40);
	v_REQ_DT DATE;
	v_REQ_YMD VARCHAR2(8);
BEGIN
	v_REQ_DT := TO_DATE('20170305 23:59:59','YYYYMMDD HH24:MI:SS');
	v_REQ_YMD := TO_CHAR(v_REQ_DT,'YYYYMMDD'); -- 입력받은 v_REQ_DT를 v_REQ_YMD로 변환

	v_NEW_PO_NO := UFN_GET_PO_NO(v_REQ_YMD);

	INSERT INTO T_PO (PO_NO ,TIT ,REQ_DT ,REQ_UID)
	VALUES (v_NEW_PO_NO ,'TEST_'||v_NEW_PO_NO ,v_REQ_DT ,'TEST');

	COMMIT;
END;

-- ************************************************
-- PART III - 8.3.5 SQL3
-- ************************************************
-- 통합채번 테이블 생성
CREATE TABLE M_NUM
(
	NUM_TP VARCHAR2(40) NOT NULL,
	BAS_YMD VARCHAR(8) NOT NULL,
	LST_NO VARCHAR2(40)  NOT NULL
);

CREATE UNIQUE INDEX PK_M_NUM ON M_NUM(NUM_TP, BAS_YMD);

ALTER TABLE M_NUM
	ADD CONSTRAINT  PK_M_NUM PRIMARY KEY (NUM_TP, BAS_YMD) USING INDEX;

-- ************************************************
-- PART III - 8.3.5 SQL4
-- ************************************************
-- 통합된 형태의 채번함수
CREATE OR REPLACE FUNCTION UFN_GET_NUM
(    v_NUM_TP IN VARCHAR2
	,v_BAS_YMD IN VARCHAR2 )
RETURN VARCHAR2 IS PRAGMA AUTONOMOUS_TRANSACTION;
	v_NEW_NO VARCHAR2(40);
	v_PREFIX VARCHAR2(40);
	v_LENGTH INT;
BEGIN
	SELECT  CASE  WHEN v_NUM_TP = 'PO' THEN 'PO'
				  WHEN v_NUM_TP = 'SO' THEN 'SO'
				  WHEN v_NUM_TP = 'CS' THEN 'CS'
			END
			,CASE WHEN v_NUM_TP = 'PO' THEN 8
				  WHEN v_NUM_TP = 'SO' THEN 8
				  WHEN v_NUM_TP = 'CS' THEN 4
			END
	INTO    v_PREFIX
			,v_LENGTH
	FROM    DUAL;

	--채번 실행.
	UPDATE  M_NUM T1
	SET     T1.LST_NO = v_PREFIX || v_BAS_YMD ||
				LPAD(TO_CHAR(TO_NUMBER(
						NVL(SUBSTR(T1.LST_NO,(-1*v_LENGTH)),'0')
			) + 1),v_LENGTH,'0')
	WHERE   T1.NUM_TP = v_NUM_TP
	AND     T1.BAS_YMD = v_BAS_YMD;

	--업데이트 데이터가 없으면, 최초 채번이므로 INSERT수행.
	IF SQL%ROWCOUNT=0 THEN
		INSERT INTO M_NUM (NUM_TP ,BAS_YMD ,LST_NO)
		VALUES  (v_NUM_TP ,v_BAS_YMD ,v_PREFIX||v_BAS_YMD||LPAD('1',v_LENGTH,'0'));
	END IF;

	--채번값 GET(채번 유형까지 변수로 사용)
	SELECT  T1.LST_NO
	INTO    v_NEW_NO
	FROM    M_NUM T1
	WHERE   T1.NUM_TP = v_NUM_TP
	AND     T1.BAS_YMD = v_BAS_YMD;

	COMMIT; --트랜잭션 COMMIT처리.

	RETURN v_NEW_NO;
END;

-- ************************************************
-- PART III - 8.3.5 SQL5
-- ************************************************
-- 통합 채번함수 사용
SELECT UFN_GET_NUM('PO','20170501') PO_NO
		 , UFN_GET_NUM('SO','20170501') SO_NO
		 , UFN_GET_NUM('CS','20170501') CS_ID
  FROM DUAL;

-- ************************************************
-- PART III - 8.4.1 SQL1
-- ************************************************
-- 시퀀스 객체를 사용할 때 테이블에 부여한 시퀀스 값에 구멍이 빠질 수 있다.
-- 구멍이 빠졌다는 뜻은 부여된 시퀀스 값이 1, 2, 4 와 같이 중간에 값이 없는 것을 뜻한다.
-- 그 이유는 스퀀스가 트랜잭션의 커밋과 롤백과는 무관하게 처리되기 때문이다.
-- 계좌이체 테이블 생성
CREATE TABLE T_ACC_TRN
(
	ACC_TRN_SEQ           NUMBER(18)  NOT NULL,
	FR_ACC_NO             VARCHAR2(40)  NULL,
	TO_ACC_NO             VARCHAR2(40)  NULL,
	TRN_AMT               NUMBER(18,3)  NULL,
	TRN_HND_ST            VARCHAR2(40)  NULL,
	TRN_ERR_CD            VARCHAR2(40)  NULL,
	TRN_REQ_DT            TIMESTAMP  NULL,
	TRN_CMP_DT            TIMESTAMP  NULL
);

ALTER TABLE T_ACC_TRN
	ADD CONSTRAINT T_ACC_TRN PRIMARY KEY (ACC_TRN_SEQ) USING INDEX;

ALTER TABLE T_ACC_TRN
	ADD (CONSTRAINT  FK_T_ACC_TRN_1 FOREIGN KEY (FR_ACC_NO) REFERENCES M_ACC(ACC_NO));

ALTER TABLE T_ACC_TRN
	ADD (CONSTRAINT  FK_T_ACC_TRN_2 FOREIGN KEY (TO_ACC_NO) REFERENCES M_ACC(ACC_NO));

-- ************************************************
-- PART III - 8.4.1 SQL2
-- ************************************************
-- 계좌이체 시퀀스 생성
CREATE SEQUENCE SQ_T_ACC_TRN
START WITH 1
INCREMENT BY 1
MAXVALUE 99999999999999999999999999
NOCYCLE
CACHE 20
NOORDER;



-- ************************************************
-- PART III - 8.4.1 SQL3
-- ************************************************
-- 시퀀스를 이용한 계좌이체 처리
DECLARE
  v_NEW_ACC_TRN_SEQ NUMBER(18);
BEGIN

  v_NEW_ACC_TRN_SEQ := SQ_T_ACC_TRN.NEXTVAL();

  INSERT INTO T_ACC_TRN
		(ACC_TRN_SEQ ,FR_ACC_NO ,TO_ACC_NO ,TRN_AMT ,TRN_HND_ST ,TRN_ERR_CD ,TRN_REQ_DT ,TRN_CMP_DT)
  VALUES(v_NEW_ACC_TRN_SEQ ,'ACC1' ,'ACC3' ,500 ,'REQ' ,NULL ,SYSDATE ,NULL);

  COMMIT;
END;

-- ************************************************
-- PART III - 8.4.2 SQL1
-- ************************************************
-- 시퀀스를 이용한 계좌이체 처리 – 잘못된 방법
DECLARE
  v_NEW_ACC_TRN_SEQ NUMBER(18);
BEGIN

  INSERT INTO T_ACC_TRN
		(ACC_TRN_SEQ ,FR_ACC_NO ,TO_ACC_NO ,TRN_AMT ,TRN_HND_ST ,TRN_ERR_CD ,TRN_REQ_DT ,TRN_CMP_DT)
  VALUES(SQ_T_ACC_TRN.NEXTVAL ,'ACC1' ,'ACC3' ,500 ,'REQ' ,NULL ,SYSDATE ,NULL);

  SELECT  MAX(ACC_TRN_SEQ)
  INTO    v_NEW_ACC_TRN_SEQ
  FROM    T_ACC_TRN;

  COMMIT;
END;

-- ************************************************
-- PART III - 8.4.2 SQL2
-- ************************************************
-- 시퀀스를 이용한 계좌이체 처리 – CURRVAL 이용
DECLARE
  v_NEW_ACC_TRN_SEQ NUMBER(18);
BEGIN

  INSERT INTO T_ACC_TRN
		(ACC_TRN_SEQ ,FR_ACC_NO ,TO_ACC_NO ,TRN_AMT ,TRN_HND_ST ,TRN_ERR_CD ,TRN_REQ_DT ,TRN_CMP_DT)
  VALUES(SQ_T_ACC_TRN.NEXTVAL ,'ACC1' ,'ACC3' ,500 ,'REQ' ,NULL ,SYSDATE ,NULL);

  v_NEW_ACC_TRN_SEQ := SQ_T_ACC_TRN.CURRVAL();

  DBMS_OUTPUT.PUT_LINE('NEW SEQ:'||TO_CHAR(v_NEW_ACC_TRN_SEQ));

  COMMIT;
END;

-- ************************************************
-- PART III - 8.4.3 SQL1
-- ************************************************
-- T_CUS_LGN 테이블 생성 및 테스트 데이터 입력
CREATE TABLE T_CUS_LGN
(
	CUS_ID VARCHAR2(40) NOT NULL,
	LGN_DT DATE NOT NULL,
	SUC_YN VARCHAR2(40) NULL,
	LGN_FAL_CD VARCHAR2(40) NULL
);

CREATE UNIQUE INDEX PK_T_CUS_LGN ON T_CUS_LGN(CUS_ID, LGN_DT);

ALTER TABLE T_CUS_LGN
	ADD CONSTRAINT PK_T_CUS_LGN PRIMARY KEY(CUS_ID, LGN_DT) USING INDEX;


INSERT INTO T_CUS_LGN (CUS_ID ,LGN_DT ,SUC_YN ,LGN_FAL_CD)
SELECT  T1.CUS_ID ,T2.LGN_DT
		,CASE WHEN T1.CUS_ID = 'CUS_0001' AND RNO >= 4998 THEN 'N' ELSE 'Y' END SUC_YN
		,CASE WHEN T1.CUS_ID = 'CUS_0001' AND RNO >= 4998 THEN 'PW.WRONG' ELSE NULL END LGN_FAL_CD
FROM    M_CUS T1
		,(    SELECT TO_DATE('20170301','YYYYMMDD') + (ROWNUM / 24 / 60 / 30) LGN_DT
					,ROWNUM  RNO
			  FROM  DUAL A CONNECT BY ROWNUM <= 5000
		) T2;

-- ************************************************
-- PART III - 8.4.3 SQL2
-- ************************************************
-- 로그인 연속 실패 카운트 – 좋지 못한 방법
SELECT COUNT(*)
  FROM T_CUS_LGN T1
 WHERE T1.LGN_DT > (SELECT MAX(T1.LGN_DT) LAST_SUC_DT
                      FROM T_CUS_LGN T1
                     WHERE T1.CUS_ID = 'CUS_0001'
                       AND T1.SUC_YN = 'Y'
                   )
   AND T1.CUS_ID = 'CUS_0001'
   AND T1.SUC_YN = 'N';

-- ************************************************
-- PART III - 8.4.3 SQL3
-- ************************************************
-- 로그인 연속 실패 카운트 – ROWNUM과 인덱스를 활용한 효율적인 방법
SELECT /*+ GATHER_PLAN_STATISTICS */ COUNT(*)
  FROM (
        SELECT *
          FROM (
                -- 인라인뷰 안쪽
                SELECT *
                  FROM T_CUS_LGN T1
                 WHERE T1.CUS_ID = 'CUS_0001'
                 ORDER BY T1.LGN_DT DESC
               ) T2
		     WHERE ROWNUM <= 3
		   ) T3
 WHERE T3.SUC_YN = 'N';

-- PK가 CUS_ID, LGN_DT 로 되어 있어 인덱스를 잘 탔다.
-----------------------------------------------------------------------------------------------------------
| Id  | Operation                        | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                 |              |      1 |        |      1 |00:00:00.01 |       4 |
|   1 |  SORT AGGREGATE                  |              |      1 |      1 |      1 |00:00:00.01 |       4 |
|*  2 |   VIEW                           |              |      1 |      3 |      3 |00:00:00.01 |       4 |
|*  3 |    COUNT STOPKEY                 |              |      1 |        |      3 |00:00:00.01 |       4 |
|   4 |     VIEW                         |              |      1 |   5180 |      3 |00:00:00.01 |       4 |
|   5 |      TABLE ACCESS BY INDEX ROWID | T_CUS_LGN    |      1 |   5180 |      3 |00:00:00.01 |       4 |
|*  6 |       INDEX RANGE SCAN DESCENDING| PK_T_CUS_LGN |      1 |      4 |      3 |00:00:00.01 |       3 |
-----------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
  2 - filter("T3"."SUC_YN"='N')
  3 - filter(ROWNUM<=3)
  6 - access("T1"."CUS_ID"='CUS_0001')

-- ************************************************
-- PART III - 8.4.3 SQL4
-- ************************************************
-- 로그인 연속 실패 카운트 – ROWNUM과 인덱스를 잘 못 사용한 경우
SELECT *
  FROM (
        SELECT *
          FROM T_CUS_LGN T1
         WHERE T1.CUS_ID = 'CUS_0001'
         ORDER BY T1.LGN_DT DESC
		   ) T2
 WHERE ROWNUM <= 3
   AND T2.SUC_YN = 'N'
