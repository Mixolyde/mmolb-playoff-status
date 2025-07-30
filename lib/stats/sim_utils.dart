import 'dart:math';

import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/site_objects.dart';

Random rand = Random(0);

Future<Set<Game>> getAllGames(List<List<TeamStandings>> subStandings) async{
  Set<Game> games = {};
  for (var standingsList in subStandings) {
    for (var standing in standingsList) {
      var gamesById = await getAllRegularSeasonGamesByTeamId(standing.id);
      games.addAll(gamesById);
    }
  }

  return games;

}


TeamSim simulateGame(TeamSim awaySim, TeamSim homeSim, int teamCount){
  //default away chance
  num awayChance = .5;
  if(awaySim.winsSave != homeSim.winsSave ||
    awaySim.lossesSave != homeSim.lossesSave){
    //print('Uneven match: ${awaySim.actualwinsSave}-${awaySim.lossesSave} vs. ' +
    //  '${homeSim.actualwinsSave}-${homeSim.lossesSave}');
    //Pa = (wPa * (1 - wPh)) / 
    // ((wPa * (1 - wPh) + wPh * ( 1 - wPa)))
    num wPa = awaySim.winsSave / (awaySim.lossesSave + awaySim.winsSave);
    num wPh = homeSim.winsSave / (homeSim.lossesSave + homeSim.winsSave);
    awayChance = (wPa * (1 - wPh)) / 
      ((wPa * (1 - wPh) + wPh * ( 1 - wPa)));
    //adjust chance for N-team league average without this team
    //WP'(N) = WP - ((WP - .500) / (N - 1))
    awayChance = awayChance - ((awayChance - .5) / (teamCount - 1));
  }
  
  //print('Calculated away win chance: $awayChance');    
  if(rand.nextDouble() < awayChance){
    return awaySim;
  } else {
    return homeSim;        
  }    
  
}


TeamSim simulateSeries(TeamSim awaySim, TeamSim homeSim, int winsNeeded, int teamCount){
  var awayWins = 0;
  var homeWins = 0;
  TeamSim winner;
  while(awayWins < winsNeeded && homeWins < winsNeeded){
    winner = simulateGame(awaySim, homeSim, teamCount);
    if(winner == awaySim){
      awayWins++;
    } else {
      homeWins++;
    }
  }
  if(awayWins >= winsNeeded){
    return awaySim;
  } else {
    return homeSim;
  }
  
}

Map<String, TeamSim> createTeamSimMap(List<List<TeamStandings>> standings, Set<Game> games){
  var sims = <String, TeamSim>{};
  for (var standingsList in standings) {
    for (var standing in standingsList) {
      var sim = TeamSim(standing.id, 
        standing.wins, standing.losses,
        standing.runDifferential,
        standing.fullName);
      sim.save();
      sims[sim.id] = sim;
    }
  }
  return sims;
}

String formatPercent(num perc){
  perc *= 100;
  if(perc < 1){
    return '<1%';
  } else if (perc > 99){
    return '>99%';
  } else {
    return '${perc.floor().toString()}%';
  }
}

class TeamSim implements Comparable<TeamSim> {
  String id;
  int wins;
  int losses;
  int runDifferential;
  String fullName;
  
  int winsSave = 0;
  int lossesSave = 0;
  
  bool wcSeries = false;
  bool slSeries = false;
  bool ilbSeries = false;
  bool ilbChamp = false;
  
  TeamSim(this.id, this.wins, this.losses,
    this.runDifferential, this.fullName);
  
  void save(){
    winsSave = wins;
    lossesSave = losses;
  }
  
  void load(){
    wins = winsSave;
    losses = lossesSave;
    wcSeries = false;
    slSeries = false;
    ilbSeries = false;
    ilbChamp = false;
  }
  
  @override
  String toString() => '$id Wins $wins Record: ($wins - $losses) '
    'Saved: $winsSave $lossesSave';

  @override
  int compareTo(TeamSim other) {
    if(wins != other.wins){
      return other.wins.compareTo(wins);
    } else if(runDifferential != other.runDifferential) {
      return other.runDifferential.compareTo(runDifferential);
    } else {
      return id.compareTo(other.id);
    }
  }
  
}