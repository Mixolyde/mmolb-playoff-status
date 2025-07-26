enum View {about, winsbehind, winningmagic, partytimemagic, chances, postseason, bracket}

class CurrentView {
  // 0 or 1
  int activeLeague = 0;
  View activeView  = View.winsbehind;
  
  CurrentView({this.activeLeague = 0, 
  this.activeView = View.winsbehind,
});
  
  CurrentView.fromHash(String hash){
    print('Restoring view from hash: $hash');
    //#activeLeague=0&activeView=0
    var exp = RegExp(r'#activeLeague=([0|1])&activeView=(\w+)');
    var match = exp.firstMatch(hash);
    if(match != null){
      //print(match.groups([1, 2, 3]));
      activeLeague = int.parse(match.group(1) ?? '0');
      activeView = View.values[int.parse(match.group(2) ?? '1')];
    } else {
      print('$hash did not match regex');
      activeLeague = 0;
      activeView = View.values[1];
    }
  }

  factory CurrentView.fromJson(Map<String, dynamic> json){
    //key1: json['key1'] == null ? null : json['key1'],
    return CurrentView(
      activeLeague: json['activeLeague'] as int,
      activeView: View.values[json['activeView']],
    );
  }

  Map toJson() => {
    'activeLeague': activeLeague,
    'activeView': activeView.index,
  };
  
  String toHash() => '#activeLeague=$activeLeague&activeView=${activeView.index}';
  
  @override
  String toString() => 'League: $activeLeague View: $activeView';
}
