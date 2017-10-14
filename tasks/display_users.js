var mongoose = require('mongoose');
var connection = require('../mongodb/connect')
var User = require('../mongodb/user_model');

User.find({},function(err, user){
	if(err) return err;

	user.forEach(function(usr){
		console.log(usr);
	});
})
