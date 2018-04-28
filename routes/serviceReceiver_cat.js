// External Library
const express = require("express");
const moment = require('moment');
const uuidv4 = require('uuid/v4');
const mysql = require('mysql');

// Custom Script
const utils = require("../utils.js");
const conn = require("../databaseSetup.js");
const cq = require("../commonQuery.js");

// --- --- ---

const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;
const pathDep = utils.pathDeprecated;
const dateTimeTemplate = 'YYYY-MM-DD HH:mm:ss';
const router = express.Router();

const category = {
  "category_A": [1, 2],
  "category_B": [3, 4],
  "category_C": [5, 6]
}
Object.freeze(category);



/* Check table availability
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
router.get('/checkTable', pathCalled, (req, res, next) => {

  const MAX_SEATCOUNT = 6;
  let rtnFormat = {
    'error': null, // null imply no problem
    'exceedMaxSeatCount': false,
    'tableInfo': [], // Table availability can be implied
    'waitingQ': -1 // -1 imply information not given
  };

  let amountOfPeople = parseInt(req.query.amountOfPeople);

  // Client query checking
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
  if (amountOfPeople > MAX_SEATCOUNT) {
    res.status(400);
    rtnFormat.error = "Exceed maximum supported amount";
    rtnFormat.exceedMaxSeatCount = true;
    res.send(rtnFormat);
    return;
  }

  conn.query("CALL tableChecking(?);", [amountOfPeople], (error, results, fields)=>{
    if (error) throw error;
    rtnFormat["error"] = results[0][0]["error"];
    if (results[0][0]['tableNo'] > 0){
      rtnFormat.tableInfo.push(results[0][0]['tableNo']);
    }
    rtnFormat.waitingQ = results[0][0]['waitingQueue'];
    res.send(rtnFormat);
  });

  // let cate = checkTableCategory(amountOfPeople);
  //
  // checkTable(cate, (data) => {
  //   if (data.length > 0) {
  //     let uid = uuidv4();
  //     console.log(uid);
  //     srMake(uid, amountOfPeople, console.log);
  //     srSitsAt(uid, data[0].tableNo, console.log);
  //     updateSR_enterDate(uid, moment().format(dateTimeTemplate), console.log);
  //     rtnFormat.tableInfo.push(data[0]);
  //     res.send(rtnFormat);
  //   } else {
  //     queueCheck(cate, (data) => {
  //       rtnFormat.waitingQ = data;
  //       console.log(rtnFormat);
  //       res.send(rtnFormat);
  //     });
  //   }
  // });
});


router.get('/requestQueue', pathCalled, (req, res, next) => {

  const MAX_SEATCOUNT = 6;
  let rtnFormat = {
    'error': null, // null imply no problem
    'exceedMaxSeatCount': false,
    'queueNo': -1 // -1 imply information not given
  };

  let amountOfPeople = parseInt(req.query.amountOfPeople);

  // Client query checking
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
  if (amountOfPeople > MAX_SEATCOUNT) {
    res.status(400);
    rtnFormat.error = "Exceed maximum supported amount";
    rtnFormat.exceedMaxSeatCount = true;
    res.send(rtnFormat);
    return;
  }

  conn.query("SELECT requestQueue(?) AS queueNo;", [amountOfPeople], (error, results, fields)=>{
    if (error) throw error;
    rtnFormat.queueNo = results[0].queueNo;
    res.send(rtnFormat);
  });
});

/* Service Receiver left the Restaurant
Query -
groupID :string: UUID of the groupID
Optional Query -
leaveDate :string: time which the customer left
*/
router.get('/srLeft', (req, res, next) => {

  let groupID = req.query.groupID || null;
  let leaveDatetime = req.query.leaveDate || moment().format(dateTimeTemplate);

  if (!groupID || groupID.length !== 36) {
    res.status(400);
    res.send({
      "error": "Malformed groupID"
    });
    return;
  }
  if (!moment(leaveDatetime, dateTimeTemplate).isValid()) {
    res.status(400);
    res.send({
      "error": "Invalid date, valid format: " + dateTimeTemplate
    });
    return;
  }

  updateSR_leaveDate(groupID, leaveDatetime, (data) => {
    res.send(data);
  });
});


/* Invalidate a SR
Query -
groupID :string: UUID of the groupID
*/
router.get('/srInvalid', pathCalled, (req, res, next) => {

  let groupID = req.query.groupID;

  if (!groupID || groupID.length !== 36) {
    res.status(400);
    res.send("No groupID provided or Malformed");
    return;
  }

  srInvalidate(groupID, (rtn) => {
    res.send(rtn);
  });
});

/*
Returns
{groupID string or null
queueNo string or null
tableNo integer or null
positionID string or null}
*/
router.get('/checkCallingQueue', pathCalled, (req, res, next) => {
  conn.query("CALL checkWaitingQueue();", (error, results, fields) => {
    if (error) throw error;
    res.send(results[0][0]);
    console.log(results);
  });
});


// callback the name of the table
module.exports.checkTableCategory = checkTableCategory = function(amtOfPpl, callback) {

  let tableCategory = null;

  switch (amtOfPpl) {
    case 1:
    case 2:
      tableCategory = "A";
      break;
    case 3:
    case 4:
      tableCategory = "B";
      break;
    case 5:
    case 6:
      tableCategory = "C";
      break;
    default:
      throw new Error("Amount of people not supported");
      break;
  }

  return tableCategory;
}


