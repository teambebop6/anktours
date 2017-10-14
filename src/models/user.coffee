mongoose = require('mongoose')
easyPbkdf2 = require('easy-pbkdf2')()

User = new (mongoose.Schema)(
  username: String
  salt: String
  password: String)

# Override save method
User.pre 'save', (next) ->
	user = this
	# only hash the password if it has been modified (or is new)
	if !user.isModified('password')
		return next()

	salt = easyPbkdf2.generateSalt()
	easyPbkdf2.secureHash user.password, salt, (err, hash, originalSalt ) ->
		user.password = hash
		user.salt = originalSalt
		next()

module.exports = mongoose.model('User', User)
