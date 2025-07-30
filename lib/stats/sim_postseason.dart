import 'package:mmolb_playoff_status/stats/sim_utils.dart';

void simulateUnstartedPostSeason(List<List<TeamSim>> simsByLeague){
  int teamCount = simsByLeague.fold(0, (sum, sub) => sum + sub.length);
  
  //simulate complete playoff run
  var leagueChampSims = <TeamSim>[];

  // figure out the wild cards from both leagues
  
  for (var simLeague in simsByLeague) {

    //TODO remove postseason games from win-loss record
    simLeague.sort();
    
    var round1Sims = <TeamSim>[];
    round1Sims.add(simLeague[0]);
    round1Sims.add(simLeague[1]);
    round1Sims.add(simLeague[2]);
    
    if (true){
    
      // wild card round
      // pick a random team not in playoffs and simulate
      var nonPlayoffCount = simLeague.length - 4;
      var wildCardIndex = rand.nextInt(nonPlayoffCount) + 4;
      var wildCard = simLeague[wildCardIndex];
      simLeague.take(4).forEach((sim) => sim.wcSeries = true);
      wildCard.wcSeries = true;
      //print('WildCard pick $wildCardIndex $wildCard');
      //simulate 3 win series with wild card pic
      var wildSeriesWinner = simulateSeries(simLeague[3], wildCard, 2, teamCount);
      round1Sims.add(wildSeriesWinner);
      //print('WildCard pick $wildCardIndex $wildCard WildSeriesWinner $wildSeriesWinner');
      
    }
    
    //round1Sims.forEach((sim) => sim.r1Series = true);
    
    // round 1
    var r1SeriesWinnerA = simulateSeries(round1Sims[0], round1Sims[3], 3, teamCount);
    var r1SeriesWinnerB = simulateSeries(round1Sims[1], round1Sims[2], 3, teamCount);
    
    // subleague round
    var slRoundSims = [r1SeriesWinnerA, r1SeriesWinnerB];
    for(var sim in slRoundSims) {
      sim.slSeries = true;
    }
    
    var slWinner = simulateSeries(slRoundSims[0], slRoundSims[1], 3, teamCount);
    leagueChampSims.add(slWinner);
  }
  // ilb round
  //leagueChampSims.forEach((sim) => sim.ilbSeries = true);
  var ilbWinner = simulateSeries(leagueChampSims[0], leagueChampSims[1], 3, teamCount);
  print('ILBWinner: $ilbWinner');
  ilbWinner.ilbChamp = true;
  
}
