var app, port;

app = require('./.app');

port = app.port;
host = app.host

app.listen(port, host, function () {
  return console.log("Listening on " + host + ":" + port + "\nPress CTRL-C to stop server.");
});
