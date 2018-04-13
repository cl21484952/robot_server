const express = require("express");
const moment = require('moment');
const uuidv4 = require('uuid/v4');
const mysql = require('mysql');
const router = express.Router();

const utils = require("../utils.js");
const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;


const conn = require("../databaseSetup.js");
const cq = require("../commonQuery.js");

const dateTimeTemplate = 'YYYY-MM-DD HH:mm:ss';

// Request a sr UUID and amount of people
router.get('/make_sr', pathCalled, (req, res, next) => {
  let amountOfPeople = req.query.amountOfPeople;
  if (!amountOfPeople) {
    res.status(400);
    res.send("No amount of people provided");
    return;
  }
  srMakeServiceReceiver(amountOfPeople, (data) => {
    console.log(data);
    res.send(data);
  });
});

// Get the number of waiting queue
router.get('/waitingQueueCount', pathCalled, (req, res, next) => {
  srWaitingQueueCount((rtn) => {
    res.send(rtn);
  });
});

// Table is available
/*
/checkTable?amountOfPeople=N_SR
N_SR :number: Amount of service receiver
Response Format: (JSON)
{
  'error': null, // If there is any error
  'exceedMaxSeatCount': false, // If exceed max seat count
  'tableInfo': [] // Table availability can be implied
}
*/
// NOTE if not number, NaN is returned
// NOTE Partially Implemented, missing no table
router.get('/checkTable', pathCalled, (req, res, next) => {

  const MAX_SEATCOUNT = 6;
  let rtnFormat = {
    'error': null,
    'exceedMaxSeatCount': false,
    'tableInfo': [] // Table availability can be implied
  };

  let amountOfPeople = parseInt(req.query.amountOfPeople);

  /*
  Client query verification
  */
  if (!amountOfPeople || typeof amountOfPeople !== "number") {
    res.status(400);
    rtnFormat.error = "Provided amount of people value have problem :D";
    res.send(rtnFormat);
    return;
  }
  if (amountOfPeople <= 0) {
    res.status(400);
    rtnFormat.error = "Cannot have 0 or less customer";
    res.send(rtnFormat);
    return;
  }

  /*
  Client query validation
  */

  if (amountOfPeople > MAX_SEATCOUNT) {
    res.status(403);
    rtnFormat.error = "Exceed maximum supported amount";
    res.send(rtnFormat);
    return;
  }

  // Nothinf

  let range = [-1, -1];

  switch (amountOfPeople) {
    case 1:
    case 2:
      range = [1, 2];
      break;
    case 3:
    case 4:
      range = [3, 4];
      break;
    case 5:
    case 6:
      range = [5, 6];
      break;
    default:
      throw new Error("Amount of people not supported");
      break;
  }

  srCheckTable(range, (data) => {
    if (data.length > 0) {
      let uid = uuidv4();
      console.log(uid);
      srMake(uid, amountOfPeople, console.log);
      srSitsAt(uid, data[0].tableNo, console.log);
      updateSR_enterDate(uid, moment().format(dateTimeTemplate), console.log);
      rtnFormat.tableInfo = data[0];
    }
    res.send(rtnFormat);
  });
});


// Check if there is queue
router.get('/checkQueue', pathCalled, (req, res, next) => {
  srCheckQueue((data) => {
    res.send(data);
  });
});


// Get a queue number
router.get('/requestQueue', pathCalled, (req, res, next) => {
  let groupID = req.query.groupID;
  let queueNo = req.query.queueNo;
  if (!groupID || !queueNo) {
    res.status(400);
    res.send("groupID or queueNo not provided");
    return;
  }
  srRequestQueue(groupID, queueNo, (rtn) => {
    res.send(rtn);
  });
});

// Drop a customer based on UUID
router.get('/drop', pathCalled, (req, res, next) => {
  let groupID = req.query.groupID;
  if (!groupID) {
    res.status(400);
    res.send("No groupID provided");
    return;
  }
  srDrop(groupID, (rtn) => {
    res.send(rtn);
  });
});

// Get the next queue number
// BUG Unknown return given to callback
router.get('/nextQueueNo', pathCalled, (req, res, next) => {
  srNextQueueNo((data) => {
    res.send(data);
  });
});


/* Insert table and groupID

*/
module.exports.srSitsAt = srSitsAt = function(groupID, tableNo, callback) {
  let q1 = "INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES ?;";
  let data = [groupID, tableNo];
  conn.query(q1, [[data]], (error, results, fields) => {
    if (error) throw error;
    callback(results);
  });
}


/* Check if there is table
callback :function: callback once done
{NOT YET FINALIZED}
*/
module.exports.srCheckTable = srCheckTable = function(range, callback) {

  let q1 = "SELECT * FROM `restauranttable` AS rt WHERE rt.seatCount BETWEEN ? AND ? AND rt.tableNo NOT IN (SELECT DISTINCT sa.tableNo FROM `ServiceReceiver` AS sr JOIN `SitsAt` AS sa ON sr.groupID = sa.groupID WHERE sr.enterDate IS NOT NULL AND sr.leaveDate IS NULL) ORDER BY rt.seatCount ASC, rt.tableNo ASC;"

  conn.query(q1, range, (error, results, fields) => {
    if (error) throw error;
    callback(results);
  });
}


