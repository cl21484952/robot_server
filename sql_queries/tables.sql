
-- CREATE DATABASE zg6kbqpoxrbx4hox;

CREATE TABLE ServiceReceiver(
	groupID VARCHAR(36) NOT NULL,
	amountOfPeople INTEGER NOT NULL,
	enterDate DATETIME,
	leaveDate DATETIME,
	PRIMARY KEY(groupID)
);

CREATE TABLE Cell(
	x_coord INTEGER NOT NULL,
	y_coord INTEGER NOT NULL,
	confidence INTEGER NOT NULL,
	PRIMARY KEY(x_coord, y_coord)
);

CREATE TABLE Queue(
	queueID VARCHAR(36) NOT NULL,
	queueNo INTEGER NOT NULL,
	queueDate DATETIME NOT NULL,
	groupID VARCHAR(36) NOT NULL,
	PRIMARY KEY(queueID),
	FOREIGN KEY(groupID) REFERENCES ServiceReceiver(groupID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Location(
	positionID VARCHAR(36) NOT NULL,
	remark VARCHAR(512),
	u_indicator INTEGER NOT NULL,
	-- Changed from "indicator" to "u_indicator" as
	-- "indicator" is already a keyword in SQL
	-- "u_indicator" stands for "use indicator"
	x_coord INTEGER NOT NULL,
	y_coord INTEGER NOT NULL,
	PRIMARY KEY(positionID),
	FOREIGN KEY(x_coord, y_coord) REFERENCES Cell(x_coord, y_coord)
);

CREATE TABLE RestaurantTable(
	tableNo INTEGER NOT NULL,
	seatCount INTEGER NOT NULL,
	positionID VARCHAR(36) NOT NULL,
	PRIMARY KEY(tableNo),
	FOREIGN KEY(positionID) REFERENCES Location(positionID)
);


CREATE TABLE SitsAt(
	groupID VARCHAR(36) NOT NULL,
	tableNo INTEGER NOT NULL,
	PRIMARY KEY(groupID, tableNo),
	FOREIGN KEY(groupID) REFERENCES ServiceReceiver(groupID),
	FOREIGN KEY(tableNo) REFERENCES RestaurantTable(tableNo)
);


CREATE TABLE Menu(
	version INTEGER NOT NULL,
	PRIMARY KEY(version)
);

CREATE TABLE Item(
	itemNo INTEGER NOT NULL,
	itemName VARCHAR(512) NOT NULL,
	itemDescription VARCHAR(512),
	itemPrice INTEGER NOT NULL,
	isAvailable BOOLEAN NOT NULL,
	PRIMARY KEY(itemNo)
);

CREATE TABLE Contain(
	version INTEGER NOT NULL,
	itemNo INTEGER NOT NULL,
	PRIMARY KEY(version, itemNo),
	FOREIGN KEY(version) REFERENCES Menu(version),
	FOREIGN KEY(itemNo) REFERENCES Item(itemNo)
);


CREATE TABLE Robot(
	robotID VARCHAR(36) NOT NULL,
	status INTEGER NOT NULL,
	x_coord INTEGER NOT NULL,
	y_coord INTEGER NOT NULL,
	PRIMARY KEY(robotID)
);


CREATE TABLE SystemAdministrator(
	ID VARCHAR(128) NOT NULL,
	password VARCHAR(128) NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Restaurant(
	name VARCHAR(128) NOT NULL,
	PRIMARY KEY(name)
);
