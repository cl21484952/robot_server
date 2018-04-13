const mysql = require("mysql");

const config = require("./config/database.js");

// Once "required" by other module
// it can be called directly
config.localhostDB.multipleStatements = true;
module.exports = mysql.createConnection(config.localhostDB, (err) => {
  if (err) throw err;
  console.log("Connected to DB");
});
