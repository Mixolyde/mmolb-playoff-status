import 'package:mmolb_playoff_status/database_api.dart';
import 'package:mmolb_playoff_status/site_objects.dart';

int gamesInRegularSeason = TimeData.gamesInRegularSeason();
Map<String,List<Team>> _allTeams = {};
late Subleague _sub1;
late Subleague _sub2;

Future<SiteData> calcSiteData(StateData stateData, TimeData timeData) async {
  print("Calculating site data for season ${timeData.seasonNumber} day ${timeData.seasonDay}");
  // get subleague data
  _sub1 = await getLeague(stateData.greaterLeagues[0]);
  _sub2 = await getLeague(stateData.greaterLeagues[1]);
  
  var lastUpdate = getUpdateTime();

  Map<String, String> lesserLeagueNames = {};
  for (var lesserLeagueId in stateData.lesserLeagues) {
    var lesserLeague = await getLeague(lesserLeagueId);
    print("Lesser League: ${lesserLeague.name} (${lesserLeague.id})");
    lesserLeagueNames[lesserLeagueId] = lesserLeague.name;

  }
  
  var sitedata = SiteData(lastUpdate, 
    timeData.seasonNumber, timeData.seasonDay,
    _sub1.id, _sub1.name, 
    _sub2.id, _sub2.name,
    lesserLeagueNames,
    [],
    TimeData.daysInRegularSeason(),
    TimeData.gamesInRegularSeason());
  //print(sitedata);

  return sitedata;
}  

String getUpdateTime(){
  var now = DateTime.now();
  print("IsoString: ${now.toIso8601String()}");
  return now.toIso8601String();
}

Future<List<List<TeamStandings>>> calcGreaterLeagueStats(StateData stateData, TimeData timeData) async {
  print('Beginning stat calculations for current season: ${timeData.seasonNumber}');
 
  _allTeams = await getGreaterLeagueTeamsBySubleague(stateData);

  var wcLeaderDiff = getWildCardDiff([_allTeams[_sub1.id]!, _allTeams[_sub2.id]!]);

  var sub1Standings = 
    await calculateSubLeague(_sub1, _allTeams[_sub1.id]!, timeData, wcLeaderDiff);
  var sub2Standings = 
    await calculateSubLeague(_sub2, _allTeams[_sub2.id]!, timeData, wcLeaderDiff);
  
  return [sub1Standings, sub2Standings];
    
}

Future<Map<String, List<TeamStandings>>> calcLesserLeagueStats(StateData stateData, TimeData timeData) async {
  print('Beginning Lesser League stat calculations for current season: ${timeData.seasonNumber}');
 
  _allTeams = await getTeamsByLesserLeagues(stateData);

  var wcLeaderDiff = 0;
  Map<String, List<TeamStandings>> lesserStandings = {};

  for (var subleagueId in stateData.lesserLeagues) {
    var subleague = await getLeague(subleagueId);

    print("Calculating Lesser League: ${subleague.name} (${subleague.id})");
    var subStandings = 
      await calculateSubLeague(subleague, _allTeams[subleague.id]!, timeData, wcLeaderDiff);
    lesserStandings[subleagueId] = subStandings;
  }
  
  return lesserStandings;
    
}

Future<List<TeamStandings>> calculateSubLeague(Subleague sub, List<Team> teams,
    TimeData timeData, int wcLeaderDiff) async{
  print('Day ${timeData.seasonDay} ${sub.name} (${sub.id})');

  print("SubLeague Teams Length: ${teams.length}");
  
  var teamStandings = <TeamStandings>[];
  for (var team in teams) {

    var gamesPlayed = gamesInRegularSeason;
    if (!timeData.inPostSeason){
      gamesPlayed = team.wins + team.losses;
    }
    
    var standing = 
      TeamStandings(team.id, 
      '${team.location} ${team.fullName}', team.shorthand, team.emoji,
      sub.name,
      team.wins, 
      team.losses,
      team.runDifferential,
      gamesPlayed);
    teamStandings.add(standing);
  }
  
  print("SubLeague TeamStandings Length: ${teamStandings.length}");

  //sort first then calculate
  teamStandings.sort();


  calculateGamesBehind(teamStandings, wcLeaderDiff);
  calculateMagicNumbers(teamStandings);
  
  return teamStandings;

}

void calculateGamesBehind(List<TeamStandings> teamStandings, int wcLeaderDiff) {
  //compute games back from Subleague leader
  var subLeaderDiff = teamStandings[0].wins - 
      (teamStandings[0].gamesPlayed - teamStandings[0].wins);

  for (var i = 1; i < teamStandings.length; i++){
    var teamDiff = teamStandings[i].wins - 
      (teamStandings[i].gamesPlayed - teamStandings[i].wins);
    num gbSubLeader = ( subLeaderDiff - teamDiff ) / 2;
    num gbWildCard = ( wcLeaderDiff - teamDiff ) / 2;
    if (gbSubLeader > 0) {
      teamStandings[i].gbDiv = formatGamesBehind(gbSubLeader);
    }
    if (gbWildCard > 0 && i > 1) {
      teamStandings[i].gbWc = formatGamesBehind(gbWildCard);
    }
    
    print('GbDiv ${teamStandings[i].gbDiv} GbWc ${teamStandings[i].gbWc}');
  }  
}

void calculateMagicNumbers(List<TeamStandings> teamStandings){
  calculateWinningMagicNumbers(teamStandings);
  calculateLosingMagicNumbers(teamStandings);
}

