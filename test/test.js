const expect = require('chai').expect;
const conn = require('../databaseSetup.js');
const fs = require('fs');
const path = require('path');

// Make database if not exist
before('Setting up database', function() {

});
after('End database connection', function() {
  conn.end();
});
describe('Testing request queue given INVALID amount of people', function() {

  it('Less than 1; Expect Z', function(done) {
    conn.query("SELECT requestQueue(0) AS requestResult;", function(error, results, fields) {
      if (error) throw error;
      console.log("Got: " + JSON.stringify(results[0]));
      expect(results[0].requestResult).equal('Z');
      done();
    });
  });

  it('More than 6; Expect X', function(done) {
    conn.query("SELECT requestQueue(7) AS requestResult;", function(error, results, fields) {
      if (error) throw error;
      console.log("Got: " + JSON.stringify(results[0]));
      expect(results[0].requestResult).equal('X');
      done();
    });
  });

});

describe('Testing request queue given VALID amount of people', function() {

  const cateRegexA = /([Aa][0-9]+)/;
  const cateRegexB = /([Bb][0-9]+)/;
  const cateRegexC = /([Cc][0-9]+)/;

  it('People = 1; Expect [Aa][0-9]+', function(done) {
    conn.query("SELECT requestQueue(1) AS requestResult;", function(error, results, fields) {
      if (error) throw error;
      console.log("Got: " + JSON.stringify(results[0]));
      expect(results[0].requestResult).to.match(cateRegexA);
      done();
    });
  });

  it('People = 3; Expect [Bb][0-9]+', function(done) {
    conn.query("SELECT requestQueue(3) AS requestResult;", function(error, results, fields) {
      if (error) throw error;
      console.log("Got: " + JSON.stringify(results[0]));
      expect(results[0].requestResult).to.match(cateRegexB);
      done();
    });
  });

  it('People = 5; Expect [Cc][0-9]+', function(done) {
    conn.query("SELECT requestQueue(5) AS requestResult;", function(error, results, fields) {
      if (error) throw error;
      console.log("Got: " + JSON.stringify(results[0]));
      expect(results[0].requestResult).to.match(cateRegexC);
      done();
    });
  });


});
