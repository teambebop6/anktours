gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
merge = require 'merge-stream'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
clean = require 'gulp-clean'
nodemon = require 'gulp-nodemon'
zip = require 'gulp-zip'
runSequence = require 'run-sequence'

buildSemantic = require('./vendor/semantic/tasks/build')
release = require('./gulptasks/release');


# Compile Less
gulp.task 'build-less', ->
  gulp.src 'src/assets/styles/**/*.less'
  .pipe less()
  .pipe gulp.dest('.app/assets/css')
  .on 'end', ->
    gutil.log "Compiled less files"

# Watch Less
gulp.task 'watch-less', ->
  gulp.src 'src/assets/styles/*.less'
  .pipe watch('src/assets/styles/*.less')
  .pipe less()
  .pipe gulp.dest('.app/assets/css')
  .on 'end', ->
    gutil.log "Compiled less files"

# Handle coffee script
gulp.task 'compile-coffee', ->
  gutil.log "Compiling coffee script"
  gulp.src 'src/**/*.coffee'
  .pipe coffee({bare: true})
  .pipe gulp.dest('.app/')

gulp.task 'move-js-files', ['compile-coffee'], ->
  gutil.log "Moving js files."
  gulp.src '.app/assets/scripts/**/*.js'
  .pipe gulp.dest('.app/assets/js/')

gulp.task 'remove-scripts-folder', ['move-js-files'], ->
  gutil.log "Removing old js folder."
  gulp.src '.app/assets/scripts', {read: false}
  .pipe clean()

gulp.task 'build-coffee', ['compile-coffee', 'move-js-files', 'remove-scripts-folder'], ->
  gutil.log "Finished building coffeescript."

gulp.task 'watch-coffee', ->
  gutil.log "Watching coffee script"
  gulp.watch 'src/**/*.coffee', ['build-coffee']

gulp.task 'watch-source', ['watch-coffee', 'watch-less']
gulp.task 'watch-all', ['watch-source', 'watch-semantic']

gulp.task 'build-semantic', buildSemantic
gulp.task 'build-source', ['build-less', 'build-coffee']
gulp.task 'build-all', ['build-source', 'build-semantic']
gulp.task 'build', ['build-source']

gulp.task 'start-server', ->
  gulp.start ['watch-source']

  if not nodemon_instance?
    nodemon_instance = nodemon
      script: 'server.js'
      watch: ['.app/']
      ext: 'js'
      verbose: true
    nodemon_instance.on 'restart', ->
      gutil.log 'Restarting server'
  else
    nodemon_instance.emit 'restart'

gulp.task 'server', ['serve']
gulp.task 'default', ['serve']
gulp.task 'serve', ['build-source'], ->
  gulp.start ['start-server']

gulp.task 'test', ->
  gutil.log 'test it done'

gulp.task 'clean', 'Clean dist folder', ->
  gulp.src ['dist/', 'dist.zip', 'ank-dist.zip'], {read: false}
  .pipe clean()

gulp.task 'dist:copy', ->
  d_app = gulp.src ['.app/**/*']
  .pipe gulp.dest 'dist/.app/'

  d_lib = gulp.src ['lib/**/*']
  .pipe gulp.dest 'dist/lib/'

  d_public = gulp.src 'public/**/*'
  .pipe gulp.dest 'dist/public/'

  d_views = gulp.src ['views/**/*']
  .pipe gulp.dest 'dist/views/'

  d_locales = gulp.src ['locales/**/*']
  .pipe gulp.dest 'dist/locales/'

  d_dist = gulp.src ['package.json', 'server.js', 'ecosystem.config.js', 'pm2.dev.config.js']
  .pipe gulp.dest 'dist/'

  return merge d_app, d_lib, d_public, d_views, d_locales, d_dist

gulp.task 'dist:archive', ->
  distFolder = __dirname
  return gulp.src 'dist/**/*', {
    dot: true
  }
  .pipe zip 'ank-dist.zip'
  .pipe gulp.dest distFolder

gulp.task 'deploy-daily', ->
  gutil.log 'Stopping service ...'
  try
    pm2Stop = spawn.sync 'pm2', ['stop', 'graspdaily']
  catch e
# ignore it
    gutil.log(e)

  gutil.log 'Deleting service ...'
  try
    pm2Delete = spawn.sync 'pm2', ['delete', 'graspdaily']
  catch e
# ignore it
    gutil.log(e)

  gutil.log 'Starting service ...'
  startService = spawn.sync 'pm2', ['start', 'server.js', '--name', '"graspdaily"', '--',
    'NODE_ENV=local']

gulp.task 'release', 'release to GitHub', release

gulp.task 'dist', () ->
  runSequence 'dist:copy', 'dist:archive'
