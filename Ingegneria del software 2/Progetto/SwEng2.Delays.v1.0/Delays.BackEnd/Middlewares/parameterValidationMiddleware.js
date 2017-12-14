var express = require('express');
var router = express.Router();
var serviceUtils = require('../Services/ServiceUtils.js');

router.use(function (req, res, next) {
  //console.log("middleware2" + req.validateToken);
  next();
});

router.use("/getLines", function(req, res1, next) {
  serviceUtils.getRoutes(function(res)
  {
    req.routes = res.body;
    //req.routes = res;
    next();
  })
});

router.use("/getDirections/routeId/:routeId", function (req, res, next) {
  serviceUtils.getDirections(req.params.routeId, function(res)
  {
    req.directions = res.body;
    next();
  })
});

router.use("/getStop/stop/:stopId", function (req, res, next) {
  serviceUtils.getStopName(req.params.stopId, function(res)
  {
    req.stop = res.body;
    next();
  })
});

router.use("/getStops/routeId/:routeId/direction/:direction", function(req, res1, next) { //TODO validate params
  serviceUtils.getStops(req.params.routeId, req.params.direction, function(res)
  {
    req.stops = res.body;
    next();
  })
});

router.use("/getTimetables/routeId/:routeId/direction/:direction/stopId/:stopId", function(req, res1, next) { //TODO validate params
  serviceUtils.getTimetables(req.params.routeId, req.params.direction, req.params.stopId, function(res)
  {
    req.timetables = res.body;
    next();
  })
});

router.use("/getDelay/tripId/:tripId", function(req, res1, next) { //TODO validate params
  serviceUtils.getDelay(req.params.tripId, function(res)
  {
    req.delay = res.body;
    next();
  })
});

router.use("/postReport/stopId/:stopId/tripId/:tripId/stopTime/:stopTime/report/:report", function(req, res1, next) {
  serviceUtils.postReport(req.params.stopId, req.params.tripId, req.params.stopTime, req.params.report, function(res)
  {
    next();
  })
});

module.exports = {
  router
}
