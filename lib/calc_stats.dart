import 'package:mmolb_playoff_status/site_objects.dart';

int gamesInRegularSeason = TimeData.gamesInRegularSeason();

Future<SiteData> calcSiteData(TimeData timeData) async {
  //_league = await getLeague(deep:true);
  //print(_league);

  //_sub1 = _league.subleague1!;
  //_sub2 = _league.subleague2!;
  
  var lastUpdate = getUpdateTime();
  
  var sitedata = SiteData(lastUpdate, 
    timeData.seasonNumber, timeData.seasonDay,
    "0", "Clover", 
    "1", "Pineapple",
    [],
    TimeData.daysInRegularSeason(),
    TimeData.gamesInRegularSeason());
  //print(sitedata);

  return sitedata;
}  

String getUpdateTime(){
  var now = DateTime.now();
  print("IsoString: ${now.toIso8601String()}");
  return now.toIso8601String();
}