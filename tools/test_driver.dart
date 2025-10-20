import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/stats/calc_stats.dart';
import 'package:mmolb_playoff_status/stats/sim_season.dart';

/// Test script used for manually executing methods and testing functionality.
Future<void> main() async { 
  // Example: Fetching state data
  var stateData = await getStateData();
  print('State Data: $stateData');

  // Example: Fetching time data
  var timeData = await getTimeData();
  print('Time Data: $timeData');

  //site data
  var siteData = await calcSiteData(stateData, timeData);
  print(siteData);

  // Example: Fetching subleague data
  //var subleague = await getSubleague('6805db0cac48194de3cd3fe4');
  //print('Subleague Data: $subleague');

  //var team = await getTeam('6805db0cac48194de3cd3ff7');
  //print('Team Data: $team');

  //var teamsBySubleague = await getTeamsBySubleague(stateData);
  //print('Teams by Subleague: $teamsBySubleague');

  //var shineGames = await getAllRegularSeasonGamesByTeamId('6805db0cac48194de3cd407c');
  //for (var game in shineGames) {
  //  print(game);
  //}

  //get subleague standings and calculate stats
  var subStandings = await calcGreaterLeagueStats(stateData, timeData);
  for (var entry in subStandings) {
    print(entry.where((team) => team.wins + team.losses > 0).toList());
  }
  calculateChances(subStandings, 101, timeData);

  //get lesser league data
  //print(stateData.lesserLeagues);
  //var lesserLeague1 = await getSubleague('6805db0cac48194de3cd3fe7');
  //print('LesserLeague1 Data: $lesserLeague1');
  //print('LesserLeague1 Teams: ${lesserLeague1.teams}');

  //var lesserLeague1Team1 = await getTeam(lesserLeague1.teams[0]);
  //print('LesserLeague1Team1 Data: $lesserLeague1Team1');

  //var teamsByLesserLeagues = await getTeamsByLesserLeagues(stateData);
  //print('Teams by LesserLeagues: $teamsByLesserLeagues');

  //var lesserStandings = await calcLesserLeagueStats(stateData, timeData);
  //for (var entry in lesserStandings.values) {
  //  print(entry.where((team) => team.wins + team.losses > 0).toList());
  //}
  
}
