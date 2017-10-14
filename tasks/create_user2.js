if (!process.env.NODE_ENV){
	console.log("Please specify environment variable NODE_ENV");
	return;
}

var mongoose = require('mongoose')
var db = require('../.app/db')
var config = require('../.app/config')

config.setEnvironment(process.env.NODE_ENV)
db.connect(config)

var User = require('../.app/models/user')

mongoose.Promise = global.Promise;

if(process.argv[2] && process.argv[3]){
	var user = new User({
		username : process.argv[2],
		password : process.argv[3]
	});

	user.save(function(err, item){
		if(err) throw err;

		console.log("User successfully created!");
	});
}
