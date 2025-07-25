/* MMOLB api league/division data
{
    "Color": "39993a",
    "Emoji": "\u2618\ufe0f",
    "LeagueType": "Greater",
    "Name": "Clover",
    "SuperstarTeam": "6805db0dac48194de3cd4257",
    "Teams": [
        "6805db0cac48194de3cd3ff7",
        "6805db0cac48194de3cd400a",
        "6805db0cac48194de3cd401d",
        "6805db0cac48194de3cd407c",
        "6805db0cac48194de3cd40a2",
        "6805db0cac48194de3cd40b5",
        "6805db0cac48194de3cd40ee",
        "6805db0cac48194de3cd4101"
    ],
    "_id": "6805db0cac48194de3cd3fe4"
}
*/

class League {
  final String id;
  final String name;
  final String subleagueId1;
  final String subleagueId2;
  
  Subleague? subleague1;
  Subleague? subleague2;

  League({this.id = '', this.name = '', this.subleagueId1 = '', this.subleagueId2 = ''});
    
  factory League.fromJson(Map<String, dynamic> json){
    List<dynamic> subLeagueJson = json['subLeagues'];
    return League(
      id: json['id'] as String,
      name: json['name'] as String,
      subleagueId1: (subLeagueJson[0] as Map<String, dynamic>)['id'],
      subleagueId2: (subLeagueJson[1] as Map<String, dynamic>)['id'],
    );
  }
  
  @override
  String toString() => '$name:$id';
}

/* MMOLB api subleague/division data
{
    "Color": "39993a",
    "Emoji": "\u2618\ufe0f",
    "LeagueType": "Greater",
    "Name": "Clover",
    "SuperstarTeam": "6805db0dac48194de3cd4257",
    "Teams": [
        "6805db0cac48194de3cd3ff7",
        "6805db0cac48194de3cd400a",
        "6805db0cac48194de3cd401d",
        "6805db0cac48194de3cd407c",
        "6805db0cac48194de3cd40a2",
        "6805db0cac48194de3cd40b5",
        "6805db0cac48194de3cd40ee",
        "6805db0cac48194de3cd4101"
    ],
    "_id": "6805db0cac48194de3cd3fe4"
}
*/
class Subleague {
  final String id;
  final String name;
  final String leagueType;
  final List<String> teams;

  Subleague({this.id = '', this.name = '', this.leagueType = '', this.teams = const []});
    
  factory Subleague.fromJson(Map<String, dynamic> json){
    return Subleague(
      id: json['_id'] as String,
      name: json['Name'] as String,
      leagueType: json['LeagueType'] as String,
      teams: (json['Teams'] as List<dynamic>)
        .map((t) => t.toString()).toList(),
    );
  }  
  
  @override
  String toString() => '$name:$id:$leagueType';

}

/*
  'id': 'f711d960-dc28-4ae2-9249-e1f320fec7d7',
  'teams': [
    'b72f3061-f573-40d7-832a-5ad475bd7909',
    '878c1bf6-0d21-4659-bfee-916c8314d69c',
    'b024e975-1c4a-4575-8936-a3754a08806a',
    'adc5b394-8f76-416d-9ce9-813706877b84',
    'ca3f1c8c-c025-4d8e-8eef-5be6accbeb16'
  ],
  'name': 'Lawful Good'
  */
class Division{
  final String id;
  final String name;
  final List<String> teams;  
  
  Division({required this.id, required this.name, required this.teams});
    
  factory Division.fromJson(Map<String, dynamic> json){
    return Division(
      id: json['id'] as String,
      name: json['name'] as String,
      teams: (json['teams'] as List<dynamic>)
        .map((t) => t.toString()).toList(),
    );
  }  
  
  @override
  String toString() => '$name:$id';
  
}
