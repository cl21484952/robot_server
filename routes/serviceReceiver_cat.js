const express = require("express");
const moment = require('moment');
const uuidv4 = require('uuid/v4');
const mysql = require('mysql');
const router = express.Router();

const utils = require("../utils.js");
const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;
const pathDep = utils.pathDeprecated;


const conn = require("../databaseSetup.js");
const cq = require("../commonQuery.js");

const dateTimeTemplate = 'YYYY-MM-DD HH:mm:ss';

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
// NOTE Partially Implemented, missing no table
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
    res.send(rtnFormat);
    return;
  }


  let cate = checkTableCategory(amountOfPeople);

  checkTable(cate, (data) => {
    if (data.length > 0) {
      let uid = uuidv4();
      console.log(uid);
      srMake(uid, amountOfPeople, console.log);
      srSitsAt(uid, data[0].tableNo, console.log);
      updateSR_enterDate(uid, moment().format(dateTimeTemplate), console.log);
      rtnFormat.tableInfo = data[0];
      res.send(rtnFormat);
    } else {
      queueCheck(cate, (data) => {
        rtnFormat.waitingQ = data;
        res.send(rtnFormat);
      });
    }
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


// router.get("/test", (req, res, next)=>{
//   checkTable(req.query.category, (data)=>{res.send(data);});
// });


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

router.get("/srLeft", (req, res, next) => {
  // 0d2a483b-ed8a-4b8f-9b8c-503c8e35b1e1

  updateSR_leaveDate(req.query.groupID, moment().format(dateTimeTemplate), (data) => {
    res.send(data);
  });
});




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


module.exports = router;
