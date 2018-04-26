-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 26, 2018 at 08:20 AM
-- Server version: 5.6.34-log
-- PHP Version: 7.1.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `zg6kbqpoxrbx4hox`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkWaitingQueue` ()  proc:BEGIN
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
    -- q.queueID IN SELECT waitingQueue() AND    q.queueID IN
      (SELECT q.queueID
      FROM
      Queue q LEFT JOIN servicereceiver sr ON sr.groupID=q.groupID
      WHERE
        sr.enterDate IS NULL AND -- Select waiting queue;        sr.valid=1 -- Still valid      ) AND
    -- rt.tableNo IN SELECT freeTables() AND    rt.tableNo IN
      (SELECT rt.tableNo
      FROM restauranttable rt
      WHERE rt.tableNo NOT IN -- Table which is free        (SELECT DISTINCT sa.tableNo -- Table that is full        FROM `ServiceReceiver` sr, `SitsAt` sa
        WHERE sr.enterDate IS NOT NULL AND -- Customer has table        sr.leaveDate IS NULL AND -- Customer has not left        sr.groupID=sa.groupID) -- JOIN      ) AND
    q.queueCate=checkTableCategory(rt.seatCount)
  ORDER BY
    q.queueDate ASC
  LIMIT 1
  ;

  -- Exists  IF (gID IS NOT NULL) THEN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `invalidateSR` (`groupid` VARCHAR(36) CHARSET utf8)  BEGIN

        UPDATE servicereceiver
    SET valid=0
    WHERE servicereceiver.groupID=groupID;

        SELECT * FROM servicereceiver
    WHERE servicereceiver.groupID=groupID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sitAtAndUpdate` (IN `groupid` VARCHAR(36) CHARSET utf8, IN `tableNo` VARCHAR(1) CHARSET utf8)  BEGIN

        UPDATE servicereceiver
    SET enterDate=SYSDATE()
    WHERE servicereceiver.groupID=groupID;


        INSERT INTO SitsAt(groupID, tableNo) VALUES
        (groupID, tableNo);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tableChecking` (IN `amountOfPeople` INT(2))  proc:BEGIN
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

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `amountCategory` (`amountOfPeople` INTEGER) RETURNS INT(11) BEGIN
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

CREATE DEFINER=`root`@`localhost` FUNCTION `checkTable` (`cate` VARCHAR(1) CHARSET utf8) RETURNS INT(11) READS SQL DATA
BEGIN
    DECLARE tableNum INTEGER DEFAULT -1;
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
            RETURN tableNum;
    END CASE;
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

CREATE DEFINER=`root`@`localhost` FUNCTION `checkTableCategory` (`amount_of_ppl` INTEGER(2)) RETURNS VARCHAR(1) CHARSET utf8 BEGIN
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

CREATE DEFINER=`root`@`localhost` FUNCTION `queueCheck` (`cat` VARCHAR(1) CHARSET utf8) RETURNS INT(11) READS SQL DATA
BEGIN
    DECLARE waitingQueue INTEGER DEFAULT -1;
    SET waitingQueue = (SELECT COUNT(*)
    FROM queue AS q INNER JOIN servicereceiver AS sr
    ON q.groupID=sr.groupID
    WHERE
        q.queueCate=cat AND         sr.enterDate IS NULL AND         sr.valid=1     );
    RETURN waitingQueue;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `queueInsert` (`cat` VARCHAR(1) CHARSET utf8, `groupid` VARCHAR(36) CHARSET utf8) RETURNS VARCHAR(5) CHARSET utf8 READS SQL DATA
BEGIN
    DECLARE qid VARCHAR(36) DEFAULT UUID();
    DECLARE qNum INT(4) DEFAULT NULL;
    SET qNum = (SELECT COALESCE(MAX(queueNo), 0) FROM queue WHERE queueCate = cat)+1;
    INSERT INTO queue(queueID, queueNo, queueDate, groupID, queueCate)
    VALUES(qid, qNum, SYSDATE(), groupid, cat);
  	RETURN CONCAT(cat, qNum);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `requestQueue` (`ppl` INT(2)) RETURNS VARCHAR(5) CHARSET utf8 NO SQL
BEGIN
    DECLARE gID varchar(36);
    DECLARE queueNow varchar(5);
    SET gID = srMake(ppl);
    SET queueNow = queueInsert(checkTableCategory(ppl), gID);
    RETURN queueNow;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `srMake` (`ppl` INTEGER) RETURNS VARCHAR(36) CHARSET utf8 NO SQL
BEGIN
    DECLARE uuid varchar(36) DEFAULT UUID();
    INSERT INTO servicereceiver(groupID, amountOfPeople)
    VALUES(uuid, ppl);
    RETURN uuid;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cell`
