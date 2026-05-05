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
      // wcLeaderDiff = 100 - (100 - 100) = 100 for wild card leader
      // Actually let's use a specific wcLeaderDiff
      calculateGamesBehind(standings, 100);

      expect(standings[0].gbDiv, '-');
      expect(standings[0].gbWc, '-');

      // Team 1: 99 wins, 1 loss. teamDiff = 99 - 1 = 98.
      // subLeaderDiff = 100 - 0 = 100.
      // gbSubLeader = (100 - 98) / 2 = 1.
      expect(standings[1].gbDiv, '1');
      expect(standings[1].gbWc, '-'); // gbWc only set if i > 1

      for (var i = 2; i < 10; i++) {
        // teamDiff = (100 - i) - i = 100 - 2i
        // gbSubLeader = (100 - (100 - 2i)) / 2 = 2i / 2 = i
        // gbWildCard = (100 - (100 - 2i)) / 2 = i
        expect(standings[i].gbDiv, i.toString());
        expect(standings[i].gbWc, i.toString());
      }
    });
  });

  group('setWinningMagicNumber tests', () {
    setUp(() {
      // Ensure gamesInRegularSeason is 120 as per TimeData.gamesInRegularSeason()
      gamesInRegularSeason = 120;
    });

    test('Standard magic number (ignores tiebreaker)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 90, 0, 10, 90);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 60, 20, 5, 80);

      // magic = 60 + (120 - 80) - 90 + 1 = 11
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '11');
    });

    test('Magic number with different run differential (ignores it)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 90, 0, 5, 90);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 60, 20, 10, 80);

      // magic = 60 + (120 - 80) - 90 + 1 = 11
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '11');
    });

    test('Clinched first spot (^)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 101, 0, 10, 101);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 20, 5, 120);

      // magic = 100 + (120 - 120) - 101 + 1 = 0
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '^');
    });

    test('Not clinched if wins are equal (MW)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 0, 10, 100);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 20, 5, 120);

      // magic = MW because they are tied in wins
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], 'MW');
    });

    test('Clinched and previous spot clinched (X)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 101, 0, 10, 101);
      standing.winning[0] = '^';
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 20, 5, 120);

      // magic = 0, winningIndex > 0, and standing.winning[0] == '^'
      setWinningMagicNumber(standing, target, 1);
      expect(standing.winning[1], 'X');
    });

    test('Clinched but previous spot not clinched (^)', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 101, 0, 10, 101);
      standing.winning[0] = '5';
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 20, 5, 120);

      // magic = 0, winningIndex > 0, but no '^' yet
      setWinningMagicNumber(standing, target, 1);
      expect(standing.winning[1], '^');
    });

    test('Large magic number near season start', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 1, 0, 0, 1);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 0, 0, 0, 0);

      // magic = 0 + (120 - 0) - 1 + 1 = 120
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], '120');
    });

    test('Tie in wins with team below should be MW', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 10, 10, 110);
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 10, 5, 110);

      // They are tied in wins.
      setWinningMagicNumber(standing, target, 0);
      expect(standing.winning[0], 'MW');
    });

    test('Tie in wins with team below but already clinched should be X', () {
      var standing = TeamStandings('1', 'Team A', 'A', '🍎', 'High', 100, 10, 10, 110);
      standing.winning[0] = '^'; // Clinched first spot
      var target = TeamStandings('2', 'Team B', 'B', '🍌', 'High', 100, 10, 5, 110);

      // They are tied in wins, but spot 1 is already clinched.
      setWinningMagicNumber(standing, target, 1);
      expect(standing.winning[1], 'X');
    });
  });

  group('calculateLosingMagicNumbers tests', () {
    setUp(() {
      // Ensure gamesInRegularSeason is 120 as per TimeData.gamesInRegularSeason()
      gamesInRegularSeason = 120;
    });

    test('Team in safe spot (i <= k)', () {
      // Create 7 teams to avoid index out of bounds in calculateWinningMagicNumbers
      var teams = List.generate(
        7,
        (i) => TeamStandings('$i', 'Team $i', 'T$i', 'E', 'H', 60, 40, 0, 100),
      );

      calculateMagicNumbers(teams);

      // Team 0 (i=0) is in spot 1 (k=0). i <= k -> MW
      expect(teams[0].elimination[0], 'MW');
      // Team 0 (i=0) is in spot 2 (k=1). i <= k -> MW
      expect(teams[0].elimination[1], 'MW');
    });

    test('Team below spot (i > k) not yet eliminated', () {
      var teams = List.generate(
        7,
        (i) => TeamStandings('$i', 'Team $i', 'T$i', 'E', 'H', 60, 40, 0, 100),
      );
      // Team 0 (spot 1): 80 wins.
      teams[0].wins = 80;
      // Team 6 (spot 7): 70 wins.
      teams[6].wins = 70;

      // Max wins Team 6 = 70 + (120 - 100) = 90.
      // Team 0 wins = 80.
      // winning[0] will be 'MW' because 90 > 80.
      // elimination[0] = 90 - 80 = 10.

      calculateMagicNumbers(teams);

      expect(teams[6].elimination[0], '10');
    });

    test('Team eliminated from spot (X)', () {
      var teams = List.generate(
        7,
        (i) => TeamStandings('$i', 'Team $i', 'T$i', 'E', 'H', 60, 40, 0, 100),
      );
      // Team 0 (spot 1): 100 wins.
      teams[0].wins = 100;
      // Team 6 (spot 7): 70 wins.
      teams[6].wins = 70;

      // Max wins Team 6 = 70 + 20 = 90.
      // 90 <= 100 -> winning[0] = 'X'.
      // elimination[0] = 'X'.

      calculateMagicNumbers(teams);

      expect(teams[6].winning[0], 'X');
      expect(teams[6].elimination[0], 'X');
    });

    test('Elimination index 6', () {
      var teams = List.generate(
        7,
        (i) => TeamStandings(
          '$i',
          'Team $i',
          'T$i',
          'E',
          'H',
          i == 0 ? 115 : (i == 6 ? 20 : 30),
          0,
          0,
          115,
        ),
      );

      calculateMagicNumbers(teams);

      // Team 0 clinches spots -> winning[6] = 'X'
      expect(teams[0].winning[6], 'X');
      expect(teams[0].elimination[6], 'X');

      // Team 6 is eliminated from everything -> winning[6] = 'E'
      expect(teams[6].winning[6], 'E');
      expect(teams[6].elimination[6], 'E');
    });
  });
}
