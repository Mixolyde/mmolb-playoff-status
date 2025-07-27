

/*
{
  "games": [
      {
          "away_score": 6,
          "away_team_color": "068200",
          "away_team_emoji": "\ud83d\udc38",
          "away_team_id": "6805db0cac48194de3cd40ee",
          "away_team_name": "Atlanta Tree Frogs",
          "day": 1,
          "game_id": "6874dbabd759dcb31e10a630",
          "home_score": 4,
          "home_team_color": "de0000",
          "home_team_emoji": "\ud83d\udc1e",
          "home_team_id": "6805db0cac48194de3cd407c",
          "home_team_name": "Baltimore Lady Beetles",
          "state": "Complete",
          "status": "Final",
          "weather": {
              "Emoji": "\ud83d\ude9a",
              "Name": "Shipment",
              "Tooltip": "Three magic items are delivered."
          }
      },
    ]
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
  final int day;
  final String gameWinnerId;
  
  Game({this.id = '', this.awayTeam = '', this.awayTeamNickname = '',
    this.awayScore = 0,
    this.homeTeam = '', this.homeTeamNickname = '', 
    this.homeScore = 0,
    this.gameComplete = false,
    this.day = 0,
    this.gameWinnerId = ''});
    
  factory Game.fromJson(Map<String, dynamic> json){
    //print("Id: ${json['game_id']} Day: ${json['day']}");

    num awayScore = json['away_score'] as num? ?? 0;
    num homeScore = json['home_score'] as num? ?? 0;
    String gameWinnerId = "";;

    if (json['state'] as String == "Complete"){
      if (awayScore > homeScore) {
        gameWinnerId = json['away_team_id'];
      } else {
        gameWinnerId = json['home_team_id'];
      }
    } 
    
    return Game(
      id: json['game_id'] as String,
      awayTeam: json['away_team_id'] as String,
      awayTeamNickname: json['away_team_name'] as String,
      awayScore: awayScore,
      homeTeam: json['home_team_id'] as String,
      homeTeamNickname: json['home_team_name'] as String,
      homeScore: homeScore,      
      gameComplete: (json['state'] as String == "Complete"),
      day: json['day'] as int,
      gameWinnerId: gameWinnerId,
    );
  }

  @override
  String toString() => 'Day $day $awayTeamNickname @ $homeTeamNickname '
    'Completed: $gameComplete Score:$awayScore-$homeScore';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Game &&
      other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
