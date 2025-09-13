import 'dart:convert';
import 'package:http/http.dart';

import 'package:mmolb_playoff_status/src/game.dart';
import 'package:mmolb_playoff_status/src/league.dart';
import 'package:mmolb_playoff_status/src/statedata.dart';
import 'package:mmolb_playoff_status/src/team.dart';
import 'package:mmolb_playoff_status/src/timedata.dart';

export 'src/game.dart';
export 'src/league.dart';
export 'src/playoffs.dart';
export 'src/simulationdata.dart';
export 'src/standings.dart';
export 'src/statedata.dart';
export 'src/team.dart';
export 'src/timedata.dart';

// New MMOLB API URLs
String mmolbApiUrl = 'https://mmolb.com/api/';

final String _stateUrl = '${mmolbApiUrl}state';
final String _timeUrl = '${mmolbApiUrl}time';
final String _subleagueUrl = '${mmolbApiUrl}league/';
final String _teamScheduleUrl = '${mmolbApiUrl}team-schedule/';
final String _teamUrl = '${mmolbApiUrl}team/';

Future<StateData> getStateData() async {
  //print("state url: $_stateUrl");
  var stateResponse = await get(Uri.parse(_stateUrl));
  print('state Response body: ${stateResponse.body}');
  return StateData.fromJson(json.decode(stateResponse.body));
}

Future<TimeData> getTimeData() async {
  //print("time url: $_timeUrl");
  var timeResponse = await get(Uri.parse(_timeUrl));
  print('Time Response body: ${timeResponse.body}');
  return TimeData.fromJson(json.decode(timeResponse.body));
}

// get subleague/division data: https://mmolb.com/api/league/6805db0cac48194de3cd3fe4
Future<Subleague> getSubleague(String id) async {
  var response = await get(Uri.parse(_subleagueUrl + id));
  print('Subleague Response body: ${response.body}');
  if (response.statusCode == 200) {
    return Subleague.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load subleague');
  }
}

// get team data: https://mmolb.com/api/team/6805db0cac48194de3cd3ff7
Future<Team> getTeam(String id) async {
  var response = await get(Uri.parse(_teamUrl + id));
  //print('Team Response body: ${response.body}');
  if (response.statusCode == 200) {
    return Team.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load team');
  }
}

//https://mmolb.com/api/team-schedule/6805db0cac48194de3cd407c
Future<List<Game>> getAllRegularSeasonGamesByTeamId(String teamId) async {
  var response = await get(Uri.parse(_teamScheduleUrl + teamId));
  //print('Team Response body: ${response.body}');
  
  List<dynamic> entities = json.decode(response.body)['games'];
  print("Entity count: ${entities.length}");
  
  var games = entities.expand((json) {
   try {
      return [Game.fromJson(json)];
    } catch (e) {
      print('Bad game json: $json');
      print(e);
      rethrow;
    }
  }).toList();

  return games;
}
