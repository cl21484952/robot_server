USE `zg6kbqpoxrbx4hox`;

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
