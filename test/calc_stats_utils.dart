import 'package:mmolb_playoff_status/src/team_standings.dart';

//test data used for generating standings
List<List<dynamic>> standingsData = [
//name, subleague, run differential, wins, losses
['Crabs',        'High', 18, 66, 24],
['Spies',         'Low', 20, 55, 35],
['Sunbeams',      'Low', 10, 53, 36],
['Flowers',       'Low', 14, 48, 42],
['Firefighters', 'High',  7, 43, 46],
['Millenials',   'High', 12, 43, 46],
['Dale',          'Low', 11, 37, 53],
['Jazz Hands',   'High', 13, 36, 53],
['Lovers',       'High',  2, 35, 55],
['Tacos',         'Low',  3, 33, 56]];

List<TeamStandings> getNewSeasonStandings(){
  //gamesInRegularSeason = 99;
  var teamStandings = <TeamStandings>[];
  for(var i = 0; i < standingsData.length; i++){
    teamStandings.add(TeamStandings(
      i.toString(),
      standingsData[i][0],
      standingsData[i][0],
      'emoji $i',
      standingsData[i][1],
      0,
      0,
      0,
      0,
    ));
  }
  
  teamStandings.sort();

  return teamStandings;
  
}


List<TeamStandings> getLateSeasonStandings(){
  //gamesInRegularSeason = 99;
  var teamStandings = <TeamStandings>[];
  for(var i = 0; i < standingsData.length; i++){
    teamStandings.add(TeamStandings(
      i.toString(),
      standingsData[i][0],
      standingsData[i][0],
      'emoji $i',
      standingsData[i][1],
      standingsData[i][3],
      standingsData[i][4],
      standingsData[i][2],
      standingsData[i][3] + standingsData[i][4],
    ));
  }
  
  return teamStandings;
}