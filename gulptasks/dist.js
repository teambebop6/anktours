/**
 * Created by Henry Huang on 2020/6/12.
 */
const gulp = require('gulp')
const { series } = require('gulp')
const merge = require('merge-stream')
const zip = require('gulp-zip')
const path = require('path')

const rootDir = path.join(__dirname, '..')
const p = row => path.join(rootDir, row)

const distCopy = () => {

  const d_app = gulp.src([p('.app/**/*')]).pipe(gulp.dest(p('dist/.app/')))
  const d_lib = gulp.src([p('lib/**/*')]).pipe(gulp.dest(p('dist/lib/')))
  const d_public = gulp.src(p('public/**/*')).pipe(gulp.dest(p('dist/public/')))
  const d_tasks = gulp.src([p('tasks/**/*')]).pipe(gulp.dest(p('dist/tasks/')))
  const d_views = gulp.src([p('views/**/*')]).pipe(gulp.dest(p('dist/views/')))
  const d_locales = gulp.src([p('locales/**/*')])
    .pipe(
      gulp.dest(p('dist/locales/'))
    )
  const d_dist = gulp.src(
    [p('package.json'), p('server.js'), p('ecosystem.config.js'),
      p('pm2.*.config.js')]
  )
    .pipe(gulp.dest(p('dist/')))

  return merge(d_app, d_lib, d_public, d_tasks, d_views, d_locales, d_dist)

}

const distArchive = () => {
  return gulp.src(p('dist/**/*'), {
    dot: true
  })
    .pipe(zip('ank-dist.zip'))
    .pipe(gulp.dest(rootDir))
}

module.exports = series(distCopy, distArchive)
