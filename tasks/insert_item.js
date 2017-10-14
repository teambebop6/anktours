var mongoose = require('mongoose')
var connection = require('../mongodb/connect')
var Trip = require('../mongodb/trip_model')
var Counter = require('../mongodb/counter_model')

// Helper methods
function insertItem() {
	Counter.findOneAndUpdate({_id: 'trip' }, {$inc : { "seq": 1 } },{},function(err, counter){
			if(err) throw err;
			console.log(counter.seq)

			// insert new item
			var trip = new Trip({
				_id: counter.seq,
				type: "day-trip",
				title: "Tagesausflug zum Hallwilersee",
				description: "<p>Zuerst machen wir dies und dann das und zuletz noch das.</p> <strong>Liste zum mitnehmen: </strong><ul><li>Erstens</li><li>Zweitens</li><li>Drittens</li></ul>",
				date_begin: new Date(),
				date_end: new Date()
			});
			
			trip.save(function(err){
				if(err) console.log("Yiikes! There was an error!")
				else{
					console.log("Item inserted: " + trip)
				}
			})

		}
	);
}

connection.on('error', console.error.bind(console, 'connection error:'));
connection.once('open', function() {

	insertItem();
});
