-- Setup up

CREATE DATABASE IF NOT EXISTS `zg6kbqpoxrbx4hox`;
USE `zg6kbqpoxrbx4hox`;



CREATE TABLE IF NOT EXISTS `SystemAdministrator` (
  `ID` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  PRIMARY KEY (`ID`)
);
INSERT INTO `SystemAdministrator` (`ID`, `password`) VALUES
	('admin', 'insecurePassword')
;
-- Query password given ID
SELECT * FROM `SystemAdministrator` WHERE `ID`='admin';


CREATE TABLE IF NOT EXISTS `Restaurant` (
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`name`)
);
INSERT INTO `Restaurant` (`name`) VALUES
	('NameOfRestaurantTest')
;
-- Query Restaurant name
SELECT * FROM `Restaurant` WHERE `name`='NameOfRestaurantTest';



CREATE TABLE IF NOT EXISTS `Robot` (
  `robotID` varchar(36) NOT NULL,
  `status` int(11) NOT NULL,
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  PRIMARY KEY (`robotID`)
);
INSERT INTO `Robot` (`robotID`, `status`, `x_coord`, `y_coord`) VALUES
	('66acd781-2bdc-4a94-a874-68e0bca95560', 1, -1, -1)
;
-- Query robot information
SELECT * FROM `Robot`;
-- Update robot status, given UUID
UPDATE `Robot` SET `status`=1 WHERE `robotID`=1;
-- Update robot position, given UUID
UPDATE `Robot` SET `x_coord`=1, `y_coord`=1 WHERE `robotID`=1;
-- Insert new robot, given UUID
INSERT INTO `Robot` (`robotID`, `status`, `x_coord`, `y_coord`) VALUES
(1, 1, 1, 1);
-- Remove robot given UUID
DELETE FROM `Robot` WHERE `RobotID`=1;


CREATE TABLE IF NOT EXISTS `Menu` (
  `version` int(11) NOT NULL,
  PRIMARY KEY (`version`)
);
INSERT INTO `Menu` (`version`) VALUES
	(1),
	(2)
;
-- Query menu
SELECT * FROM `Menu`;

CREATE TABLE IF NOT EXISTS `Item` (
  `itemNo` int(11) NOT NULL,
  `itemName` varchar(512) NOT NULL,
  `itemDescription` varchar(512) DEFAULT NULL,
  `itemPrice` int(11) NOT NULL,
  `isAvailable` tinyint(1) NOT NULL,
  PRIMARY KEY (`itemNo`)
);
INSERT INTO `Item` (`itemNo`, `itemName`, `itemDescription`, `itemPrice`, `isAvailable`) VALUES
	(1, 'Fried Rice', 'Gud Fud', 45, 1),
	(2, 'Fried Egg', 'Gud Egg', 20, 1),
	(3, 'Lamb Sauce', 'Gordon Ramsy does not approve :c', 450, 0)
;
-- Query item
SELECT * FROM `Item`;

CREATE TABLE IF NOT EXISTS `Contain` (
  `version` int(11) NOT NULL,
  `itemNo` int(11) NOT NULL,
  PRIMARY KEY (`version`,`itemNo`),
  FOREIGN KEY (`version`) REFERENCES `Menu` (`version`),
  FOREIGN KEY (`itemNo`) REFERENCES `Item` (`itemNo`)
);
INSERT INTO `Contain` (`version`, `itemNo`) VALUES
	(2, 1),
	(2, 2),
	(1, 3)
;
-- Query Menu items, given menu version
SELECT * FROM `Item` i, `Contain` c, `Menu` m
WHERE i.itemNo=c.itemNo AND m.version=c.version AND -- Join
m.version=1; -- Chosen version


CREATE TABLE IF NOT EXISTS `Cell` (
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  `confidence` int(11) NOT NULL,
  PRIMARY KEY (`x_coord`,`y_coord`)
);
INSERT INTO `Cell` (`x_coord`, `y_coord`, `confidence`) VALUES
	(-1, -1, -1)
;
-- Insert cell given: x_coord, y_coord and confidence
INSERT INTO `Cell` (`x_coord`, `y_coord`, `confidence`) VALUES
	(-2, -2, -1)
;

