var gulp = require('gulp-param')(require('gulp'), process.argv);
var foreach = require('gulp-foreach');
var imageResize = require('gulp-image-resize');
var path = require('path');
var fs = require('fs');

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

	return image_files;
};

gulp.task("create-thumbs", function(src, dest, size, imageMagick){
	
	if(!src || !dest || !size){
		console.log("Missing arguments!");
		return;
	}

	if(imageMagick !== true){ imageMagick = false; }

	var image_files = _getImagesFromFolder(src);
	console.log("Images found: " + image_files);

	return gulp.src(image_files)
		.pipe(foreach(function(stream, file){
			return stream
				.pipe(imageResize({
					width: size,
					height: size,
					imageMagick: imageMagick 
				}));
		}))
		.pipe(gulp.dest(dest));
});

/*
var dirname = path.dirname(filesrc);
     
      
*/
