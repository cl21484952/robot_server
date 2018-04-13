-- Values
INSERT INTO Menu(version) VALUES
	(1),
	(2),
	(3)
;

INSERT INTO Item(itemNo, itemName, itemDescription, itemPrice, isAvailable) VALUES
	(1, "Fried Rice", "Gud Fud", 45, true),
	(2, "Fried Egg", "Gud Egg", 20, true),
	(3, "Lamb Sauce", "Gordon Ramsy does not approve :c", 450, false)
;

INSERT INTO Contain(version, itemNo) VALUES
	(1, 3),
	(2, 1),
	(2, 2)
;

INSERT INTO SystemAdministrator(ID, password) VALUES
	("admin", "insecurePassword")
;

INSERT INTO Restaurant(name) VALUES
	("My Own Amazing Restaurant")
;

-- Place holder cell information
INSERT INTO Cell(x_coord, y_coord, confidence) VALUES
	(-1, -1, -1)
;

-- Place holder location information
-- 1: Restaurant Table
-- 2: Charging station
-- 3: Base station
-- Note: UUID of these are place holder
INSERT INTO Location(positionID, remark, u_indicator, x_coord, y_coord) VALUES
	("fe63b0af-0225-4286-b40c-24276aa57a4f", "Table next to entrance, left side", 1, -1, -1)
	("5121e2cd-d697-4f26-af97-a64ce82ddff4", "Charging station next to the kitchen", 2, -1, -1),
	("6957d388-b751-46be-86a4-d0d96ff060d2", "Shop entrance, right side of menu stand", 3, -1, -1)
;

--
INSERT INTO RestaurantTable(tableNo, seatCount, positionID) VALUES
	(1, 4, "fe63b0af-0225-4286-b40c-24276aa57a4f"),
	(2, 2, "fe63b0af-0225-4286-b40c-24276aa57a4f"),
	(3, 1, "fe63b0af-0225-4286-b40c-24276aa57a4f")
;
