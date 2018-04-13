
-- Select all queue of a given date
SELECT * FROM Queue WHERE queueDate BETWEEN '2018-03-28 00:00:00' AND '2018-03-28 23:59:59' ORDER BY queueDate DESC;

-- Get the next queue of a given date
SELECT MAX(queueNo)+1 FROM Queue WHERE queueDate BETWEEN '2018-03-28 00:00:00' AND '2018-03-28 23:59:59';

-- Get the estimated number of waiting queue of a given date
SELECT COUNT(q.queueNo) FROM Queue q, ServiceReceiver sr 
WHERE q.queueDate BETWEEN '2018-03-28 00:00:00' AND '2018-03-28 23:59:59' AND
q.groupID=sr.groupID AND -- Join
sr.enterDate IS NULL; -- Service reciever that have no table

-- Get all waiting queue
SELECT * FROM Queue q, ServiceReceiver sr 
WHERE q.queueDate BETWEEN '2018-03-28 00:00:00' AND '2018-03-28 23:59:59' AND
q.groupID=sr.groupID AND -- Join
sr.enterDate IS NULL; -- Service reciever that have no table

-- Get all waiting queue along with table
SELECT *
FROM Queue q, ServiceReceiver sr, RestaurantTable rt
WHERE
q.groupID=sr.groupID AND sr.enterDate IS NULL AND -- Find waiting queue
rt.seatCount>=sr.amountOfPeople -- Find table
ORDER BY
q.queueDate ASC, -- Oldest queue first
rt.seatCount ASC; -- Least amount of table first