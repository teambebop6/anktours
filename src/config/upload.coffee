upload = require('jquery-file-upload-middleware')
utils = require('../utils/Utils')
path = require('path')
mongoose = require('mongoose')

Galery = require('../models/galery')

module.exports.configure = (app) ->
	gm = if app.get('config').USE_IMAGE_MAGICK then require('gm').subClass({imageMagick: true}) else require('gm')
	
	uploadDir = __dirname + '/../../public/images/galeries'
	console.log 'Upload directory is: ', uploadDir

	upload.configure
		uploadDir: uploadDir
		uploadUrl: '/uploads'
		imageTypes: /\.(gif|jpe?g|png)$/i

	# prevent access to /upload
	app.get '/uploads', (req, res) ->
		res.redirect('/')
	app.put '/uploads', (req, res) ->
		res.redirect('/')
	app.delete '/uploads', (req, res) ->
		res.redirect('/')

	upload.on 'begin', (fileInfo, req, res) ->
		fileInfo.name = utils.getBase64Name((new Date()).getTime() + fileInfo.name)
		fileInfo.id = path.basename(fileInfo.name, path.extname(fileInfo.name))

	upload.on 'end', (fileInfo, req, res) ->
		galery_id = req.fields.galery_id

		Galery.findOne {_id: req.fields.galery_id}, (err, galery) ->
			if err then return err

			galery.images.push({
				_id: fileInfo.id,
				title: fileInfo.name,
				fileName: fileInfo.name
			})

			galery.save (err) ->
				if err then return err
				
				filesrc = path.join(uploadDir, fileInfo.name)

				# Resize
				gm(filesrc)
					.resize('700','700','^') # The '^' argument on the resize function will tell GraphicsMagick to use the height and width as a minimum instead of the default behavior, maximum.
					.write(filesrc, (err) ->
						if err then return console.log(err)

						# create thumbs
						thumbsDir = path.join(uploadDir, 'thumbs/')
						utils.ensureDirExists thumbsDir, (err) ->
							if err then return err

							gm(filesrc)
								.resize('150', '150')
								.write(path.join(thumbsDir, fileInfo.name), (err) ->
									if err then return console.log(err)
								)
					)


	uploadFunc = (req, res, next) ->
		return upload.fileHandler({
			uploadDir: () ->
				return uploadDir
		})(req, res, next)

	app.use '/uploads', uploadFunc
