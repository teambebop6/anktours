/**
 * Created by Henry Huang on 2020/6/12.
 */
const gh = require('ghreleases')
const gutil = require('gulp-util')
const moment = require('moment')

const gitHubToken = process.env.TOKEN
const branch = process.env.BRANCH_NAME || 'dev'
const user = 'henryhuang'

const auth = {
  token: gitHubToken,
  user
};

const org = 'teambebop6'
const repo = 'anktours-secret'

module.exports = () => {

  gutil.log('creating release...')

  const timeTag = moment().format("YYYYMMDDHHmmss")
  const tag_name = branch + '-build-' + timeTag
  const data = {
    tag_name: tag_name,
    name: 'Build at ' + timeTag,
    body: 'Automatically release from travis.'
  }

  gh.create(auth, org, repo, data, (err) => {
    if (err) {
      throw new gutil.PluginError({
        plugin: 'release',
        message: err.message
      })
    }
    gutil.log('release created!')
    gutil.log('asset uploading...')
    const ref = 'tags/' + tag_name
    const files = [
      'ank-dist.zip',
    ]
    gh.uploadAssets(auth, org, repo, ref, files, (err, res) => {
      if (err) {
        throw new gutil.PluginError({
          plugin: 'release',
          message: err.message
        })
      }
      gutil.log('asset uploaded!')
    })
  })
}
