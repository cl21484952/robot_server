const express = require("express");
const router = express.Router();

const utils = require("../utils.js");

const cq = require("../commonQuery.js");


const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;

// Used for testing
router.get('/test', pathCalled, (req, res, next) => {
  res.send("server hi");
});

router.get('/allRobot', pathCalled, (req, res, next) => {
  cq.robotListAll((data) => {
    res.send(data);
  });
});

// Initialize Robot information (UUID)
router.get('/initialize', pathCalled, (req, res, next) => {
  cq.robotSetup((data) => {
    res.send(data);
  });
});

// Drop robot from database using UUID
router.get('/dropRobot', pathCalled, (req, res, next) => {
let robotUUID = req.query.robotUUID;
  cq.robotDrop(req.query.robotUUID, (e, r, f) => {
    res.send(r);
  });
});

// Update robot status
router.get('/updateStatus', pathCalled, (req, res, next) => {
  let rstatus = req.query.rstatus;
  let robotUUID = req.query.robotUUID;
  cq.robotUpdateStatus(rstatus, robotUUID, (eee)=>{
    res.send(eee);
  });
});

// Update robot coordinate
router.get('/updateCoordinate', pathCalled, (req, res, next) => {
  let robotUUID = req.query.robotUUID;
  let xCoord = req.query.x_coord;
  let yCoord = req.query.y_coord;
  cq.robotUpdateCoordinate(robotUUID, xCoord, yCoord, (data)=>{
    res.send(data);
  });
});

module.exports = router;
