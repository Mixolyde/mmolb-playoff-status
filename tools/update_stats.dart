import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:dotenv/dotenv.dart';


import 'package:mmolb_playoff_status/database_api.dart' as db;
import 'package:mmolb_playoff_status/stats/calc_stats.dart';
import 'package:mmolb_playoff_status/stats/sim_season.dart';

String envBucket = "prod";
const simCount = '103';

Future<void> main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption(simCount, abbr: 'c',  defaultsTo: '103');
  var results = parser.parse(args);
  var numSims = int.parse(results[simCount]);

  var env = DotEnv(includePlatformEnvironment: true)
    ..load();

  print('Read all vars? ${env.isEveryDefined(['bucket'])}');
  print('bucket=${env['bucket']}');
  if (env.isDefined('bucket') ) {
    envBucket = env['bucket']!;
  } else {
    print('No bucket defined, using default prod');
  }



  var stateData = await db.getStateData();
  //print(stateData);

  var timeData = await db.getTimeData();
  //print(timeData);

  //site data
  var siteData = await calcSiteData(stateData, timeData);
  print(siteData);

  //get greater league standings and calculate stats
  var greaterLeagueStandings = await calcGreaterLeagueStats(stateData, timeData);
  
  //print out data
  print(greaterLeagueStandings[0]);
  print(greaterLeagueStandings[1]);

  await calculateChances(greaterLeagueStandings, numSims, timeData);

  //get lesser league standings and calculate stats
  var lesserLeagueStandings = await calcLesserLeagueStats(stateData, timeData);

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
  sinkJSON.write(json.encode(greaterLeagueStandings[0]));
  await sinkJSON.close();
  
  filenameJSON = '${temp.path}/data/${siteData.sub2id}.json';
  sinkJSON = File(filenameJSON).openWrite();
  sinkJSON.write(json.encode(greaterLeagueStandings[1]));
  await sinkJSON.close();

  for(var lesserLeagueId in lesserLeagueStandings.keys){
    filenameJSON = '${temp.path}/data/$lesserLeagueId.json';
    sinkJSON = File(filenameJSON).openWrite();
    sinkJSON.write(json.encode(lesserLeagueStandings[lesserLeagueId]));
    await sinkJSON.close();
  }

  var aws = File('/usr/bin/aws');
  var exists = await aws.exists();
  if(exists){
    uploadFiles();
  }

}

void uploadFiles() {
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
