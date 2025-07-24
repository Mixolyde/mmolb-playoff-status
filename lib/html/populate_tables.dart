import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:mmolb_playoff_status/site_objects.dart';

void populateWinsBehindTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable')! as HTMLTableElement;
  var standings = subStandings.toList();
  
  for (var row in standings){
    var trow = insertCommonCells(table, row);
    var cell = trow.insertCell(3);
    cell.innerText = row.gamesPlayed.toString();    
    cell = trow.insertCell(4);
    cell.innerText = (sitedata.gamesInSeason - row.gamesPlayed).toString();       
    cell = trow.insertCell(5);
    cell.innerText = row.gbDiv;        
    cell = trow.insertCell(6);
    cell.innerText = row.gbWc;
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
      span.innerText = getEntryText(top);
      assignBracketClass(span, top);
    }
    
    span = document.querySelector('#${matchupIDs[index]} .brk-bteam .brk-tseed') as HTMLSpanElement?;
    if (span == null){
      print('ERROR: span #${matchupIDs[index]} .brk-bteam .brk-tseed is null');
    } else {
      span.innerText = getEntryText(bottom);
      assignBracketClass(span, bottom);
    }
    
  }
  
  var winner = entries[18];
  span = document.querySelector('#brk-final-box .brk-tseed') as HTMLSpanElement?;
  if (span == null){
    print('ERROR: span #brk-final-box .brk-tseed is null');
  } else {
    if (winner.teamNickname == 'TBD'){
      span.innerText = 'TBD';
    } else {
      span.innerText = '(${winner.seed}) ${winner.teamNickname}';
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
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row);
    var cell = trow.insertCell(5);
    cell.innerText = (sitedata.gamesInSeason - row.gamesPlayed).toString();  
    for(var i = 0; i < 5; i++){
      var cell = trow.insertCell(6 + i);
      cell.innerText = row.po[i];
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
    for(var i = 0; i < 5; i++){
      if(b.post[i] != a.post[i]){
        return getOrderValue(b.post[i]).compareTo(getOrderValue(a.post[i]));
      }
    }
    if(a.wins != b.wins){
      return b.wins.compareTo(a.wins);
    } else {
      return a.fullName.compareTo(b.fullName);
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
      cell.innerText = row.post[i];
      if(row.winning[4] == 'PT' || 
          (row.winning[2] == 'DNCD' && row.winning[3] == 'DNCD') ){
        cell.classList.add('redcell');
      } else {
        cell.classList.add('greencell');
      }

    }
  }
  
}

void populateWinningTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable') as  HTMLTableElement?;
  if(table == null){
    print('ERROR: #standingsTable is null');
    return;
  }
  var standings = subStandings.toList();
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row);
    var cell = trow.insertCell(5);
    cell.innerText = (sitedata.gamesInSeason - row.gamesPlayed).toString();      
    for(var i = 0; i < 5; i++){
      cell = trow.insertCell(6 + i);
      cell.innerText = row.winning[i];
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
  
}

void populatePartyTimeTable(List<TeamStandings> subStandings, bool groupByDiv, SiteData sitedata){
  var table = document.querySelector('#standingsTable') as  HTMLTableElement?;
  if(table == null){
    print('ERROR: #standingsTable is null');
    return;
  }
  var standings = subStandings.toList();
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row);   
    var cell = trow.insertCell(5);
    cell.innerText = (sitedata.gamesInSeason - row.gamesPlayed).toString();    
    for(var i = 0; i < 5; i++){
      var cell = trow.insertCell(6 + i);
      cell.innerText = row.partytime[i];
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
  
}

void populateAboutPageData(List<List<TeamStandings>> subStandings){

  print('Populating about page data');
      
}

HTMLTableRowElement insertCommonCells(HTMLTableElement table, 
  TeamStandings row, {showLeague = false} ){
  //print('Inserting TeamStandings for $row');
  var trow = table.insertRow();

  HTMLAnchorElement shortTeamLink = HTMLAnchorElement();
  shortTeamLink.href = 'https://mmolb.com/team/${row.id}';
  shortTeamLink.innerText = row.nickname;
  shortTeamLink.target = '_new';
  HTMLAnchorElement longTeamLink = HTMLAnchorElement();
  longTeamLink.href = 'https://mmolb.com/team/${row.id}';
  longTeamLink.innerText = row.fullName;
  longTeamLink.target = '_new';  
  var emojiSpan = HTMLSpanElement();
  //print('Emoji string: ${row.emoji}');
  if(row.emoji.startsWith('0')){
    emojiSpan.innerHTML = ' &#${row.emoji.substring(1, row.emoji.length)};'.toJS;
  } else {
    emojiSpan.innerHTML = '  '.toJS;
  }
  
  var cell = trow.insertCell(0);
  cell.classList.add('tblteam');
  var wideSpan = HTMLSpanElement();
  wideSpan.classList.add('wide');
  var narrowSpan = HTMLSpanElement();
  narrowSpan.classList.add('narrow');

  wideSpan.appendChild(longTeamLink);
  narrowSpan.appendChild(shortTeamLink);
  
  cell.appendChild(wideSpan);
  cell.appendChild(narrowSpan);
  cell.appendChild(emojiSpan);
  
  var leagueAdjust = 0;
  if(showLeague){
    leagueAdjust = 1;
    var cell = trow.insertCell(1);
    cell.innerText = row.subleague;    
  }

  cell = trow.insertCell(1 + leagueAdjust);
  cell.innerText = row.wins.toString();
  var record = '${row.gamesPlayed - row.losses} - ${row.losses}';
  cell = trow.insertCell(2 + leagueAdjust);
  cell.innerText = record;   

  return trow;

}

void insertSeparatorRow(HTMLTableElement table, int row, int columns){
  var sepRow = table.insertRow(row);
  sepRow.insertCell(0)
    ..innerText = '&nbsp;'
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
