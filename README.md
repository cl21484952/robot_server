# Restaurant Central Server

This is a server which is used to manage data, communicate, and provide logic for the Robot UI. From menu to queuing system in the integrated robot system.

# Getting Started

## Prerequisites

* [MAMP](https://www.mamp.info/en/) - Local server environment: Apache server and MySQL server
* [GitHub Desktop](https://desktop.github.com/) - Source code control with GUI
* [NodeJs](https://nodejs.org/en/) - Asynchronous event for network application

## Setting up Environment

### Clone Repository

Clone the github repository in the GitHub Desktop

### Setting Up MySQL Server

Open the link for MAMP in browser
```
http://localhost/MAMP/
```

Go to phpMyAdmin page and make database name `zg6kbqpoxrbx4hox` then in the cloned repository is a folder `sql_queries`. Import the file named `prepEnv_vNN`. Where `NN` is replaced with the largest version in the folder.

### Setting Up Central Server

Open terminal and change directory into the folder which the repository is cloned. Install the dependency for the server by typing
```
npm install
```

Once everything is installed, install `nodemon` globally
```
npm i -g nodemon
```

Then run the server by typing in the console
```
nodemon
```

If the console shows the server running in port 100 then the server is running successfully.
You can test this by opening `http://localhost:100` which there will be text "`NODEJS - SERVER`"


## Running the tests

Type in the terminal which is the repository cloned, to see if the query in database works
```
npm test
```
Note: It will create 3 additional entry in the database, it must be manually removed.

## Built With

* [ExpressJs](https://expressjs.com/) - Minimal web framwork for NodeJs
* [MochaJs](https://mochajs.org/) - Feature-rich JavaScript test framework
* [chaijs](http://www.chaijs.com/) - Testing styles
* [cors](https://github.com/expressjs/cors) - Enable CORS for nodejs

# Usage

The server provide service through REST pattern.

## Available URL/API

### General Services - /api

#### /restaurantName

```
{restaurantName: 'Example restaurantName'}
```

#### /getMenuItem=[?mVer=`N1`]

Query
`N1` (integer) - The specific version of the menu, otherwise the latest version is returned

Return array of map
```
[
{
  itemNo: 1,
  itemName: 'Fried Rice',
  itemDescription: 'Gud Fud',
  itemPrice: 45,
  isAvailable: 1,
  category: 1
}, ...
]
```

#### /loginDemo?id=`N1`&password=`N2`

Returns `true` IFF password is valid for the repective ID else `false`

### Robot Services - /robot

#### /updateStatus?rstatus=`N1`&robotUUID=`N2`

Updates the status of a robot given it's UUID

### Service Receiver Services - /sr

#### /checkTable?amountOfPeople=`N1`

Check if table of the given `amountOfPeople` is available. If available, a table will be reserved immediately and returned in `tableInfo` field. Otherwise number of waiting queue `waitingQ` is given. If erroneous query is detected, `error` reason will be provided.
```
{
  error: null or error message,
  exceedMaxSeatCount: boolean,
  tableInfo: [],
  waitingQ: -1
}
```

#### /requestQueue?amountOfPeople=`N1`

A queue number will be returned in the format of `category` `queueNum`

#### /srLeft?groupID=`N1`[&leaveDate=`N2`]

Given `groupID`, set `leaveDate` of service receiver to the `leaveDate` provided, otherwise it will be assume to current server time.

#### /srInvalid?groupID=`N1`

Given `groupID`, set the `valid` field to `0`

#### /checkCallingQueue

Get the available queue that can be called.

# Contacts

* Phone: 1-800-system-provider - To contact the creator of the system
* Email: thisProvider@provider.com - To email creator of the system
* And the owner of this repository
