import 'dart:convert';
import 'dart:io';

import 'package:mmolb_playoff_status/database_api.dart' as db;
import 'package:mmolb_playoff_status/stats/calc_stats.dart';
import 'package:mmolb_playoff_status/stats/sim_season.dart';


Future<void> main(List<String> args) async {  
  var stateData = await db.getStateData();
  //print(stateData);

  var timeData = await db.getTimeData();
  //print(timeData);

  //site data
  var siteData = await calcSiteData(stateData, timeData);
  print(siteData);

  //get subleague standings and calculate stats
  var subStandings = await calcStats(stateData, timeData);
  
  //print out data
  print(subStandings[0]);
  print(subStandings[1]);

  int numSims = 101;

  await calculateChances(subStandings, numSims, timeData);

  var temp = Directory.systemTemp;
  print(temp);
  
  var dataDir = Directory('${temp.path}/data/');
  await dataDir.create(recursive: true);
  
  var filenameJSON = '${temp.path}/data/sitedata.json';
  var sinkJSON = File(filenameJSON).openWrite();
  sinkJSON.write(json.encode(siteData));
  await sinkJSON.close();
 
  
  filenameJSON = '${temp.path}/data/${siteData.sub1id}.json';
  sinkJSON = File(filenameJSON).openWrite();
  sinkJSON.write(json.encode(subStandings[0]));
  await sinkJSON.close();
  
  filenameJSON = '${temp.path}/data/${siteData.sub2id}.json';
  sinkJSON = File(filenameJSON).openWrite();
  sinkJSON.write(json.encode(subStandings[1]));
  await sinkJSON.close();


  var aws = File('/usr/bin/aws');
  var exists = await aws.exists();
  if(exists){
    uploadFiles();
  }

}

void uploadFiles() {
  Map<String, String> envVars = Platform.environment;
  String envBucket = envVars['BUCKET'] ?? "prod/";
  print("Environment Bucket: $envBucket");
  Process.run('/usr/bin/aws', [
      's3', 'cp', '/tmp/data/',
      's3://mmolb-playoff-status/data/$envBucket',
      '--include="*.json"', 
      '--recursive',
      '--content-type=application/json; charset=utf-8'
  ]).then((ProcessResult results) {
    print(results.stdout);
    print(results.stderr);
  });

}
