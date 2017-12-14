// grab the things we need
var mongo_utils = require('../utils/mongo');
var credentials = require('./../credentials')
var mongoose = require('mongoose');
mongoose.Promise = global.Promise;
mongoose.connect(
    mongo_utils.extract_url(credentials),
    {useMongoClient: true}
).then(function() {
    console.log("connection successfull");
}).catch(function(error){
    console.log(error);
});

var Schema = mongoose.Schema;

// create a schema
var delaySchema = new Schema({
	trip_id: { type: Number, required: true },
	report_date: { type: Date, required: true },
	stop_id: { type: Number, required: true },
	report_type: { type: Number, required: true }, //si intende la risposta messa dall'utente no, bho, sì potrebbe rispettivamente essere 0=no, 1=boh, 2=sì
	real_delay: { type: Number, required: true } //è il ritardo calcolato come ora attuale meno ora in cui il bus dovrebbe passare
});

// the schema is useless so far
// we need to create a model using it
var Delay = mongoose.model('Delay', delaySchema);

// make this available to our users in our Node applications
module.exports = Delay;
