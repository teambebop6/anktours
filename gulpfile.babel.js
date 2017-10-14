/**
 * Created by Henry Huang on 10/14/17.
 */
import gulp from 'gulp';
import gutil from 'gulp-util';
import gulpif from 'gulp-if';
import watch from 'gulp-watch';
import merge from 'merge-stream';
import less from 'gulp-less';
import coffee from 'gulp-coffee';
import clean from 'gulp-clean';
import nodemon from 'gulp-nodemon';
import zip from 'gulp-zip';

import buildSemantic from './vendor/semantic/tasks/build';

// Compile Less
gulp.task('build-less', () => {
  gulp.src('src/assets/styles/**/*.less')
    .pipe(less())
    .pipe(gulp.dest('.app/assets/css'))
    .on('end', () => {
      gutil.log
      "Compiled less files";
    })
})
