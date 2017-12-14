// Constants
let ls_key_hits = "hits";
let ls_key_favourites = "favourites";

// OnClick handler
let choseRoute = res => {
  let currentHits = registerItemHit(res);
  storeFavourites(currentHits);
  window.open(baseUrl + '/buslines/routeId/' + res.route_id + '/direction/?routeName=' + res.route_short_name, "_self")
}

let choseFavouriteRoute = res => {
  let currentHits = registerItemHit(res);
  window.open(baseUrl + '/buslines/routeId/' + res.route_id + '/direction/?routeName=' + res.route_short_name, "_self")
}

// Favourites management function

// This kind of data structure is pretty inefficient for reading and sorting, could be done better
let registerItemHit = item => {
  // Reads the object containing hits from the localStorage
  var hits = localStorage.getItem(ls_key_hits);
  // If there's nothing into local storage, creates an empty object
  // Else it deserializes the object
  if (hits == null) {
    hits = {};
  } else {
    hits = JSON.parse(hits);
  }
  // If the route is already into the local storage increments the number of hits
  // else it sets it to 1
  if (hits[item.route_id]) {
    hits[item.route_id]++;
  } else {
    hits[item.route_id] = 1;
  }
  // Stores the output into the local storage
  localStorage.setItem(ls_key_hits, JSON.stringify(hits));
  // Returns the final hits count for further calculation
  return hits;
}

let storeFavourites = hits => {
  let bus_ids = Object.keys(hits);
  // sorts lines in ascending order of frequency
  let sorted_lines = [];
  while (bus_ids.length > 0) {
    var min = bus_ids.slice(0, 1)[0];
    bus_ids.forEach(key => {
      if (hits[key] < hits[min])
        min = key;
    });
    sorted_lines.push(min);
    bus_ids = bus_ids.filter(value => {
      if (value != min)
        return true;
      return false;
    });
  }
  // Orders the bus lines in descending order of frequency
  sorted_lines.reverse();
  // Creates the object containing the favourites to store
  sorted_lines = sorted_lines.slice(0, 4);
  let favourites = busLines.routes.filter(line => {
    return sorted_lines.indexOf(line.route_id) != -1;
  });
  // Stores the array of favourites
  localStorage.setItem(ls_key_favourites, JSON.stringify(favourites));
}

let getFavourites = () => {
  return JSON.parse(localStorage.getItem(ls_key_favourites))
}

// Vue's objects
var busLines = new Vue({
  el: '#busLines',
  created: () => {
    //TODO change ip
    axios.get(baseUrl + '/getLines')
      .then(response => {
        busLines.routes = response.data;
        // HOTFIX, sorry mum
        busLines.routes = busLines.routes.filter((line) => {
          return line.route_color !== "" && line.route_color;
        });
      })
      .catch(error => {
        console.log(error);
      });
  },
  data: {
    routes: null
  }
});

var favouriteLines = new Vue({
  el: '#favouriteLines',
  data: {
    favourites: null
  }
});

favouriteLines.favourites = getFavourites();