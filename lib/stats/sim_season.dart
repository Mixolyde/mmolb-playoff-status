import 'dart:math';

import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/site_objects.dart';
import 'package:mmolb_playoff_status/src/game.dart';
import 'package:mmolb_playoff_status/src/timedata.dart';

Random rand = Random(0);


Future<void> calculateChances(List<List<TeamStandings>> subStandings, 
  int numSims, TimeData timeData) async {
  
  print('Getting full game schedule data');
  var games = await getAllGames(subStandings);
  print("Games fetched count: ${games.length}");

  //TODO fix live postseason stuff

  //print(games[0]);

  runSimulations(games, subStandings, numSims);
  
}

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

void runSimulations(Set<Game> games, List<List<TeamStandings>> standings, 
  int numSims) async {
  var sims = mapTeamSims(standings, games);
  
  //simulate season X times and gather results
  var poCounts = <String, List<num>>{};
  var postCounts = <String, List<num>>{};
  // initialize counts for each league playoff berth and no playoffs
  for (var key in sims.keys) {
    poCounts[key] = [0, 0, 0, 0, 0]; 
    // counts for MMOLB champ, MMOLB series, League series, WC Round
    postCounts[key] = [0, 0, 0, 0];
  }

  var simsByLeague = <List<TeamSim>>[];
  for (var standingList in standings) {
    var simList = <TeamSim>[];
    for (var standing in standingList) {
      simList.add(sims[standing.id]!);
    }
    simsByLeague.add(simList);
  }
  
  for (var count = 0; count < numSims; count++){
    /* TODO fix live postseason simulations
    if(simData.inPostSeason) {
      // set completed round/matchup standings
      print("Simulation is in PostSeason: $currentPostSeason");
      setCompletedPostSeasonStandings(standings, currentPostSeason);

      // simulate unfinished rounds
      simulateStartedPostSeason(simsByLeague, currentPostSeason);
      
    } else {
      //simulate the rest of the regular season and unstarted post season
      simulateSeason(games, sims);
      simulateUnstartedPostSeason(simsByLeague);
    }
    */
    
    simulateSeason(games, sims);
    //simulateUnstartedPostSeason(simsByLeague);
      
    if (count % 1000 == 0){
      print('Completed simulation count $count');
    }
    
    //sort and count positions
    for (var simLeague in simsByLeague) {
      simLeague.sort();
      TeamSim sim;
      //print('Sorted simleague: $simLeague');
      for (var i = 0; i < simLeague.length; i++){
        sim = simLeague[i];
        switch(i){
          case 0:
          case 1:
          case 2:
          case 3:
            poCounts[sim.id]![i]++;
            break;
          default:
            poCounts[sim.id]![4]++;
            break;
        }
        if(sim.ilbChamp){
          postCounts[sim.id]![0]++;
        }
        if(sim.ilbSeries){
          postCounts[sim.id]![1]++;
        }
        if(sim.slSeries){
          postCounts[sim.id]![2]++;
        }     
        if(sim.wcSeries){
          postCounts[sim.id]![3]++;
        }        
      }
    }
    
    for (var sim in sims.values) { sim.load(); }
  }  
  
  //update standings with counts / numSims and formatted
  print('Completed $numSims simulations');
  print('poCounts $poCounts');
  print('postCounts $postCounts');

  for(var standingList in standings){
    for(var standing in standingList){
    
    for(var i = 0; i < 5; i++){
      switch(standing.winning[i]){
        case '^':
        case 'X':
        case 'PT':
          standing.po[i] = standing.winning[i];
          break;
        default:
          standing.po[i] = formatPercent(poCounts[standing.id]![i] / numSims);
          break;
      }
      

    }

    //only three rounds and champ of post season percents to format
    for(var i = 0; i < 4; i++){
      //postseason percents
      standing.post[i] = formatPercent(postCounts[standing.id]![i] / numSims);
    }
    print('$standing Po ${standing.po} Post ${standing.post} Winning ${standing.winning}');
  }
  }
  
}

void simulateSeason(Set<Game> games, Map<String, TeamSim> sims){
  //print('SimulateSeason with TeamSim keys:');
  //print(sims.keys.join(' '));
  //print(sims);
  //print(games[0]);
  //simulate unplayed games
  games.where((g) => !g.gameComplete).forEach((g) {
    //print("Sim game between ${g.awayTeam} and ${g.homeTeam}");
    //print('Simulate outcome of $g');
    var awaySim = sims[g.awayTeam]!;
    var homeSim = sims[g.homeTeam]!;
    var winner = simulateGame(awaySim, homeSim, sims.length);
    
    if(winner == awaySim){
      awaySim.wins++;
      homeSim.losses++;
    } else {
      homeSim.wins++;
      awaySim.losses++;        
    }    
  });
}
  
/*
void simulatePostSeason(List<List<TeamSim>> simsByLeague){
  int teamCount = simsByLeague.fold(0, (sum, sub) => sum + sub.length);
  
  //simulate complete playoff run
  var leagueChampSims = <TeamSim>[];
  
  for (var simLeague in simsByLeague) {
    sortTeamSims(simLeague);
    
    var round1Sims = <TeamSim>[];
    round1Sims.add(simLeague[0]);
    round1Sims.add(simLeague[1]);
    round1Sims.add(simLeague[2]);
    
    //TODO handle MMOLB wild cards

    // mild card round
    // pick 5th place team and simulate      
    var mildCard = simLeague[4];
    simLeague.take(5).forEach((sim) => sim.wcSeries = true);
    //print('Mild Card pick $mildCard');
    //simulate 3 win series with mild card pic
    var mildSeriesWinner = simulateSeries(simLeague[3], mildCard, 2, teamCount);
    round1Sims.add(mildSeriesWinner);      
    
    // subleague round
    var slRoundSims = [r1SeriesWinnerA, r1SeriesWinnerB];
    slRoundSims.forEach((sim) => sim.slSeries = true);
    
    var slWinner = simulateSeries(slRoundSims[0], slRoundSims[1], 3, teamCount);
    leagueChampSims.add(slWinner);
  }
  // ilb round
  leagueChampSims.forEach((sim) => sim.ilbSeries = true);
  var ilbWinner = simulateSeries(leagueChampSims[0], leagueChampSims[1], 3, teamCount);
  //print('ILBWinner: $ilbWinner');
  ilbWinner.ilbChamp = true;
  
}
*/

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

Map<String, TeamSim> mapTeamSims(List<List<TeamStandings>> standings, Set<Game> games){
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
      return fullName.compareTo(other.fullName);
    }
  }
  
}