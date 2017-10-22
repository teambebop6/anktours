runSequence = require 'run-sequence'
gh = require 'ghreleases'
gulp = require 'gulp'
gutil = require 'gulp-util'
moment = require 'moment'

gitHubToken = process.env.GitHubToken
branch = process.env.TRAVIS_BRANCH || 'dev'

auth = {
  token: gitHubToken,
  user: 'henryhuang'
};

org = 'teambebop6'
repo = 'anktours'

module.exports = (callback) ->
  gutil.log 'creating release...'

  timeTag = moment().format("YYYYMMDDHHmmss")
  tag_name = branch + '-build-' + timeTag
  data = {
    tag_name: tag_name,
    name: 'Build at ' + timeTag
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
