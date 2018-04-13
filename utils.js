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
  logger: function(data) {
    console.log(data)
  }
}
