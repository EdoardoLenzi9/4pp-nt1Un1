const express = require('express');
const fs = require('fs');
var mongo_utils = require('../utils/mongo');
var gtfs = require('gtfs');
var gtfs_import = require('./gtfs_import')
var mongoose = require('mongoose');
var credentials = require('../credentials.json');

// var delay = require('../delays/delay');
var trip = require('gtfs/models/gtfs/trip');
var stop_time = require('gtfs/models/gtfs/stop-time');
var stop = require('gtfs/models/gtfs/stop');
var route = require('gtfs/models/gtfs/route');

// const wait = require('delay');

mongoose.Promise = global.Promise;
mongoose.connect(
    mongo_utils.extract_url(credentials),
    {useMongoClient: true}
).then(function() {
    console.log("connection successfull");
}).catch(function(error){
    console.log(error);
});

router = express.Router({
    mergeParams: true
});

//TODO consider agency field for handling more agencies at once
router.route('/routes').get(function(req, res) {
    gtfs.getRoutes({}, "route_id route_short_name route_text_color route_color -_id")
    .then(routes => {
        res.json(routes);
    })
});

router.route('/routes/:route_id').get(function(req, res) {
    gtfs.getRoutes({
        route_id: req.params.route_id
    })
    .then(routes => {
        res.json(routes[0]);
    })
});

router.route('/routes/:route_id/trips/').get(function(req, res) {
    //get direction
    var direction_id = req.query.direction_id;
    if(direction_id === undefined){
        direction_id = [1, 0]; // se direzione non passata la ignoro
    }

    trip.
        find({
            route_id: req.params.route_id,
            direction_id: direction_id
        }).
        exec(function(err, trips) {
            try{ error(req, res, err, trips.length);
            } catch(e){return 0;}
            //console.log("1°lvl trips.length: " + trips.length);
            //console.log(trips);
            res.json(trips)
        });
});

router.route('/routes/:route_id/trips/:trip_id/').get(function(req, res) {
    gtfs.getTrips({
        route_id: req.params.route_id,
        trip_id: req.params.trip_id
    })
    .then(trips => {
        res.json(trips[0]);
    });
});

//TODO: consider direction
router.route('/trips').get(function(req, res) {
    gtfs.getTrips({} , "trip_id -_id")
    .then(trips => {
        //TODO filter the informations
        res.json(trips);
    });
});

router.route('/trips/:trip_id').get(function(req, res) {
    gtfs.getTrips({
        trip_id: req.params.trip_id
    })
    .then(trips => {
        res.json(trips[0]);
    });
});

router.route('/trips/:trip_id/stoptimes').get(function(req, res) {
    gtfs.getStoptimes({
        trip_id: req.params.trip_id,
    })
    .then(stops => {
        res.json(stops);
    });
});

router.route('/stops').get(function(req, res) {
    gtfs.getStops({}, "stop_id stop_code stop_name -_id")
    .then(stops => {
        //TODO filter the informations
        res.json(stops);
    });
});

router.route('/stops/:stop_id').get(function(req, res) {
    gtfs.getStops({
        stop_id: req.params.stop_id
    })
    .then(stops => {
        res.json(stops[0]);
    });
});

//forse alla fine questa query non serve
router.route('/routes/:route_id/stops/:stop_id/trips').get(function(req, res) {
    //get all the trips of a specific route which are passing in the stop with stop_id
    //param get: time: arrival time of the bus at the stop, if empty assumed actual time, direction: 0 or 1 is required
    //in both case the time of bus passing is retrive
    //una possibile chiamata è:
    //http://localhost:8080/api/v1/trento/routes/496/stops/2289/trips?time=07:03:50&direction_id=0

    //get direction
    var direction_id = req.query.direction_id;
    if(direction_id === undefined){
        return res.json(JSON.parse(fs.readFileSync('err_missing_parameter.json', 'utf8')));
    }

    //get time
    var time = req.query.time;
    if(time === undefined){
        time = new Date().toLocaleTimeString();
        time += (3600*1000); // aggiungo un ora al datetime segnata in millisecondi questo perchè siamo avanti di un ora rispetto al meridiano di greenwich
        time = time.slice(0, -7);   //tolgo cifre non significative
    }
    time = invert_mod_24(time)

    params = req.params;

    console.log("get trip_id from route_id, stop, direction, time")
    trip.
        find({
            route_id: params.route_id,
            direction_id: direction_id
        }, { '_id': 0, 'trip_id' : 1}).
        exec(function(err, trip_ids) {
            try{ error(req, res, err, trip_ids);
            } catch(e){return 0;}

            // convert from json to array
            trip_ids = trip_ids.map(function(doc) { return doc.trip_id; });
            console.log("1°lvl trip_ids.length: " + trip_ids.length);
            //console.log(trip_ids);
            stop_time.
                find({
                        trip_id: {$in: trip_ids},       //"0002864212017091120180607",
                        arrival_time: {$gte: time},     //"07:03:50 gte=greater than or equal
                        stop_id: params.stop_id         //2289
                    }, { '_id': 0, 'trip_id' : 1, 'arrival_time': 1}).
                sort('arrival_time').  //NB: il sort funziona anche se non seleziono quel parametro
                exec(function(err, second_trip_ids) {
                    console.log("2°lvl second_trip_ids length: " + second_trip_ids.length + "\n");
                    if(second_trip_ids==0){
                        stop_time.
                            find({
                                    trip_id: {$in: trip_ids},       //"0002864212017091120180607"
                                    stop_id: params.stop_id         //2289
                                }, { '_id': 0, 'trip_id' : 1, 'arrival_time': 1}).
                            sort('arrival_time').  //NB: il sort funziona anche se non seleziono quel parametro
                            exec(function(err, second_trip_ids2) {
                                try{ error(req, res, err, second_trip_ids2[0]);
                                } catch(e){return 0;}

                                second_trip_ids2[0].arrival_time = mod_24(second_trip_ids2[0].arrival_time);
                                //console.log(second_trip_ids2[0]);
                                res.json(second_trip_ids2[0])
                            });
                    } else{
                        try{ error(req, res, err, second_trip_ids[0]);
                        } catch(e){return 0;}

                        second_trip_ids[0].arrival_time = mod_24(second_trip_ids[0].arrival_time);
                        //console.log(second_trip_ids[0]);
                        res.json(second_trip_ids[0])
                    }
                });
        });
});

