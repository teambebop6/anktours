runSequence = require 'run-sequence'
gh = require 'ghreleases'
gulp = require 'gulp'
gutil = require 'gulp-util'
moment = require 'moment'

gitHubToken = process.env.GitHubToken

auth = {
  token: gitHubToken,
  user: 'henryhuang'
};

org = 'teambebop6'
repo = 'anktours'

#gulp.task 'release', ()->
#  gutil.log 'r'
#  gh.list(auth, 'teambebop6', 'anktours', (err, list) ->
#    gutil.log(list)
#  )

module.exports = (callback) ->
  gutil.log 'creating release...'

  timeTag = moment().format("YYYYMMDDHHmmss")
  tag_name = 'release-' + timeTag
  data = {
    tag_name: tag_name,
    name: 'Release at ' + timeTag
    body: 'Automatically release from travis.'
  }
  gh.create(auth, org, repo, data, (err) ->
    if err
      throw new gutil.PluginError({
        plugin: 'release',
        message: err.message
      })
    gutil.log 'release created!'
    gutil.log 'asset uploading...'
    ref = 'tags/' + tag_name
    files = [
      'ank-dist.zip',
    ]
    gh.uploadAssets(auth, org, repo, ref, files, (err, res) ->
      if err
        throw new gutil.PluginError({
          plugin: 'release',
          message: err.message
        })
      gutil.log 'asset uploaded!'
    )
  )
