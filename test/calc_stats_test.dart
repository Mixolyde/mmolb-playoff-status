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
      calculateGamesBehind(standings, 6);

      expect(standings[0].gbDiv, '-');
      expect(standings[0].gbWc, '-');

      expect(standings[1].gbDiv, '11');
      expect(standings[1].gbWc, '-');

      expect(standings[2].gbDiv, '12½');
      expect(standings[2].gbWc, '-');

      expect(standings[3].gbDiv, '18');
      expect(standings[3].gbWc, '-');

      expect(standings[4].gbDiv, '22½');
      expect(standings[4].gbWc, '4½');
    });
  });

  group('setWinningMagicNumber tests', () {
    setUp(() {
      // Ensure gamesInRegularSeason is 120 as per TimeData.gamesInRegularSeason()
      gamesInRegularSeason = 120;
    });

    test('Standard magic number (no tiebreaker)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 90, 0, 10, 90);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 60, 0, 5, 80);

      // magic = 60 + (120 - 80) - 90 = 10
      // standing wins ties (10 > 5)
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '10');
    });

    test('Magic number with tiebreaker (standing loses tie)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 90, 0, 5, 90);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 60, 0, 10, 80);

      // magic = 60 + (120 - 80) - 90 = 10
      // standing loses ties (5 < 10) -> magic + 1 = 11
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '11');
    });

    test('Clinched first spot (^)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 0, 10, 100);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 0, 5, 120);

      // magic = 100 + (120 - 120) - 100 = 0
      // standing wins ties (10 > 5)
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '^');
    });

    test('Clinched and previous spot clinched (X)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 0, 10, 100);
      standing.winning[0] = '^';
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 0, 5, 120);

      // magic <= 0, winningIndex > 0, and standing.winning[0] == '^'
      setWinningMagicNumber(standing, target, 1);
      expect(standing.winning[1], 'X');
    });

    test('Clinched but previous spot not clinched (^)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 0, 10, 100);
      standing.winning[0] = '5';
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 0, 5, 120);

      // magic <= 0, winningIndex > 0, but no '^' yet
      setWinningMagicNumber(standing, target, 1);
      expect(standing.winning[1], '^');
    });

    test('Large magic number near season start', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 1, 0, 0, 1);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 0, 0, 0, 0);

      // magic = 0 + (120 - 0) - 1 = 119
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '119');
    });

    test('Equal run differential (standing wins ties)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 0, 10, 100);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 0, 10, 120);

      // magic = 100 + (120 - 120) - 100 = 0
      // runDiff equal (10 == 10) -> magic stays 0
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '^');
    });
  });
}
