// https://github.com/mysqljs/mysql#introduction
// https://www.w3schools.com/sql/sql_primarykey.asp
// Have not decide to use other library as of time constrain

// Built-in Library
const crypto = require('crypto');
const http = require('http');

// External Library
const uuidv4 = require('uuid/v4');
const mysql = require("mysql");
const express = require("express");
const bodyParser = require("body-parser");
const socketIo = require('socket.io');
const moment = require('moment');
const cors = require('cors');

// Custom Scripts
const cq = require("./commonQuery.js");
const databaseConfig = require("./config/database.js");
const utils = require('./utils.js');
const dd = require('./databaseSetup.js');
const dd2 = require('./databaseSetup.js');

let date = "2018-03-28";
//console.log(`SELECT MAX(queueNo) FROM Queue WHERE queueDate BETWEEN '${date} 00:00:00' AND '${date} 23:59:59';`);
//console.log(moment().format('YYYY-MM-DD HH:mm:ss'));

// dd.query("SELECT * FROM Robot", (e, r, f)=>{
//   console.log(r);
// });

// --- --- ---

let logger = utils.logger;

// Express.js Setup
const app = express();
app.use(bodyParser.json()); // JSON parser
app.use(cors()); // Allow cross domain access
// Routing, Pages & Modularity
app.use("/api", require("./routes/api.js"));
app.use('/robot', require('./routes/robot.js'));
app.use('/test', require('./routes/test.js'));
app.use('/sr', require('./routes/serviceReceiver_cat.js'));
app.get('/', function(req, res) {
  res.sendFile(__dirname + '/index.html');
});

// REST api
const server = http.Server(app);
let SERVER_PORT = 100;
server.listen(SERVER_PORT, () => {
  console.log(`Server on port: ${SERVER_PORT}!`);
});

// Socket io
const io = socketIo(server);
io.on('connection', function(socket) {
  socket.emit('serverTest', {
    hello: 'world'
  });
  socket.on('clientTest', logger);
});




// let x = null;
// cq.serviceReceiverRequest(2, (arr) => {
//   cq.serviceReceiverOne(arr[0].groupID, logger);
// });
// cq.ServiceReceiverList(logger);
// cq.serviceReceiverDrop("509293a9-ed97-4e75-b5cf-c7bc5924555b", logger);
// cq.serviceReceiverDrop("4dc499df-27b7-4dd1-afdf-7eb924841ca7", logger);
// cq.queryDB('SELECT MAX(queueNo) maxQ FROM Queue ORDER BY queueDate DESC LIMIT 1;', logger);

// Query for restaurantName
// cq.getRestaurantName(logger);

// Get menu versions
// cq.getMenuVersion(1, logger);

// Demonstrate login verification
// cq.demoLogin("admin", "insecurePassword", logger);

// Setup basic robot information: UUID
// cq.robotSetup(logger);

// See robot information
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);

// Update robot status
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);
// cq.robotUpdateStatus("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", 1, logger);
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);
// cq.robotUpdateStatus("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", 0, logger);
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);

// Update robot position
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);
// cq.robotUpdateCoordinate("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", 1, 1, logger);
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);
// cq.robotUpdateCoordinate("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", -1, -1, logger);
// cq.robotInformation("e2e4bd59-9692-4486-bd80-b0af9e80d7d0", logger);

// Show all queue
// cq.queueAll(logger);

// Request a Queue
// setTimeout(() => {
//   console.log("Closing server!");
//   server.close();
//   cq.conn.end();
// }, 20000);
