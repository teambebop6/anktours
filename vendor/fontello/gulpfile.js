var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

gulp.task('glyph', function () {
  return gulp.src('config.json')
    .pipe($.fontello())
    .pipe($.print())
    .pipe(gulp.dest('../../public/fontello'))
});
