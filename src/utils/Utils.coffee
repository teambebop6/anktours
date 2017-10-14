path = require('path')
fs = require('fs')

module.exports.ensureDirExists = (path, mask, cb) ->
	if typeof mask == 'function' # allow the `mask` parameter to be optional
		cb = mask
		mask = 0o0777
	
	fs.mkdir path, mask, (err) ->
		if err
			if (err.code == 'EEXIST')
				cb(null) # ignore the error if the folder already exists
			else
				cb(err) # something else went wrong
		else
			cb(null) # successfully created folder

exports.getBase64Name = (name) ->
	fileName = name.substring(0, name.lastIndexOf("."))
	format = name.substring(name.lastIndexOf(".") + 1, name.length)
	return new Buffer(fileName).toString('base64') + '.' + format
