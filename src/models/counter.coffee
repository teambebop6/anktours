mongoose = require('mongoose')
Schema = mongoose.Schema
counter = new Schema(
  _id: String
  seq: Number)
Counter = mongoose.model('Counter', counter, 'counters')
module.exports = Counter
