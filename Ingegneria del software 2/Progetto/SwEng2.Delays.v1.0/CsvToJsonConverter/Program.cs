using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.IO;
using System.Linq;

namespace CsvToJsonConverter
{
    class Program
    {
        static void Main(string[] args)
        {
            /*var tripsString = LoadJson<TripsString>("sources/json/trips.json");
            var trips = new List<Trips>();
            tripsString.ForEach(x => {
                trips.Add(new Trips {
                    route_id = Int32.Parse(x.route_id), 
                    service_id = x.service_id,
                    trip_id = x.trip_id,
                    trip_headsign = x.trip_headsign,
                    direction_id = Int32.Parse(x.direction_id),
                    shape_id = x.shape_id,
                    wheelchair_accessible = x.wheelchair_accessible
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/trips.json", JsonConvert.SerializeObject(trips));

            var routesString = LoadJson<RoutesString>("sources/json/routes.json");
            var routes = new List<Routes>();
            routesString.ForEach(x => {
                routes.Add(new Routes {
                    route_id = Int32.Parse(x.route_id),
                    agency_id = Int32.Parse(x.agency_id),
                    route_short_name = x.route_short_name,
                    route_long_name = x.route_long_name,
                    route_type = x.route_type,
                    route_color= x.route_color,
                    route_text_color = x.route_text_color
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/routes.json", JsonConvert.SerializeObject(routes));

            var calendarString = LoadJson<CalendarString>("sources/json/calendar.json");
            var calendar = new List<Calendar>();
            calendarString.ForEach(x => {
                calendar.Add(new Calendar {
                    service_id = x.service_id,
                    monday = Int32.Parse(x.monday),
                    tuesday = Int32.Parse(x.tuesday),
                    wednesday = Int32.Parse(x.wednesday),
                    thursday = Int32.Parse(x.thursday),
                    friday = Int32.Parse(x.friday),
                    saturday = Int32.Parse(x.saturday),
                    sunday = Int32.Parse(x.sunday),
                    start_date = x.start_date,
                    end_date = x.end_date
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/calendar.json", JsonConvert.SerializeObject(calendar));

            var calendarDateString = LoadJson<CalendarDatesString>("sources/json/calendar_dates.json");
            var calendarDate = new List<CalendarDates>();
            calendarDateString.ForEach(x => {
                calendarDate.Add(new CalendarDates {
                    service_id = x.service_id,
                    date = x.date,
                    exception_type = Int32.Parse(x.exception_type)
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/calendar_dates.json", JsonConvert.SerializeObject(calendarDate));

            var feedInfoString = LoadJson<FeedInfoString>("sources/json/feed_info.json");
            System.IO.File.WriteAllText(@"sources/NewJson/feed_info.json", JsonConvert.SerializeObject(feedInfoString));

        
            var shapesString = LoadJson<ShapesString>("sources/json/shapes.json");
            var shapes = new List<Shapes>();
            shapesString.ForEach(x => {
                shapes.Add(new Shapes {
                    shape_id = x.shape_id,
                    shape_pt_lat = float.Parse(x.shape_pt_lat),
                    shape_pt_lon = float.Parse(x.shape_pt_lon),
                    shape_pt_sequence = Int32.Parse(x.shape_pt_sequence)
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/shapes.json", JsonConvert.SerializeObject(shapes));
*/
            var stopString = LoadJson<StopsString>("sources/json/stops.json");
            var stops = new List<Stops>();
            stopString.ForEach(x => {
                stops.Add(new Stops {
                    stop_id = Int32.Parse(x.stop_id),
                    stop_code = x.stop_code,
                    stop_name = x.stop_name,
                    stop_desc = x.stop_desc,
                    stop_lat = float.Parse(x.stop_lat),
                    stop_lon = float.Parse(x.stop_lon),
                    zone_id = Int32.Parse(x.zone_id),
                    wheelchair_boarding = x.wheelchair_boarding
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/stops.json", JsonConvert.SerializeObject(stops));
/*
            var stopTimesString = LoadJson<StopTimesString>("sources/json/stop_times.json");
            var stopsTimes = new List<StopTimes>();
            stopTimesString.ForEach(x => {
                stopsTimes.Add(new StopTimes {
                    trip_id = x.trip_id,
                    arrival_time = x.arrival_time,
                    departure_time = x.departure_time,
                    stop_id = Int32.Parse(x.stop_id),
                    stop_sequence = Int32.Parse(x.stop_sequence)
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/stop_times.json", JsonConvert.SerializeObject(stopsTimes));


            var transfersString = LoadJson<TransfersString>("sources/json/transfers.json");
            var transfers = new List<Transfers>();
            transfersString.ForEach(x => {
                transfers.Add(new Transfers {
                    from_stop_id = Int32.Parse(x.from_stop_id),
                    to_stop_id = Int32.Parse(x.to_stop_id),
                    transfer_type = Int32.Parse(x.transfer_type)
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/transfers.json", JsonConvert.SerializeObject(transfers));

            var zonesString = LoadJson<ZonesString>("sources/json/zone_urbano.json");
            var zones = new List<Zones>();
            zonesString.ForEach(x => {
                zones.Add(new Zones {
                    zone_id = Int32.Parse(x.zone_id),
                    zone_name = x.zone_name,
                    zone_lat = float.Parse(x.zone_lat),
                    zone_lon = float.Parse(x.zone_lon)
                });
            });
            System.IO.File.WriteAllText(@"sources/NewJson/zone_urbano.json", JsonConvert.SerializeObject(zones));
*/
        }

        public static List<T> LoadJson<T>(string file)
        {
            StreamReader r = new StreamReader(file);
            string json = r.ReadToEnd();
            List<T> items = JsonConvert.DeserializeObject<List<T>>(json);
            Console.WriteLine(JsonConvert.SerializeObject(items));
            return items;
        }

        public class TripsString
        {
            public string route_id;
            public string service_id;
            public string trip_id;
            public string trip_headsign;
            public string direction_id;
            public string shape_id;
            public string wheelchair_accessible;
        }

        public class Trips
        {
            public int route_id;
            public string service_id;
            public string trip_id;
            public string trip_headsign;
            public int direction_id;
            public string shape_id;
            public string wheelchair_accessible;
        }

        public class RoutesString
        {
            public string route_id;
            public string agency_id;
            public string route_short_name;
            public string route_long_name;
            public string route_type;
            public string route_color;
            public string route_text_color;
        }

        public class Routes
        {
            public int route_id;
            public int agency_id;
            public string route_short_name;
            public string route_long_name;
            public string route_type;
            public string route_color;
            public string route_text_color;
        }

        public class CalendarString
        {
            public string service_id;
            public string monday;
            public string tuesday;
            public string wednesday;
            public string thursday;
            public string friday;
            public string saturday;
            public string sunday;
            public string start_date;
            public string end_date;
        }

        public class Calendar
        {
            public string service_id;
            public int monday;
            public int tuesday;
            public int wednesday;
            public int thursday;
            public int friday;
            public int saturday;
            public int sunday;
            public string start_date;
            public string end_date;
        }

        public class CalendarDatesString
        {
            public string service_id;
            public string date;
            public string exception_type;
        }

        public class CalendarDates
        {
            public string service_id;
            public string date;
            public int exception_type;
        }

        public class FeedInfoString
        {
            public string feed_publisher_name;
            public string feed_publisher_url;
            public string feed_lang;
            public string feed_start_date;
            public string feed_end_date;
            public string feed_version;
        }

        public class ShapesString
        {
            public string shape_id;
            public string shape_pt_lat;
            public string shape_pt_lon;
            public string shape_pt_sequence;
        }

        public class Shapes
        {
            public string shape_id;
            public float shape_pt_lat;
            public float shape_pt_lon;
            public int shape_pt_sequence;
        }

        public class StopsString
        {
            public string stop_id;
            public string stop_code;
            public string stop_name;
            public string stop_desc;
            public string stop_lat;
            public string stop_lon;
            public string zone_id;
            public string wheelchair_boarding;
        }

        public class Stops
        {
            public int stop_id;
            public string stop_code;
            public string stop_name;
            public string stop_desc;
            public float stop_lat;
            public float stop_lon;
            public int zone_id;
            public string wheelchair_boarding;
        }

        public class StopTimesString
        {
            public string trip_id;
            public string arrival_time;
            public string departure_time;
            public string stop_id;
            public string stop_sequence;
        }

        public class StopTimes
        {
            public string trip_id;
            public string arrival_time;
            public string departure_time;
            public int stop_id;
            public int stop_sequence;
        }

        public class TransfersString
        {
            public string from_stop_id;
            public string to_stop_id;
            public string transfer_type;
        }

        public class Transfers
        {
            public int from_stop_id;
            public int to_stop_id;
            public int transfer_type;
        }

        public class ZonesString
        {
            public string zone_id;
            public string zone_name;
            public string zone_lat;
            public string zone_lon;
        }

        public class Zones
        {
            public int zone_id;
            public string zone_name;
            public float zone_lat;
            public float zone_lon;
        }
    }
}