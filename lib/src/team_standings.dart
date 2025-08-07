class TeamStandings implements Comparable<TeamStandings> {
  final String id;
  final String fullName;
  final String nickname;
  final String emoji;
  final String subleague;
  int wins;
  int losses;
  int runDifferential;
  final int gamesPlayed;
  
  String gbDiv = '-';
  String gbWc = '-';
  final List<String> po = ['-', '-', '-', '-', '-', '-', '-'];
  final List<String> winning = ['-', '-', '-', '-', '-'];
  final List<String> elimination = ['-', '-', '-', '-', '-'];
  final List<String> post = ['-', '-', '-', '-', '-'];  
  
  TeamStandings(this.id, 
    this.fullName, this.nickname, 
    this.emoji, this.subleague,
    this.wins, this.losses, 
    this.runDifferential,
    this.gamesPlayed);
    
  TeamStandings.fromMap({this.id = '', this.fullName = '',
    this.nickname = '', this.emoji = '', this.subleague = '', 
    this.wins = 0, this.losses = 0,
    this.runDifferential = 0,
    this.gamesPlayed = 0,
    this.gbDiv = '-', this.gbWc = '-',
    po, winning, elimination, post}){
    for(var i = 0; i < 5; i++){
      this.po[i] = po[i].toString();
      this.winning[i] = winning[i].toString();
      this.elimination[i] = elimination[i].toString();
      this.post[i] = post[i].toString();
    }
  }
    
  factory TeamStandings.fromJson(Map<String, dynamic> json){
    return TeamStandings.fromMap(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      nickname: json['nickname'] as String,
      emoji: json['emoji'] as String,
      subleague: json['subleague'] as String,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      runDifferential: json['runDifferential'] as int,
      gamesPlayed: json['gamesPlayed'] as int,
      gbDiv: json['gbDiv'] as String,
      gbWc: json['gbWc'] as String,
      po: json['po'] as List<dynamic>,
      winning: json['winning'] as List<dynamic>,
      elimination: json['elimination'] as List<dynamic>,
      post: json['post'] as List<dynamic>,
    );
  }
    
  Map toJson() => {
    'id': id,
    'fullName': fullName,
    'nickname': nickname,
    'emoji': emoji,
    'subleague': subleague,
    'wins': wins,
    'losses': losses,
    'runDifferential': runDifferential,
    'gamesPlayed': gamesPlayed,
    'gbDiv': gbDiv,
    'gbWc': gbWc,
    'po': po,
    'winning': winning,
    'elimination': elimination,
    'post': post,
  };
  
  @override
  String toString() => 'Standings: $fullName:$nickname - $subleague ($wins - $losses) RunDiff: $runDifferential';

  @override
  int compareTo(TeamStandings other) {
    if(wins != other.wins){
      return other.wins.compareTo(wins);
    } else if(runDifferential != other.runDifferential) {
      return other.runDifferential.compareTo(runDifferential);
    }else {
      return id.compareTo(other.id);
    }
  }
  
}
