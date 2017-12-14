/* Init page*/
document.getElementById('timetables').style.display = 'none';
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

/* times */

document.getElementById('loader').style.display = 'block';
var timetablesRepeater = new Vue({
  el: '#timetableRepeater',
  data: {
    timetables: null
  },
  created: function () {
    axios.get(baseUrl + '/getTimetables/routeId/' + routeId + '/direction/' + direction + '/stopId/' + stopId)
      .then(function (response) {
        timetablesRepeater.timetables = response.data;
        document.getElementById('loader').style.display = 'none';
        document.getElementById('timetables').style.display = 'block';
        document.getElementById('timetableRepeater').style.display = 'none';
      })
      .catch(function (error) {
        console.log(error);
      });
  }
});

/* utils */
var filter = function (inputType, repeaterType) {
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
  window.open(baseUrl + '/busLines/'+ routeId + '/direction', "_self")
}

var nextScreen = function (tripId, arrivalTime) {
  window.open(baseUrl + '/delaysView/routeId/'+ routeId + '/direction/' + direction + '/stopId/' + stopId + '/tripId/'+ tripId + '/arrivalTime/' + arrivalTime +'/?routeName=' + routeName + '&stopName=' + stopName, "_self")
}
