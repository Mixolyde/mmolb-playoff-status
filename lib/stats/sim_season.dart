import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/site_objects.dart';
import 'package:mmolb_playoff_status/stats/sim_postseason.dart';
import 'package:mmolb_playoff_status/stats/sim_utils.dart';

Future<void> calculateChances(List<List<TeamStandings>> subStandings, 
  int numSims, TimeData timeData) async {
  
  print('Getting full game schedule data');
  var games = await getAllGames(subStandings);
  print("Games fetched count: ${games.length}");

  runSimulations(games, subStandings, numSims);
  
}

void runSimulations(Set<Game> games, List<List<TeamStandings>> standings, 
  int numSims) async {
  // generate map of team id to team simulation trackers
  var sims = createTeamSimMap(standings, games);
  
  //simulate season X times and gather results
  var poCounts = <String, List<num>>{};
  var postCounts = <String, List<num>>{};
  // initialize counts for each league playoff berth and no playoffs
  for (var key in sims.keys) {
    poCounts[key] = [0, 0, 0, 0, 0, 0, 0]; 
    // counts for MMOLB champ, MMOLB series, League series, WC Round
    postCounts[key] = [0, 0, 0, 0];
  }

  //List of lists of TeamSims for each greater league
  List<List<TeamSim>> simsByLeague = <List<TeamSim>>[];
  for (var standingList in standings) {
    var simList = <TeamSim>[];
    for (var standing in standingList) {
      simList.add(sims[standing.id]!);
    }
    simsByLeague.add(simList);
  }
  
  for (var count = 0; count < numSims; count++){
    
    simulateRegularSeason(games, sims);
    simulateUnstartedPostSeason(simsByLeague);
      
    if (count % 1000 == 0){
      print('Completed simulation count $count');
    }
    
    //sort and count positions
    List<TeamSim> allSims = [];
    allSims.addAll(simsByLeague.expand((x) => x));
    allSims.sort();

    TeamSim sim;
    //print('Sorted simleague: $simLeague');
    for (var i = 0; i < allSims.length; i++){
      sim = allSims[i];
      switch(i){
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
          poCounts[sim.id]![i]++;
          break;
        default:
          poCounts[sim.id]![6]++;
          break;
      }

      if(sim.mmolbChamp){
        postCounts[sim.id]![0]++;
      }
      if(sim.mmolbSeries){
        postCounts[sim.id]![1]++;
      }
      if(sim.slSeries){
        postCounts[sim.id]![2]++;
      }     
      if(sim.wcSeries){
        postCounts[sim.id]![3]++;
      }        
    }
    
    for (var sim in sims.values) { sim.load(); }
  }  
  
  //update standings with counts / numSims and format percentages
  print('Completed $numSims simulations');
  print('poCounts $poCounts');
  print('postCounts $postCounts');

  for(var standingList in standings){
    for(var standing in standingList){
    
    for(var i = 0; i < 7; i++){
      if (standing.winning[4] == 'E' && i < 6){
        standing.po[i] = 'X';
      } else if (standing.winning[4] == 'E' && i == 6) {
        standing.po[i] = 'E';
      } else {
        standing.po[i] = formatPercent(poCounts[standing.id]![i] / numSims);
      }

      /* TODO re enable when .winning converted to single league
      switch(standing.winning[i]){
        case '^':
        case 'X':
        case 'E':
          standing.po[i] = standing.winning[i];
          break;
        default:
          standing.po[i] = formatPercent(poCounts[standing.id]![i] / numSims);
          break;
      }
      */
      

    }

    //only three rounds and champ of post season percents to format
    for(var i = 0; i < 4; i++){
      //postseason percents
      if (standing.winning[4] == 'E' && i < 4){
        standing.post[i] = 'X';
      } else {
        standing.post[i] = formatPercent(postCounts[standing.id]![i] / numSims);
      }
    }
    print('$standing Po ${standing.po} Post ${standing.post} Winning ${standing.winning}');
  }
  }
  
}

void simulateRegularSeason(Set<Game> games, Map<String, TeamSim> sims){
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
  