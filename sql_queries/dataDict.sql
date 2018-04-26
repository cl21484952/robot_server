

/* Make ServiceReceiver (SR) and insert
Return the UUID of the newly created SR
*/
DELIMITER $$
CREATE FUNCTION srMake(
    ppl INTEGER(2)
) RETURNS varchar(36) CHARSET utf8
NO SQL
BEGIN
    DECLARE uuid varchar(36);
    set uuid = UUID();
    INSERT INTO servicereceiver(groupID, amountOfPeople)
    VALUES(uuid, ppl);
    RETURN uuid;
END$$
DELIMITER ;

/* Check which category the amount of people belong
Return 'Z' if amount is less than 0
Return 'X' if the amount isn't supported
*/;
DELIMITER $$
CREATE FUNCTION checkTableCategory(
    amount_of_ppl INTEGER(2)
) RETURNS VARCHAR(1) CHARSET utf8
DETERMINISTIC
BEGIN
    DECLARE output VARCHAR(3);
    IF amount_of_ppl <= 0 THEN
        SET output = 'Z';
    ELSEIF amount_of_ppl <= 2 THEN
        SET output = 'A';
    ELSEIF amount_of_ppl <= 4 THEN
        SET output = 'B';
    ELSEIF amount_of_ppl <= 6 THEN
        SET output = 'C';
    ELSE
        SET output = 'X';
    END IF;
    RETURN output;
END$$
DELIMITER ;


/* Count the number of waiting queue
Returns the amount of queue waiting
*/
CREATE FUNCTION queueCheck(
    cat VARCHAR(1) CHARSET utf8
) RETURNS INTEGER
NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE waitingQueue INTEGER DEFAULT -1;
    SET waitingQueue = (SELECT COUNT(*)
    FROM queue AS q INNER JOIN servicereceiver AS sr
    ON q.groupID=sr.groupID
    WHERE
        q.queueCate=cat AND
        sr.enterDate IS NULL AND
        sr.valid=1);
    RETURN waitingQueue;
END


/* Insert queue for groupID
Returns queue number with category (eg b12)
*/
DELIMITER $$
CREATE FUNCTION queueInsert(
    cat VARCHAR(1) CHARSET utf8,
    groupid VARCHAR(36) CHARSET utf8
) RETURNS varchar(5) CHARSET utf8
NOT DETERMINISTIC
BEGIN
    DECLARE qid VARCHAR(36) DEFAULT UUID();
    DECLARE qNo INT(4) DEFAULT NULL; -- Ensure either success or fail
    SET qNO = (SELECT MAX(queueNo) FROM queue WHERE queueCate = cat)+1;
    INSERT INTO queue(queueID, queueNo, queueDate, groupID, queueCate)
    VALUES(qid, qNO, SYSDATE(), groupid, cat);
  	RETURN CONCAT(cat, qNO);
END$$
DELIMITER ;


/* Request a queue
Returns queueNo
*/
DELIMITER $$
CREATE FUNCTION requestQueue(
    ppl INTEGER(2)
) RETURNS varchar(5) CHARSET utf8
NO SQL
BEGIN
    DECLARE gID varchar(36);
    DECLARE queueNo varchar(5);
    SET gID = srMake(ppl);
    SET queueNo = queueInsert(checkTableCategory(ppl), gID);
    RETURN queueNo;
END$$
DELIMITER ;


/* Insert sits at and update enter date
*/
DELIMITER $$
CREATE PROCEDURE sitAtAndUpdate(
    groupid VARCHAR(36) CHARSET utf8,
    tableNo VARCHAR(1) CHARSET utf8
)
NOT DETERMINISTIC
BEGIN

    -- update enter date
    UPDATE servicereceiver
    SET enterDate=SYSDATE()
    WHERE servicereceiver.groupID=groupID;

    -- RETURN
    SELECT * FROM servicereceiver
    WHERE servicereceiver.groupID=groupID;

    -- insert sits at
    INSERT INTO SitsAt(groupID) VALUES
        (groupID, tableNo);

    -- Return
    SELECT * FROM sitsAt
    WHERE sitsAt.groupID=groupID;

END$$
DELIMITER ;



