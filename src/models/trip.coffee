mongoose = require('mongoose')
helpers = require('./../../lib/helpers')

tripSchema = new (mongoose.Schema)({
	_id: Number
	type: String
	title: String
	price: Number
	single_room: Number
	services: String
	description: String
	date_begin: Date
	date_end: Date
	isSoldOut:
		type: Boolean
		default: false
	images: [
		src: String
		sort: Number
	]
	tags: [ String ]
}, collection: 'Trips')

# Custom static functions
tripSchema.statics.findSorted = (conditions, cb) ->
	trip = this.findOne(conditions, (err, trip) ->
		if err then return cb(err, null)
		trip.images = helpers.getSorted(trip.images)
		cb(null, trip)
	)

module.exports = mongoose.model('trip_model', tripSchema)
