const express = require('express');
const fs = require('fs');

var delay = require('../delays/delay');

router = express.Router({
    mergeParams: true
}); //TODO find why of mergeParams

router.route('/try').get(function(req, res) {
	res.sendStatus(200);
});

// add/trips/557/stops/34?stoptime=07:56:00&report=2
router.route('/add/trips/:trip_id/stops/:stop_id').post(function(req, res) {
	console.log("\ninsert_delay:")
    
    var currentDate = Date.now(); // uguale a new Date().getTime();
    currentDate += (3600*1000); // aggiungo un ora al datetime segnata in millisecondi questo perchè siamo avanti di un ora rispetto al meridiano di greenwich

	var report = req.query.report;
	if(report === undefined){
		return res.json(JSON.parse(fs.readFileSync('err_missing_parameter.json', 'utf8')));
	}

    var stoptime = req.query.stoptime;
    if(stoptime === undefined){
        return res.json(JSON.parse(fs.readFileSync('err_missing_parameter.json', 'utf8')));
    }
    var ts_stoptime = from_time_to_timestamp(stoptime.split(':'));
    //console.log("ts_stoptime: " + ts_stoptime);

    var date = new Date();
    var ts_actual_time = from_time_to_timestamp([date.getHours(), date.getMinutes(), date.getSeconds()])

    var real_delay = ts_actual_time - ts_stoptime;
    console.log("ts_actual_time:" + ts_actual_time + " - ts_stoptime:" + ts_stoptime + " = real_delay: " + real_delay)

    insert_delay(req, res, currentDate, real_delay, report);
});

router.route('/all').get(function(req, res) {
    console.log("get all delay:")
    delay.
        find({}).//report_type: [0, 2]
        exec(function(err, delays) {
            try{ error(req, res, err, delays);
            } catch(e){return 0;}
            console.log("1°lvl delays.length: " + delays.length + "\n");
            //console.log(delays);
            res.json(delays);
        });
});

//retrive the stop where the bus is seen last datetime, and  
//when my bus (trip_id) will pass in the passed stop_id consider the delay
router.route('/trips/:trip_id').get(function(req, res) {
    console.log("get delay from trip_id")

    // get datetime
	datetime = Date.now();
    datetime += (3600*1000); // aggiungo un ora al datetime segnata in millisecondi questo perchè siamo avanti di un ora rispetto al meridiano di greenwich

    params = req.params;

	//console.log("trip_id: " + params.trip_id + " datetime: " + datetime);

    //get all significant reports
    datetime -= (3*3600*1000); //catch only the most recend report, subtract 3 hour
    
    delay.
        find({
            trip_id: params.trip_id,
            report_date: {$gt: datetime}
        }).
        sort({report_date: -1}).// inverse order on report_date or sequence_id is the same but here we don't have sequence_id of stoptimes table so i use report_date
        exec(function(err, trip_ids) {
            try{ error(req, res, err, trip_ids);
            } catch(e){return 0;}
            console.log("1°lvl trip_ids.length: " + trip_ids.length);
            //console.log(trip_ids);

            //report can have 3 value: 0=no, 1=boh, 2=yes
            // i look for the first yes, and take delay from max of all no find
            var max = -60000000;    //default value it's -1000minute or 60milion of millisecond
            var i = 0;
            while(i<trip_ids.length && trip_ids[i].report_type!=2){
            	if(trip_ids[i].report_type==0){
            		max = ((trip_ids[i].real_delay>max)? trip_ids[i].real_delay : max);
            		//console.log("\tfind no -> i:" + i + " max:" + max + "\n")
            	}// else if(trip_ids[i].report_type==1){} //user say boh
            	i++;
            }

            var last_seen_id = -1;	// never see the bus
            if(i<trip_ids.length){	// i exit from while because i find a yes
            	max = ((trip_ids[i].real_delay>max)? trip_ids[i].real_delay : max);
                //console.log("find yes -> i:" + i + " max:" + max + "\n")
            	last_seen_id = trip_ids[i].stop_id
            }
            var max_minute = Math.floor((max-1)/(60*1000))+1;   //trasform from millisecond to minute and arround to upper
            //console.log("END i:" + i + " max:" + max + " max_minute:" + max_minute + " last_seen_id: " + last_seen_id)

            var result = {
            	trip_id: params.trip_id, 
			    delay: max_minute,
			    last_seen: last_seen_id
			};
			console.log("RESULT: " + JSON.stringify(result) + "\n")
            res.json(result)
        });
});

module.exports = router

//________________FUNZIONI________________________________________________________________________________________

function error(req, res, err, el){
    if (err){
        console.log("error: " + err)
        res.sendStatus(400);  // error message
        throw err;
    } else if(el===undefined){
        //console.log("elemento undefined")
        res.sendStatus(400);
        throw new Error('undefined element')
    }
}

function insert_delay(req, res, date, real_delay, report){
	var trip_id  = req.params.trip_id;
	var stop_id  = req.params.stop_id;

	//console.log("trip_id: " + trip_id + " stop_id: " + stop_id + " report: " + report + " real_delay: " + real_delay);
	
	// create a new delay called d
	var d = new delay({
		trip_id: trip_id,
		report_date: date,
		stop_id: stop_id,
		report_type: report,
		real_delay: real_delay
	});

	// call the built-in save method to save to the database
	d.save(
		function(err) {
            try{ error(req, res, err, d);
            } catch(e){return 0;}
			if (err){
				res.status(400); //messaggio d'errore
				throw err;
			}
			//res.sendStatus(200); //messaggio di successo
			res.json(JSON.parse(JSON.stringify(d)));
		}
	);
}

function from_time_to_timestamp(parts){
    //convert into timestamp (in millisecond) from [07,56,00] format
    //console.log("parts[0]:" + parts[0] + " parts[1]:" + parts[1] + " parts[2]:" + parts[2])
    var ts_time = parts[0];
    ts_time = ts_time*60 + parts[1]*1;
    ts_time = ts_time*60 + parts[2]*1;
    ts_time = ts_time*1000;
    //console.log("ts_time: " + ts_time)
    return(ts_time)
}