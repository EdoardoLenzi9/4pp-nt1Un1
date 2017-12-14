var express = require('express');
var router = express.Router();

var bodyParser = require('body-parser')
router.use( bodyParser.json() );       // to support JSON-encoded bodies
router.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
}));


router.use(function (req, res, next) {
  console.log("middleware1");
  //req.validateToken = 12345; //TODO dopo aver validato il token/cookie/id passamelo al secondo middleware
  next();
});

router.post("/loginResponse", function(req, res1) {
  console.log(req.body.id_token)
});

module.exports = {
    router
}