// Copy file ./[arr_el]/ to dest/[arr_el]/ 
// node copyToNewDir filename dest 

gulp = require('gulp');
path = require('path');

filename = process.argv[2];
to = process.argv[3];

console.log("Filename is: " + filename);
console.log("Destination is: " + to);

dirs = ['./', './squared', './thumbs'];

dirs.forEach(function(dirname){
  var from = path.join(dirname, filename)
  console.log("Copying from: " + from);

  var dest = path.join(to, dirname, filename);
  console.log("To: " + dest);
  
  gulp.src(from)
    .pipe(gulp.dest(dest));
  
  console.log("copied image");
});
