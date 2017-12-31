// Create thumbnails from all images in current folder and copies them to dest_path
// example: node createThumbs from_path to_path 100

var	path = require('path'),
    fs = require('fs'),
    gm = require('gm').subClass({imageMagick: true});

var utils = require('../.app/utils/Utils')

var original_path = process.argv[2];
var destination_path = process.argv[3]

utils.ensureDirExists(destination_path, function(err){
  if(err){
    return console.log(err);
  }


  // Read dir for all images files
  var _getImagesFromFolder = function(dir){		
    var image_files = []

      // Scan directory
      fs.readdirSync(dir).forEach(function(file){
        file = path.join(dir, file);
        var stat = fs.statSync(file);
        if(stat && stat.isDirectory()){
          image_files = image_files.concat(_getImagesFromFolder(file));	
        }
        else{
          if(path.extname(file) == '.jpg' || '.png' || '.gif') image_files.push(file);
        }
      });

    return image_files
  };

  var image_files = _getImagesFromFolder(original_path);


  image_files.forEach(function(image){
    // Create thumbnail
    gm(image)
      .resize(process.argv[4], process.argv[4])
      .write(path.join(destination_path, path.basename(image)), function(err){
        if(!err) console.log('done')
        else{
          console.log(err);
        }
      });
  });
});
