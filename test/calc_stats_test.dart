import 'package:test/test.dart';

import 'package:mmolb_playoff_status/src/team_standings.dart';
import '../lib/stats/calc_stats.dart';

import 'calc_stats_utils.dart';

void main() {
  group('format tests', () {
    test('Format games behind', () {
      expect(formatGamesBehind(0), '0');
      expect(formatGamesBehind(1), '1');
      expect(formatGamesBehind(0.5), '½');
      expect(formatGamesBehind(1.5), '1½');
      expect(formatGamesBehind(2.5), '2½');
    });
  });

  group('Games Behind number tests', () {
    test('Near season end', () {
      var standings = getLateSeasonStandings();
      // wcLeaderDiff = 6
      calculateGamesBehind(standings, 6);

      // Crabs (High 1): -
      expect(standings[0].gbDiv, '-');
      expect(standings[0].gbWc, '-');

      // Spies (Low 1): - (was 11 gbDiv but now we are global?)
      // Wait, subLeaderDiff is Crabs (66 wins, 90 played -> diff 42)
      // Spies (55 wins, 90 played -> diff 20). gbDiv = (42 - 20)/2 = 11.
      expect(standings[1].gbDiv, '11');
      expect(standings[1].gbWc, '-');

      // Sunbeams (Low 2): (42 - (53-36))/2 = (42-17)/2 = 12.5
      expect(standings[2].gbDiv, '12½');
      expect(standings[2].gbWc, '-');

      // Flowers (Low 3): (42 - (48-42))/2 = (42-6)/2 = 18. wcCount=1
      expect(standings[3].gbDiv, '18');
      expect(standings[3].gbWc, '-');

      // Firefighters (High 2): (42 - (43-46))/2 = (42 - (-3))/2 = 22.5. subCount[High]=2
      expect(standings[4].gbDiv, '22½');
      expect(standings[4].gbWc, '-'); // USED TO BE 4.5, NOW '-' because High #2

      // Millenials (High 3): subCount[High]=3. wcCount=2
      expect(standings[5].gbDiv, '22½');
      expect(standings[5].gbWc, '-');
      
      // Dale (Low 4): subCount[Low]=4. wcCount=3.
      // teamDiff = 37-53 = -16. wcLeaderDiff = 6. (6 - (-16))/2 = 11.
      expect(standings[6].gbWc, '11');
    });

    test('All same wins', () {
      var standings = List.generate(
        10,
        (i) => TeamStandings('$i', 'Team $i', 'T$i', 'E', 'H', 50, 50, 0, 100),
      );
      calculateGamesBehind(standings, 0);

      for (var i = 0; i < 10; i++) {
        expect(standings[i].gbDiv, '-');
        expect(standings[i].gbWc, '-');
      }
    });

    test('All different wins', () {
      var standings = List.generate(
        10,
        (i) => TeamStandings(
          '$i',
          'Team $i',
          'T$i',
          'E',
          'H',
          100 - i,
          i,
          0,
          100,
        ),
      );
      // wcLeaderDiff = 100
      calculateGamesBehind(standings, 100);

      expect(standings[0].gbDiv, '-');
      expect(standings[0].gbWc, '-');

      expect(standings[1].gbDiv, '1');
      expect(standings[1].gbWc, '-'); // subCount=2

      expect(standings[2].gbDiv, '2');
      expect(standings[2].gbWc, '-'); // subCount=3, wcCount=1

      expect(standings[3].gbDiv, '3');
      expect(standings[3].gbWc, '-'); // subCount=4, wcCount=2

      for (var i = 4; i < 10; i++) {
        expect(standings[i].gbDiv, i.toString());
        expect(standings[i].gbWc, i.toString()); // wcCount=3+
      }
    });

    test('Top 6 teams have no gbWc', () {
      var s1Wins = [100, 95, 90, 85, 80, 75];
      var s2Wins = [70, 65, 60, 55];
      var standings = <TeamStandings>[];
      for (var w in s1Wins) {
        standings.add(TeamStandings('s1_$w', 'S1 Team $w', 'T', 'E', 'S1', w, 0, 0, w));
      }
      for (var w in s2Wins) {
        standings.add(TeamStandings('s2_$w', 'S2 Team $w', 'T', 'E', 'S2', w, 0, 0, w));
      }
      
      standings.sort();
      
      calculateGamesBehind(standings, 85);

      // S1(100), S1(95) - Top 2 S1
      expect(standings[0].gbWc, '-');
      expect(standings[1].gbWc, '-');
      
      // S1(90), S1(85) - WC leaders
      expect(standings[2].gbWc, '-');
      expect(standings[3].gbWc, '-');
      
      // S1(80), S1(75) - WC contenders
      expect(standings[4].gbWc, '2½');
      expect(standings[5].gbWc, '5');

      // S2(70), S2(65) - Top 2 S2. SHOULD BE '-'
      var s2Leader = standings.firstWhere((t) => t.id == 's2_70');
      expect(s2Leader.gbWc, '-', reason: 'Subleague leader should not have gbWc');

      var s2RunnerUp = standings.firstWhere((t) => t.id == 's2_65');
      expect(s2RunnerUp.gbWc, '-', reason: 'Subleague runner-up should not have gbWc');

      // S2(60) - WC contender
      var s2_60 = standings.firstWhere((t) => t.id == 's2_60');
      expect(s2_60.gbWc, '12½'); // (85 - 60)/2 = 12.5
    });
  });

  group('setWinningMagicNumber tests', () {
    setUp(() {
      gamesInRegularSeason = 120;
    });

    test('Standard magic number', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 90, 0, 10, 90);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 60, 20, 5, 80);
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '11');
    });

    test('Clinched first spot (^)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 101, 0, 10, 101);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 20, 5, 120);
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '^');
    });
  });

  group('calculateLosingMagicNumbers tests', () {
    setUp(() {
      gamesInRegularSeason = 120;
    });

    test('Team in safe spot', () {
      var teams = List.generate(
        7,
        (i) => TeamStandings('$i', 'Team $i', 'T$i', 'E', 'H', 60, 40, 0, 100),
      );
      calculateMagicNumbers(teams);
      expect(teams[0].elimination[0], 'MW');
    });
  });
}
