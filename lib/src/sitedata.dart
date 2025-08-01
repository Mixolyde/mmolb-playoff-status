class SiteData {
  final String lastUpdate;
  final int season;
  final int day;
  final String sub1id;
  final String sub1name;
  final String sub2id;
  final String sub2name;
  final List<String> attributes;
  final int daysInSeason;
  final int gamesInSeason;

  
  List<String> get subNicknames => 
    [sub1name, sub2name];
  
  SiteData.fromMap({this.lastUpdate = '', 
    this.season = 0, this.day = 0,
    this.sub1id = '', this.sub1name = '',
    this.sub2id = '', this.sub2name = '',
    this.attributes = const [],
    this.daysInSeason = 99,
    this.gamesInSeason = 99});
  
  SiteData(this.lastUpdate, 
    this.season, this.day,
    this.sub1id, this.sub1name,
    this.sub2id, this.sub2name, 
    this.attributes, this.daysInSeason, this.gamesInSeason);
  
  factory SiteData.fromJson(Map<String, dynamic> json){
    return SiteData.fromMap(
      lastUpdate: json['lastUpdate'] as String,
      season: json['season'] as int,
      day: json['day'] as int,
      sub1id: json['sub1id'] as String,
      sub1name: json['sub1name'] as String,
      sub2id: json['sub2id'] as String,
      sub2name: json['sub2name'] as String,
      attributes: [],      
      daysInSeason: json['daysInSeason'] as int,
      gamesInSeason: json['gamesInSeason'] ?? 99, // Default to 99 if not provided
    );
  }
  
  Map toJson() => {
      'lastUpdate':    lastUpdate,
      'season':        season,
      'day':           day,
      'sub1id':        sub1id,
      'sub1name':      sub1name,
      'sub2id':        sub2id,
      'sub2name':      sub2name,
      'attributes':    attributes,
      'daysInSeason':  daysInSeason,
      'gamesInSeason': gamesInSeason,
  };
  
  @override
  String toString() => '$lastUpdate Season:$season Day:$day $sub1name $sub2name $attributes';
  
  bool get leagueWildCards => attributes.contains('WILD_CARDS');
  
  bool get leagueMildCards => attributes.contains('MILD_CARDS');

}
