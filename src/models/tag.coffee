mongoose = require('mongoose')

Tag = new (mongoose.Schema)(
	name: String,
	value: String
)

module.exports = mongoose.model('Tags', Tag)
