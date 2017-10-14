mongoose		= require 'mongoose'

exports.connect = (config) ->
	if config.DB_USER && config.DB_PASS
		auth =
			user: config.DB_USER
			pass: config.DB_PASS

	if auth?
		db_string = 'mongodb://' + config.DB_USER + ':' + config.DB_PASS + '@' + config.DB_HOST + ":" + config.DB_PORT + "/" + config.DB_NAME
	else
		db_string = 'mongodb://' + config.DB_HOST + ":" + config.DB_PORT + "/" + config.DB_NAME

	db = mongoose.connect db_string
	
	db.connection.on 'error', (err) ->
		console.log "Failed to connect to database"
		console.log err
		process.exit
	
	mongoose.Promise = global.Promise
