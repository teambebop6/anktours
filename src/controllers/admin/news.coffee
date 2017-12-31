express = require('express')
router = express.Router()
path = require 'path'
fs = require 'fs'
News = require '../../models/news'
helpers = require('../../../lib/helpers')
upload = require('../../../lib/upload')('news')

getNewsFolder = (req) ->
  return path.join(req.config.IMAGE_UPLOAD_FOLDER, req.config.NEWS_FOLDER)

router.get '/', (req, res) ->
  News.find({}).sort(active: 'desc', creationDate: 'desc').exec (err, newses) ->
    if err then return next(err)
    return res.render 'admin/news/index',
      page_script: 'js/admin/news'
      active: {news: true}
      newses: newses
      title: "Nachrichten"
      _: helpers

initOrFindNews = (news_id) ->
  return new Promise((resolve, reject) ->
    if (news_id)
      News.findOne {_id: news_id}, (error, news) ->
        if (error)
          reject error
        resolve news
    else
      news = new News()
      resolve news
  )

router.get ['/new_or_update/?:news_id', '/new_or_update/'], (req, res, next) ->
# TODO
  initOrFindNews(req.params.news_id).then((news) ->
    console.log(news)
    return res.render 'admin/news/new',
      page_script: 'js/admin/news'
      active: {news: true}
      news: news
      isNew: !req.params.news_id
      title: "Nachrichten"
  ).catch((error) ->
    return next error
  )

addImagesOrFilesToNews = (news, files, baseFolder, callback) ->
  itemsProcessed = 0

  console.log(files)
  if !files || files.length == 0
    return callback(null, news)

  files.forEach (file, index, array) ->
    newFilePath = path.join(baseFolder, file.filename)
    # Be sure the directory is created if not exists
    try
      fs.mkdirSync path.dirname(newFilePath)
    catch e
      if e.code != 'EEXIST'
        throw e
    # Move file to news folder
    fs.rename file.path, newFilePath, (err) ->
      if err
        return callback(err)

      news.attachments[itemsProcessed].link = file.filename
      console.log 'File successfully added!'
      # Compress and resize image
      itemsProcessed++
      console.log 'Items processed: ' + itemsProcessed
      if itemsProcessed == array.length
        news.save (err) ->
          if err
            return callback(err)

          callback(null, news)
      return
    return
  return

insertOrUpdate = (req, res, next) ->
  console.log(req.body)
  data = {
    title: req.body.news.title,
    content: req.body.news.content,
    attachments: []
  }

  ## only update attachments if new
  if (!req.body.news._id && req.body.attachment_titles)
    if (req.body.attachment_titles instanceof Array)
      req.body.attachment_titles.forEach((title) ->
        data.attachments.push({
          title: title
        })
      )
    else
      data.attachments.push({
        title: req.body.attachment_titles
      })

  if req.body.news._id
    data._id = req.body.news._id
    News.findOne {_id: req.body.news._id}, (err, old) ->
      if err
        return next err
      data.attachments = old.attachments
      News.update {_id: req.body.news._id}, data, (err) ->
        if err then return next(err)
        return res.redirect '/admin/news'
  else
    news = new News data
    news.save (err) ->
      if err then return next(err)
      # Add images
      addImagesOrFilesToNews news, req.files, getNewsFolder(req), (err, news) ->
#        console.log req.body.sort
#        # Add sort params
#        trip.images.forEach (image, index, images) ->
#          images[index].sort = (req.body.sort.split(',').indexOf(image.src) + 1) || 1
#
#        trip.save (err) ->
#          if err then return err
#
#          res.json({ success: true })
        if err
          return next err
        return res.redirect '/admin/news'
      return

# create or update news
router.post '/', upload.array('attachment_files', 10), (req, res, next) ->
  return insertOrUpdate req, res, next

router.post '/active', (req, res) ->
  active = req.body.active
  id = req.body.id

  console.log(active, id)
  News.update({_id: id}, {active: active}, (err) ->
    success = true
    if err
      res.status(500).send(err.message)
    else
      res.status(200).send('updated')
    return
  )

router.get '/attachment/new/:index', (req, res) ->
  res.render 'admin/news/partials/new_attachment',
    index: req.params.index || 0
    isNew: true

router.post '/delete', (req, res) ->
  News.findOne {_id: req.body.id}, (err, news) ->
    if err or !news
      res.status(500).send('Error finding trip.')
      return
    news.remove (err) ->
      if err
        res.status(500).send('Error removing trip.')
        return
      # Delete associated files
      deletion_error = false
      newsImageBaseFolder = getNewsFolder(req)
      if news.attachments
        news.attachments.forEach (attach) ->
          [
            newsImageBaseFolder
          ].forEach (img_dir) ->
            try
              delete_path = path.join(img_dir, attach.link)
              console.log "Delete path is: " + delete_path
              fs.unlink delete_path, (err) ->
                if err
                  deletion_error = true
                return
            catch err
              console.log err
          return
      if deletion_error
        res.status(200).send('There were deletion errors with associated images.')
      else
        res.status(200).send('Success!')
      return
    return
  return

module.exports = router
