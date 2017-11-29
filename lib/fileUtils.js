var mkdirp = require('mkdirp');
var fs = require('fs');

exports.mkdirIfNotExist = function (dir) {
  if (!fs.existsSync(dir)){
    mkdirp.sync(dir);
  }
};