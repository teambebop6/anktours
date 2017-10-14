var mongoose = require('mongoose')
var connection = require('../mongodb/connect')
var Trip = require('../mongodb/trip_model')
var Counter = require('../mongodb/counter_model')

// Helper methods
function updateItem(id, item) {
	Trip.findOne({_id: id }, function(err, trip){
			if(err) throw err;

			// update item
			for(var property in item){
				trip[property] = item[property];
			}

			trip.save(function(err){
				if(err) console.log("Yiikes! There was an error!")
				else{
					console.log("Updated item: " + trip)
				}
			})

		}
	);
}

connection.on('error', console.error.bind(console, 'connection error:'));
connection.once('open', function() {

	updateItem(32, {
		tags: ['See', 'Tagesfahrt', 'Familienausflug', 'Sport']
	});
});
