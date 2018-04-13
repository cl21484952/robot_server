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
describe('Basic testing', function(){
  it('Query name of the Restaurant', function(done){
    filePath = path.join(__dirname, 'createDB.sql');
    fs.readFile(filePath, {
      encoding: 'utf-8'
    }, function(err, data) {
      if (err) throw done(err);
      conn.query("SELECT * FROM Restaurant", (error, results, fields) => {
        if (error) throw done(error);

        // expect(results).to.be.a('array');
        // expect(results).to.have.property('length', 1);
        expect(results[0]).to.include({'name':'NameOfRestaurantTest'});
        // console.log(results);
        done();
      });
    });
  });
});
