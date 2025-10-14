/*
{"Day":120,
"GreaterLeagues":[
"6805db0cac48194de3cd3fe4",
"6805db0cac48194de3cd3fe5"],
"LesserLeagues":[
"6805db0cac48194de3cd3fe7",
"6805db0cac48194de3cd3fe8",
"6805db0cac48194de3cd3fe9",
"6805db0cac48194de3cd3fea",
"6805db0cac48194de3cd3feb",
"6805db0cac48194de3cd3fec",
"6805db0cac48194de3cd3fed",
"6805db0cac48194de3cd3fee",
"6805db0cac48194de3cd3fef",
"6805db0cac48194de3cd3ff0",
"6805db0cac48194de3cd3ff1",
"6805db0cac48194de3cd3ff2",
"6805db0cac48194de3cd3ff3",
"6805db0cac48194de3cd3ff4",
"6805db0cac48194de3cd3ff5",
"6805db0cac48194de3cd3ff6"],
"SeasonID":"68e73333f12cf0454a984e48",
"SeasonStatus":"Regular Season",
"_id":"e975f475dc08155e86ad5355"}
*/

class StateData {
  final int day;
  final List<String> greaterLeagues;
  final List<String> lesserLeagues;
  final List<String> eventGameIDs;
  final String seasonID;
  final String seasonStatus;
  final String id;
  
  StateData({
    required this.day,
    required this.greaterLeagues,
    required this.lesserLeagues,
    required this.eventGameIDs,
    required this.seasonID,
    required this.seasonStatus,
    required this.id,
  });

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      day: json['Day'] as int,
      greaterLeagues: List<String>.from(json['GreaterLeagues'] ?? []),
      lesserLeagues: List<String>.from(json['LesserLeagues'] ?? []),
      eventGameIDs: List<String>.from(json['EventGameIDs'] ?? []),
      seasonID: json['SeasonID'] as String,
      seasonStatus: json['SeasonStatus'] as String,
      id: json['_id'] as String,
    );
  }

  @override
  String toString() => 'StateData(day: $day, greaterLeagues: $greaterLeagues, seasonID: $seasonID, seasonStatus: $seasonStatus, id: $id)';
  
}