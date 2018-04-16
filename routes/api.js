// External Library
const express = require("express");

// Custom Script
const utils = require("../utils.js");
const cq = require("../commonQuery.js");
const conn = require("../databaseSetup.js");
// --- --- ---
const router = express.Router();
const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;



// Used for testing purpose
// router.get('/test', pathCalled, (req, res, next) => {
//   res.send("called test");
// });

// Get the name of the restaurant
router.get('/restaurantName', pathCalled, (req, res, next) => {
  restaurantNameGet((data) => {
    res.send(data);
  });
});

function restaurantNameGet(callback) {
  let q1 = 'SELECT * FROM `Restaurant`;';
  conn.queryDB(q1, (error, results, fields) => {
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

  if (!mVer){ // Version not provided
    menuItemVersionLatest((data) => {
      res.send(data);
    });
  }

  mVer = parseInt(mVer);
  if (typeof mVer !== "number") {
    res.status(400);
    res.send({
      "error": "Malformed menu version"
    });
  }

  menuItemVersion(mVer, (data) => {
    res.send(data);
  });
});

function menuItemVersion(mVer, callback) {
  let q1 = 'SELECT * FROM `item` i JOIN `contain` c JOIN `menu` m ON i.itemNo=c.itemNo AND c.version=m.version WHERE m.version=?;';
  conn.query(q1, (error, results, fields) => {
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
    cq.demoLogin(userID, userPassword, (canLogin) => {
      res.send(canLogin);
    });
  } else {
    res.send({
      'error': 'Missing ID or password'
    });
  }
});

module.exports = router;
