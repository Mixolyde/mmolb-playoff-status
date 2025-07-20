import 'package:mmolb_playoff_status/calc_stats.dart';
import 'package:mmolb_playoff_status/database_api.dart';

/// Test script used for manually executing methods and testing functionality.
Future<void> main() async { 
  // Example: Fetching state data
  var stateData = await getStateData();
  print('State Data: $stateData');

  // Example: Fetching time data
  var timeData = await getTimeData();
  print('Time Data: $timeData');

  // Example: Fetching subleague data
  var subleague = await getSubleague('6805db0cac48194de3cd3fe4');
  print('Subleague Data: $subleague');

  var team = await getTeam('6805db0cac48194de3cd3ff7');
  print('Team Data: $team');

  var teamsBySubleague = await getTeamsBySubleague(stateData);
  print('Teams by Subleague: $teamsBySubleague');

}