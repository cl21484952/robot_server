

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


DELIMITER $$
CREATE PROCEDURE checkTable(
    cate VARCHAR(1) CHARSET utf8
)
NOT DETERMINISTIC
BEGIN
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
            SELECT "Outside valid range";
    END CASE;
    -- Select
    SELECT * FROM restauranttable rt
    WHERE
        rt.seatCount BETWEEN startRange AND endRange AND
        rt.tableNo NOT IN(
        SELECT sa.tableNo
        FROM sitsAt sa, servicereceiver sr
        WHERE sa.groupID=sr.groupID);
END$$
DELIMITER ;