/* Check if there is queue
Check if there is queue available to be called
callback :function: callback once done
{NOT YET FINALIZED}
*/
module.exports.srCheckQueue = srCheckQueue = function(callback) {
  let q1 = "SELECT rt.tableNo, rt.seatCount, sr.amountOfPeople, sr.groupID, q.queueID, q.queueNo FROM `RestaurantTable` rt, `ServiceReceiver` sr LEFT JOIN `Queue` q ON sr.groupID=q.groupID WHERE sr.enterDate IS NULL AND rt.seatCount>=sr.amountOfPeople AND (rt.tableNo NOT IN (SELECT DISTINCT sa.tableNo FROM `ServiceReceiver` sr, `SitsAt` sa WHERE sr.enterDate IS NOT NULL AND sr.leaveDate IS NULL AND sr.groupID=sa.groupID)) ORDER BY q.groupID DESC, sr.amountOfPeople ASC, q.queueDate ASC, rt.seatCount ASC LIMIT 1;";
  conn.query(q1, (error, results, fields) => {
    if (error) throw error;
    console.log(results[0]);
    callback(results[0]);
  });
}


/* Get the next queue number
callback :function: callback once done
Callback Format:
{"nextQ": NEXT_QUEUE_NUMBER}
*/
module.exports.srNextQueueNo = srNextQueueNo = function(callback) {
  let q1 = 'SELECT MAX(`queueNo`)+1 nextQ FROM `Queue` WHERE `queueDate` BETWEEN ? AND ?;';
  //let today = moment().format('YYYY-MM-DD');
  let today = "2018-03-28";
  let start = `${today} 00:00:00`;
  let end = `${today} 23:59:59`;
  let data = [start, end];
  conn.query(q1, [data], (error, results, fields) => {
    if (error) throw error;
    if (typeof results.nextQ !== 'integer') {
      callback({
        "nextQ": 1
      });
    } else {
      callback({
        "nextQ": results.nextQ
      });
    }
  });
}


/* Make queue base on, groupID & queue number
groupID :string: UUID of the group
nextQueueNo :integer: the next queue number
callback :function: callback once done
{"affectedRows": NUMBER_OF_ROWS}
*/
module.exports.srRequestQueue = srRequestQueue = function(groupID, nextQueueNo, callback) {
  let q1 = 'INSERT INTO Queue(`queueID`, `queueNo`, `queueDate`, `groupID`) VALUES ?;';
  let queueID = uuidv4();
  let queueDate = moment().format(dateTimeTemplate);
  let data = [queueID, parseInt(nextQueueNo), queueDate, groupID];
  console.log(data);
  conn.query(q1, [
    [data],
  ], (error, results, fields) => {
    if (error) throw error;
    console.log(results);
    callback({
      "affectedRows": results.affectedRows
    });
  });
}


/* Drop ServiceReceiver given group ID
groupID :str: ServiceReceiver group ID
callback :function: callback once done
Callback Format:
{"affectedRows": NUMBER_OF_ROWS}
NOTE: Auto drop queue as CASCADE is used
*/
module.exports.srDrop = srDrop = function(groupID, callback) {
  let q1 = 'DELETE FROM `ServiceReceiver` WHERE groupID=?;';
  conn.query(q1, [groupID], (error, results, fields) => {
    if (error) throw error;
    callback({
      "affectedRows": results.affectedRows
    });
  });
}


/* Make a ServiceReceiver
callback :function: callback once done
Callback Format:
{"srUUID": STRING_UUID}
*/
module.exports.srMakeServiceReceiver = srMakeServiceReceiver = function(amtOfPpl, callback) {
  let q1 = "INSERT INTO `ServiceReceiver` (`groupID`, `amountOfPeople`, `enterDate`, `leaveDate`) VALUES ?;";
  let groupID = uuidv4();
  let data = [groupID, amtOfPpl];
  conn.query(q1, [
    [data],
  ], (error, results, fields) => {
    if (error) throw error;
    callback({
      "groupID": groupID,
      "affectedRows": results.affectedRows
    });
  });
}


module.exports.srMake = srMake = function(groupID, amtOfPpl, callback) {
  let q1 = "INSERT `ServiceReceiver` (`groupID`, `amountOfPeople`) VALUES ?";
  conn.query(q1, [[[groupID, amtOfPpl]]], (error, results, fields) => {
    if (error) throw error;
    callback({
      "groupID": groupID,
      "affectedRows": results.affectedRows
    });
  });
}


module.exports.srUpdate_enterDate = updateSR_enterDate = function(groupID, enterDate, callback) {
  let q1 = "UPDATE `ServiceReceiver` SET `enterDate`=? WHERE `groupID`=?;";
  conn.query(q1, [enterDate, groupID], (error, results, fields) => {
    if (error) throw error;
    callback({
      "groupID": groupID,
      "affectedRows": results.affectedRows
    });
  });
}


module.exports.srUpdate_leaveDate = updateSR_leaveDate = function(groupID, leaveDate, callback) {
  let q1 = "UPDATE `ServiceReceiver` SET `leaveDate`=? WHERE `groupID`=?;";
  conn.query(q1, [leaveDate, groupID], (error, results, fields) => {
    if (error) throw error;
    callback({
      "groupID": groupID,
      "affectedRows": results.affectedRows
    });
  });
}

/* Get the number of group waiting
groupID :str: ServiceReceiver group ID
callback :function: callback once done
Callback Format:
{"waitingQ": NUMBER_OF_WAITING_Q}
*/
// BUG also count completed queue
module.exports.srWaitingQueueCount = srWaitingQueueCount = function(callback) {
  let q1 = 'SELECT COUNT(*) waitingQ FROM Queue q WHERE queueDate BETWEEN ? AND ?;';
  //let today = moment().format('YYYY-MM-DD');
  let today = "2018-03-28";
  let start = `${today} 00:00:00`;
  let end = `${today} 23:59:59`;
  conn.query(q1, [start, end], (error, results, fields) => {
    if (error) throw error;
    if (typeof results.waitingQ !== 'integer') {
      callback({
        "waitingQ": 0
      });
    } else {
      callback({
        "waitingQ": results.waitingQ
      });
    }
  });
}


module.exports = router;