--

CREATE TABLE `cell` (
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  `confidence` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cell`
--

INSERT INTO `cell` (`x_coord`, `y_coord`, `confidence`) VALUES
(-1, -1, -1);

-- --------------------------------------------------------

--
-- Table structure for table `contain`
--

CREATE TABLE `contain` (
  `version` int(11) NOT NULL,
  `itemNo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `contain`
--

INSERT INTO `contain` (`version`, `itemNo`) VALUES
(2, 1),
(2, 2),
(1, 3);

-- --------------------------------------------------------

--
-- Table structure for table `item`
--

CREATE TABLE `item` (
  `itemNo` int(11) NOT NULL,
  `itemName` varchar(512) NOT NULL,
  `itemDescription` varchar(512) DEFAULT NULL,
  `itemPrice` int(11) NOT NULL,
  `isAvailable` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `item`
--

INSERT INTO `item` (`itemNo`, `itemName`, `itemDescription`, `itemPrice`, `isAvailable`) VALUES
(1, 'Fried Rice', 'Gud Fud', 45, 1),
(2, 'Fried Egg', 'Gud Egg', 20, 1),
(3, 'Lamb Sauce', 'Gordon Ramsy does not approve :c', 450, 0);

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `positionID` varchar(36) NOT NULL,
  `remark` varchar(512) DEFAULT NULL,
  `u_indicator` int(11) NOT NULL,
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `location`
--

INSERT INTO `location` (`positionID`, `remark`, `u_indicator`, `x_coord`, `y_coord`) VALUES
('5121e2cd-d697-4f26-af97-a64ce82ddff4', 'Charging station next to the kitchen', 2, -1, -1),
('6957d388-b751-46be-86a4-d0d96ff060d2', 'Shop entrance, right side of menu stand', 3, -1, -1),
('fe63b0af-0225-4286-b40c-24276aa57a4f', 'Table next to entrance, left side', 1, -1, -1);

-- --------------------------------------------------------

--
-- Table structure for table `menu`
--

CREATE TABLE `menu` (
  `version` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `menu`
--

INSERT INTO `menu` (`version`) VALUES
(1),
(2);

-- --------------------------------------------------------

--
-- Table structure for table `queue`
--

CREATE TABLE `queue` (
  `queueID` varchar(36) NOT NULL,
  `queueNo` int(11) NOT NULL,
  `queueDate` datetime NOT NULL,
  `groupID` varchar(36) NOT NULL,
  `queueCate` varchar(1) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `queue`
--

INSERT INTO `queue` (`queueID`, `queueNo`, `queueDate`, `groupID`, `queueCate`) VALUES
('0cddc751-485b-11e8-b441-7a791935f7b4', 3, '2018-04-25 14:34:12', '0cddbd68-485b-11e8-b441-7a791935f7b4', 'A'),
('150a7c26-485b-11e8-b441-7a791935f7b4', 1, '2018-04-25 14:34:26', '150a77d3-485b-11e8-b441-7a791935f7b4', 'B'),
('bf46d889-485a-11e8-b441-7a791935f7b4', 1, '2018-04-25 14:32:02', 'bf46d276-485a-11e8-b441-7a791935f7b4', 'A'),
('bf507807-485a-11e8-b441-7a791935f7b4', 2, '2018-04-25 14:32:02', 'bf50714f-485a-11e8-b441-7a791935f7b4', 'A');

-- --------------------------------------------------------

--
-- Table structure for table `restaurant`
--

CREATE TABLE `restaurant` (
  `name` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `restaurant`
--

INSERT INTO `restaurant` (`name`) VALUES
('NameOfRestaurantTest');

-- --------------------------------------------------------

--
-- Table structure for table `restauranttable`
--

CREATE TABLE `restauranttable` (
  `tableNo` int(11) NOT NULL,
  `seatCount` int(11) NOT NULL,
  `positionID` varchar(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `restauranttable`
--

INSERT INTO `restauranttable` (`tableNo`, `seatCount`, `positionID`) VALUES
(1, 4, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
(2, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
(3, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
(4, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f');

-- --------------------------------------------------------

--
-- Table structure for table `robot`
--

CREATE TABLE `robot` (
  `robotID` varchar(36) NOT NULL,
  `status` int(11) NOT NULL,
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `robot`
--

INSERT INTO `robot` (`robotID`, `status`, `x_coord`, `y_coord`) VALUES
('66acd781-2bdc-4a94-a874-68e0bca95560', 1, -1, -1);

-- --------------------------------------------------------

--
-- Table structure for table `servicereceiver`
--

CREATE TABLE `servicereceiver` (
  `groupID` varchar(36) NOT NULL,
  `amountOfPeople` int(4) NOT NULL,
  `enterDate` datetime DEFAULT NULL,
  `leaveDate` datetime DEFAULT NULL,
  `valid` int(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `servicereceiver`
--

INSERT INTO `servicereceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`, `valid`) VALUES
('0cddbd68-485b-11e8-b441-7a791935f7b4', 2, NULL, NULL, 1),
('150a77d3-485b-11e8-b441-7a791935f7b4', 3, NULL, NULL, 1),
('bf46d276-485a-11e8-b441-7a791935f7b4', 2, NULL, NULL, 1),
('bf50714f-485a-11e8-b441-7a791935f7b4', 1, NULL, NULL, 1),
('ffe723ac-4858-11e8-b441-7a791935f7b4', 2, '2018-04-25 14:19:32', NULL, 1),
('ffea6b08-4858-11e8-b441-7a791935f7b4', 2, '2018-04-25 14:19:32', '2018-04-25 00:00:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `sitsat`
--

CREATE TABLE `sitsat` (
  `groupID` varchar(36) NOT NULL,
  `tableNo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sitsat`
--

INSERT INTO `sitsat` (`groupID`, `tableNo`) VALUES
('ffe723ac-4858-11e8-b441-7a791935f7b4', 2),
('ffea6b08-4858-11e8-b441-7a791935f7b4', 3);

-- --------------------------------------------------------

--
-- Table structure for table `systemadministrator`
--

CREATE TABLE `systemadministrator` (
  `ID` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `systemadministrator`
--

INSERT INTO `systemadministrator` (`ID`, `password`) VALUES
('admin', 'insecurePassword');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cell`
--
ALTER TABLE `cell`
  ADD PRIMARY KEY (`x_coord`,`y_coord`);

--
-- Indexes for table `contain`
--
ALTER TABLE `contain`
  ADD PRIMARY KEY (`version`,`itemNo`),
  ADD KEY `itemNo` (`itemNo`);

--
-- Indexes for table `item`
--
ALTER TABLE `item`
  ADD PRIMARY KEY (`itemNo`);

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`positionID`),
  ADD KEY `x_coord` (`x_coord`,`y_coord`);

--
-- Indexes for table `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`version`);

--
-- Indexes for table `queue`
--
ALTER TABLE `queue`
  ADD PRIMARY KEY (`queueID`),
  ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `restaurant`
--
ALTER TABLE `restaurant`
  ADD PRIMARY KEY (`name`);

--
-- Indexes for table `restauranttable`
--
ALTER TABLE `restauranttable`
  ADD PRIMARY KEY (`tableNo`),
  ADD KEY `positionID` (`positionID`);

--
-- Indexes for table `robot`
--
ALTER TABLE `robot`
  ADD PRIMARY KEY (`robotID`);

--
-- Indexes for table `servicereceiver`
--
ALTER TABLE `servicereceiver`
  ADD PRIMARY KEY (`groupID`);

--
-- Indexes for table `sitsat`
--
ALTER TABLE `sitsat`
  ADD PRIMARY KEY (`groupID`,`tableNo`),
  ADD KEY `tableNo` (`tableNo`);

--
-- Indexes for table `systemadministrator`
--
ALTER TABLE `systemadministrator`
  ADD PRIMARY KEY (`ID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `contain`
--
ALTER TABLE `contain`
  ADD CONSTRAINT `contain_ibfk_1` FOREIGN KEY (`version`) REFERENCES `menu` (`version`),
  ADD CONSTRAINT `contain_ibfk_2` FOREIGN KEY (`itemNo`) REFERENCES `item` (`itemNo`);

--
-- Constraints for table `location`
--
ALTER TABLE `location`
  ADD CONSTRAINT `location_ibfk_1` FOREIGN KEY (`x_coord`,`y_coord`) REFERENCES `cell` (`x_coord`, `y_coord`);

--
-- Constraints for table `queue`
--
ALTER TABLE `queue`
  ADD CONSTRAINT `queue_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `servicereceiver` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `restauranttable`
--
ALTER TABLE `restauranttable`
  ADD CONSTRAINT `restauranttable_ibfk_1` FOREIGN KEY (`positionID`) REFERENCES `location` (`positionID`);

--
-- Constraints for table `sitsat`
--
ALTER TABLE `sitsat`
  ADD CONSTRAINT `sitsat_ibfk_1` FOREIGN KEY (`groupID`) REFERENCES `servicereceiver` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sitsat_ibfk_2` FOREIGN KEY (`tableNo`) REFERENCES `restauranttable` (`tableNo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
