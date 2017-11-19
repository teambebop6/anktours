express = require('express')
router = express.Router()
path = require('path')
fs = require('fs')
pug = require('pug')
helpers = require('../../../lib/helpers')

mongoose = require('mongoose')
Galery = require '../../models/galery'

view_root = 'admin/galeries/'

# List galeries
router.get '/', (req, res, next) ->
  Galery.find {}, (err, galeries) ->
    if err then return next(err)

    res.render view_root + 'index',
      page_script: 'js/admin/galeries'
      page_styles: []
      active: { galeries: true }
      galeries: galeries
      title: "Galerien"
      _: helpers

router.get '/new', (req, res, next) ->
  res.render view_root + 'new',
    page_script: 'js/admin/galeries'
    title: 'Neue Galerie erstellen'
    active: { galeries: true }
    galery: new Galery()
    _: helpers

router.post '/new', (req, res, next) ->
# Create new galery
  galery = new Galery(req.body.galery)

  galery.save (err) ->
    if err then return next(err)

    res.redirect './modify/' + galery._id

router.get '/modify/:id([a-zA-Z0-9]+)', (req, res, next) ->
  Galery.findOne { _id: req.params.id }, (err, galery) ->
    if err then return next(err)
    if not galery then return next({ status: 404 })

    res.render view_root + 'modify',
      galery: galery
      page_script: 'js/admin/galeries'
      active: { galeries: true }
      _: helpers

router.post '/modify', (req, res, next) ->
  Galery.findOne { _id: req.body.galery_id }, (err, galery) ->
# Update basic data
    if req.body.info
      galery.title = req.body.info.title
      galery.date = req.body.info.date
      galery.location = req.body.info.location

    # Update image data
    if req.body.images && req.body.images.data
      images_data = req.body.images.data
      images_data.forEach (field) ->
        matches = field.name.match(/\[(.*?)\]/)
        if matches
          image = (galery.images.filter (image) -> return image._id == matches[1])[0]
          if image
            image.title = field.value

    # Add sort params
    galery.images.forEach (image, index, images) ->
      images[index].sort = (req.body.images.sort.indexOf(image.src) + 1) || 1

    galery.save (err) ->
      if err then return next(err)

      return res.json({ status: 200 })

router.post '/deleteImage', (req, res, next) ->
  id = req.body.id
  filename = req.body.filename

  if !id or !filename then return res.json({ status: 400 })

  Galery.findOne { _id: id }, (err, galery) ->
    if err then return res.json(err)
    if !galery then return res.json({ status: 400, message: "Galery not found!" })

    # Delete from images array
    i = galery.images.length - 1
    while i >= 0
      if galery.images[i]._id == filename
        image = galery.images[i]
        galery.images.splice i, 1
      i--


    files = [
      path.join(req.config.IMAGE_UPLOAD_FOLDER, req.config.GALLERIES_FOLDER, image.fileName),
      path.join(req.config.IMAGE_UPLOAD_FOLDER, req.config.GALLERIES_FOLDER, 'thumbs', image.fileName)
    ]

    succeeds = 0
    removeFilesMessage = ''
    files.forEach (file) ->
      fs.open file, 'r', (err) ->
        if err
          removeFilesMessage += err + '\n\u000d'
        else
          fs.unlink file, (err) ->
            if err
              removeFilesMessage += err + '\n\u000d'

    galery.save (err) ->
      if err then return res.json(err)
      res.json({ status: 200, message: removeFilesMessage })

router.post '/delete', (req, res, next) ->
  Galery.findOne { _id: req.body.id }, (err, galery) ->
    if err then return next(err)
    if !galery then return next({ status: 400, message: "Galery not found!" })

    galery.remove (err) ->
      if err then return next(err)

      # Delete associated images
      deletion_error = false
      if galery.images
        galery.images.forEach (image) ->
          [
            path.join(req.config.IMAGE_UPLOAD_FOLDER, req.config.GALLERIES_FOLDER)
          ].forEach (img_dir) ->
            delete_path = path.join(img_dir, image.fileName)
            fs.unlink delete_path, (err) ->
              if err then deletion_error = true

      if deletion_error
        res.json({
          status: 200
          message: "Galert deleted! But, there were deletion errors with associated images."
        })
      else
        res.json(status: 200)

router.post '/renderThumbView', (req, res, next) ->
  image = req.body.image
  if image && image.id
    image._id = image.id

  return res.render view_root + 'thumb_view',
    image: image

module.exports = router
