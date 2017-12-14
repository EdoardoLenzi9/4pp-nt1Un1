# Rest api

Until now the rest apis can provide the following data by accessing at <http://address:8080/api/v1/trento>:

- /routes: all the routes with `route_id`, `short_names`, `route_color` `route_text_color`
- /routes/<route_id> All the informations about a route
- /routes/<route_id>/trips/ all the trips available for that route
- /routes/<route_id>/trips/<trip_id>/ all the informations about a specific trip of that route
- /trips/ all the trips available
- /trips/<trip_id> all the informations about a specific trip
- /trips/<trip_id>/stoptimes all the stops and times for a specific trip_id
- /stops/ all the stops available
- /stop/<stop_id>/ all the informations about a specific stop


- /routes/:route_id/stops [?direction=]
	return all stops information that have a specific route and direction if direction isn't passed is not consider
- /routes/:route_id/stops/:stop_id/trips [?direction=]
	get all the trips of a specific route which are passing in the stop with stop_id
    param get: time: arrival time of the bus at the stop, if empty assumed actual time, direction(required) 0 or 1
   	es: routes/496/stops/2289/trips?time=07:03:50&direction=0
- /routes/:route_id/stops/:stop_id/times [?direction=]
	return all times and his trip_id in one stop where a trip, of route_id and direction(required) is pass

--> anteporre /delay

- /add/trips/:trip_id/stops/:stop_id method:post insert the delay report
	exist 2 required parameter:
		- stoptime: when the bus should pass in the stop
		- report: the response of the user can have 3 value 0=no, 1=boh, 2=yes
	es: add/trips/557/stops/34?stoptime=07:56:00&report=2

- /trips/:trip_id
	retrive like this {"trip_id":"557","delay":345000,"last_seen":34} where trip_id is the passed value, last_seen is the id of the stop where bus is seen for the last time and delay the delay of that bus, the delay retrive are in millisecond

# Docker

In order to simplify the test of the environment a ``docker-compose`` environment is set up.
It includes an instance of:

- `mongodb`
- `mongo-express`: web ui for accessing mongodb, runnning at <http://127.0.0.1:8081>
- `nodejs` application for data management of `delays`, runnning at <http://127.0.0.1:8080>

## Usage

Firstly you have to build the context with the command:
```docker-compose build```,
remember each time the `delays` code changes you have to rebuild the context.
Secondly you have to fetch the images for mongo and mongo-express with the following command:
```docker-compose pull```.
Then you can start the services with the following command:
```docker-compose up``` (you can kill them with ctrl-c).
