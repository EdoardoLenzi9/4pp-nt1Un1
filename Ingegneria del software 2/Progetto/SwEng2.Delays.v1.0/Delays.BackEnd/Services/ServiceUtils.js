var request = require('request');
var http = require('https');
//var baseUrl = "https://blooming-citadel-47981.herokuapp.com";
// var baseUrl = "http://localhost:8080";
//var baseUrl = "http://delays_database:8080" //deploy
var baseUrl = "http://andreagilardoni.com:8080"
// var baseUrl = "http://51.15.82.147:8080"

var getRoutes = function (callback) {
    //callback(routes);
    request.get(baseUrl + '/api/v1/trento/routes', function (err, res) {
        callback(res);
    });
};

var getDirections = function (routeId, callback) {
    request.get(baseUrl + '/api/v1/trento/routes/' + routeId + '/reference', function (err, res) {
        callback(res);
    });
};

var getStopName = function (stopId, callback){
    request.get(baseUrl + '/api/v1/trento/stops/' + stopId, function(err,res){
        callback(res);
    });
};

var getStops = function (routeId, direction, callback) {
    request.get(baseUrl + '/api/v1/trento/routes/' + routeId + '/stops?direction_id=' + direction, function (err, res) {
        callback(res);
    });
};

var getTimetables = function (routeId, direction, stopId, callback) {
    request.get(baseUrl + '/api/v1/trento/routes/' + routeId + '/stops/' + stopId + '/times?direction_id=' + direction, function (err, res) {
        callback(res);
    });
};

var getDelay = function (tripId, callback) {
    var a = baseUrl + '/api/v1/trento/delay/trips/' + tripId;
    request.get(baseUrl + '/api/v1/trento/delay/trips/' + tripId, function (err, res) {
        callback(res);
    });
};

var postReport = function(stopId, tripId, stopTime, report, callback){
    request.post(baseUrl + '/api/v1/trento/delay/add/trips/' + tripId + '/stops/' + stopId + '?stoptime=' + stopTime + '&report=' + report, function(err,res){
      callback(true);
    });
}

module.exports = {
    getRoutes,
    getDirections,
    getStopName,
    getStops,
    getTimetables,
    getDelay,
    postReport,
};
