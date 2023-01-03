/**
 * Created by Henry Huang on 2020/6/13.
 */
const gutil = require('gulp-util')

module.exports = (done) => {
  gutil.log('Clean up releases only retain n releases')
  gutil.log(`Branch ${process.env.BRANCH_NAME}`)
  gutil.log('TODO')
  done()
}
