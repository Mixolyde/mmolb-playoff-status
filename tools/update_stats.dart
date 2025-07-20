import 'package:mmolb_playoff_status/calc_stats.dart';
import 'package:mmolb_playoff_status/database_api.dart' as db;

Future<void> main(List<String> args) async {  
  var stateData = await db.getStateData();
  //print(stateData);

  var timeData = await db.getTimeData();
  //print(timeData);

  //site data
  var siteData = await calcSiteData(stateData, timeData);
  print(siteData);

  //get subleague standings and calculate stats
  var subStandings = await calcStats(stateData, timeData);
  
  //print out data
  print(subStandings[0]);
  print(subStandings[1]);

}