var to_be = new Vue({
    el: '#to_be',
    data: {
        routeName: routeName,
        stopName: stopName,
        arrivalTime: arrivalTime.split(':')[0]+':'+arrivalTime.split(':')[1]
    }
});

var last_seen = new Vue({
    el: '#last_seen',
    created: function () {
      console.log("tripId: "+tripId);
      axios.get(baseUrl + '/getDelay/tripId/' + tripId)
        .then(function (response) {
          console.log("Ritardo: ");
          console.log(response);
          axios.get(baseUrl + '/getStop/stop/' + response.data.last_seen)
            .then(function (response1) {
              last_seen.last_stop = response1.data.stop_name;
              console.log("delay: ");
              console.log(last_seen.delay);
              if(last_seen.delay != -1000 && last_seen.delay != null && last_seen.delay != undefined){ //-1000 means there is no info about the delay
                console.log("last_seen.last_stop: "+last_seen.last_stop);
                last_seen.title = "Avvistato l'ultima volta a:";
                last_seen.message = last_seen.last_stop + " circa " + response.data.delay + " minuti fa."
              } else {
                last_seen.title = "";
                last_seen.message = "Non abbiamo informazioni sul ritardo del bus.";
              }
            })
            .catch(function (error) {
                console.log(error);
            });
        })
        .catch(function (error) {
            console.log(error);
        });
    },
    data: {
      message: "",
      title: "",
      last_stop: "",
      delay: null,
      last_seen: null //Last seen bus stop id
    }
});

///////////////////////////////////////////////
//       Until here was just rendering       //
///////////////////////////////////////////////

function button_pressed(value, btn_name) {
    console.log(value);

    switch (btn_name) {
        case 'y':
            { //If yes button was pressed can't be changed in something else
                document.getElementById('yes').style.background = "blue";
                document.getElementById('maybe').style.background = "white";
                document.getElementById('no').style.background = "white";
                document.getElementById('yes').disabled = true;
                document.getElementById('maybe').disabled = true;
                document.getElementById('no').disabled = true;
                break;
            }
        case 'm':
            { //If maybe button was pressed it can be changed to both yes or no
                document.getElementById('yes').style.background = "white";
                document.getElementById('maybe').style.background = "grey";
                document.getElementById('no').style.background = "white";
                document.getElementById('maybe').disabled = true;
                break;
            }
        case 'n':
            { //If the no button was pressed it can be changed to yes if the bus has arrived
                document.getElementById('yes').style.background = "white";
                document.getElementById('maybe').style.background = "white";
                document.getElementById('no').style.background = "red";
                document.getElementById('maybe').disabled = true;
                document.getElementById('no').disabled = true;
                break;
            }
    }

    axios.post(baseUrl + "/postReport/stopId/" + stopId + "/tripId/" + tripId + "/stopTime/" + arrivalTime + "/report/"+ value)
    .catch(function (error) {
      console.log(error);
    });
    alert("Grazie per la tua segnalazione");
}
