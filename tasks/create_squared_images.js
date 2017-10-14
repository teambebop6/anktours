if (!process.env.NODE_ENV){
	console.log("Please specify environment variable NODE_ENV");
	return;
}

var gulp = require('gulp');
var path = require('path');
var gm = require('gm').subClass({imageMagick: true});

var createSquare = function(filesrc){
	var dirname = path.dirname(filesrc);
	var filename = path.basename(filesrc);

	gm(filesrc)
		.resize('700','700','^') // ^ designates minimum height
		.gravity('Center')
		.crop('700', '700')
		.write(path.join(dirname, '/squared', filename), function(err){
			if(err) { console.log(err); return; }
			console.log("Thumbnail successfully generated!");
		});
	}

var mongoose = require('mongoose')
var db = require('../.app/db')
var config = require('../.app/config')

config.setEnvironment(process.env.NODE_ENV)
db.connect(config)

var Trip = require('../.app/models/trip')

Trip.find({}, function(err, trips){
	trips.forEach(function(trip){
		trip.images.forEach(function(image){
			createSquare(__dirname+'/../public/images/trip/'+ image.src);
		});
	});
});