void calculateWinningMagicNumbers(List<TeamStandings> teamStandings) {
  for (var i = 0; i < teamStandings.length; i++){
    var maxWins = (gamesInRegularSeason - teamStandings[i].gamesPlayed) +
      teamStandings[i].wins;

    print('${teamStandings[i]} maxWins: $maxWins');

    for (var j = 0; j < i && j < 4; j++){
      teamStandings[i].winning[j] = 'MW';
      if( maxWins < teamStandings[j].wins ||
        (maxWins == teamStandings[j].wins &&
        teamStandings[i].runDifferential < teamStandings[j].runDifferential)){
        teamStandings[i].winning[j] = 'X';
      }
    }
    
    for (var b = i + 1; b < 5; b++){
      setWinningMagicNumber(teamStandings[i], 
          teamStandings[b], b - 1);
    }
        
    if(teamStandings[i].winning.any((s) => s == '^')){
      teamStandings[i].winning[4] = 'X';
    } else {
      teamStandings[i].winning[4] = '0';
    }
    
    if(teamStandings[i].winning[0] == 'X' &&
      teamStandings[i].winning[1] == 'X' &&
      teamStandings[i].winning[2] == 'X' &&
      teamStandings[i].winning[3] == 'X'){
      teamStandings[i].winning[4] = 'E';
    }
    
  }
}

void setWinningMagicNumber(TeamStandings standing, TeamStandings target,
  int winningIndex){
  //Wb + GRb - Wa + 1
  var magic = target.wins +
    (gamesInRegularSeason - target.gamesPlayed) -
    standing.wins;
  if (standing.runDifferential < target.runDifferential) {
    //team b wins ties
    magic += 1;
  }
  //print('WinMN for ${teamStandings[i]} vs. ${teamStandings[b]}: $magic');
  if (magic > 0){
    //set magic number
    standing.winning[winningIndex] = '$magic';
  } else if (winningIndex > 0 && 
    standing.winning.any((s) => s == '^')) {
    //previous spot guaranteed, so this one can't
    standing.winning[winningIndex] = 'X';
  } else {
    //this spot or better guaranteed
    standing.winning[winningIndex] = '^';
  }
    
}

void calculateLosingMagicNumbers(List<TeamStandings> teamStandings) {
    
  for (var i = 0; i < teamStandings.length; i++){
    var stand = teamStandings[i];
    var maxWins = (gamesInRegularSeason - stand.gamesPlayed) + stand.wins;
    for(var k = 0; k < 5; k++){
      switch(stand.winning[k]){
        case '^':
        case 'X':
        case 'E':
          stand.elimination[k] = stand.winning[k];
          break;
        default:
          if(i <= k) {
            stand.elimination[k] = 'MW';
          } else if (k == 4) {
            stand.elimination[k] = 'MW';
          } else {
            //maxWinsi - Wk
            //print('Find Elim: $stand Berth: $k');
            var magic = maxWins - teamStandings[k].wins;
            //if we don't have favor, elim is one lower
            if(stand.runDifferential > teamStandings[k].runDifferential) {
              magic += 1;
            }
            stand.elimination[k] = '$magic';
          }
          
          break;
      } 
    }
  }
}

int getWildCardDiff(List<List<Team>> teams) {
  //compute games back from Wild Card leader
  List<Team> league1Teams = teams[0].toList();
  List<Team> league2Teams = teams[1].toList();

  league1Teams.sort();
  league2Teams.sort();

  // remove first two teams from standings
  league1Teams.removeRange(0, 2);
  league2Teams.removeRange(0, 2);

  // merge the two lists
  league1Teams.addAll(league2Teams);

  // sort all teams
  league1Teams.sort();

  // calculate the wild card leader difference of the second team
  int wcLeaderGamesPlayed = league1Teams[1].wins + league1Teams[1].losses;
  var wcLeaderDiff = league1Teams[1].wins - 
      (wcLeaderGamesPlayed - league1Teams[1].wins);

  print('WC Leader Diff: $wcLeaderDiff from team ${league1Teams[1].fullName}');
  
  return wcLeaderDiff;
}


Future<Map<String,List<Team>>> getGreaterLeagueTeamsBySubleague(StateData stateData) async {
  print("Greater League subleague ids: ${stateData.greaterLeagues}");
  Map<String,List<Team>> teamMap = {};

  for (var subleague in [_sub1, _sub2]) {
    print("Subleague: ${subleague.name} (${subleague.id})");
    List<Team> teams = [];
    for (var teamId in subleague.teams) {
      var team = await getTeam(teamId);
      teams.add(team);
    }
    teamMap[subleague.id] = teams;
  }

  return teamMap;
}

Future<Map<String,List<Team>>> getTeamsByLesserLeagues(StateData stateData) async {
  print("Lesser League subleague ids: ${stateData.lesserLeagues}");
  Map<String,List<Team>> teamMap = {};

  for (var lesserLeagueId in stateData.lesserLeagues) {
    teamMap.putIfAbsent(lesserLeagueId, () => []);
    var subleague = await getLeague(lesserLeagueId);
    var lesserTeamIds = subleague.teams;
    print("Fetching Subleague: ${subleague.name} (${subleague.id})");
    while (lesserTeamIds.isNotEmpty) {
      print("Teams left to fetch: ${lesserTeamIds.length}");
      // trim the list to 100 teams (max API limit)
      var allLesserTeamsToFetch = lesserTeamIds.take(100).toList();  
      var teams = await getTeams(allLesserTeamsToFetch);
      for (Team team in teams) {
        teamMap[lesserLeagueId]!.add(team);
      }
      lesserTeamIds.removeRange(0, 100 > lesserTeamIds.length ? lesserTeamIds.length : 100);
    }
  }

  return teamMap;
}

String formatGamesBehind(num gb){
  if(gb == gb.toInt()){
    return gb.toInt().toString();
  } else if (gb < 1 ) {
    return '½';
  } else {
    return '${gb.toInt()}½';
  }
}