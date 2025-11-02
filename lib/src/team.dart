/* MMOLB Team api data
{    "BallparkName": "Washington Baseball Field",
    "BallparkSuffix": "Field",
    "BallparkUseCity": true,
    "BallparkWord1": null,
    "BallparkWord2": null,
    "Bench": {
        "Championships": 0,
    "Color": "de5500",
    "Emoji": "\u26be",
    "Fund": 1715,
    "IsPlaying": true,
    "LastRosterSwapAt": null,
    "League": "6805db0cac48194de3cd3fe4",
    "LineupPriority": null,
    "Location": "Washington",
    "Modifications": [],
    "Name": "Baseball Team",
    "Players": [
    "Record": {
        "Regular Season": {
            "Losses": 21,
            "RunDifferential": 35,
            "Wins": 31
        }
    },
    "SwapAvailable": true,
    "_id": "6805db0cac48194de3cd3ff7"
*/

class Team implements Comparable<Team>  {
  final String id;
  final String fullName;
  final String emoji;
  final String location;
  int wins;
  int losses;
  int runDifferential;
  
  Team({this.id = '', this.fullName = '',
    this.emoji = '',
    this.location = '',
    this.wins = 0, this.losses = 0,
    this.runDifferential = 0});
  
  factory Team.fromJson(Map<String, dynamic> json){ 
    return Team(
      id: json['_id'] as String,
      fullName: json['Name'] as String,
      emoji: json['Emoji'] as String,
      location: json['Location'] as String,
      wins: json['Record']['Regular Season']['Wins'] as int,
      losses: json['Record']['Regular Season']['Losses'] as int,
      runDifferential: json['Record']['Regular Season']['RunDifferential'] as int,
    );
  }
  
  @override
  String toString() => "$location $fullName ($wins - $losses) RunDiff: $runDifferential)";

    @override
  int compareTo(Team other) {
    if(wins != other.wins){
      return other.wins.compareTo(wins);
    } else if(runDifferential != other.runDifferential) {
      return other.runDifferential.compareTo(runDifferential);
    } else {
      return id.compareTo(other.id);
    }
  }
  
}
