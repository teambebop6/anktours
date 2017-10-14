# Galery model
mongoose = require 'mongoose'
helpers = require('./../../lib/helpers')

GalerySchema = new mongoose.Schema(
	_id: String
	date: Date
	location: String
	title: String
	text: String
	images: [
		_id: String
		title: String
		fileName: String
	]
)
# Custom static functions
GalerySchema.statics.findSorted = (conditions, cb) ->
	galery = this.findOne(conditions, (err, galery) ->
		if err then return cb(err, null)
		galery.images = helpers.getSorted(galery.images)
		cb(null, galery)
	)

GalerySchema.pre 'save', (next) ->
	if this.isNew
		this._id = new Buffer((new Date()).getTime()+"anktours").toString('base64')
	next()
	
module.exports = mongoose.model 'Galery', GalerySchema
