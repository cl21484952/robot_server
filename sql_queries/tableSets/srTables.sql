/* NOTE
This SQL file contain the following tables:
Cell, Location, RestaurantTable
With data related to each tables
*/;

USE `zg6kbqpoxrbx4hox`;



CREATE TABLE IF NOT EXISTS `Cell` (
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  `confidence` int(11) NOT NULL,
  PRIMARY KEY (`x_coord`,`y_coord`)
);

-- Place holder data for cell
INSERT INTO `Cell` (`x_coord`, `y_coord`, `confidence`) VALUES
	(-1, -1, -1);



CREATE TABLE IF NOT EXISTS `Location` (
  `positionID` varchar(36) NOT NULL,
  `remark` varchar(512) DEFAULT NULL,
  `u_indicator` int(11) NOT NULL,
  `x_coord` int(11) NOT NULL,
  `y_coord` int(11) NOT NULL,
  PRIMARY KEY (`positionID`),
  FOREIGN KEY (`x_coord`, `y_coord`) REFERENCES `Cell` (`x_coord`, `y_coord`)
);

-- Location data for testing
INSERT INTO `Location` (`positionID`, `remark`, `u_indicator`, `x_coord`, `y_coord`) VALUES
	('5121e2cd-d697-4f26-af97-a64ce82ddff4', 'Charging station next to the kitchen', 2, -1, -1),
	('6957d388-b751-46be-86a4-d0d96ff060d2', 'Shop entrance, right side of menu stand', 3, -1, -1),
	('fe63b0af-0225-4286-b40c-24276aa57a4f', 'Table next to entrance, left side', 1, -1, -1);



CREATE TABLE IF NOT EXISTS `RestaurantTable` (
  `tableNo` int(11) NOT NULL,
  `seatCount` int(11) NOT NULL,
  `positionID` varchar(36) NOT NULL,
  PRIMARY KEY (`tableNo`),
  FOREIGN KEY (`positionID`) REFERENCES `Location` (`positionID`)
);

INSERT INTO `RestaurantTable` (`tableNo`, `seatCount`, `positionID`) VALUES
  -- 4 table of 4 seats
  ( 1, 4, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  ( 2, 4, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  ( 3, 4, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  ( 4, 4, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  -- 4 tables of 2 seats
  ( 5, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  ( 6, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  ( 7, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  ( 8, 2, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  -- 4 tables of 6 seats
  ( 9, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
  (10, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
	(11, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f'),
	(12, 6, 'fe63b0af-0225-4286-b40c-24276aa57a4f');
