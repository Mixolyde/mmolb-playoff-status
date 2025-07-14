import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:mmolb_playoff_status/site_objects.dart';

void populateWinsBehindTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable')! as HTMLTableElement;
  var standings = subStandings.toList();
  if(groupByDiv == true){
    var firstDiv = subStandings[0].division;
    standings = subStandings.where((t) => t.division == firstDiv).toList();
    standings.addAll(subStandings.where((t) => 
      t.division != firstDiv).toList());
  }
  
  for (var row in standings){
    var trow = insertCommonCells(table, row);
    var cell = trow.insertCell(5);
    cell.textContent = row.gamesPlayed.toString();    
    cell = trow.insertCell(6);
    cell.textContent = (sitedata.gamesInSeason - row.gamesPlayed).toString();       
    cell = trow.insertCell(7);
    cell.textContent = row.gbDiv;        
    cell = trow.insertCell(8);
    cell.textContent = row.gbWc;
  }
  
  if(groupByDiv == true){
    insertSeparatorRow(table, 8, 9); 
  } else {
    insertSeparatorRow(table, 6, 9); 
  }
  
}

void populatePlayoffBracket(List<PlayoffBracketEntry> entries){

  print('Bracket 0: ${entries[0]}');
  
  // Set Leagues
  for (var s in ['brk-mu_1_2', 'brk-mu_2_1', 'brk-mu_2_2', 'brk-mu_3_1']) {
    document.querySelector('#$s .brk-date')?.textContent = '${entries[0].subleague} League';
  }
  
  for (var s in ['brk-mu_1_7', 'brk-mu_2_3', 'brk-mu_2_4', 'brk-mu_3_2']) {
    document.querySelector('#$s .brk-date')?.textContent = '${entries[2].subleague} League';
  }
  
  // Set Entries
  var matchupIDs = [
    'brk-mu_1_2', 'brk-mu_1_7', 
    'brk-mu_2_1', 'brk-mu_2_2', 
    'brk-mu_2_3', 'brk-mu_2_4',
    'brk-mu_3_1', 'brk-mu_3_2',
    'brk-mu_4_1'
  ];
  
  HTMLSpanElement? span;
  
  for(var index = 0; index < matchupIDs.length; index++){
    //print('Matchup $index');
    var top = entries[index * 2];
    var bottom = entries[index * 2 + 1];
    
    span = document.querySelector('#${matchupIDs[index]} .brk-tteam .brk-tseed') as HTMLSpanElement?;
    if (span == null){
      print('ERROR: span #${matchupIDs[index]} .brk-tteam .brk-tseed is null');
    } else {
      span.textContent = getEntryText(top);
      assignBracketClass(span, top);
    }
    
    span = document.querySelector('#${matchupIDs[index]} .brk-bteam .brk-tseed') as HTMLSpanElement?;
    if (span == null){
      print('ERROR: span #${matchupIDs[index]} .brk-bteam .brk-tseed is null');
    } else {
      span.textContent = getEntryText(bottom);
      assignBracketClass(span, bottom);
    }
    
  }
  
  var winner = entries[18];
  span = document.querySelector('#brk-final-box .brk-tseed') as HTMLSpanElement?;
  if (span == null){
    print('ERROR: span #brk-final-box .brk-tseed is null');
  } else {
    if (winner.teamNickname == 'TBD'){
      span.textContent = 'TBD';
    } else {
      span.textContent = '(${winner.seed}) ${winner.teamNickname}';
    }
  }
  
}

String getEntryText(PlayoffBracketEntry entry){
  if (entry.teamNickname == 'Seed'){
    return '(${entry.seed}) Seed';
  } else if (entry.teamNickname == 'TBD'){
    return 'TBD';
  } else {
    return '(${entry.seed}) ${entry.teamNickname} Wins: ${entry.wins}';
  }
}

void assignBracketClass(HTMLSpanElement span, PlayoffBracketEntry entry){
  if (entry.teamNickname == 'TBD'){
    span.classList.add('brk-ttbd');
  } else {
    span.classList.remove('brk-ttbd');
  }
}

void populateChancesTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable') as HTMLTableElement?;
  if(table == null){
    print('ERROR: #standingsTable is null');
    return;
  }
  var standings = subStandings.toList();
  if(groupByDiv == true){
    var firstDiv = subStandings[0].division;
    standings = subStandings.where((t) => t.division == firstDiv).toList();
    standings.addAll(subStandings.where((t) => 
      t.division != firstDiv).toList());
  }
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row);
    var cell = trow.insertCell(5);
    cell.textContent = (sitedata.gamesInSeason - row.gamesPlayed).toString();  
    for(var i = 0; i < 5; i++){
      var cell = trow.insertCell(6 + i);
      cell.textContent = row.po[i];
      switch (row.po[i]){
        case 'PT':
        case 'X':
          cell.classList.add('redcell');
          break;
        default:
          if(row.winning[i] == 'DNCD') {
            cell.classList.add('redcell');
          } else {
            cell.classList.add('greencell');
          }
          break;
      }
    }
  }
  
  if(groupByDiv == true){
    insertSeparatorRow(table, 8, 11); 
  } else {
    insertSeparatorRow(table, 6, 11); 
  }
}

void populatePostseasonTable(List<List<TeamStandings>> allStandings, bool groupByDiv,
  SiteData sitedata){
  var table = document.querySelector('#standingsTable') as HTMLTableElement?;
  if(table == null){
    print('ERROR: #standingsTable is null');
    return;
  }
  var standings = <TeamStandings>[];
  standings.addAll(allStandings[0]);
  standings.addAll(allStandings[1]);

  standings.sort((a, b) {
    if(groupByDiv){
      if(a.subleague != b.subleague){
        return a.subleague.compareTo(b.subleague);
      } else if (a.division != b.division){
        return a.division.compareTo(b.division);
      }
    }
    for(var i = 0; i < 5; i++){
      if(b.post[i] != a.post[i]){
        return getOrderValue(b.post[i]).compareTo(getOrderValue(a.post[i]));
      }
    }
    if(a.wins != b.wins){
      return b.wins.compareTo(a.wins);
    } else {
      return a.favor.compareTo(b.favor);
    }
  });
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row, showLeague: true);
    var psRounds = 4;
    if(sitedata.leagueWildCards || sitedata.leagueMildCards){
      psRounds = 5;
    }
    for(var i = 0; i < psRounds; i++){
      var cell = trow.insertCell(6 + i);
      cell.textContent = row.post[i];
      if(row.winning[4] == 'PT' || 
          (row.winning[2] == 'DNCD' && row.winning[3] == 'DNCD') ){
        cell.classList.add('redcell');
      } else {
        cell.classList.add('greencell');
      }

    }
  }
  
  if(groupByDiv == true){
    insertSeparatorRow(table, 8, 11); 
    insertSeparatorRow(table, 15, 11); 
    insertSeparatorRow(table, 22, 11); 
  } 
}

void populateWinningTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable') as  HTMLTableElement?;
  if(table == null){
    print('ERROR: #standingsTable is null');
    return;
  }
  var standings = subStandings.toList();
  if(groupByDiv == true){
    var firstDiv = subStandings[0].division;
    standings = subStandings.where((t) => t.division == firstDiv).toList();
    standings.addAll(subStandings.where((t) => 
      t.division != firstDiv).toList());
  }
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row);
    var cell = trow.insertCell(5);
    cell.textContent = (sitedata.gamesInSeason - row.gamesPlayed).toString();      
    for(var i = 0; i < 5; i++){
      cell = trow.insertCell(6 + i);
      cell.textContent = row.winning[i];
      switch (row.winning[i]){
        case 'PT':
        case 'X':
        case 'DNCD':
          cell.classList.add('redcell');
          break;
        default:
          cell.classList.add('greencell');
          break;
      }
    }
  }
  
  if(groupByDiv == true){
    insertSeparatorRow(table, 8, 11); 
  } else {
    insertSeparatorRow(table, 6, 11); 
  }
}

void populatePartyTimeTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable') as  HTMLTableElement?;
  if(table == null){
    print('ERROR: #standingsTable is null');
    return;
  }
  var standings = subStandings.toList();
  if(groupByDiv == true){
    var firstDiv = subStandings[0].division;
    standings = subStandings.where((t) => t.division == firstDiv).toList();
    standings.addAll(subStandings.where((t) => 
      t.division != firstDiv).toList());
  }
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row);   
    var cell = trow.insertCell(5);
    cell.textContent = (sitedata.gamesInSeason - row.gamesPlayed).toString();    
    for(var i = 0; i < 5; i++){
      var cell = trow.insertCell(6 + i);
      cell.textContent = row.partytime[i];
      switch (row.partytime[i]){
        case 'PT':
        case 'X':
          cell.classList.add('redcell');
          break;
        default:
          cell.classList.add('greencell');
          break;
      }
    }
  }
  
  if(groupByDiv == true){
    insertSeparatorRow(table, 8, 11); 
  } else {
    insertSeparatorRow(table, 6, 11); 
  }
}

void populateAboutPageData(List<List<TeamStandings>> subStandings){
  HTMLOListElement? tbList = document.querySelector('#tiebreakerlist') as HTMLOListElement?;
  if(tbList == null){
    print('ERROR: OList #tiebreakerlist is null');
    return;
  }

  tbList.replaceChildren(JSArray());


  var allStandings = <TeamStandings>[];
  allStandings.addAll(subStandings[0]);
  allStandings.addAll(subStandings[1]);      
  
  for(var favor = 0; favor < allStandings.length; favor++){
    var stand = allStandings.firstWhere((team) =>
      team.favor == favor);
    HTMLLIElement item = HTMLLIElement();
    item.textContent = stand.nickname;
    tbList.children.add(item);
  }
      
}

HTMLTableRowElement insertCommonCells(HTMLTableElement table, 
  TeamStandings row, {showLeague = false} ){
  var trow = table.insertRow();
  HTMLAnchorElement shortTeamLink = HTMLAnchorElement()
    ..href = 'https://www.blaseball.com/team/${row.id}'
    ..textContent = row.nickname
    ..target = '_new';
  var longTeamLink = HTMLAnchorElement()
    ..href = 'https://www.blaseball.com/team/${row.id}'
    ..textContent = row.fullName
    ..target = '_new';  
  var emojiSpan = HTMLSpanElement();
  //print('Emoji string: ${row.emoji}');
  if(row.emoji.startsWith('0')){
    emojiSpan.innerHTML = ' &#${row.emoji.substring(1, row.emoji.length)};'.toJS;
  } else if (row.nickname == 'Lift') {
    //stupid manual correction for one team with a weird character
    emojiSpan.innerHTML = ' &#x1F3CB;'.toJS;
  } else {
    emojiSpan.innerHTML = '  '.toJS;
  }
  
  var cell = trow.insertCell(0);
  cell.classList.add('tblteam');
  var wideSpan = HTMLSpanElement();
  wideSpan.classList.add('wide');
  var narrowSpan = HTMLSpanElement();
  narrowSpan.classList.add('narrow');
  wideSpan.children.add(longTeamLink);
  narrowSpan.children.add(shortTeamLink);
  
  cell.children.add(wideSpan);
  cell.children.add(narrowSpan);
  cell.children.add(emojiSpan);
  
  var leagueAdjust = 0;
  if(showLeague){
    leagueAdjust = 1;
    var cell = trow.insertCell(1);
    cell.textContent = row.subleague;    
  }
  cell = trow.insertCell(1 + leagueAdjust);
  cell.textContent = row.division;
  cell = trow.insertCell(2 + leagueAdjust);
  cell.textContent = (row.favor + 1).toString();
  cell = trow.insertCell(3 + leagueAdjust);
  cell.textContent = row.wins.toString();
  var record = '${row.gamesPlayed - row.losses} - ${row.losses}';
  cell = trow.insertCell(4 + leagueAdjust);
  cell.textContent = record;   

  return trow;

}

void insertSeparatorRow(HTMLTableElement table, int row, int columns){
  var sepRow = table.insertRow(row);
  sepRow.insertCell(0)
    ..textContent = '&nbsp;'
    ..colSpan = columns
    ..classList.add('sepRow');  
}

int getOrderValue(String percent){
  if(percent == 'X'){
    return -10;
  } else if(percent == '<1%'){
    return 0;
  } else if(percent == '>99%'){
    return 100;
  } else if(percent == '^'){
    return 101;
  } else {
    var digits = percent.replaceAll('%', '');
    return int.parse(digits);
  }
}