// Check if the table of the given category is available
module.exports.checkTable = checkTable = function(tableCategory, callback) {

  let q1 = null;
  let q1_a = "SELECT rt.tableNo, rt.seatCount, rt.positionID FROM `RestaurantTable` rt WHERE rt.seatCount BETWEEN 1 AND 2 AND rt.tableNo NOT IN (SELECT sa.tableNo FROM `SitsAt` sa INNER JOIN `ServiceReceiver` sr ON sa.groupID = sr.groupID AND sr.enterDate IS NOT NULL AND sr.leaveDate IS NULL);";
  let q1_b = "SELECT rt.tableNo, rt.seatCount, rt.positionID FROM `RestaurantTable` rt WHERE rt.seatCount BETWEEN 3 AND 4 AND rt.tableNo NOT IN (SELECT sa.tableNo FROM `SitsAt` sa INNER JOIN `ServiceReceiver` sr ON sa.groupID = sr.groupID AND sr.enterDate IS NOT NULL AND sr.leaveDate IS NULL);";
  let q1_c = "SELECT rt.tableNo, rt.seatCount, rt.positionID FROM `RestaurantTable` rt WHERE rt.seatCount BETWEEN 5 AND 6 AND rt.tableNo NOT IN (SELECT sa.tableNo FROM `SitsAt` sa INNER JOIN `ServiceReceiver` sr ON sa.groupID = sr.groupID AND sr.enterDate IS NOT NULL AND sr.leaveDate IS NULL);";

  switch (tableCategory) {
    case "A":
      q1 = q1_a;
      break;
    case "B":
      q1 = q1_b;
      break;
    case "C":
      q1 = q1_c;
      break;
    default:
      throw new Error("Unknown category");
      break;
  }

  conn.query(q1, (error, results, fields) => {
    if (error) throw error;
    callback(results);
  });
}


// Check the number of waiting queue
module.exports.queueCheck = queueCheck = async function(tableCategory, callback) {

  let q1 = null;
  let q1_a = "SELECT COUNT(*) wq FROM `queue_a` qa JOIN `servicereceiver` sr ON qa.groupID = sr.groupID WHERE sr.enterDate IS NULL AND sr.valid=1";
  let q1_b = "SELECT COUNT(*) wq FROM `queue_b` qa JOIN `servicereceiver` sr ON qa.groupID = sr.groupID WHERE sr.enterDate IS NULL AND sr.valid=1";
  let q1_c = "SELECT COUNT(*) wq FROM `queue_c` qa JOIN `servicereceiver` sr ON qa.groupID = sr.groupID WHERE sr.enterDate IS NULL AND sr.valid=1";

  switch (tableCategory) {
    case "A":
      q1 = q1_a;
      break;
    case "B":
      q1 = q1_b;
      break;
    case "C":
      q1 = q1_c;
      break;
    default:
      throw new Error("Unknown category");
      break;
  }

  conn.query(q1, (error, results, fields) => {
    if (error) throw error;
    callback(results[0].wq);
  });

}


// Make servicereceiver ID
module.exports.srMake = srMake = function(groupID, amtOfPpl, callback) {

  let q1 = "INSERT `ServiceReceiver` (`groupID`, `amountOfPeople`) VALUES ?";

  conn.query(q1, [
    [
      [groupID, amtOfPpl]
    ]
  ], (error, results, fields) => {
    if (error) throw error;
    callback({
      "groupID": groupID,
      "affectedRows": results.affectedRows
    });
  });
}


// Insert table and groupID
module.exports.srSitsAt = srSitsAt = function(groupID, tableNo, callback) {
  let q1 = "INSERT INTO `SitsAt` (`groupID`, `tableNo`) VALUES ?;";
  let data = [groupID, tableNo];
  conn.query(q1, [
    [data]
  ], (error, results, fields) => {
    if (error) throw error;
    callback(results);
  });
}


// // Check queue
// module.exports.checkCallingQueue = checkCallingQueue = function(callback) {
//
// }


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
module.exports.srInvalidate = srInvalidate = function(groupID, callback) {
  let q1 = 'UPDATE `servicereceiver` SET `enterDate`=? `valid`=? WHERE `groupID`=?;';
  conn.query(q1, [null, 0, groupID], (error, results, fields) => {
    if (error) throw error;
    callback({
      "affectedRows": results[0].affectedRows
    });
  });
}


/* Update when SR enter restaurant
Paremeters:
groupID :string: the UUID for the SR
enterDate :string: the date time to be inserted with
*/
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


/* Update when SR leaves restaurant
Paremeters:
groupID :string: the UUID for the SR
enterDate :string: the date time to be inserted with
*/
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


/*
DEPRECATED
*/


/* DEPRECATED Get the number of group waiting
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

/* DEPRECATED Check if there is table
callback :function: callback once done
{NOT YET FINALIZED}
*/
module.exports.srCheckTable = srCheckTable = function(amountOfPeople, callback) {

  let q1 = "SELECT * FROM `restauranttable` AS rt WHERE rt.seatCount BETWEEN ? AND ? AND rt.tableNo NOT IN (SELECT DISTINCT sa.tableNo FROM `ServiceReceiver` AS sr JOIN `SitsAt` AS sa ON sr.groupID = sa.groupID WHERE sr.enterDate IS NOT NULL AND sr.leaveDate IS NULL) ORDER BY rt.seatCount ASC, rt.tableNo ASC;"

  conn.query(q1, range, (error, results, fields) => {
    if (error) throw error;
    callback(results);
  });
}

/* DEPRECATED Check if there is queue
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

/* DEPRECATED Get the next queue number
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



module.exports = router;
