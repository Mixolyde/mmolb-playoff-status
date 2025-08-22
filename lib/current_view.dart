enum View {about, winsbehind, winningmagic, eliminationmagic, chances, postseason, bracket}

class CurrentView {
  // 0 or 1
  int activeLeague = 0;
  View activeView  = View.winsbehind;
  bool groupBySubLeague = false;
  
  CurrentView({this.activeLeague = 0, 
  this.activeView = View.winsbehind,
  this.groupBySubLeague = false
});
  
  CurrentView.fromHash(String hash){
    print('Restoring view from hash: $hash');
    //#activeLeague=0&activeView=0&groupBySubLeague=false
    var exp = RegExp(r'#activeLeague=([0|1])&activeView=(\w+)&groupBySubLeague=(\w+)');
    var match = exp.firstMatch(hash);
    if(match != null){
      //print(match.groups([1, 2, 3]));
      activeLeague = int.parse(match.group(1) ?? '0');
      activeView = View.values[int.parse(match.group(2) ?? '1')];
      groupBySubLeague = match.group(3) == 'true' ? true : false;
    } else {
      print('$hash did not match regex');
      activeLeague = 0;
      activeView = View.values[1];
      groupBySubLeague = false;
    }
  }

  factory CurrentView.fromJson(Map<String, dynamic> json){
    //key1: json['key1'] == null ? null : json['key1'],
    return CurrentView(
      activeLeague: json['activeLeague'] as int,
      activeView: View.values[json['activeView']],
      groupBySubLeague: json['groupBySubLeague'] == null ? false : 
        json['groupBySubLeague'] as bool,
    );
  }

  Map toJson() => {
    'activeLeague': activeLeague,
    'activeView': activeView.index,
    'groupBySubLeague': groupBySubLeague,
  };
  
  String toHash() => '#activeLeague=$activeLeague&activeView=${activeView.index}&groupBySubLeague=$groupBySubLeague';
  
  @override
  String toString() => 'League: $activeLeague View: $activeView GroupBySubLeague: $groupBySubLeague';
}
