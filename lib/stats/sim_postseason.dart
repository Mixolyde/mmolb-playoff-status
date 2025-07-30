import 'package:mmolb_playoff_status/stats/sim_utils.dart';

//simulate complete playoff run
void simulateUnstartedPostSeason(List<List<TeamSim>> simsByLeague){
  //print("Simulating unstarted postseason for ${simsByLeague.length} leagues");
  int teamCount = simsByLeague.expand((simList) => simList).length;
  //print("Simulating unstarted postseason for $teamCount teams");

  // figure out the wild cards from both leagues
  simsByLeague[0].sort();
  simsByLeague[1].sort();

  var wildCardRoundSims = <TeamSim>[];

  wildCardRoundSims.add(simsByLeague[0][0]);
  wildCardRoundSims.add(simsByLeague[0][1]);
  wildCardRoundSims.add(simsByLeague[1][0]);
  wildCardRoundSims.add(simsByLeague[1][1]);

  //print("WildCardRoundSims from top 2 of each league: ${wildCardRoundSims.join('\n')}");

  //join all leagues into one league to find wild card teams
  var allWildSims = <TeamSim>[];
  allWildSims.addAll(simsByLeague.expand((simList) => simList));
  allWildSims.removeWhere((sim) => wildCardRoundSims.contains(sim));
  allWildSims.sort();

  //print("Selecting wild card teams from: ${allWildSims.length} teams");
  wildCardRoundSims.addAll(allWildSims.take(2));

  for(var sim in wildCardRoundSims) {
    sim.wcSeries = true;
  }

  print("WildCardRoundSims after adding top 2 wild cards: ${wildCardRoundSims.join('\n')}");
  
  //TODO remove postseason games from win-loss record
  
  // wild card round

  // simulate 2 win series with 2nd place league team and a wild card team
  // TODO flip a coin for wild card selection
  var wildSeriesWinner1 = simulateSeries(wildCardRoundSims[1], wildCardRoundSims[4], 2, teamCount);
  var wildSeriesWinner2 = simulateSeries(wildCardRoundSims[3], wildCardRoundSims[5], 2, teamCount);
  
  // subleague round
  // add 1st place teams to subleague series sims
  var slRoundSims = [wildCardRoundSims[0], wildCardRoundSims[2]];
  slRoundSims.add(wildSeriesWinner1);
  slRoundSims.add(wildSeriesWinner2);
  for(var sim in slRoundSims) {
    sim.slSeries = true;
  }
  //print('slRoundSims: ${slRoundSims.join('\n')}');
  
  //simulate 3 win series with 1st place league team and wild card round winner
  var slWinner1 = simulateSeries(slRoundSims[0], slRoundSims[2], 3, teamCount);
  var slWinner2 = simulateSeries(slRoundSims[1], slRoundSims[3], 3, teamCount);

  var leagueChampSims = <TeamSim>[];
  leagueChampSims.add(slWinner1);
  leagueChampSims.add(slWinner2);
  for (var sim in leagueChampSims) {
    sim.mmolbSeries = true;
  }
  //print('leagueChampSims: ${leagueChampSims.join('\n')}');

  // mmolb champ round
  //simulate 4 win series with subleague winners
  var mmolbWinner = simulateSeries(leagueChampSims[0], leagueChampSims[1], 4, teamCount);
  mmolbWinner.mmolbChamp = true;
  //print('mmolbWinner: $mmolbWinner');
  
}
