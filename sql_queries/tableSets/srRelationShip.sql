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
	('0116c10d-d998-4f96-9476-10d0ba89719c', 2, '2018-01-02 10:01:00', '2018-01-02 10:21:00'),
	('82274cdd-b9d7-4f2f-be3b-a7d9a3714032', 2, '2018-01-02 10:02:00', '2018-01-02 10:22:00'),
	('98fe3d1b-e155-47e3-b639-e34cc1179802', 2, '2018-01-02 10:03:00', '2018-01-02 10:23:00'),
	('b077bf76-2a5b-4e94-a3a2-5476b91e5b47', 2, '2018-01-02 10:04:00', '2018-01-02 10:24:00'),
	('b1604377-4e7c-4f2f-9eee-6eaa7967e380', 2, '2018-01-02 10:05:00', '2018-01-02 10:25:00');


INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES
  -- Ate and already left
	('0116c10d-d998-4f96-9476-10d0ba89719c', 2, '2018-03-28 08:55:38', '2018-03-28 09:23:11'),
	('1018b679-e005-4165-8863-a62cc29670cd', 6, '2018-03-28 10:56:03', NULL),
	('10a3e379-c4e7-4f2e-8746-3a878822b713', 4, NULL, NULL);

INSERT INTO `Queue` (`queueID`, `queueNo`, `queueDate`, `groupID`) VALUES
	('ea0a5e2c-878f-49a6-a5c4-bfb0321bd649', 2, '2018-03-28 10:56:03', '1018b679-e005-4165-8863-a62cc29670cd'),
	('701c3f24-2d89-48f1-9574-8bf1f76ae9a1', 1, '2018-03-28 08:55:38', '10a3e379-c4e7-4f2e-8746-3a878822b713');

INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES
  ('0116c10d-d998-4f96-9476-10d0ba89719c', 2),
  ('1018b679-e005-4165-8863-a62cc29670cd', 4);
