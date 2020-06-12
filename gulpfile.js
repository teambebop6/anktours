const gulp = require('gulp')
const { series, parallel } = require('gulp')
const gutil = require('gulp-util')
const watch = require('gulp-watch')
const merge = require('merge-stream')
const less = require('gulp-less')
const coffee = require('gulp-coffee')
const clean = require('gulp-clean')
const nodemon = require('gulp-nodemon')
const zip = require('gulp-zip')
const runSequence = require('run-sequence')

const release = require('./gulptasks/release')
const dist = require('./gulptasks/dist')

// Compile Less
const buildLess = (done) => {
  return gulp.src('src/assets/styles/**/*.less')
    .pipe(less())
    .pipe(gulp.dest('.app/assets/css'))
    .on('end', () => {
      gutil.log('Compiled less files')
      done()
    })
}

// Watch Less
const watchLess = (done) => {
  return gulp.watch('src/assets/styles/*.less', series(buildLess))
}

// Handle coffee script
const compileCoffee = (done) => {
  gutil.log('Compiling coffee script')
  return gulp.src('./src/**/*.coffee')
    .pipe(coffee({ bare: true }))
    .pipe(gulp.dest('.app/'))
    .on('end', () => {
      gutil.log('Compiled coffee files')
      done()
    })
}

const moveJSFiles = (done) => {
  gutil.log('Moving js files.')
  return gulp.src('.app/assets/scripts/**/*.js')
    .pipe(gulp.dest('.app/assets/js/'))
    .on('end', () => {
      gutil.log('Moved js files.')
      done()
    })
}

const deleteScriptsFolder = (done) => {
  gutil.log('Deleting .app/assets/scripts')
  return gulp.src('.app/assets/scripts', { read: false, allowEmpty: true })
    .pipe(clean())
    .on('end', () => {
      gutil.log('Deleted .app/assets/scripts')
      done()
    })
}

const buildCoffee = series(compileCoffee, moveJSFiles, deleteScriptsFolder)

const watchCoffee = () => {
  gutil.log('Watching coffee script')
  return gulp.watch('src/**/*.coffee', series(buildCoffee))
}

const watchSource = (done) => {
  gulp.watch('src/**/*.coffee', series(buildCoffee));
  gulp.watch('src/assets/styles/*.less', series(buildLess));
  done()
}

const buildSource = series(buildLess, buildCoffee)

const startServer = (done) => {
  const nm = nodemon({
    script: 'server.js',
    watch: ['.app/'],
    ext: 'js',
    verbose: true,
    done: done
  })
  nm.on('restart', () => {
    gutil.log('Restarting server...')
  })
  return nm
}

const serve = series(buildSource, parallel(watchSource, startServer))

const cleanDist = (done) => {
  return gulp
    .src(
      ['dist/', 'dist.zip', 'ank-dist.zip'],
      { read: false, allowEmpty: true }
    )
    .pipe(clean())
    .on('end', () => done())
}

const cleanApp = (done) => {
  return gulp.src(['.app/'], { read: false, allowEmpty: true })
    .pipe(clean())
    .on('end', () => done())
}

// exports.buildLess = buildLess
// exports.watchLess = watchLess
// exports.compileCoffee = compileCoffee
// exports.watchCoffee = watchCoffee
// exports.moveJSFiles = moveJSFiles
// exports.startServer = startServer
// exports.buildCoffee = buildCoffee

exports.serve = serve
exports.clean = series(cleanDist, cleanApp)
exports.dist = dist
exports.release = release
exports.build = buildSource
exports.default = buildSource
