/*
{
    "phase_times": {
        "ElectionStart": "2025-07-27T00:00:00-05:00",
        "HolidayStart": "2025-07-27T16:00:00-05:00",
        "HomeRunChallenge": "2025-07-19T20:00:00-05:00",
        "OpeningDay": "2025-07-14T01:00:00-05:00",
        "PostseasonPreview": "2025-07-25T00:00:00-05:00",
        "PostseasonRound1": "2025-07-25T20:00:00-05:00",
        "PostseasonRound2": "2025-07-26T08:00:00-05:00",
        "PostseasonRound3": "2025-07-26T14:00:00-05:00",
        "Preseason": "2025-07-14T00:00:00-05:00",
        "RegularSeasonResume": "2025-07-19T23:00:00-05:00",
        "SuperstarBreakStart": "2025-07-19T03:00:00-05:00",
        "SuperstarGame": "2025-07-19T21:00:00-05:00"
    },
    "season_day": 74,
    "season_number": 3,
    "season_status": "Regular Season"
}

*/

class TimeData {
  final Map<String, String> phaseTimes;
  final int seasonDay;
  final int seasonNumber;
  final String seasonStatus;

  TimeData({
    required this.phaseTimes,
    required this.seasonDay,
    required this.seasonNumber,
    required this.seasonStatus,
  });

  factory TimeData.fromJson(Map<String, dynamic> json) {
    return TimeData(
      phaseTimes: Map<String, String>.from(json['phase_times']),
      seasonDay: json['season_day'] as int,
      seasonNumber: json['season_number'] as int,
      seasonStatus: json['season_status'] as String,
    );
  }

  @override
  String toString() => 'Phase Times: $phaseTimes, Season Day: $seasonDay, Season Number: $seasonNumber, Season Status: $seasonStatus';
  
  bool get inPostSeason => seasonDay >= daysInRegularSeason();
  
  static int daysInRegularSeason() {
    return 239;
  }
  
  static int gamesInRegularSeason() {
    return 120;
  } 
}