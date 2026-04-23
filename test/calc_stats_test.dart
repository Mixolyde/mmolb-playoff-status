import 'package:test/test.dart';

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
}