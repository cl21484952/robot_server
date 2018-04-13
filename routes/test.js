const express = require("express");


const cq = require("../commonQuery.js");
const utils = require("../utils.js");

const router = express.Router();

router.get('', (req, res, next) => {
  console.log(req);
  console.log(res);
  res.send('Nothing');
  console.log(req.originalUrl);
});


router.get('/respond', (req, res, next) => {
  pathCalled("/respond");
  res.send("hi");
});

router.post('/json', (req, res, next) => {
  pathCalled("/json");
  console.log(req.body);
  res.send(req.body);
});

router.get('/menuItems', (req, res, next) => {
  pathCalled("/menuItems");
  cq.getItems((array) => {
    res.send(JSON.stringify(array));
  });
});

module.exports = router;
