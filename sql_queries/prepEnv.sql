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


CREATE TABLE IF NOT EXISTS `Restaurant` (
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`name`)
);
INSERT INTO `Restaurant` (`name`) VALUES
	('NameOfRestaurantTest')
;



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


CREATE TABLE IF NOT EXISTS `Menu` (
  `version` int(11) NOT NULL,
  PRIMARY KEY (`version`)
);
INSERT INTO `Menu` (`version`) VALUES
	(1),
	(2)
;

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


CREATE TABLE IF NOT EXISTS `Cell` (
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  `confidence` int(11) NOT NULL,
  PRIMARY KEY (`x_coord`,`y_coord`)
);
INSERT INTO `Cell` (`x_coord`, `y_coord`, `confidence`) VALUES
	(-1, -1, -1)
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
	(3, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  (4, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f')
;



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