//return all stops information that have a specific route and direction if direction isn't passed is not consider
router.route('/routes/:route_id/stops').get(function(req, res) {
    params = req.params;
    console.log("get stops from route_id and direction")

    //get direction
    var direction_id = req.query.direction_id;
    if(direction_id === undefined){
        direction_id = [1, 0]; // se direzione non passata la ignoro
    }

    //get trips of route 5  one way
    trip.
        find({
            route_id: params.route_id,
            direction_id: direction_id
        }, { '_id': 0, 'trip_id' : 1}).
        exec(function(err, trip_ids) {
            try{ error(req, res, err, trip_ids);
            } catch(e){return 0;}

            console.log("1°lvl trip_ids.length: " + trip_ids.length);
            //console.log(trip_ids)
            trip_ids = trip_ids.map(function(doc) { return doc.trip_id; });
            //get all stop of 5 one way
            stop_time.
                find({trip_id: {$in: trip_ids}
                }, { '_id': 0, 'stop_id': 1}).
                exec(function(err, stop_ids) {
                    try{ error(req, res, err, stop_ids);
                    } catch(e){return 0;}

                    console.log("2°lvl stop_ids.length: " + stop_ids.length);
                    //console.log(stop_ids);
                    stop_ids = stop_ids.map(function(doc) { return doc.stop_id; });
                    //get full information about all stop of 5  one way
                    stop.
                        find({stop_id: {$in: stop_ids}}).
                        sort('stop_id').
                        exec(function(err, stop_list) {
                            try{ error(req, res, err, stop_list);
                            } catch(e){return 0;}

                            console.log("3°lvl stop_list.length: " + stop_list.length + "\n");
                            //console.log(stop_list);
                            res.json(stop_list);
                        });
                });
        });
});

//return all times and his trip_id in one stop where a trip, of route_id and direction(required) is pass
router.route('/routes/:route_id/stops/:stop_id/times').get(function(req, res) {
    params = req.params;
    console.log("get times from stop, route_id and direction")

    //get direction
    var direction_id = req.query.direction_id;
    if(direction_id === undefined){
        return res.json(JSON.parse(fs.readFileSync('err_missing_parameter.json', 'utf8')));
    }

    //get trips of route 5 one way
    trip.
        find({
            route_id: params.route_id,
            direction_id: direction_id
        }, { '_id': 0, 'trip_id' : 1}).
        exec(function(err, trip_ids) {
            try{ error(req, res, err, trip_ids);
            } catch(e){return 0;}
            console.log("1°lvl trip_ids.length: " + trip_ids.length);
            //console.log(trip_ids)
            trip_ids = trip_ids.map(function(doc) { return doc.trip_id; });

            //get times and relatives trip_id of 5 that pass in one stop
            stop_time.
                find({
                    trip_id: {$in: trip_ids},
                    stop_id: params.stop_id
                }, { '_id': 0, 'trip_id': 1, 'arrival_time': 1}).
                sort('arrival_time').
                exec(function(err, times) {
                    try{ error(req, res, err, times);
                    } catch(e){return 0;}
                    for(var i=(times.length-1); i>=0; i--){
                        times[i].arrival_time = mod_24(times[i].arrival_time);
                    }
                    console.log("2°lvl times.length: " + times.length + "\n");
                    //console.log(times)
                    res.json(times);
                });
        });
});

