/*
  'id': 'dc767612-eb77-417b-8d2f-c21eb4dab868',
  'basesOccupied': [],
  'baseRunners': [],
  'baseRunnerNames': [],
  'baserunnerCount': 0,
  'outcomes': [],
  'terminology': 'b67e9bbb-1495-4e1b-b517-f1444b0a6c8b',
  'lastUpdate': 'Game over.',
  'rules': '4ae9d46a-5408-460a-84fb-cbd8d03fff6c',
  'statsheet': 'a8fd2115-7d95-42f9-8bfe-b44132da2b16',
  'awayPitcher': 'c182f33c-aea5-48a2-97ed-dc74fa29b3c0',
  'awayPitcherName': 'Swamuel Mora',
  'awayBatter': 'e4e4c17d-8128-4704-9e04-f244d4573c4d',
  'awayBatterName': 'Wesley Poole',
  'awayTeam': 'ca3f1c8c-c025-4d8e-8eef-5be6accbeb16',
  'awayTeamName': 'Chicago Firefighters',
  'awayTeamNickname': 'Firefighters',
  'awayTeamColor': '#8c2a3e',
  'awayTeamEmoji': '0x1F525',
  'awayOdds': 0.5583847767978104,
  'awayStrikes': 3,
  'awayScore': 4,
  'awayTeamBatterCount': 35,
  'homePitcher': 'db33a54c-3934-478f-bad4-fc313ac2580e',
  'homePitcherName': 'Percival Wheeler',
  'homeBatter': null,
  'homeBatterName': null,
  'homeTeam': 'b72f3061-f573-40d7-832a-5ad475bd7909',
  'homeTeamName': 'San Francisco Lovers',
  'homeTeamNickname': 'Lovers',
  'homeTeamColor': '#780018',
  'homeTeamEmoji': '0x1F48B',
  'homeOdds': 0.44161522320218954,
  'homeStrikes': 3,
  'homeScore': 2,
  'homeTeamBatterCount': 31,
  'season': 1,
  'isPostseason': false,
  'day': 28,
  'phase': 4,
  'gameComplete': true,
  'finalized': true,
  'gameStart': true,
  'halfInningOuts': 0,
  'halfInningScore': 0,
  'inning': 8,
  'topOfInning': false,
  'atBatBalls': 0,
  'atBatStrikes': 0,
  'seriesIndex': 2,
  'seriesLength': 3,
  'shame': false,
  'weather': 7
  */
  
class Game {
  final String id;  
  final String awayTeam;
  final String awayTeamNickname;
  final num awayScore;
  final String homeTeam;
  final String homeTeamNickname;
  final num homeScore;
  final bool gameComplete;
  final String seasonId;
  final int day;
  final String gameWinnerId;
  
  Game({this.id = '', this.awayTeam = '', this.awayTeamNickname = '',
    this.awayScore = 0,
    this.homeTeam = '', this.homeTeamNickname = '', 
    this.homeScore = 0,
    this.gameComplete = false,
    this.seasonId = '', this.day = 0,
    this.gameWinnerId = ''});
    
  factory Game.fromJson(Map<String, dynamic> json){
    Map<String,dynamic> awayTeamMap = json['awayTeam']!;
    Map<String,dynamic> homeTeamMap = json['homeTeam']!;
    List<dynamic> gameStatesList = json['gameStates']!;
    //print("Id: ${json['id']} Day: ${json['day']}");
    num awayScore = 0;
    num homeScore = 0;
    if(gameStatesList.isNotEmpty){
      awayScore = gameStatesList[0]['awayScore'] as num? ?? 0;
      homeScore = gameStatesList[0]['homeScore'] as num? ?? 0;
    }
    
    return Game(
      id: json['id'] as String,
      awayTeam: awayTeamMap['id'] as String,
      awayTeamNickname: awayTeamMap['nickname'] as String,
      awayScore: awayScore,
      homeTeam: homeTeamMap['id'] as String,
      homeTeamNickname: homeTeamMap['nickname'] as String,
      homeScore: homeScore,      
      gameComplete: json['complete'] as bool,
      seasonId: json['seasonId'] as String,
      day: json['day'] as int,
      gameWinnerId: json['gameWinnerId'] as String? ?? '',
    );
  }

  @override
  String toString() => 'Day $day $awayTeamNickname @ $homeTeamNickname '
    'Completed: $gameComplete Score:$awayScore-$homeScore';
  
}
