var gulp = require('gulp');
var imageResize = require('gulp-image-resize');
var path = require('path');
var gm = require('gm').subClass({imageMagick: true});
var utils = require('../.app/utils/Utils')

function processImg (filesrc) {
	var dirname = path.dirname(filesrc);	
	var filename = path.basename(filesrc);


  var dirnames = [
    path.join(dirname, '/squared'),
    path.join(dirname, '/thumbs')
  ]

  dirnames.forEach(function(dir){
    utils.ensureDirExists(dir, function(err){});
  });

	gm(filesrc)
		.resize('700','700','^') // ^ designates minimum height
		.gravity('Center')
		.crop('700', '700')
		.write(path.join(dirnames[0], filename), function(err){
			if(err) { console.log(err); return; }
			console.log("Thumbnail successfully generated!");
		});
 
	return gulp.src(filesrc) 
		// save big
		.pipe(imageResize({
			width: 700,
			height: 700,
			imageMagick: true
		}))
		.pipe(gulp.dest(path.join(dirname)))
		
		
		// save thumb 
		.pipe(imageResize({
			width: 120,
			height: 120,
			crop: true,
			imageMagick: true
		}))
		.pipe(gulp.dest(dirnames[1]))
}

process.on('message', function (images) {
				console.log('Image processing started...');
				
	var stream = processImg(images);
				stream.on('end', function () {
					process.send('Image processing complete');
					process.exit();
				});
				stream.on('error', function (err) {
					process.send(err);
					process.exit(1);
	});
});

module.exports = {};