router.route('/routes/:route_id/reference').get(function(req, res){
    params = req.params;
    query = req.query;

    //check direction_id in query, if undefined repeat this query for both directions
    directions_id = query.direction_id || [0, 1]
    directions_id = directions_id.map!==undefined ? directions_id:[directions_id];

    promises = directions_id.map(function(direction_id) {
        return find_common_starting_ending_stops_from_route(params.route_id, direction_id)
    });

    Promise.all(promises).then(function(results) {

        return Object.assign({}, ...results);
    }).then(function(results) {

        res.json(results)
    });
});

router.route('/import').put(function(req, res) {
    gtfs_import.import(req.body).then(() => {
        console.log('GTFS Import Successful');
        res.sendStatus(200);
    }).catch(function(error){
        console.log(error);
    });
});

module.exports = router

//________________FUNZIONI________________________________________________________________________________________

function error(req, res, err, el){
    if (err){
        console.log("error: " + err)
        res.sendStatus(400);  // error message
        throw err;
    } else if(el===undefined){/* pianta l'esecuzione...&& Object.keys(el).length>0*/
        //console.log("elemento undefined")
        res.sendStatus(400);
        throw new Error('undefined element')
    }
}

function mod_24(time_str){  //i convert time like 25:12:00 to normal 24 hour like 1:12:00
    if(time_str>"24"){
        var parts = time_str.split(':')
        parts[0] = (parts[0]*1) % 24
        parts[0] = ((parts[0]<10)? ("0"+parts[0]) : parts[0])   // i add a 0 from 1:12:00 to 01:12:00
        //console.log("time_str: " + time_str + "  res: " + (parts[0] + ":" + parts[1] + ":" + parts[2]))
        return(parts[0] + ":" + parts[1] + ":" + parts[2])
    }
    return(time_str)
}

function invert_mod_24(time_str){  //i convert time like 25:12:00 to normal 24 hour like 1:12:00
    if((time_str[0]=='0' &&  time_str<"4")||(time_str[1]==':' &&  time_str<"4")){
        var parts = time_str.split(':')
        parts[0] = (parts[0]*1) + 24
        console.log("time_str: " + time_str + "  res: " + (parts[0] + ":" + parts[1] + ":" + parts[2]))
        return(parts[0] + ":" + parts[1] + ":" + parts[2])
    }
    return(time_str)
}

function find_common_starting_ending_stops_from_route(route_id, direction_id) {
    return trip.find(
        {
            route_id: route_id,
            direction_id: direction_id
        }, {
            _id: 0,
            trip_id: 1}
    ).then(function(result) {
        trip_ids = result.map(function(doc) { return doc.trip_id; });
        return find_common_starting_ending_stops_tripids(trip_ids);
    }).then(function(result){
        return {[direction_id]: result}
    });
}

function find_common_starting_ending_stops_tripids(trip_ids) {
    return stop_time.aggregate([
            {
                "$match": {
                    "trip_id": {
                        "$in": trip_ids
                    }
                }
            }, {
                "$sort": {
                    "trip_id": 1
                }
            }, {
                "$group": {
                    "_id": {
                        stop_id: "$stop_id",
                        stop_sequence: "$stop_sequence"
                    },
                    "trip_id_first": {
                        "$first": "$trip_id"
                    }
                }
            }
        ]).then(function(stoptimes) {
            stops = {};
            stoptimes.map(function(doc) {
                if(stops[doc.trip_id_first] === undefined) {
                    stops[doc.trip_id_first] = [];
                }

                stops[doc.trip_id_first][doc._id.stop_sequence-1] = doc._id.stop_id;
                // return [doc.trip_id_first, doc._id.stop_id, doc._id.stop_sequence];
            });

            starting_stops = new Set(); //FIXME is it the best data structure?
            ending_stops = new Set(); //FIXME is it the best data structure?

            for(tr_id in stops) {
                if(stops[tr_id][0] !== undefined) {
                    starting_stops.add(stops[tr_id][0])
                }

                if(stops[tr_id][stops[tr_id].length-1] !== undefined) {
                    ending_stops.add(stops[tr_id][stops[tr_id].length-1])
                }
            }

            for(tr_id in stops) {
                for(var i=1; i<stops[tr_id].length; i++) {
                    if(stops[tr_id][i] !== undefined) {
                        starting_stops.delete(stops[tr_id][i]);
                    }
                }
            }
            for(tr_id in stops) {
                for(var i=1; i<stops[tr_id].length-1; i++) {
                    if(stops[tr_id][i] !== undefined) {
                        ending_stops.delete(stops[tr_id][i]);
                    }
                }
            }

            return {
                starting_stops: Array.from(starting_stops),
                ending_stops: Array.from(ending_stops)
            }
        }
    );
}