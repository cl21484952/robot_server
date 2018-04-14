USE `zg6kbqpoxrbx4hox`;

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
