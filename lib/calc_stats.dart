import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/site_objects.dart';

int gamesInRegularSeason = TimeData.gamesInRegularSeason();
Map<String,List<Team>> _allTeams = {};
late Subleague _sub1;
late Subleague _sub2;

Future<SiteData> calcSiteData(StateData stateData, TimeData timeData) async {
  print("Calculating site data for season ${timeData.seasonNumber} day ${timeData.seasonDay}");
  // get subleague data
  _sub1 = await getSubleague(stateData.greaterLeagues[0]);
  _sub2 = await getSubleague(stateData.greaterLeagues[1]);
  
  var lastUpdate = getUpdateTime();
  
  //TODO get subleague nicknames from league data
  var sitedata = SiteData(lastUpdate, 
    timeData.seasonNumber, timeData.seasonDay,
    _sub1.id, _sub1.name, 
    _sub2.id, _sub2.name,
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

  var sub1Standings = 
    await calculateSubLeague(_sub1, _allTeams[_sub1.id]!, timeData);
  var sub2Standings = 
    await calculateSubLeague(_sub2, _allTeams[_sub2.id]!, timeData);
  
  return [sub1Standings, sub2Standings];
    
}

Future<List<TeamStandings>> calculateSubLeague(Subleague sub, List<Team> teams,
    TimeData timeData) async{
  print('Day ${timeData.seasonDay} ${sub.name} (${sub.id})');

  print("SubLeague Teams Length: ${teams.length}");
  
  var teamStandings = <TeamStandings>[];
  for (var team in teams) {

    var gamesPlayed = gamesInRegularSeason;
    if (!timeData.inPostSeason){
      gamesPlayed = team.wins + team.losses;
    }
    
    var standing = 
      TeamStandings(team.id, 
      team.fullName, team.shorthand, team.emoji,
      sub.name,
      team.wins, 
      team.losses,
      gamesPlayed);
    teamStandings.add(standing);
  }
  
  print("SubLeague TeamStandings Length: ${teamStandings.length}");

  //sort first then calculate
  sortTeamsNotGrouped(teamStandings);


  calculateGamesBehind(teamStandings);
  //calculateMagicNumbers(teamStandings);
  
  return teamStandings;

}

void calculateGamesBehind(List<TeamStandings> teamStandings) {
  //compute games back from Subleague leader
  //TODO compute games back from Wild Card spot
  //TODO handle actual tiebreakers
  var subLeaderDiff = teamStandings[0].wins - 
      (teamStandings[0].gamesPlayed - teamStandings[0].wins);
  
  for (var i = 1; i < teamStandings.length; i++){
    var teamDiff = teamStandings[i].wins - 
      (teamStandings[i].gamesPlayed - teamStandings[i].wins);
    num gbSubLeader = ( subLeaderDiff - teamDiff ) / 2;
    teamStandings[i].gbDiv = formatGamesBehind(gbSubLeader);
    
    print('GbDiv ${teamStandings[i].gbDiv} GbWc ${teamStandings[i].gbWc}');
  }  
}


Future<Map<String,List<Team>>> getTeamsBySubleague(StateData stateData) async {
  print("Greater League subleague ids: ${stateData.greaterLeagues}");
  Map<String,List<Team>> teamMap = {};

  for (var subleague in [_sub1, _sub2]) {
    print("Subleague: ${subleague.name} (${subleague.id})");
    List<Team> teams = [];
    for (var teamId in subleague.teams) {
      var team = await getTeam(teamId);
      teams.add(team);
    }
    teamMap[subleague.id] = teams;
  }

  return teamMap;
}

//sort teams by wins, then full name
void sortTeamsNotGrouped(List<TeamStandings> teams) {
  teams.sort((a, b) {
    if(b.wins != a.wins){
      return b.wins.compareTo(a.wins);
    } else {
      return a.fullName.compareTo(b.fullName);
    }
  });
 
}

String formatGamesBehind(num gb){
  if(gb == gb.toInt()){
    return gb.toInt().toString();
  } else if (gb < 1 ) {
    return '½';
  } else {
    return '${gb.toInt()}½';
  }
}