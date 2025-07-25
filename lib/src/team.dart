/* MMOLB Team api data
{"Abbreviation":"WAS",
"Active":true,
"Augments":0,
"BallparkName":"Washington Baseball Field",
"BallparkSuffix":"Field",
"BallparkUseCity":true,
"BallparkWord1":null,
"BallparkWord2":null,
"Championships":0,
"Color":"de5500",
"Emoji":"\u26be",
FEED
"FullLocation":"Washington D.C., DC, USA",
"League":"6805db0cac48194de3cd3fe4",
"Location":"Washington",
"Modifications":[],
"Motto":"We're from Washington.",
"Name":"Baseball Team",
"OwnerID":null,
PLAYERS
"Record":{"Regular Season":{"Losses":39,"RunDifferential":-65,"Wins":30}},
"SeasonRecords":{"6805db0fac48194de3cd42d1":"6805e5e5ac48194de3cd4353","6846ba011b7a53d888cdef49":"6846cf0abbbdca25fbc09e0b","6858e7be2d94a56ec8d460ea":"6858f83c77c1de710a904fd9","6874db85d759dcb31e10a62a":"6874e6b520e81c1eef9821ea"},
"_id":"6805db0cac48194de3cd3ff7"}
*/

class Team implements Comparable<Team>  {
  final String id;
  final String fullName;
  final String shorthand;
  final String emoji;
  final String location;
  int wins;
  int losses;
  int runDifferential;
  
  Team({this.id = '', this.fullName = '',
    this.shorthand = '', this.emoji = '',
    this.location = '',
    this.wins = 0, this.losses = 0,
    this.runDifferential = 0});
  
  factory Team.fromJson(Map<String, dynamic> json){ 
    return Team(
      id: json['_id'] as String,
      fullName: json['Name'] as String,
      shorthand: json['Abbreviation'] as String,
      emoji: json['Emoji'] as String,
      location: json['Location'] as String,
      wins: json['Record']['Regular Season']['Wins'] as int,
      losses: json['Record']['Regular Season']['Losses'] as int,
      runDifferential: json['Record']['Regular Season']['RunDifferential'] as int,
    );
  }
  
  @override
  String toString() => "$location $fullName ($shorthand) ($wins - $losses) RunDiff: $runDifferential)";

    @override
  int compareTo(Team other) {
    if(wins != other.wins){
      return other.wins.compareTo(wins);
    } else if(runDifferential != other.runDifferential) {
      return other.runDifferential.compareTo(runDifferential);
    }{
      return fullName.compareTo(other.fullName);
    }
  }
  
}
