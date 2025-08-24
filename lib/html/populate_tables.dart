import 'dart:js_interop';

import 'package:web/web.dart';
import 'package:mmolb_playoff_status/site_objects.dart';

void populateGamesBehindTable(List<TeamStandings> allStandings, SiteData sitedata, bool groupBySubLeague){
  var table = document.querySelector('#standingsTable')! as HTMLTableElement;
  allStandings.sort();
  var standings = allStandings.toList();

  if(groupBySubLeague == true){
    var firstDiv = allStandings[0].subleague;
    standings = allStandings.where((t) => t.subleague == firstDiv).toList();
    standings.addAll(allStandings.where((t) => 
      t.subleague != firstDiv).toList());
  }
  
  for (var row in standings){
    var trow = insertCommonCells(table, row, sitedata, showPlayedAndLeft: true);
    var cell = trow.insertCell(6);
    cell.innerText = row.gbDiv;        
    cell = trow.insertCell(7);
    cell.innerText = row.gbWc;
  }

  if(groupBySubLeague == true){
    insertSeparatorRow(table, 10, 8); 
  } else {
    insertSeparatorRow(table, 8, 8); 
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

void populateChancesTable(List<TeamStandings> allStandings, SiteData sitedata, bool groupBySubLeague){
  var table = document.querySelector('#standingsTable') as HTMLTableElement;

  allStandings.sort((a, b) {
    for(var i = 0; i < a.po.length; i++){
      if(b.po[i] != a.po[i]){
        return getOrderValue(b.po[i]).compareTo(getOrderValue(a.po[i]));
      }
    }
    return a.compareTo(b);
  });

  var standings = allStandings.toList();
  if(groupBySubLeague == true){
    var firstDiv = allStandings[0].subleague;
    standings = allStandings.where((t) => t.subleague == firstDiv).toList();
    standings.addAll(allStandings.where((t) => 
      t.subleague != firstDiv).toList());
  }

  
  for(var row in standings) {
    var trow = insertCommonCells(table, row, sitedata, showPlayedAndLeft: false);
    //print('Displaying playoff chances for ${row.fullName} ${row.po}');

    for(var i = 0; i < 7; i++){
      var cell = trow.insertCell(4 + i);
      cell.innerText = row.po[i];
      switch (row.po[i]){
        case 'E':
        case 'X':
          cell.classList.add('redcell');
          break;
        default:
          // TODO figure out red/green cell logic from winning table
          break;
      }
    }
  }

  if(groupBySubLeague == true){
    insertSeparatorRow(table, 10, 11); 
  } else {
    insertSeparatorRow(table, 8, 11); 
  }
  
}

void populatePostseasonTable(List<TeamStandings> allStandings,
  SiteData sitedata, bool groupBySubLeague){
  var table = document.querySelector('#standingsTable') as HTMLTableElement;

  allStandings.sort((a, b) {
    for(var i = 0; i < a.post.length; i++){
      if(b.post[i] != a.post[i]){
        return getOrderValue(b.post[i]).compareTo(getOrderValue(a.post[i]));
      }
    }
    return a.compareTo(b);
  });

  var standings = allStandings.toList();
  if(groupBySubLeague == true){
    var firstDiv = allStandings[0].subleague;
    standings = allStandings.where((t) => t.subleague == firstDiv).toList();
    standings.addAll(allStandings.where((t) => 
      t.subleague != firstDiv).toList());
  }
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row, sitedata, showPlayedAndLeft: false);
    var psRounds = 4;

    for(var i = 0; i < psRounds; i++){
      var cell = trow.insertCell(4 + i);
      cell.innerText = row.post[i];
      if(row.winning[4] == 'E' ){
        cell.classList.add('redcell');
      } else if (row.winning[4] == '^') {
        cell.classList.add('greencell');
      } 

    }
  }

  if(groupBySubLeague == true){
    insertSeparatorRow(table, 10, 8); 
  } else {
    insertSeparatorRow(table, 8, 8); 
  }
  
}

void populateWinningTable(List<TeamStandings> allStandings, SiteData sitedata, bool groupBySubLeague){
  var table = document.querySelector('#standingsTable') as  HTMLTableElement;

  allStandings.sort();
  var standings = allStandings.toList();

  if(groupBySubLeague == true){
    var firstDiv = allStandings[0].subleague;
    standings = allStandings.where((t) => t.subleague == firstDiv).toList();
    standings.addAll(allStandings.where((t) => 
      t.subleague != firstDiv).toList());
  }
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row, sitedata, showPlayedAndLeft: true);
     
    for(var i = 0; i < 5; i++){
      var cell = trow.insertCell(6 + i);
      cell.innerText = row.winning[i];
      switch (row.winning[i]){
        case 'E':
        case 'X':
          cell.classList.add('redcell');
          break;
        default:
          cell.classList.add('greencell');
          break;
      }
    }
  }

  if(groupBySubLeague == true){
    insertSeparatorRow(table, 10, 11); 
  } else {
    insertSeparatorRow(table, 8, 11); 
  }
  
}

void populateEliminationTable(List<TeamStandings> allStandings, SiteData sitedata, bool groupBySubLeague){
  var table = document.querySelector('#standingsTable') as  HTMLTableElement;

  allStandings.sort();
  var standings = allStandings.toList();

  if(groupBySubLeague == true){
    var firstDiv = allStandings[0].subleague;
    standings = allStandings.where((t) => t.subleague == firstDiv).toList();
    standings.addAll(allStandings.where((t) => 
      t.subleague != firstDiv).toList());
  }
  
  for(var row in standings) {
    var trow = insertCommonCells(table, row, sitedata, showPlayedAndLeft: true);   
   
    for(var i = 0; i < 5; i++){
      var cell = trow.insertCell(6 + i);
      cell.innerText = row.elimination[i];
      switch (row.elimination[i]){
        case 'E':
        case 'X':
          cell.classList.add('redcell');
          break;
        default:
          cell.classList.add('greencell');
          break;
      }
    }
  }

  if(groupBySubLeague == true){
    insertSeparatorRow(table, 10, 11); 
  } else {
    insertSeparatorRow(table, 8, 11); 
  }
  
}

HTMLTableRowElement insertCommonCells(HTMLTableElement table, 
  TeamStandings row, SiteData sitedata, {showPlayedAndLeft = true} ){
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
  
  cell = trow.insertCell(1);
  cell.innerText = row.subleague;    

  var record = '${row.gamesPlayed - row.losses} - ${row.losses}';
  cell = trow.insertCell(2);
  cell.innerText = record;

  if(showPlayedAndLeft){
    cell = trow.insertCell(3);
    cell.innerText = row.gamesPlayed.toString();    
    cell = trow.insertCell(4);
    cell.innerText = (sitedata.gamesInSeason - row.gamesPlayed).toString();
    cell = trow.insertCell(5);
    cell.innerText = row.runDifferential.toString();
  } else {
    cell = trow.insertCell(3);
    cell.innerText = row.runDifferential.toString();
  }


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
