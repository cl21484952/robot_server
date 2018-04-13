// External Library
const express = require("express");

// Custom Script
const utils = require("../utils.js");
// --- --- ---
const router = express.Router();
const pathCalled = utils.pathCalled;
const notImp = utils.notImplemented;

const cq = require("../commonQuery.js");

// Used for testing purpose
router.get('/test', pathCalled, (req, res, next) => {
  res.send("called test");
});

// Get the name of the restaurant
router.get('/restaurantName', pathCalled, (req, res, next) => {
  cq.getRestaurantName((dataList) => {
    res.send(dataList[0]);
  });
});

// Get all available version of menu
router.get('/menus', pathCalled, (req, res, next) => {
  cq.getMenus((dataList) => {
    res.send(dataList);
  });
});

// Get all available menu
router.get('/items', pathCalled, (req, res, next) => {
  cq.getItems((dataList) => {
    res.send(dataList);
  });
});

// Get a menu of a specific version
router.get('/menuVersion', pathCalled, (req, res, next) => {
  if (req.query.version) {
    cq.getMenuVersion(req.query.version, (dataList) => {
      res.send(dataList);
    });
  } else {
    res.status(500).send({
      'error': 'No version provided'
    });
  }
});

// Get Latest verion of the menu item list
router.get('/menuLatest', pathCalled, (req, res, next) => {
  cq.getMenuLatest((dataList) => {
    res.send(dataList);
  });
});

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
