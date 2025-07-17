import 'package:mmolb_playoff_status/calc_stats.dart';
import 'package:mmolb_playoff_status/database_api.dart' as db;

Future<void> main(List<String> args) async {  
  var timeData = await db.getTimeData();
  print(timeData);

  var stateData = await db.getStateData();
  print(stateData);

  //site data
  var sitedata = await calcSiteData(timeData);
  print(sitedata);

}