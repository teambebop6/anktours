var mongoose = require('mongoose')
var connection = require('../mongodb/connect')
var User = require('../mongodb/user_model')
var Counter = require('../mongodb/counter_model')

username = process.argv[2]
password = process.argv[3]

Counter.findOne({_id: 'user'}, function(err, counter){
	if(err) return err;

	// Check if seq already set
	if(!counter){
		counter = new Counter({
			_id : "user",
			seq : 0
		});
	} 

	// Increase +1
	counter.seq++;

	counter.save(function(err){

		if(err) return err;

		var user = new User({
			_id : counter.seq,
			username : username, 
			password: password
		});

		user.save(function(err, item){
			if(err) return err;

			console.log("User successfully created!");
		});
	});
	
})

