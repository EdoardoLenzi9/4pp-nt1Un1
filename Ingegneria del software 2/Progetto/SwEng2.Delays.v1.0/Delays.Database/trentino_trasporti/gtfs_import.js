var gtfs = require('gtfs');
var mongo_utils = require('../utils/mongo');
var mongoose = require('mongoose');

var credentials = require('../credentials.json');
//Setting up gtfs

// configuration for gtfs
var config = {
  mongoUrl: mongo_utils.extract_url(credentials),
  "agencies": [
    {
      "agency_key": "trentino_trasporti",
      "url": "https://transitfeeds.com/p/trentino-trasporti-esercizio/613/latest/download"
    }
  ]
};

// mongoose.Promise = global.Promise;
// mongoose.connect(config.mongoUrl, {useMongoClient: true});
// credentials = undefined; //trying to void bad behaviour of preserving credentials inside of memory

module.exports.import = function(cfg){
  console.log(cfg);
  if(cfg !== undefined && Object.keys(cfg).length>0) {
    c = cfg;
  } else {
    c = config;
  }
  console.log(c);

  return gtfs.import(c);
};
