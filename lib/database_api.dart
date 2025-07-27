import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'package:mmolb_playoff_status/src/game.dart';
import 'package:mmolb_playoff_status/src/league.dart';
import 'package:mmolb_playoff_status/src/playoffs.dart';
import 'package:mmolb_playoff_status/src/simulationdata.dart';
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

// Old Blaseball URLs
String apiUrl = 'https://api.blaseball.com/';
String authToken = Platform.environment['AUTH_TOKEN'] ?? "";

final String _dbUrl = '${apiUrl}database/';
final String _playoffsUrl = '${_dbUrl}playoffs?number=';
final String _playoffMatchupsUrl = '${_dbUrl}playoffMatchups?ids=';
final String _playoffRoundUrl = '${_dbUrl}playoffRound?id=';
final String _simulationDataUrl = '${apiUrl}sim';

//final String _ilbId = 'd3182b4d-91b6-4b4e-96a5-13d69e0043b7';
//final String _scheduleUrl = apiUrl + 'api/games/schedule/';
//final String _simulationDataUrl = _dbUrl + 'simulationData';
//final String _allTeamsUrl = _dbUrl + 'allTeams';
//final String _divisionUrl = _dbUrl + 'division?id=';
//final String _leagueUrl = _dbUrl + 'league?id=' + _ilbId;
//final String _standingsUrl = apiUrl + 'api/standings';
//final String _subleagueUrl = _dbUrl + 'subleague?id=';
//final String _streamDataUrl = apiUrl + 'events/streamData';

Future<Response> getWithAuthToken(String url) {
  print("Using authToken: $authToken");
  return get(
    Uri.parse(url),
    headers: {'Cookie': authToken}
  );
}

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
      throw e;
      //return <Game>[];
    }
  }).toList();

  return games;
}


/*
Future<Standings> getStandings() async {
  var response = await get(Uri.parse(_standingsUrl));
  var standings = Standings.fromJson(json.decode(response.body));
  return standings;
}

Future<Division> getDivision(String id) async {
  var response = await get(Uri.parse(_divisionUrl + id));
  return Division.fromJson(json.decode(response.body));
}
*/

// Old blaseeball API functions
Future<League> getLeague({bool deep = false}) async {
  var response = await get(Uri.parse(_simulationDataUrl));
  var responsejson = json.decode(response.body);
  Map<String, dynamic> simJson = responsejson['simData'];
  Map<String, dynamic> currentLeagueData = simJson['currentLeagueData'];
  
  //if not deep
  if(!deep) {
    //shallow league
    return League.fromJson(currentLeagueData);
  } else {
    //parse shallow league values
    League league = League.fromJson(currentLeagueData);
    //then fill in subleagues and divisions
    List<dynamic> subLeagueJson = currentLeagueData['subLeagues'];
    (subLeagueJson[0] as Map<String, dynamic>)['name'] = "Good";
    (subLeagueJson[1] as Map<String, dynamic>)['name'] = "Evil";
    
    List<dynamic> divisions1 =
      (subLeagueJson[0] as Map<String, dynamic>)['divisions'];
    List<dynamic> divisions2 =
      (subLeagueJson[1] as Map<String, dynamic>)['divisions'];
      
    divisions1[0]['teams'] = [];
    divisions1[1]['teams'] = [];
    divisions2[0]['teams'] = [];
    divisions2[1]['teams'] = [];
    
    league.subleague1 = Subleague.fromJson(
      (subLeagueJson[0] as Map<String, dynamic>));
    league.subleague2 = Subleague.fromJson(
      (subLeagueJson[1] as Map<String, dynamic>));
    
    return league;
  }
}

Future<SimulationData> getSimulationData() async {
  //print("url: $_simulationDataUrl");
  var response = await get(Uri.parse(_simulationDataUrl));
  //print('Response body: ${response.body}');
  return SimulationData.fromJson(json.decode(response.body));
}

