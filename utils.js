module.exports = {
  pathCalled: function(request, response, next) {
    console.log("Path called: " + request.originalUrl);
    next();
  },
  notImplemented: function(request, response, next) {
    console.log("Unimplemented path called: " + request.originalUrl);
    response.send("Path not implemented");
    next();
  },
  pathDeprecated: function() {
    console.log("Deprecated path called: " + request.originalUrl);
    response.send("Path deprecated");
    next();
  },
  logger: function(data) {
    console.log(data)
  }
}
