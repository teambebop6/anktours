'use strict';
var striptags = require('striptags');

// Constants
var monthNames = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"];
var dayNames = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"];

var monthNamesShort = [];
monthNames.forEach(function(name){
	monthNamesShort.push(name.substring(0,3));
});
var dayNamesShort = [];
dayNames.forEach(function(name){
	dayNamesShort.push(name.substring(0,3));
});


var contains = function(array, string){
	console.log(array);
	console.log(string);
	
	if(!array){ return false; }
	if(array.indexOf(string) > -1){ return true; }

	return false;
}
exports.getSorted = function(arr){
	return arr.sort(function(m1, m2){ 
		if(m1.sort && m2.sort)
			return m1.sort - m2.sort; 

		return 1
	});
}

exports.contains = contains;

// Helpers
var concatArray = function(array1, array2){
	var newArray = [].concat(array1);
	
	for(var i=0; i<array2.length; i++){
	
		if(newArray.indexOf(array2[i]) < 0){
			newArray.push(array2[i]);
		}
	}

	return newArray;
}

exports.concatArray = concatArray;

var convertToCHF = function(price){
	if(!price) return '';

	return (parseFloat(price) / 100).toFixed(0);
}
exports.convertToCHF = convertToCHF;

exports.formatPrice = function(price){
	return '<span class="currency">CHF</span> ' + convertToCHF(price) + '.-';
}

exports.formatDate = function(date){
	if(!date){
		return "";
	}
	
	return date.getDate() + "." + (date.getMonth()+1) + "." + date.getFullYear();
}

exports.formatDateSpan = function(dateBegin, dateEnd){
	if(!dateBegin || !dateEnd) return "";

	if(dateBegin.getYear() == dateEnd.getYear() &&
			dateBegin.getMonth() == dateEnd.getMonth() &&
			dateBegin.getDate() == dateEnd.getDate()){
		// One day trip
		return dateBegin.getDate() + ". " + monthNames[dateBegin.getMonth()] + " " + dateBegin.getFullYear();
	}

	if(dateBegin.getYear() == dateEnd.getYear()){
		// Multi day, same year	
		if(dateBegin.getMonth() == dateEnd.getMonth()){
			// Within same month
			return dateBegin.getDate() + ". - " + dateEnd.getDate() + ". " + monthNames[dateBegin.getMonth()] + " " + dateBegin.getFullYear();
		}

		// same year but not within same month
		return dateBegin.getDate() + ". " + monthNames[dateBegin.getMonth()] + " - " + dateEnd.getDate() + ". " + monthNames[dateEnd.getMonth()] + " " + dateEnd.getFullYear();
	}else{
		// Multi day, not within same year
		return dateBegin.getDate() + ". " + monthNames[dateBegin.getMonth()] + " " + dateBegin.getFullYear() + " - " + dateEnd.getDate() + ". " + monthNames[dateEnd.getMonth()] + " " + dateEnd.getFullYear();
		
	}
}

exports.formatFullDateString = function(date){
	if(!date){ return ""; }
	
	return dayNames[date.getDay()] + ", " + date.getDate() + ". " + monthNames[date.getMonth()] + " " + date.getFullYear();
}

exports.formatDateString = function(date){
	if(!date){ return ""; }

	return dayNames[date.getDay()] + " " + date.getDate() + " " + monthNamesShort[date.getMonth()] + " " + date.getFullYear();
}

exports.isMultiDay = function(trip){
	if(!trip.date_begin || !trip.date_end){ return ""; }
	
	return (trip.date_begin.toDateString() != trip.date_end.toDateString())
}

var getDays = function(trip){
	if(!trip.date_begin || !trip.date_end){ return ""; }
	
	var days = 1 + Math.ceil(Math.abs(trip.date_end.getTime() - trip.date_begin.getTime()) / (1000 * 3600 * 24));
	return days;
}

exports.days_duration_string = function(trip){
	var days = getDays(trip)
	return days > 1 ? days + " Tage" : days + " Tag";
}
exports.days_duration = function(trip){
	return getDays(trip)
}

exports.yell = function (msg) {
    return msg.toUpperCase();
    };

exports.limitToNChars = function(N, string){

	var str = striptags(string.replace(/</g, ' <')).replace(/\s\s+/, ' ');
	
	if(str.length > 200){
		return str.substring(0, N) + "...";
	}

	return str;
}
