
DELIMITER $$
CREATE FUNCTION `amountCategory`( -- Function Name
    `amountOfPeople` INTEGER -- Parameters
) RETURNS INTEGER -- Return Type
DETERMINISTIC -- Function property
BEGIN
	DECLARE category VARCHAR(1);
	SET category = CASE `amountOfPeople`
    	WHEN 1 OR 2 OR 7
        	THEN 'A'
        WHEN 3 OR 4
        	THEN 'B'
        WHEN 5 OR 6
        	THEN 'C'
        ELSE '!'
	END;
  RETURN category;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `ptest`(
    `param1` INTEGER
)
BEGIN
	SELECT * FROM `cell`;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `ptest3`(
	`amountOfPeople` INTEGER
)
BEGIN
	DECLARE cate VARCHAR;
    SET cate = AMOUNTCATEGORY(`amountOfPeople`);

    SELECT * FROM `cell`;
    SELECT * FROM `contain`;
    SELECT * FROM `menu`;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `ptest4`(
	`amountOfPeople` INTEGER
)
BEGIN
	DECLARE cate VARCHAR(1);
    DECLARE waitingQueue INTEGER;

    SET cate = amountCategory(`amountOfPeople`);

    SELECT *
    FROM `restauranttable` rt
    WHERE rt.tableNo NOT IN (
    	SELECT *
    	FROM `sitsAt` sa INNER JOIN `servicereceiver` AS `sr`
    	ON sa.groupID=sr.groupID
    ) AND rt.seatCount BETWEEN 1 AND 2;

    SET waitingQueue = (
        SELECT COUNT(*)
    	FROM `queueA` AS `q` INNER JOIN `servicereceiver` AS `sr`
        	ON q.groupID=sr.groupID
    	WHERE
            `q`.`queueCate`=cate AND -- Queue with category
            `sr`.valid=1 AND -- Valid SR
        	sr.enterDate IS NULL AND -- Entered
        	sr.leaveDate IS NOT NULL -- Not yet left
    );
    SELECT waitingQueue;
END$$
DELIMITER ;