CREATE TABLE IF NOT EXISTS `Location` (
  `positionID` varchar(36) NOT NULL,
  `remark` varchar(512) DEFAULT NULL,
  `u_indicator` int(11) NOT NULL,
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  PRIMARY KEY (`positionID`),
  FOREIGN KEY (`x_coord`, `y_coord`) REFERENCES `Cell` (`x_coord`, `y_coord`)
);
INSERT INTO `Location` (`positionID`, `remark`, `u_indicator`, `x_coord`, `y_coord`) VALUES
	('5121e2cd-d697-4f26-af97-a64ce82ddff4', 'Charging station next to the kitchen', 2, -1, -1),
	('6957d388-b751-46be-86a4-d0d96ff060d2', 'Shop entrance, right side of menu stand', 3, -1, -1),
	('fe63b0af-0225-4286-b40c-24276aa57a4f', 'Table next to entrance, left side', 1, -1, -1)
;
-- Query positions
SELECT * FROM `Location`;

CREATE TABLE IF NOT EXISTS `RestaurantTable` (
  `tableNo` int(11) NOT NULL,
  `seatCount` int(11) NOT NULL,
  `positionID` varchar(36) NOT NULL,
  PRIMARY KEY (`tableNo`),
  FOREIGN KEY (`positionID`) REFERENCES `Location` (`positionID`)
);
INSERT INTO `RestaurantTable` (`tableNo`, `seatCount`, `positionID`) VALUES
	(1, 4, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
	(2, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
	(3, 1, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  (4, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f')
;
-- Query tables
SELECT * FROM `RestaurantTable`;
-- Query table given: amountOfPeople
SELECT * FROM `RestaurantTable` WHERE `seatCount`=1; -- Number of people
-- [!] Query table with queue



CREATE TABLE IF NOT EXISTS `ServiceReceiver` (
  `groupID` varchar(36) NOT NULL,
  `amountOfPeople` int(11) NOT NULL,
  `enterDate` datetime DEFAULT NULL,
  `leaveDate` datetime DEFAULT NULL,
  PRIMARY KEY (`groupID`)
);

CREATE TABLE IF NOT EXISTS `Queue` (
  `queueID` varchar(36) NOT NULL,
  `queueNo` int(11) NOT NULL,
  `queueDate` datetime NOT NULL,
  `groupID` varchar(36) NOT NULL,
  PRIMARY KEY (`queueID`),
  FOREIGN KEY (`groupID`) REFERENCES `ServiceReceiver` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `SitsAt` (
  `groupID` varchar(36) NOT NULL,
  `tableNo` int(11) NOT NULL,
  PRIMARY KEY (`groupID`,`tableNo`),
  FOREIGN KEY (`groupID`) REFERENCES `ServiceReceiver` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`tableNo`) REFERENCES `RestaurantTable` (`tableNo`)
);
-- Find customer current in shop
SELECT *
FROM ServiceReceiver sr
WHERE sr.enterDate IS NOT NULL AND
sr.leaveDate IS NULL;
-- Find Full table
SELECT *
FROM `ServiceReceiver` sr, `SitsAt` sa
WHERE sr.enterDate IS NOT NULL AND -- Customer has table
sr.leaveDate IS NULL AND -- Customer has not left
sr.groupID=sa.groupID -- JOIN
-- Find empty table
SELECT *
FROM `RestaurantTable` rt
WHERE rt.tableNo NOT IN
(SELECT DISTINCT sa.tableNo AS tableNo -- Table that is full
FROM `ServiceReceiver` sr, `SitsAt` sa
WHERE sr.enterDate IS NOT NULL AND -- Customer has table
sr.leaveDate IS NULL AND -- Customer has not left
sr.groupID=sa.groupID); -- JOIN


-- Find compatable Table from queue &
SELECT *
FROM Queue q, ServiceReceiver sr, RestaurantTable rt, sr LEFT JOIN q ON sr.groupID=q.groupID
WHERE sr.enterDate IS NULL AND -- Get SR without table
-- sr.groupID LEFT JOIN q.groupID AND
-- q.groupID=sr.groupID AND -- Get queue only
rt.seatCount>=sr.amountOfPeople AND  -- Table which customer can sit
(rt.tableNo NOT IN -- Table which is free
  (SELECT DISTINCT sa.tableNo -- Table that is full
  FROM `ServiceReceiver` sr, `SitsAt` sa
  WHERE sr.enterDate IS NOT NULL AND -- Customer has table
  sr.leaveDate IS NULL AND -- Customer has not left
  sr.groupID=sa.groupID) -- JOIN
)
ORDER BY
sr.amountOfPeople ASC, -- Rank from most people
q.queueDate ASC, -- Oldest queue first
rt.seatCount ASC; -- Least amount of table first


-- Find compatable table from queue & no queue
SELECT rt.tableNo, rt.seatCount, sr.amountOfPeople, sr.groupID, q.queueID
FROM RestaurantTable rt, ServiceReceiver sr LEFT JOIN Queue q ON sr.groupID=q.groupID
WHERE sr.enterDate IS NULL AND -- Get SR without table
rt.seatCount>=sr.amountOfPeople AND  -- Table which customer can sit
(rt.tableNo NOT IN -- Table which is free
  (SELECT DISTINCT sa.tableNo -- Table that is full
  FROM `ServiceReceiver` sr, `SitsAt` sa
  WHERE sr.enterDate IS NOT NULL AND -- Customer has table
  sr.leaveDate IS NULL AND -- Customer has not left
  sr.groupID=sa.groupID) -- JOIN
)
ORDER BY
q.groupID DESC, -- People with queue first
sr.amountOfPeople ASC, -- Rank from most people
q.queueDate ASC, -- Oldest queue first
rt.seatCount ASC; -- Least amount of table first



-- Situation 0.1: Step by step, eat & left WITHOUT taking queue
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`) VALUES
  ('3d614942-6c28-4451-8a4b-fa6d2977a6cd', 3) -- 3 people
;
-- Find table query and have table
-- 1. find table that are available 
-- 2. match suitable  table (available and right size) with the service receiver (find compatible table from no queue)
-- 3. insert GroupID and tableNo into SitsAt
-- 4. update enter time
-- 5. When ServiceReceiver have paid,and leave the retaurant --> update leave time
-- Update enter time
UPDATE `ServiceReceiver`
SET `enterDate`='2018-01-01 08:00:00'
WHERE `groupID`='3d614942-6c28-4451-8a4b-fa6d2977a6cd';
-- Update leave time
UPDATE `ServiceReceiver`
SET `leaveDate`='2018-01-01 10:00:00'
WHERE `groupID`='3d614942-6c28-4451-8a4b-fa6d2977a6cd';


-- Situation 0.2: Step by step, eat & left WITH queue
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`) VALUES
  ('c244e6b3-607a-4df8-b4bd-425effefdef6', 2); -- 2 people

-- Find table query and DOES NOT have table
-- 1. request reserve table 
-- 2. Insert service receiver's info into queue
-- 3. Find compatable table from queue
-- 4. service receiver confirm their queue within 1 minute when their queue arrived --> Insert service receiver's info into SitsAt
-- 5. update enter time
-- 6. When ServiceReceiver have paid,and leave the retaurant --> update leave time

-- Update enter time
UPDATE `ServiceReceiver`
SET `enterDate`='2018-01-02 08:00:00'
WHERE `groupID`='c244e6b3-607a-4df8-b4bd-425effefdef6';
-- Update leave time
UPDATE `ServiceReceiver`
SET `leaveDate`='2018-01-02 10:00:00'
WHERE `groupID`='c244e6b3-607a-4df8-b4bd-425effefdef6';


-- Situation 0.3: Step by step, comes WITH queue BUT NOT eat
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`) VALUES
  ('b55e3194-dd44-4733-a277-8f15a9c5aeeb', 4) -- 4 people
;
-- Find table query and DOES NOT have table
-- 1. request reserve table 
-- 2. Insert service receiver's info into queue
-- 3. Find compatable table from queue
-- 4. service receiver DOES NOT confirm their queue within 1 minute --> DELETE service receiver's info from the queue
-- Update enter time
DELETE FROM `ServiceReceiver` -- CASCADE which also delete QUEUE
WHERE `groupID`='b55e3194-dd44-4733-a277-8f15a9c5aeeb';



-- Situation 1-1: Came eat & left without queue (day 1)
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
  -- Ate and already left, without queue
	('0116c10d-d998-4f96-9476-10d0ba89719c', 2, '2018-01-01 08:55:18', '2018-01-01 09:23:11')
;
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  -- Sits at table 2 (2 people)
  ('0116c10d-d998-4f96-9476-10d0ba89719c', 2)
;


-- Situation 1-2: Came eat & left without queue (day 1)
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
  -- Ate and already left, without queue
	('df7978ea-e48a-4573-b9bb-50e6af8b3f8b', 3, '2018-01-01 14:30:39', '2018-01-01 14:54:22')
;
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  -- Sits at table 1 (4 people)
  ('df7978ea-e48a-4573-b9bb-50e6af8b3f8b', 1)
;

-- Situation 1-3: Come eat & left without queue (day 2)
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
  -- Ate and already left, without queue
	('68e246c7-bc60-4b91-b988-32713a9c9f34', 4, '2018-01-02 14:30:39', '2018-01-02 14:54:22')
;
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  -- Sits at table 1 (4 people)
  ('68e246c7-bc60-4b91-b988-32713a9c9f34', 1)
;

-- Situation 1-4: Come eat & left without queue (day 2)
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
  -- Ate and already left, without queue
	('29891876-b953-4445-9e13-4bbeba2807b9', 1, '2018-01-02 14:30:39', '2018-01-02 14:54:22')
;
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  -- Sits at table 3 (1 people)
  ('29891876-b953-4445-9e13-4bbeba2807b9', 3)
;

-- Situation 2-1: Come eat & left with queue (day 3)
-- Requests a table
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
	('29891876-b953-4445-9e13-4bbeba2807b9', 1, NULL, NULL)
;
-- Queue was accepted
INSERT INTO `Queue` (`queueID`, `queueNo`, `queueDate`, `groupID`) VALUES
	('1aa633b0-98e5-4117-9ca9-4180649aafef', 1, '2018-01-03 13:01:04', '29891876-b953-4445-9e13-4bbeba2807b9')
;
-- A table was found
UPDATE `ServiceReceiver` SET `enterDate` = `2018-01-03 13:05:04`
WHERE `groupID` = '29891876-b953-4445-9e13-4bbeba2807b9';
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  ('29891876-b953-4445-9e13-4bbeba2807b9', 3)
;
UPDATE `ServiceReceiver` SET `leaveDate` = `2018-01-01 14:45:04`
WHERE `groupID` = '29891876-b953-4445-9e13-4bbeba2807b9';

-- Situation 3-1: Come but didn't come when called queue (day 3)

-- Situation 4-1: Queue skipping (4, 2)

INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
  -- Ate and already left
	('0116c10d-d998-4f96-9476-10d0ba89719c', 2, '2018-03-28 08:55:38', '2018-03-28 09:23:11'),
	('1018b679-e005-4165-8863-a62cc29670cd', 6, '2018-03-28 10:56:03', NULL),
	('10a3e379-c4e7-4f2e-8746-3a878822b713', 4, NULL, NULL),
	('NKR60VFI9MPYmpE00YqPqd31Ovl2Itl4', 2, '2018-03-29 11:28:26', '0000-00-00 00:00:00'),
	('QRD56FRF5RTPsxJ98FaOuq99Otx7Ksl7', 1, '2018-03-29 23:44:00', '0000-00-00 00:00:00'),
	('RUL63PAZ6BHGfxV40FxKle49Kop0Wkx8', 5, '2018-03-29 09:35:25', '0000-00-00 00:00:00'),
	('RYO30GZB2TCIynH26HwLhk61Wny5Xyd1', 6, '2018-03-30 22:47:41', '0000-00-00 00:00:00'),
	('TRQ62FZU7IAZcgW49AxScj19Orq0Jjz6', 4, '2018-03-31 16:32:04', '0000-00-00 00:00:00'),
	('WNB78IDQ6FRGuhS41SyNms35Fno6Yge0', 3, '2018-03-31 09:07:06', '0000-00-00 00:00:00');
/*!40000 ALTER TABLE `ServiceReceiver` ENABLE KEYS */;

-- Dumping data for table zg6kbqpoxrbx4hox.Queue: ~4 rows (approximately)
/*!40000 ALTER TABLE `Queue` DISABLE KEYS */;
INSERT INTO `Queue` (`queueID`, `queueNo`, `queueDate`, `groupID`) VALUES
	('1aa633b0-98e5-4117-9ca9-4180649aafef', 2, '2018-03-31 16:32:04', 'TRQ62FZU7IAZcgW49AxScj19Orq0Jjz6'),
	('ea0a5e2c-878f-49a6-a5c4-bfb0321bd649', 2, '2018-03-28 10:56:03', '1018b679-e005-4165-8863-a62cc29670cd'),
	('80d6f2f9-628e-47a6-86ce-ee01aca40ced', 1, '2018-03-31 09:07:06', 'WNB78IDQ6FRGuhS41SyNms35Fno6Yge0'),
	('701c3f24-2d89-48f1-9574-8bf1f76ae9a1', 1, '2018-03-28 08:55:38', '0116c10d-d998-4f96-9476-10d0ba89719c');
/*!40000 ALTER TABLE `Queue` ENABLE KEYS */;









-- Dumping data for table zg6kbqpoxrbx4hox.SitsAt: ~0 rows (approximately)
/*!40000 ALTER TABLE `SitsAt` DISABLE KEYS */;
/*!40000 ALTER TABLE `SitsAt` ENABLE KEYS */;



/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
