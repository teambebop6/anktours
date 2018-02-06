express = require('express')
app = express()
router = express.Router()
mime = require('mime')
path = require('path')
fs = require('fs')
passport = require('passport')

Tag = require('../../models/tag')

helpers = require('../../../lib/helpers')

router.all '/*', (req, res, next) ->
# Check if user is logged in
  if !req.user
    res.redirect '/login'
    return
  req.app.locals.layout = 'admin'
  req.app.locals.admin_path = '/admin'
  next()
  # pass control to the next handler
  return

# Subroutes
router.use '/trip', require('./trip')
router.use '/galeries', require('./galeries')

router.use '/news', require('./news')

router.get '/tags', (req, res, next) ->
  Tag.find({}, (err, tags) ->
    if err then return err

    res.render 'admin/tags',
      title: "Manage tags",
      tags: tags
      active:
        tags: true
      page_script: 'js/admin/tags'
  )

router.post '/tags/delete', (req, res, next) ->
  console.log req.body.value

  if !req.body.value
    return res.json({
      status: 400,
      message: "Name is missing."
    })

  Tag.findOne('value': req.body.value, (err, tag) ->
    if err then return err
    if !tag
      return res.json(
        status: 400,
        message: "No tag found."
      )

    tag.remove (err) ->
      if err then return err

      return res.json(
        status: 200,
        message: "Successfully deleted task."
      )
  )

router.post '/tags/add', (req, res, next) ->
  if !req.body.name
    return res.json({
      status: 400,
      message: "Kein name angegeben"
    })

  tag = new Tag(
    name: req.body.name,
    value: req.body.name.toLowerCase().replace(/\s+/g, '')
  )

  tag.save (err) ->
    if err then return err

    res.redirect('/admin/tags')

router.get '/settings', (req, res, next) ->
  res.render 'admin/settings',
    title: 'Settings'
    active:
      settings: true

router.get '/logout', (req, res) ->
  req.logout()
  res.redirect '/'

router.get '/', (req, res) ->
  res.redirect '/admin/trip/manage'

module.exports = router
