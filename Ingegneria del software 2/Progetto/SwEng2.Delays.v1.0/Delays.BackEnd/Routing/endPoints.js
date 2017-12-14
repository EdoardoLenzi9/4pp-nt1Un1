var express = require('express');
var router = express.Router();
var serviceUtils = require('../Services/ServiceUtils.js');

/* End Points */
router.get("/getLines", function(req, res1) {
    res1.send(req.routes);
});

router.get("/getDirections/routeId/:routeId", function(req, res1) {
  res1.send(req.directions);
});

router.get("/getStop/stop/:stopId", function(req, res1) {
  res1.send(req.stop);
});       

router.get("/getStops/routeId/:routeId/direction/:direction", function(req, res1) {
  res1.send(req.stops);
});

router.get("/getTimetables/routeId/:routeId/direction/:direction/stopId/:stopId", function(req, res1) {
  res1.send(req.timetables);
});

router.get("/getDelay/tripId/:tripId", function(req, res1) {
  res1.send(req.delay);
});

router.post("/postReport/stopId/:stopId/tripId/:tripId/stopTime/:stopTime/report/:report", function(req, res1) {
});

module.exports = {
    router
}


