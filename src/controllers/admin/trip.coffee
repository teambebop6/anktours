express       = require('express')
router        = express.Router()
path          = require('path')
fs            = require('fs')
stringify     = require('js-stringify')
utf8          = require('utf8')
Utils         = require('../../utils/Utils')

# Helpers
upload = require('../../../lib/upload')('trip')
helpers = require('../../../lib/helpers')

Counter = require('../../models/counter')
Trip = require('../../models/trip')
Tag = require('../../models/tag')

getTripFolder = (req) ->
  return path.join(req.config.IMAGE_UPLOAD_FOLDER, req.config.TRIP_FOLDER)

router.post '/getTags', (req, res) ->
  Trip.findOne {_id: req.body.tripId}, (err, trip) ->
    if err
      return res.json
        success: false
        err: err
    else
      return res.json
        success: true
        content:
          tags: trip.tags

router.post '/getDescription', (req, res) ->
  Trip.findOne {_id: req.body.tripId}, (err, trip) ->
    if err
      return res.json
        success: false
        err: err
    else
      return res.json
        success: true
        content:
          description: trip.description

router.post '/getServices', (req, res) ->
  Trip.findOne {_id: req.body.tripId}, (err, trip) ->
    if err
      return res.json
        success: false
        err: err
    else
      return res.json
        success: true
        content:
          services: trip.services

router.get '/new', (req, res) ->
  Tag.find({}, (err, tags) ->
    if err then return err
    
    res.render 'admin/new-trip',
      page_script: 'js/admin/new-trip',
      page_styles: [
        'admin/new-trip'
      ],
      stringify: stringify,
      active:
        new: true
      ,
      tags: tags,
      trip: {},
      _: helpers
  )
router.post '/new', upload.array('file', 10), (req, res) ->
  Counter.findOne { _id: 'trip' }, (err, counter) ->
    if err
      res.json
        success: false
        message: err.message
      return
    # Check if seq already set
    if !counter
      counter = new (Counter)(
        _id: 'trip'
        seq: 0)
    counter.seq++
    console.log counter
    counter.save (err) ->
      images = []
      
      trip = new Trip
        _id: counter.seq
        title: req.body.title
        description: req.body.description
        date_begin: new Date(req.body.date_begin)
        date_end: new Date(req.body.date_end)
        services: req.body.services
        tags: req.body.tags.split(',')
        images: images
      
      if req.body.price
        trip.price = parseInt(parseFloat(req.body.price) * 100)
      if req.body.single_room
        trip.single_room = parseInt(parseFloat(req.body.single_room) * 100)

      console.log trip
      trip.save (err) ->
        if err
          res.json
            success: false
            message: err.message
          console.log err
          return
        if req.files.length == 0
          res.json success: true
        else
          # Add images 
          addImagesToTrip trip, req.files, getTripFolder(req), (trip) ->
            res.json({ success: true })
            return
        return
      return
    return
  return

compressTask = path.resolve('tasks/compressAndResize.js')
compressAndResize = (imageUrl) ->
  # We need to spawn a child process so that we do not block 
  # the EventLoop with cpu intensive image manipulation 
  childProcess = require('child_process').fork(compressTask)
  childProcess.on 'message', (message) ->
    console.log message
    return
  childProcess.on 'error', (error) ->
    console.error error.stack
    return
  childProcess.on 'exit', ->
    console.log 'process exited'
    return
  childProcess.send imageUrl
  return

# Add new Images to Trip
addImagesToTrip = (trip, files, baseFolder, callback) ->
  itemsProcessed = 0
  
  if files.length == 0
    return callback(trip)
  
  files.forEach (file, index, array) ->
    newFilePath = path.join(baseFolder, file.filename)
    # Be sure the directory is created if not exists
    try
      fs.mkdirSync path.dirname(newFilePath)
    catch e
      if e.code != 'EEXIST'
        throw e
    # Move file to trip folder 
    fs.rename file.path, newFilePath, (err) ->
      if err
        return callback(
          success: false
          message: err)
      trip.images.push src: file.filename
      console.log 'File successfully added!'
      # Compress and resize image
      compressAndResize newFilePath
      itemsProcessed++
      console.log 'Items processed: ' + itemsProcessed
      if itemsProcessed == array.length
        trip.save (err) ->
          if err
            return callback(
              success: false
              message: err)
          
          callback(trip)
      return
    return
  return

