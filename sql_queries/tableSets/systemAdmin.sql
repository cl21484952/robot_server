
USE `zg6kbqpoxrbx4hox`;


CREATE TABLE IF NOT EXISTS
`SystemAdministrator` (
  `ID` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  PRIMARY KEY (`ID`)
);


INSERT INTO `SystemAdministrator` (`ID`, `password`) VALUES
	('admin', 'insecurePassword')
;
