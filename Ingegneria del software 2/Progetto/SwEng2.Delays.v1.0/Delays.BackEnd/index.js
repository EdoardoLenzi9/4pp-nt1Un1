var debug = require('debug')('expressdebug:server')

/* Express */
var express = require('express');
var app = express();

/* Cors */
const cors = require('cors');
app.use(cors());
app.options('*', cors());

/* Static Declarations */
var port = process.env.PORT || 3000;


/* Init router */
var authenticationMiddleware = require(__dirname + '/Middlewares/authenticationMiddleware.js');
var parameterValidationMiddleware = require(__dirname + '/Middlewares/parameterValidationMiddleware.js');
var routes = require(__dirname + '/Routing/routes.js');
var endPoints = require(__dirname + '/Routing/endPoints.js');

/* Middelwares */
app.use("/", authenticationMiddleware.router);
app.use("/", parameterValidationMiddleware.router);
app.use("/", endPoints.router);
app.use("/", routes.router);

app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

/* Port Declaration */

//app.listen(process.env.PORT || 80); //for Heroku
app.listen(port, function(){
    console.log("server running at https://localhost:3000/")
});
