const uuidv4 = require('uuid/v4');
const mysql = require("mysql");

/*
Connection to the database, this MUST be set
in the main javascript file before using
other functions
*/
function toListDictionary(results, fields) {
  let rObj = [];
  for (let row of results) {
    let _tmp = {};
    for (let field of fields) {
      _tmp[field.name] = row[field.name];
    }
    rObj.push(_tmp);
  }
  return rObj;
}

module.exports = {

  conn: null,

  queryDB: function(q, callback, paramList = null) {
    if (typeof callback !== 'function') {
      console.warn("No callback function, doing nothing");
      return;
    }
    this.conn.query(q, [paramList], (error, results, fields) => {
      if (error) throw error;
      callback(toListDictionary(results, fields));
    });
  },

  getMenus: function(callback) {
    let q = 'SELECT * FROM Menu;';
    this.queryDB(q, callback);
  },

  getItems: function(callback) {
    let q = 'SELECT * FROM Item i;';
    this.queryDB(q, callback);
  },

  getMenuVersion: function(version, callback) {
    let q = 'SELECT i.itemNo, i.itemName, i.itemDescription, i.itemPrice, i.isAvailable FROM Contain c, Menu m, Item i WHERE m.version = c.version AND c.itemNo = i.itemNo AND m.version = ?;';
    this.queryDB(q, callback, version);
  },

  getMenuLatest: function(callback) {
    let q = 'SELECT * FROM Menu m, Contain c, Item i WHERE m.version=c.version AND i.itemNo=c.itemNo AND m.version = (SELECT MAX(m.version) FROM Menu m);';
    this.queryDB(q, callback);
  },

  getRestaurantName: function(callback) {
    let q = 'SELECT * FROM Restaurant WHERE 1;';
    this.queryDB(q, callback);
  },

  robotSetup: function(callback) {
    let q = 'INSERT INTO Robot(robotID, status, x_coord, y_coord) VALUES ?;';
    let robotUUID = uuidv4();
    let tmp = [
      [robotUUID, 0, -1, -1],
    ];
    this.conn.query(q, [tmp], (error, results, fields) => {
      if (error) throw error;
      this.robotInformation(robotUUID, (data) => {
        callback(data[0]);
      });
    });
  },

  robotDrop: function(robotUUID, callback) {
    let q = 'DELETE FROM Robot WHERE robotID = ?;';
    this.conn.query(q, [robotUUID], (e, r, f) => {
      if (e) throw e;
      callback(r);
    });
  },

  robotListAll: function(callback) {
    let q = 'SELECT * FROM Robot';
    this.queryDB(q, callback);
  },

  robotInformation: function(robotUUID, callback) {
    let q = 'SELECT * FROM Robot WHERE robotID = ?';
    this.queryDB(q, callback, robotUUID);
  },

  robotUpdateStatus: function(robotUUID, status, callback) {
    let q = 'UPDATE Robot SET status = ? WHERE robotID = ?';
    this.conn.query(q, [status, robotUUID], (error, results, fields) => {
      if (error) throw error;
      callback({
        "affectedRows": results.affectedRows
      });
    });
  },

  robotUpdateCoordinate: function(robotUUID, x_coord, y_coord, callback) {
    let q = 'UPDATE Robot SET x_coord=?, y_coord=? WHERE robotID = ?';
    this.conn.query(q, [x_coord, y_coord, robotUUID], (error, results, fields) => {
      if (error) throw error;
      callback({
        "affectedRows": results.affectedRows
      });
    });
  },

  demoLogin: function(ID, pw, callback) {
    let q = 'SELECT * FROM SystemAdministrator WHERE ID=?;';
    this.conn.query(q, ID, (error, results, fields) => {
      if (error) throw error;
      if (!results) callback(false);
      let DB_ID = results[0].ID;
      let DB_PASSWORD = results[0].password;
      if (DB_ID === ID && DB_PASSWORD === pw) {
        callback(true);
      } else {
        callback(false);
      }
    });
  },

  ServiceReceiverList: function(callback) {
    let q = 'SELECT * FROM ServiceReceiver;';
    this.queryDB(q, callback);
  },

  serviceReceiverRequest: function(amount, callback) {
    // Request a ID for customer
    let q = 'INSERT INTO ServiceReceiver(groupID, amountOfPeople) VALUES ?;';
    let gID = uuidv4();

    let data = [gID, amount];

    this.conn.query(q, [
      [data, ],
    ], (e, r, f) => {
      if (e) throw e;
      console.log(r);
    });

    this.serviceReceiverOne(gID, callback);
  },

  serviceReceiverOne: function(groupID, callback) {
    let q = 'SELECT * FROM ServiceReceiver WHERE groupID = ? LIMIT 1;';
    this.queryDB(q, callback, groupID);
  },

  serviceReceiverDrop: function(groupID, callback) {
    let q = 'DELETE FROM ServiceReceiver WHERE groupID = ?;';
    this.conn.query(q, [groupID], (e, r, f) => {
      if (e) throw e;
      console.log(r);
    });
  },

  queueRequest: function(callback) {
    let q = 'SELECT MAX(queueNo) maxQ FROM Queue ORDER BY queueDate DESC LIMIT 1;';
    this.queryDB(q, (arr) => {
      let queueNum = (!arr[0].maxQ) ? 1 : !arr[0].maxQ;
      let qID = uuidv4();
      let d = new Date().toISOString().slice(0, 19).replace('T', ' ');
      let v = [qID, 1, d];
      let iq = 'INSERT INTO Queue(queueID, queueNo, queueDate) VALUES ?';
      this.queryDB(iq, callback, [v]);
    });
    s
  },

  queueLatestQueueNo: function(callback) {
    // Get the latest queueNo of the day
    // SELECT MAX(queueNo) FROM Queue WHERE queueDate BETWEEN '2018-01-01 00:00:00' AND '2018-01-01 23:59:59';
  },

  queueIncomplete: function(callback) {
    // Get list of incomplete Queue
    // SELECT * FROM Queue q, ServiceReceiver sr WHERE q.groupID=sr.groupID AND sr.enterDate IS NULL;
  },

  getCompatableTable: function(amountOfPeople, callback) {
    // Get getCompatableTable
    // SELECT * FROM RestaurantTable rt WHERE rt.seatCount >= 1 ORDER BY rt.seatCount ASC;
  },

  getCompatableQueue: function(callback) {
    // Call queue with free table
    /*
    SELECT *
    FROM Queue q, ServiceReceiver sr, RestaurantTable rt
    WHERE
    q.groupID=sr.groupID AND sr.enterDate IS NULL AND -- Find waiting queue
    rt.seatCount>=sr.amountOfPeople -- Find table
    ORDER BY
    q.queueDate ASC, -- Oldest queue first
    rt.seatCount ASC -- Least amount of table first
    */
  },

  queueAll: function(callback) {
    let q = 'SELECT * FROM Queue';
    this.queryDB(q, callback);
  }

};
