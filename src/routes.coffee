express = require('express')
router = express.Router()
path = require 'path'

# Load controller and plugin to app
getRoute = (name) ->
  route = null
  try
    route = require("./controllers/" + name)
  catch e
    console.warn "route not found: " + name, e
    route = router # bypass
  route

# Redirect to login
checkAuth = (req, res, next) ->
  unless req.user
    res.redirect '/login'
  else
    next()

module.exports = (config) ->
# Static folders
  router.use '/assets/vendor/jquery', express.static('bower_components/jquery/dist')
  router.use '/assets/vendor/jquery-validation', express.static('bower_components/jquery-validation/dist')
  router.use '/assets/vendor/slick', express.static('node_modules/slick-carousel/slick/')
  router.use '/assets', express.static('.app/assets')
  router.use '/assets', express.static('public')
  router.use '/assets/js', express.static('vendor/jQuery-File-Upload/js')
  router.use '/assets/images/trip', express.static(path.join(config.IMAGE_UPLOAD_FOLDER, config.TRIP_FOLDER))
  router.use '/assets/images/galeries', express.static(path.join(config.IMAGE_UPLOAD_FOLDER, config.GALLERIES_FOLDER))
  router.use '/assets/files/newses', express.static(path.join(config.IMAGE_UPLOAD_FOLDER, config.NEWS_FOLDER))

  router.use '/', getRoute('index')
  router.use '/admin', checkAuth, getRoute('admin/')


  # If all else failed, show 404 page
  router.all '/*', (req, res) ->
    res.statusCode = 404
    res.render 'errors/404',
      title: 'Page Not Found'

  return router
