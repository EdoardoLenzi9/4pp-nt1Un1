/* Init page*/
document.getElementById('stops').style.display = 'none';
document.getElementById('loader').style.display = 'none';

/* title */
var title = new Vue({
  el: '#title',
  data: {
    message: routeName
  }
});

/* stops */


if (direction == 0) {
  title.message = routeName + ' - Andata';
} else {
  title.message = routeName + ' - Ritorno';
}
document.getElementById('loader').style.display = 'inline-block';

var stopsRepeater = new Vue({
  el: '#stopsRepeater',
  data: {
    stops: null
  },
  created: function () {
    axios.get(baseUrl + '/getStops/routeId/' + routeId + '/direction/' + direction)
      .then(function (response) {
        stopsRepeater.stops = response.data;
        document.getElementById('loader').style.display = 'none';
        document.getElementById('stops').style.display = 'block';
        document.getElementById('stopsRepeater').style.display = 'none';
      })
      .catch(function (error) {
        console.log(error);
      });
  }
});

/* utils */
var filter = function (inputType, repeaterType) { //TODO spostare utils
  var input, filter, ul, li, a, i, count = 0;
  input = document.getElementById(inputType);
  filter = input.value.toUpperCase();
  ul = document.getElementById(repeaterType);
  ul.style.display = 'block';
  li = ul.getElementsByTagName('li');
  for (i = 0; i < li.length; i++) {
    a = li[i].getElementsByTagName('a')[0];
    if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
      if (count < 5) {
        li[i].style.display = '';
        count++;
      } else {
        li[i].style.display = 'none';
      }
    } else {
      li[i].style.display = 'none';
    }
  }
}

var reset = function () {
  window.open(baseUrl + '/busLines/' + routeId + '/direction', "_self")
}

var nextScreen = function (stop) {
  window.open(baseUrl + '/buslines/routeId/' + routeId + '/direction/' + direction + '/stopId/' + stop.stop_id + '/?routeName=' + routeName + '&stopName=' + stop.stop_name, "_self")
}