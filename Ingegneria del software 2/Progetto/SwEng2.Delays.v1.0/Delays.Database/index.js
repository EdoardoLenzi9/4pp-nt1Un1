const express = require('express');
const bodyParser = require('body-parser');
const tt_rest=require('./trentino_trasporti/gtfs_rest');
const delay_rest=require('./delays/delay_rest');

var port = process.env.PORT || 8080;

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// middleware route to support CORS and preflighted requests
app.use(function (req, res, next) {
    //Enabling CORS
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    res.header('Content-Type', 'application/json');
    if (req.method == 'OPTIONS') {
        res.header('Access-Control-Allow-Methods', 'PUT, POST, DELETE');
        return res.status(200).json({});
    }
    // make sure we go to the next routes
    next();
});

//Adding application for trentino_trasporti urban data
app.use('/api/v1/trento/', tt_rest);
app.use('/api/v1/trento/delay/', delay_rest);

// handle invalid requests and internal error
app.use((req, res, next) => {
    const err = new Error('Not Found');
    err.status = 404;
    next(err);
});

app.use((err, req, res, next) => {
    res.status(err.status || 500);
    res.json({ error: { message: err.message } });
});

app.listen(port);
console.log('Server running ' + port);
