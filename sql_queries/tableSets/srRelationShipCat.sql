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
  `valid` boolean DEFAULT 1, -- TINYINT(1)
  PRIMARY KEY (`groupID`)
);

-- 1 to 2 people
CREATE TABLE IF NOT EXISTS `Queue_A` (
  `queueID` varchar(36) NOT NULL,
  `queueNo` int(11) NOT NULL,
  `queueDate` datetime NOT NULL,
  `groupID` varchar(36) NOT NULL,
  PRIMARY KEY (`queueID`),
  FOREIGN KEY (`groupID`) REFERENCES `ServiceReceiver` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3 to 4 people
CREATE TABLE IF NOT EXISTS `Queue_B` (
  `queueID` varchar(36) NOT NULL,
  `queueNo` int(11) NOT NULL,
  `queueDate` datetime NOT NULL,
  `groupID` varchar(36) NOT NULL,
  PRIMARY KEY (`queueID`),
  FOREIGN KEY (`groupID`) REFERENCES `ServiceReceiver` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5 to 6 people
CREATE TABLE IF NOT EXISTS `Queue_C` (
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

/*
SELECT rt.tableNo, rt.seatCount, rt.positionID
FROM `RestaurantTable` rt INNER JOIN `ServiceReceiver` sr INNER JOIN `SitsAt` sa
 ON sa.groupID=sr.groupID, sa.tableNo=rt.tableNo
WHERE
 rt.seatCount BETWEEN 1 AND 2 AND
 sr.valid = 1
;
*/
