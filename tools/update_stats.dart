
import 'package:mmolb_playoff_status/database_api.dart' as db;

Future<void> main(List<String> args) async {  
  var timeData = await db.getTimeData();
  print(timeData);

}