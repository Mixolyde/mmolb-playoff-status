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

  var wcLeaderDiff = getWildCardDiff([_allTeams[_sub1.id]!, _allTeams[_sub2.id]!]);

  var sub1Standings = 
    await calculateSubLeague(_sub1, _allTeams[_sub1.id]!, timeData, wcLeaderDiff);
  var sub2Standings = 
    await calculateSubLeague(_sub2, _allTeams[_sub2.id]!, timeData, wcLeaderDiff);
  
  return [sub1Standings, sub2Standings];
    
}

Future<List<TeamStandings>> calculateSubLeague(Subleague sub, List<Team> teams,
    TimeData timeData, int wcLeaderDiff) async{
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
      '${team.location} ${team.fullName}', team.shorthand, team.emoji,
      sub.name,
      team.wins, 
      team.losses,
      team.runDifferential,
      gamesPlayed);
    teamStandings.add(standing);
  }
  
  print("SubLeague TeamStandings Length: ${teamStandings.length}");

  //sort first then calculate
  teamStandings.sort();


  calculateGamesBehind(teamStandings, wcLeaderDiff);
  //calculateMagicNumbers(teamStandings);
  
  return teamStandings;

}

void calculateGamesBehind(List<TeamStandings> teamStandings, int wcLeaderDiff) {
  //compute games back from Subleague leader
  var subLeaderDiff = teamStandings[0].wins - 
      (teamStandings[0].gamesPlayed - teamStandings[0].wins);

  for (var i = 1; i < teamStandings.length; i++){
    var teamDiff = teamStandings[i].wins - 
      (teamStandings[i].gamesPlayed - teamStandings[i].wins);
    num gbSubLeader = ( subLeaderDiff - teamDiff ) / 2;
    num gbWildCard = ( wcLeaderDiff - teamDiff ) / 2;
    teamStandings[i].gbDiv = formatGamesBehind(gbSubLeader);
    if (gbWildCard > 0) {
      teamStandings[i].gbWc = formatGamesBehind(gbWildCard);
    }
    
    
    print('GbDiv ${teamStandings[i].gbDiv} GbWc ${teamStandings[i].gbWc}');
  }  
}

int getWildCardDiff(List<List<Team>> teams) {
  //compute games back from Wild Card leader
  List<Team> league1Teams = teams[0].toList();
  List<Team> league2Teams = teams[1].toList();

  league1Teams.sort();
  league2Teams.sort();

  // remove first two teams from standings
  league1Teams.removeRange(0, 2);
  league2Teams.removeRange(0, 2);

  // merge the two lists
  league1Teams.addAll(league2Teams);

  // sort all teams
  league1Teams.sort();

  // calculate the wild card leader difference of the second team
  int wcLeaderGamesPlayed = league1Teams[1].wins + league1Teams[1].losses;
  var wcLeaderDiff = league1Teams[1].wins - 
      (wcLeaderGamesPlayed - league1Teams[1].wins);

  print('WC Leader Diff: $wcLeaderDiff from team ${league1Teams[1].fullName}');
  
  return wcLeaderDiff;
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

String formatGamesBehind(num gb){
  if(gb == gb.toInt()){
    return gb.toInt().toString();
  } else if (gb < 1 ) {
    return '½';
  } else {
    return '${gb.toInt()}½';
  }
}