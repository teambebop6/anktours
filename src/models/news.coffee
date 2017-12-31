mongoose = require('mongoose')
autoIncrement = require('mongoose-auto-increment')
autoIncrement.initialize(mongoose.connection);

Attachment = new (mongoose.Schema) (
  title: String,
  link: String,
)

News = new (mongoose.Schema)(
  _id: Number,
  title: String,
  content: String,
  active: {
    type: Boolean,
    default: true,
  },
  attachments: [Attachment],
  creationDate: {
    type: Date,
    'default': Date.now,
  },
  lastModifiedDate: {
    type: Date,
    'default': Date.now,
  },
)

News.plugin(autoIncrement.plugin, 'News');

module.exports = mongoose.model('News', News)
