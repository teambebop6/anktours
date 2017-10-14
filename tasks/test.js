var date_end = new Date(2016,3,3);
var date_begin = new Date(2016,3,1);

var days =  Math.ceil(Math.abs(date_end.getTime() - date_begin.getTime()) / (1000 * 3600 * 24));
console.log(days)