# Delete image of trip
router.post '/deleteImage', (req, res) ->
  id = req.body.id
  filename = req.body.filename
  if !id or !filename
    res.json
      success: false
      message: 'Invalid request received!'
    return

  Trip.findOne { _id: id }, (err, trip) ->
    if err
      res.json
        success: false
        message: err
      return
    if !trip
      res.json
        success: false
        message: 'Trip not found.'
      return
    
    # Delete from images array
    i = trip.images.length - 1
    while i >= 0
      if trip.images[i].src == filename
        console.log 'Deleting ' + filename
        trip.images.splice i, 1
      i--

    imageTripFolder = getTripFolder(req)
    files = [
      path.join(imageTripFolder, filename)
      path.join(imageTripFolder, 'thumbs', filename)
      path.join(imageTripFolder, 'squared', filename)
    ]
    removeFilesMessage = ''
    files.forEach (file) ->
      fs.open file, 'r', (err) ->
        if err
          removeFilesMessage += err + '\n\u000d'
        else
          fs.unlink file, (err) ->
            if err
              removeFilesMessage += err + '\n\u000d'
            return
        return
      return
    trip.save (err) ->
      if err
        res.json
          success: false
          message: err
        return
      res.json
        success: true
        message: 'File successfully deleted. \n\u000d' + removeFilesMessage
      return
    return
  return

router.post '/delete', (req, res) ->
  Trip.findOne { _id: req.body.id }, (err, trip) ->
    if err or !trip
      res.send
        success: false
        message: 'Error finding trip.'
      return
    trip.remove (err) ->
      if err
        res.send
          success: false
          message: 'Error removing trip.'
        return
      # Delete associated images
      deletion_error = false
      tripImageBaseFolder = getTripFolder(req)
      if trip.images
        trip.images.forEach (img) ->
          [
            tripImageBaseFolder
            tripImageBaseFolder + '/thumbs'
            tripImageBaseFolder + '/squared'
          ].forEach (img_dir) ->
            try
              delete_path = path.join(img_dir, img.src)
              console.log "Delete path is: " + delete_path
              fs.unlink delete_path, (err) ->
                if err
                  deletion_error = true
                return
            catch err
              console.log err
          return
      if deletion_error
        res.send
          success: true
          message: 'There were deletion errors with associated images.'
      else
        res.send
          success: true
          message: 'Success!'
      return
    return
  return

router.get '/modify/:id', (req, res) ->
  Trip.findSorted { _id: req.params.id }, (err, trip) ->
    if err then return err

    Tag.find({}, (err, tags) ->
      if err then return err
    
      res.render 'admin/modify-trip',
        trip: trip
        page_script: 'js/admin/modify-trip'
        page_styles: [
          'admin/new-trip'
        ]
        tags: tags
        stringify: stringify
        active: modify: true
        _: helpers
    )

# Save trip
router.post '/save', upload.array('file', 10), (req, res) ->
  Trip.findOne { _id: req.body.id }, (err, trip) ->
    if err
      res.json
        success: false
        message: err
      return
    if !trip
      message = 'Trip not defined'
      res.json
        success: false
        message: message
      return
    
    if req.body.price
      trip.price = parseInt(parseFloat(req.body.price) * 100)
    if req.body.single_room
      trip.single_room = parseInt(parseFloat(req.body.single_room) * 100)
    # Copy properties from form request body
    trip.title = req.body.title
    trip.description = req.body.description
    trip.date_begin = new Date(req.body.date_begin)
    trip.date_end = new Date(req.body.date_end)
    trip.services = req.body.services
    trip.tags = req.body.tags.split(',')
    # Intermediate save trip
    trip.save (err) ->
      if err
        res.json
          success: false
          message: err
        return
      # Process files
      itemsProcessed = 0
      
      # Add images 
      addImagesToTrip trip, req.files, getTripFolder(req), (trip) ->
        console.log req.body.sort
        # Add sort params
        trip.images.forEach (image, index, images) ->
          images[index].sort = (req.body.sort.split(',').indexOf(image.src) + 1) || 1

        trip.save (err) ->
          if err then return err

          res.json({ success: true })
        return
      return
    return
  return

# Manage trip
router.get '/manage', (req, res) ->
  # Fetch trips
  Trip.find {}, (err, trips) ->
    if err
      console.log err
      return
    res.render 'admin/manage-trips',
      trips: trips
      page_script: 'js/admin/manage-trips'
      active: manage: true
      _: helpers

module.exports = router
