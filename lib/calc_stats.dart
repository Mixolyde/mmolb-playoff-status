import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/site_objects.dart';
import 'package:mmolb_playoff_status/src/tiebreakers.dart';

int gamesInRegularSeason = TimeData.gamesInRegularSeason();
Map<String,List<Team>> _allTeams = {};
late Tiebreakers _tiebreakers;

Future<SiteData> calcSiteData(StateData stateData, TimeData timeData) async {
  //_league = await getLeague(deep:true);
  //print(_league);

  //_sub1 = _league.subleague1!;
  //_sub2 = _league.subleague2!;
  
  var lastUpdate = getUpdateTime();
  
  //TODO get subleague nicknames from league data
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

Future<List<List<TeamStandings>>> calcStats(StateData stateData, TimeData timeData) async {
  print('Beginning stat calculations for current season: ${timeData.seasonNumber}');
 
  _allTeams = await getTeamsBySubleague(stateData);
    
  _tiebreakers = getAlphaTiebreakers();

  /*
  var sub1Standings = 
    await calculateSubLeague(_sub1, stateData);
  var sub2Standings = 
    await calculateSubLeague(_sub2, stateData);
  */
  
  //return [sub1Standings, sub2Standings];
  return [];
    
}

Future<List<TeamStandings>> calculateSubLeague(Subleague sub, 
    StateData simData) async{

  print("Calculating standings for subleague: ${sub.name}");
  List<TeamStandings> standings = [];

  return standings;
}

Tiebreakers getAlphaTiebreakers(){
  String id = "AlphaTiebreakers";
  //expand each teamlist into a list of id strings and flatmap them
  List<String> teamIds = 
    _allTeams.values.expand<String>((teamList) => 
      teamList.map((team) => team.id)).toList();
  //print("TeamIds: $teamIds");
  teamIds.sort();
  return Tiebreakers(id: id, order: teamIds);
  
}