// External Library
const express = require("express");

// Custom Script
const utils = require("../utils.js");
const conn = require("../databaseSetup.js");
// --- --- ---
const router = express.Router();
const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;


// Get the name of the restaurant
router.get('/restaurantName', pathCalled, (req, res, next) => {
  restaurantNameGet((data) => {
    res.send(data);
  });
});

function restaurantNameGet(callback) {
  let q1 = 'SELECT * FROM `Restaurant`;';
  conn.query(q1, (error, results, fields) => {
    if (error) throw error;
    callback(results);
  });
}


/* Get a menu of a specific version
Optional Query -
mVer :integer: Version of the number
*/
router.get('/getMenuItem', pathCalled, (req, res, next) => {

  let mVer = req.query.mVer;

  if (!mVer) { // Version not provided
    menuItemVersionLatest((data) => {
      res.send(data);
      console.log(data);
    });
    return;
  }

  mVer = parseInt(mVer);
  if (typeof mVer === "NaN") {
    res.status(400);
    res.send({
      "error": "Malformed menu version"
    });
  }

  menuItemVersion(mVer, (data) => {
    res.send(data);
    console.log(data);
  });
});

function menuItemVersion(mVer, callback) {
  let q1 = 'SELECT * FROM `item` i JOIN `contain` c JOIN `menu` m ON i.itemNo=c.itemNo AND c.version=m.version WHERE m.version=?;';
  conn.query(q1, [mVer], (error, results, fields) => {
    callback(results);
  });
}

function menuItemVersionLatest(callback) {
  let q1 = 'SELECT * FROM `item` i JOIN `contain` c JOIN `menu` m ON i.itemNo=c.itemNo AND c.version=m.version WHERE m.version=(SELECT MAX(version) FROM `contain`);';
  conn.query(q1, (error, results, fields) => {
    callback(results);
  });
}


// Demonstrate login
router.get('/loginDemo', pathCalled, (req, res, next) => {
  let userID = req.query.id;
  let userPassword = req.query.password;
  if (userID && userPassword) {
    demoLogin(userID, userPassword, (canLogin) => {
      res.send(canLogin);
    });
  } else {
    res.send({
      'error': 'Missing ID or password'
    });
  }
});

function demoLogin(uID, uPW, callback) {
  let q = 'SELECT * FROM SystemAdministrator WHERE ID=?;';
  conn.query(q, [uID], (error, results, fields) => {
    if (error) throw error;
    if (!results) callback(false);
    let DB_ID = results[0].ID;
    let DB_PASSWORD = results[0].password;
    if (DB_ID === uID && DB_PASSWORD === uPW) {
      callback(true);
    } else {
      callback(false);
    }
  });
}

module.exports = router;