/* Invalidate SR
Return the row which is affected
*/
DELIMITER $$
CREATE PROCEDURE invalidateSR(
    groupid VARCHAR(36) CHARSET utf8
)
NOT DETERMINISTIC
BEGIN

    -- update enter date
    UPDATE servicereceiver
    SET valid=0
    WHERE servicereceiver.groupID=groupID;

    -- RETURN
    SELECT * FROM servicereceiver
    WHERE servicereceiver.groupID=groupID;

END$$
DELIMITER ;

/* Check if there is free table available
Returns -1 if there is not table available
Returns NULL if input category is invalid
*/
DELIMITER $$
CREATE FUNCTION checkTable(
    cate VARCHAR(1) CHARSET utf8
) RETURNS INTEGER
NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE tableNum INTEGER DEFAULT NULL;
    DECLARE startRange INTEGER(2) DEFAULT NULL;
    DECLARE endRange INTEGER(2) DEFAULT NULL;
    CASE `cate`
        WHEN 'A' THEN
            SET startRange = 1;
            SET endRange = 2;
        WHEN 'B' THEN
            SET startRange = 3;
            SET endRange = 4;
        WHEN 'C' THEN
            SET startRange = 5;
            SET endRange = 6;
        ELSE
            RETURN -1;
    END CASE;
    -- Select
    -- SET tableNum = (SELECT rt.tableNo
    SELECT rt.tableNo INTO tableNum
    FROM restauranttable rt
    WHERE
        rt.seatCount BETWEEN startRange AND endRange AND
        rt.tableNo NOT IN(
        SELECT sa.tableNo
        FROM sitsAt sa, servicereceiver sr
        WHERE sa.groupID=sr.groupID)
    ORDER BY rt.tableNo ASC
    LIMIT 1;
    RETURN tableNum;
END$$
DELIMITER ;


/* Check if there is free table available
Returns -1 if there is not table available
Returns NULL if input category is invalid
*/
DELIMITER $$
CREATE PROCEDURE `tableChecking3`
(IN `amountOfPeople` INT(2))
NOT DETERMINISTIC
CONTAINS SQL
proc:BEGIN
    DECLARE cate VARCHAR(1);
    DECLARE tableNo INTEGER;
    DECLARE groupID VARCHAR(36) DEFAULT NULL;
    DECLARE waitingQueue INTEGER DEFAULT -1;
    DECLARE error VARCHAR(255);

    SELECT checkTableCategory(amountOfPeople) INTO cate;

    IF (cate = 'Z' OR cate = 'X') THEN
        SET error = "Invalid range";
    ELSE
    	SELECT checkTable(cate) INTO tableNo;
        IF (tableNo > 0) THEN
        BEGIN
            SELECT srMake(amountOfPeople) INTO groupID;
            CALL sitAtAndUpdate(groupID, tableNo);
        END;
        ELSE
            SELECT queueCheck(cate) INTO waitingQueue;
        END IF;
    END IF;

    SELECT error, tableNo, waitingQueue;

END$$
DELIMITER ;


-- Select queue which are waiting
SELECT *
FROM
Queue q LEFT JOIN servicereceiver sr ON sr.groupID=q.groupID
WHERE
	sr.enterDate IS NULL -- Select waiting queue;
	sr.valid=1 -- Still valid
;

-- Select tables which are free
SELECT *
FROM restauranttable rt
WHERE rt.tableNo NOT IN -- Table which is free
  (SELECT DISTINCT sa.tableNo -- Table that is full
  FROM `ServiceReceiver` sr, `SitsAt` sa
  WHERE sr.enterDate IS NOT NULL AND -- Customer has table
  sr.leaveDate IS NULL AND -- Customer has not left
  sr.groupID=sa.groupID) -- JOIN
;

-- Select queue aligned with table
SELECT *
FROM Queue q, RestaurantTable rt
WHERE
	-- q.queueID IN SELECT waitingQueue() AND
	q.queueID IN
		(SELECT q.queueID
		FROM
		Queue q LEFT JOIN servicereceiver sr ON sr.groupID=q.groupID
		WHERE
			sr.enterDate IS NULL AND -- Select waiting queue;
			sr.valid=1 -- Still valid
		) AND
	-- rt.tableNo IN SELECT freeTables() AND
	rt.tableNo IN
		(SELECT rt.tableNo
		FROM restauranttable rt
		WHERE rt.tableNo NOT IN -- Table which is free
		  (SELECT DISTINCT sa.tableNo -- Table that is full
		  FROM `ServiceReceiver` sr, `SitsAt` sa
		  WHERE sr.enterDate IS NOT NULL AND -- Customer has table
		  sr.leaveDate IS NULL AND -- Customer has not left
		  sr.groupID=sa.groupID) -- JOIN
		) AND
	q.queueCate=checkTableCategory(rt.seatCount)
ORDER BY
	q.queueDate ASC
;


DELIMITER $$
CREATE PROCEDURE `checkWaitingQueueTest`()
NOT DETERMINISTIC
CONTAINS SQL
proc:BEGIN
  SELECT q.groupID, CONCAT(q.queueCate, q.queueNo) AS queueTicket, rt.tableNo, rt.positionID
  FROM queue q, RestaurantTable rt
  WHERE
    -- q.queueID IN SELECT waitingQueue() AND
    q.queueID IN
      (SELECT q.queueID
      FROM
      Queue q LEFT JOIN servicereceiver sr ON sr.groupID=q.groupID
      WHERE
        sr.enterDate IS NULL AND -- Select waiting queue;
        sr.valid=1 -- Still valid
      ) AND
    -- rt.tableNo IN SELECT freeTables() AND
    rt.tableNo IN
      (SELECT rt.tableNo
      FROM restauranttable rt
      WHERE rt.tableNo NOT IN -- Table which is free
        (SELECT DISTINCT sa.tableNo -- Table that is full
        FROM `ServiceReceiver` sr, `SitsAt` sa
        WHERE sr.enterDate IS NOT NULL AND -- Customer has table
        sr.leaveDate IS NULL AND -- Customer has not left
        sr.groupID=sa.groupID) -- JOIN
      ) AND
    q.queueCate=checkTableCategory(rt.seatCount)
  ORDER BY
    q.queueDate ASC
  LIMIT 1
  ;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `checkWaitingQueue3`()
NOT DETERMINISTIC
CONTAINS SQL
proc:BEGIN
  DECLARE gID VARCHAR(36) DEFAULT NULL;
  DECLARE queueNum VARCHAR(4) DEFAULT NULl;
  DECLARE queueCate VARCHAR(1) DEFAULT NULL;
  DECLARE tableNum INTEGER DEFAULT NULL;
  DECLARE positionID VARCHAR(36) DEFAULT NULL;

  DECLARE queueTicket VARCHAR(5) DEFAULT NULL;

  SELECT
    q.groupID, q.queueNo, q.queueCate, rt.tableNo, rt.positionID
	 INTO
	 gID, queueNum, queueCate, tableNum, positionID
  FROM queue q, RestaurantTable rt
  WHERE
    -- q.queueID IN SELECT waitingQueue() AND
    q.queueID IN
      (SELECT q.queueID
      FROM
      Queue q LEFT JOIN servicereceiver sr ON sr.groupID=q.groupID
      WHERE
        sr.enterDate IS NULL AND -- Select waiting queue;
        sr.valid=1 -- Still valid
      ) AND
    -- rt.tableNo IN SELECT freeTables() AND
    rt.tableNo IN
      (SELECT rt.tableNo
      FROM restauranttable rt
      WHERE rt.tableNo NOT IN -- Table which is free
        (SELECT DISTINCT sa.tableNo -- Table that is full
        FROM `ServiceReceiver` sr, `SitsAt` sa
        WHERE sr.enterDate IS NOT NULL AND -- Customer has table
        sr.leaveDate IS NULL AND -- Customer has not left
        sr.groupID=sa.groupID) -- JOIN
      ) AND
    q.queueCate=checkTableCategory(rt.seatCount)
  ORDER BY
    q.queueDate ASC
  LIMIT 1
  ;

  -- Exists
  IF (gID IS NOT NULL) THEN
    SET queueTicket = CONCAT(queueCate, queueNum);
    CALL sitAtAndUpdate(gID, tableNum);
  END IF;

  SELECT
    gID AS groupID,
    queueTicket AS queueID,
    tableNum AS tableNo,
    positionID
  ;
END$$
DELIMITER ;
