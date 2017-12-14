// NOTICE routeId is a given input from the routing

// Vue's object
var app = new Vue({
  el: '#app',
  data: {
    busline: routeName
  }
});

var forwardStartingStops = new Vue({
  el: '#forwardStartingStops',
  data: {
    forwardStartingStops: ""
  }
});

var forwardEndingStops = new Vue({
  el: '#forwardEndingStops',
  data: {
    forwardEndingStops: ""
  }
});

var returnStartingStops = new Vue({
  el: '#returnStartingStops',
  data: {
    returnStartingStops: ""
  }
});

var returnEndingStops = new Vue({
  el: '#returnEndingStops',
  data: {
    returnEndingStops: ""
  }
});

axios.get(baseUrl + '/getDirections/routeId/' + routeId)
  .then(function (response) {
    console.log(response);

    response.data[0].starting_stops.forEach((item, index, array) => {
      console.log(item);
      forwardStartingStopsNames(item);
    });
    response.data[0].ending_stops.forEach((item, index, array) => {
      console.log(item);
      forwardEndingStopsNames(item);
    });
    response.data[1].starting_stops.forEach((item, index, array) => {
      console.log(item);
      returnStartingStopsNames(item);
    });
    response.data[1].ending_stops.forEach((item, index, array) => {
      console.log(item);
      returnEndingStopsNames(item);
    });
  })
  .catch(function (error) {
    console.log(error);
  });

var forwardStartingStopsNames = function (stopId) {
  axios.get(baseUrl + '/getStop/stop/' + stopId)
    .then(function (response) {
      forwardStartingStops.forwardStartingStops = response.data.stop_name;
    })
    .catch(function (error) {
      console.log(error);
    });
}

var forwardEndingStopsNames = function (stopId) {
  axios.get(baseUrl + '/getStop/stop/' + stopId)
    .then(function (response) {
      forwardEndingStops.forwardEndingStops = response.data.stop_name;
    })
    .catch(function (error) {
      console.log(error);
    });
}
var returnStartingStopsNames = function (stopId) {
  axios.get(baseUrl + '/getStop/stop/' + stopId)
    .then(function (response) {
      returnStartingStops.returnStartingStops = response.data.stop_name;
    })
    .catch(function (error) {
      console.log(error);
    });
}

var returnEndingStopsNames = function (stopId) {
  axios.get(baseUrl + '/getStop/stop/' + stopId)
    .then(function (response) {
      returnEndingStops.returnEndingStops = response.data.stop_name;
    })
    .catch(function (error) {
      console.log(error);
    });
}

// Direction picked event handler
// input expected 0 for andata, 1 for ritorno
let selectdirection = pick => {
  // Checks the input is valid
  if (pick === 1 || pick === 0) {
    window.open(baseUrl + '/buslines/routeId/' + routeId + "/direction/" + pick + '/?routeName=' + routeName, "_self")
  }
}
