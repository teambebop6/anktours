// Upload middleware
var multer = require('multer');
var fs = require('fs');
var crypto = require('crypto'); // Cryptography module
var mime = require('mime'); // For mime filetypes mapping
var path = require('path');
var fileUtils = require('./fileUtils');


// var upload_path = __dirname + '/../public/images/upload/';

// Be sure the directory is created if not exists
// try {
//   fs.mkdirSync(upload_path);
// } catch (e) {
//   if (e.code != 'EEXIST') throw e;
// }


module.exports = function (baseFolder) {

  var storage = multer.diskStorage({
    destination: function (req, file, cb) {
      var upload_path = path.join(req.app.get('config').IMAGE_UPLOAD_FOLDER, baseFolder);
      fileUtils.mkdirIfNotExist(upload_path);
      cb(null, upload_path);
    },
    filename: function (req, file, cb) {
      crypto.pseudoRandomBytes(16, function (err, raw) {
        cb(null, raw.toString('hex') + '.' + mime.extension(file.mimetype))
      });
    }
  });
  var upload = multer({ storage: storage });
  return upload;
};
