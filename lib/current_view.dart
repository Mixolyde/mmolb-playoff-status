enum View {about, winsbehind, winningmagic, eliminationmagic, chances, postseason, bracket}

enum LeagueType {greater, lesser}

class CurrentView {
  // 0 or 1
  int activeLeague = 0;
  View activeView  = View.winsbehind;
  bool groupBySubLeague = false;
  LeagueType leagueType = LeagueType.greater;
  
  CurrentView({this.activeLeague = 0, 
  this.activeView = View.winsbehind,
  this.groupBySubLeague = false,
  leagueType = LeagueType.greater
});
  
  CurrentView.fromHash(String hash){
    print('Restoring view from hash: $hash');
    //#activeLeague=0&activeView=0&groupBySubLeague=false&leagueType=0
    var exp = RegExp(r'#activeLeague=([0|1])&activeView=(\w+)&groupBySubLeague=(\w+)&leagueType=([0|1])');
    var match = exp.firstMatch(hash);
    if(match != null){
      //print(match.groups([1, 2, 3]));
      activeLeague = int.parse(match.group(1) ?? '0');
      activeView = View.values[int.parse(match.group(2) ?? '1')];
      groupBySubLeague = match.group(3) == 'true' ? true : false;
      leagueType = LeagueType.values[int.parse(match.group(4) ?? '0')];
    } else {
      print('$hash did not match regex');
      activeLeague = 0;
      activeView = View.values[1];
      groupBySubLeague = false;
      leagueType = LeagueType.greater;
    }
  }

  factory CurrentView.fromJson(Map<String, dynamic> json){
    //key1: json['key1'] == null ? null : json['key1'],
    return CurrentView(
      activeLeague: json['activeLeague'] as int,
      activeView: View.values[json['activeView']],
      groupBySubLeague: json['groupBySubLeague'] == null ? false : 
        json['groupBySubLeague'] as bool,
      leagueType: LeagueType.values[json['leagueType'] ?? 0],
    );
  }

  Map toJson() => {
    'activeLeague': activeLeague,
    'activeView': activeView.index,
    'groupBySubLeague': groupBySubLeague,
    'leagueType': leagueType.index,
  };
  
  String toHash() => '#activeLeague=$activeLeague&activeView=${activeView.index}&groupBySubLeague=$groupBySubLeague^&leagueType=${leagueType.index}';
  
  @override
  String toString() => 'League: $activeLeague View: $activeView GroupBySubLeague: $groupBySubLeague LeagueType: $leagueType';
}
