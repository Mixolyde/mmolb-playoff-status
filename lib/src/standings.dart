
class Standings {
  final Map<String, Standing> standings;
  
  Standings(this.standings);
  
  factory Standings.fromJson(Map<String, dynamic> json){
    //var standingsMap = json as Map<String, Map<String, List<Map<String, dynamic>>>>;
    Map<String, Standing> result = <String, Standing>{};
    for (var leagueMap in json.values) {
      for (var subleagueList in leagueMap.values) {
        for (var stand in subleagueList) {
          //print(stand);
          result[stand['id'] as String] = Standing(
            id: stand['id'] as String,
            emoji: stand['emoji'] as String,
            mainColor: stand['mainColor'] as String,
            secondaryColor: stand['secondaryColor'] as String,
            fullName: stand['fullName'] as String,
            wins: stand['wins'] as int,
            losses: stand['losses'] as int,
            elimination: stand['elimination'] as bool,
            deceased: stand['deceased'] as bool,
            scattered: stand['scattered'] as bool,
          );
        }
      }
    }
    for (var leagueMap in json.values) {
      leagueMap.values.forEach( (subleagueList) =>
        subleagueList.forEach((stand){
          //print(stand);
          result[stand['id'] as String] = Standing(
            id: stand['id'] as String,
            emoji: stand['emoji'] as String,
            mainColor: stand['mainColor'] as String,
            secondaryColor: stand['secondaryColor'] as String,
            fullName: stand['fullName'] as String,
            wins: stand['wins'] as int,
            losses: stand['losses'] as int,
            elimination: stand['elimination'] as bool,
            deceased: stand['deceased'] as bool,
            scattered: stand['scattered'] as bool,
          );
        }));
    }
      
    return Standings(result);
  }
  
  @override
  String toString() => 'Standings: $standings';

}

/*
  {"id":"43a27ded-3229-49b5-9e44-2213d946588e",
  "emoji":"0x1F36C",
  "mainColor":"#178f55",
  "secondaryColor":"#178f55",
  "fullName":"Kansas City Breath Mints",
  "wins":49,"losses":35,
  "elimination":false,
  "deceased":false,
  "scattered":false},
*/

class Standing {
  final String id;
  final String emoji;
  final String mainColor;
  final String secondaryColor;
  final String fullName;
  final int wins;
  final int losses;
  final bool elimination;
  final bool deceased;
  final bool scattered; 
  
  Standing({required this.id, required this.emoji, required this.mainColor,
    required this.secondaryColor, required this.fullName,
    required this.wins, required this.losses,
    required this.elimination, required this.deceased,
    required this.scattered});
    
  @override
  String toString() => 'Standing: $id $fullName ($wins-$losses)';    
}