/*
Future<Subleague> getSubleague(String id) async {
  var response = await get(Uri.parse(_subleagueUrl + id));
  return Subleague.fromJson(json.decode(response.body));
}

Future<List<Team>> getTeams() async {
  var response = await get(Uri.parse(_allTeamsUrl));
  List<dynamic> parsed = json.decode(response.body);
  var teams = parsed.map((json) => Team.fromJson(json)).toList();
  return teams;
}
*/

Future<Map<String,List<Team>>> getTeamsByDivision(String seasonId, int day) async {
  //https://api2.blaseball.com/seasons/cd1b6714-f4de-4dfc-a030-851b3459d8d1/days/0/teams
  var response = await getWithAuthToken(
    "${apiUrl}seasons/$seasonId/days/$day/teams");
  //print(response.body);
  print(response.statusCode);
  Map<String,dynamic> divisions = json.decode(response.body);
  Map<String,List<Team>> teamMap = {};
  print("${divisions.keys}");
  for(var key in divisions.keys) {
    List<Team> teams = [];
    print("Key: $key");
    divisions[key].forEach((json){
      Team team = Team.fromJson(json);
      List<dynamic> standingList = json['standings'];
      var thisStanding = standingList
        .firstWhere((stand) => stand['seasonId'] == seasonId);
      team.wins = thisStanding['wins'];
      team.losses = thisStanding['losses'];
      teams.add(team);
    });
    
    teamMap[key] = teams;
  }
  return teamMap;
}

Future<Playoffs?> getPlayoffs(int season) async {
  print('GetPlayoffs Request URL: ${_playoffsUrl + season.toString()}');
  var response = await get(Uri.parse(_playoffsUrl 
    + season.toString() ));
  //print('Response body: ***${response.body}***');
  if(response.body == '' 
    || response.body.contains('error')) {
    return null;
  } else {
    return Playoffs.fromJson(json.decode(response.body));
  }
}

Future<PlayoffRound> getPlayoffRound(String roundID) async {
  var response = await get(Uri.parse(_playoffRoundUrl + roundID ));
  //print('Response body: ${response.body}');
  return PlayoffRound.fromJson(json.decode(response.body));
}

Future<List<PlayoffMatchup>> getPlayoffMatchups(List<String> matchIDs) async {
  var response = await get(Uri.parse(_playoffMatchupsUrl 
    + matchIDs.join(',')));
  //print('Response body: ${response.body}');
  List<dynamic> parsed = json.decode(response.body);
  var matchups = parsed.map((json) => 
    PlayoffMatchup.fromJson(json)).toList();
  
  return matchups;
}

Future<CompletePostseason?> getCurrentPostseason() async {
  //var postseasons = games['postseasons'] as List<dynamic>;
  //print (postseasons);
  //if(postseasons.length == 0 || postseasons[0]!.keys.length == 0){
    print("Returning null CurrentPostseason");
    return null;
  //} else {
  //  return CompletePostseason.fromStreamData(postseasons[0]!);
  //}
  
}

Future<CompletePostseason?> getCompletePostseason(int season) async {
  var playoffs = await getPlayoffs(season);
  if(playoffs == null){
    return null;
  }
  
  return buildCompletePostseason(playoffs);
}

Future<CompletePostseason> buildCompletePostseason(Playoffs playoffs) async {

  var playoffRounds = <String, PlayoffRound>{};
  var playoffMatchups = <String, PlayoffMatchup>{};
  
  await Future.forEach(playoffs.rounds, (String id) async {
    var round = await getPlayoffRound(id);
    playoffRounds[id] = round;
    print('Fetched round ${playoffRounds[id]} with ${playoffRounds[id]?.matchupIDs.length} matchupIDs');
    if (round.matchupIDs.isNotEmpty){
      var matchups = await getPlayoffMatchups(round.matchupIDs);
      for (var matchup in matchups) {
        playoffMatchups[matchup.id] = matchup;
      }
    }
  });
  
  return CompletePostseason(id: playoffs.id, playoffs: playoffs, 
    playoffRounds: playoffRounds, playoffMatchups: playoffMatchups);
}
