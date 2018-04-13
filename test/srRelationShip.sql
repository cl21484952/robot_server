/* NOTE
This SQL file contain the following tables:
ServiceReceiver, Queue, SitsAt
With data related to each tables
*/;
/* NOTE
Any testing data with DATETIME MUST use date range in year 2018
All DATETIME is in format of year-month-day hour:minute:seconds YYYY-MM-DD HH:MM:SS
*/;

USE `zg6kbqpoxrbx4hox`;



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


-- Situation 1: Empty restaurant
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
	('0116c10d-d998-4f96-9476-10d0ba89719c', 2, '2018-01-01 10:00:00', '2018-01-01 10:20:00');
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  ('0116c10d-d998-4f96-9476-10d0ba89719c', 7);


-- Situation 2: Full restaurant of 1-2 people only
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
	('b316e067-60d1-47f5-842b-1c43ae234b7b', 2, '2018-01-02 10:01:00', NULL),
	('82274cdd-b9d7-4f2f-be3b-a7d9a3714032', 2, '2018-01-02 10:02:00', NULL),
	('98fe3d1b-e155-47e3-b639-e34cc1179802', 2, '2018-01-02 10:03:00', NULL),
	('b077bf76-2a5b-4e94-a3a2-5476b91e5b47', 2, '2018-01-02 10:04:00', NULL);
INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  ('b316e067-60d1-47f5-842b-1c43ae234b7b', 5),
  ('82274cdd-b9d7-4f2f-be3b-a7d9a3714032', 6),
  ('98fe3d1b-e155-47e3-b639-e34cc1179802', 7),
  ('b077bf76-2a5b-4e94-a3a2-5476b91e5b47', 8);


-- Situation 2.1: Count waiting queue
SELECT COUNT(*)
FROM `Queue` AS q INNER JOIN `ServiceReceiver` AS sr
  ON q.groupID = sr.groupID
WHERE
sr.amountOfPeople BETWEEN 1 AND 2 AND
sr.enterDate IS NULL;
-- Expect 0

-- Situation 2.2: 1 waiting queue and 2 ppl
INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
	('b3ba41a8-2b7a-4a19-a931-fc3fe66da056', 2, NULL, NULL);
INSERT INTO `Queue` (`queueID`, `queueNo`, `queueDate`, `groupID`) VALUES
  ('3b345dfc-0705-4c3a-9347-857380147fbc', 1, '2018-01-03 10:04:00', 'b3ba41a8-2b7a-4a19-a931-fc3fe66da056');

SELECT COUNT(*)
FROM `Queue` AS q INNER JOIN `ServiceReceiver` AS sr
  ON q.groupID = sr.groupID
WHERE
sr.amountOfPeople BETWEEN 1 AND 2 AND
sr.enterDate IS NULL;
-- Expect 1

-- Situation 2.3: 3 ppl check waiting queue
SELECT COUNT(*)
FROM `Queue` AS q INNER JOIN `ServiceReceiver` AS sr
  ON q.groupID = sr.groupID
WHERE
sr.amountOfPeople BETWEEN 3 AND 4 AND
sr.enterDate IS NULL;
-- Expect 0
