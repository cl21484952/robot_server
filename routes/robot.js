const express = require("express");
const router = express.Router();

const utils = require("../utils.js");


const conn = require("../databaseSetup.js");

// const cq = require("../commonQuery.js");


const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;

// Used for testing
// router.get('/test', pathCalled, (req, res, next) => {
//   res.send("server hi");
// });
//
// router.get('/allRobot', pathCalled, (req, res, next) => {
//   cq.robotListAll((data) => {
//     res.send(data);
//   });
// });
//
// // Initialize Robot information (UUID)
// router.get('/initialize', pathCalled, (req, res, next) => {
//   cq.robotSetup((data) => {
//     res.send(data);
//   });
// });

// Drop robot from database using UUID
// router.get('/dropRobot', pathCalled, (req, res, next) => {
//   let robotUUID = req.query.robotUUID;
//   cq.robotDrop(req.query.robotUUID, (e, r, f) => {
//     res.send(r);
//   });
// });

// Update robot status
router.get('/updateStatus', pathCalled, (req, res, next) => {

  let rstatus = req.query.rstatus || null;
  let robotUUID = req.query.robotUUID || null;

  if (!robotUUID || robotUUID.length === 36) {
    res.status(400);
    res.send({
      "error": "Malformed robot UUID"
    });
    return;
  }
  if (!rstatus || typeof rstatus === "number") {
    res.status(400);
    res.send({
      "error": "Malformed robot status"
    });
    return;
  }

  robotUpdateStatus(robotUUID, rstatus, (eee) => {
    res.send(eee);
  });
});

function robotUpdateStatus(robotUUID, status, callback) {
  let q = 'UPDATE `Robot` SET `status`=? WHERE `robotID`=?;';
  conn.query(q, [status, robotUUID], (error, results, fields) => {
    if (error) throw error;
    callback({
      "affectedRows": results.affectedRows
    });
  });
}

// Update robot coordinate
// router.get('/updateCoordinate', pathCalled, (req, res, next) => {
//   let robotUUID = req.query.robotUUID;
//   let xCoord = req.query.x_coord;
//   let yCoord = req.query.y_coord;
//   cq.robotUpdateCoordinate(robotUUID, xCoord, yCoord, (data) => {
//     res.send(data);
//   });
// });

module.exports = router;
