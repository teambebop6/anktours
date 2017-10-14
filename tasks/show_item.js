var mongoose = require('mongoose')
var connection = require('../mongodb/connect')
var Trip = require('../mongodb/trip_model')
var Counter = require('../mongodb/counter_model')

// Helper methods
function showItem(id, item) {
	Trip.findOne({_id: id }, function(err, trip){
			if(err) throw err;

			console.log(trip);
			console.log(trip.date_begin.getTime())
			console.log(trip.date_end.getTime())
			
			var days =  Math.ceil(Math.abs(trip.date_end.getTime() - trip.date_begin.getTime()) / (1000 * 3600 * 24));
			console.log(days)
		}
	);
}

connection.on('error', console.error.bind(console, 'connection error:'));
connection.once('open', function() {

	showItem(process.argv[2]);
});
