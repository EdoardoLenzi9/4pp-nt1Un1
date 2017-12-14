var express = require('express');
var router = express.Router();

/* Paths */
var baseFrontEndPath = __dirname.replace('Delays.BackEnd/Routing','Delays.BackEnd');
//var baseFrontEndPath = "/usr/src/app"; //deploy
var nodeModulesPath = baseFrontEndPath + '/node_modules';
var sourcesPath = baseFrontEndPath + '/src';

console.log(baseFrontEndPath);

router.use(express.static(baseFrontEndPath + 'public'));
router.use('/node_modules', express.static(nodeModulesPath));
router.use('/src', express.static(sourcesPath));

/* Ruotes */

router.get("/",function(req,res){
  res.redirect('/login');
});

router.get("/login",function(req,res){
  res.render(sourcesPath + "/login/login.html");
});

router.get("/busLines",function(req,res){
  res.render(sourcesPath + "/bus-lines/busLines.html");
});

router.get("/busLines/routeId/:routeId/direction", function (req, res) {
  res.render(sourcesPath + "/direction-picker/directionpicker.html", {
    routeName: req.query.routeName,
    routeId: req.params.routeId
  });
});

router.get("/busLines/routeId/:routeId/direction/:direction", function (req, res) {
  res.render(sourcesPath + "/stop-picker/stopPicker.html", {
    routeName: req.query.routeName,
    routeId: req.params.routeId,
    direction: req.params.direction
  });
});

router.get("/busLines/routeId/:routeId/direction/:direction/stopId/:stopId", function (req, res) {
  res.render(sourcesPath + "/timetable-picker/timetablePicker.html", {
    routeName: req.query.routeName,
    routeId: req.params.routeId,
    direction: req.params.direction,
    stopId: req.params.stopId,
    stopName: req.query.stopName
  });
});

router.get("/delaysView/routeId/:routeId/direction/:direction/stopId/:stopId/tripId/:tripId/arrivalTime/:arrival_time",function(req,res){
  res.render(sourcesPath + "/delays-view/delays-view.html",{
    routeName: req.query.routeName,
    routeId: req.params.routeId,
    direction: req.params.direction,
    stopName: req.query.stopName,
    stopId: req.params.stopId,
    tripId:req.params.tripId,
    arrivalTime:req.params.arrival_time
  });
});

router.use("*",function(req,res){
    res.render(sourcesPath + "/404/404.html");
});

module.exports = {
    router
}
