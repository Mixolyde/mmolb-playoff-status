import 'dart:async';
import 'dart:convert';
import 'dart:js_interop' as js;
import 'package:cron/cron.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart';

import 'package:mmolb_playoff_status/current_view.dart';
import 'package:mmolb_playoff_status/s3_api.dart' as s3;
import 'package:mmolb_playoff_status/site_objects.dart';
import 'package:mmolb_playoff_status/html/populate_tables.dart';


late String aboutHTML;
late String bracketHTML;
late String chancesHTML;
late String chancesNotesHTML;
late String gamesbehindHTML;
late String magicHTML;
late String eliminationNotesHTML;
late String postseasonHTML;
late String winningNotesHTML;
late SiteData sitedata;

CurrentView currentView = CurrentView();
List<PlayoffBracketEntry> entries = [];

List<List<TeamStandings>> subStandings = [];
List<TeamStandings> allStandings = [];

void main() {
  s3.envBucket = const String.fromEnvironment("bucket", defaultValue: "prod");
  
  print ("EnvBucket: ${s3.envBucket}");

  getContentPages().then((v) {
    print('Retrieved content pages and data');
    
    if(window.location.hash.length > 2){
      currentView = CurrentView.fromHash(window.location.hash);
      print('Loaded view from hash: $currentView');
      replaceViewState();
    } else {
      // else, load from disk if it exists
      currentView = loadCurrentView();
      print('Loaded view from storage: $currentView');
      replaceViewState();
    }

    selectGroupBySubLeague();
    selectViewButton();
    redisplayData();
    
    addListeners();
    
    //setup auto refresh
    var cron = Cron();
    //Every five minutes from 20-50
    cron.schedule(Schedule.parse('1,21,26,31,36,41,46,51,56 * * * *'), () async {
      if(!document.hidden && 
        currentView.activeView != View.about){
        await refreshData();
      }
    });
  });
}

Future<void> getContentPages() async {
  sitedata = await s3.getSiteData();
  
  print('Initial sitedata: $sitedata');
  setSeasonDay(sitedata);
  subStandings = await s3.getSubStandings(sitedata);

  allStandings.clear();
  allStandings.addAll(subStandings[0]);
  allStandings.addAll(subStandings[1]);

  //entries = await s3.getPlayoffBracketEntries();
  
  setUpdateTime(sitedata);

  //load content pages
  aboutHTML = await read(Uri.parse('main-content/about.html'));
  //bracketHTML = await read(Uri.parse('main-content/bracket.html'));
  chancesHTML = await read(Uri.parse('main-content/chances.html'));
  magicHTML = await read(Uri.parse('main-content/magic.html'));
  postseasonHTML = await read(Uri.parse('main-content/postseason.html'));
  gamesbehindHTML = await read(Uri.parse('main-content/gamesbehind.html'));

  //load notes pages
  chancesNotesHTML = await read(Uri.parse('notes/chancesNotes.html'));
  eliminationNotesHTML = await read(Uri.parse('notes/eliminationNotes.html'));
  winningNotesHTML = await read(Uri.parse('notes/winningNotes.html'));

  setMainContent(gamesbehindHTML);

}

Future<void> refreshData() async{
  //get all data for displaying
  print('Refreshing data');
  sitedata = await s3.getSiteData();
  print('Updated sitedata: $sitedata');
  
  setSeasonDay(sitedata);
  subStandings = await s3.getSubStandings(sitedata);
  
  allStandings.clear();
  allStandings.addAll(subStandings[0]);
  allStandings.addAll(subStandings[1]);

  //entries = await s3.getPlayoffBracketEntries();
  
  var standingsTable = document.querySelector('#standingsTable') as HTMLTableElement?;
  if(standingsTable != null){
    while (standingsTable.rows.length > 2){
      standingsTable.deleteRow(2);
    }
  }
  
  switch(currentView.activeView){
  case View.winsbehind:
    populateGamesBehindTable(allStandings, sitedata, currentView.groupBySubLeague);
    break;
  case View.winningmagic:
    populateWinningTable(allStandings, sitedata, currentView.groupBySubLeague);
    break;
  case View.eliminationmagic:
    populateEliminationTable(allStandings, sitedata, currentView.groupBySubLeague);
    break;
  case View.chances:
    populateChancesTable(allStandings, sitedata, currentView.groupBySubLeague);
    break;    
  case View.postseason:
    populatePostseasonTable(allStandings, sitedata, currentView.groupBySubLeague);
    break; 
  case View.bracket:
    //populatePlayoffBracket(entries);
    break;    
  default:
    break;
  }
  
  setUpdateTime(sitedata);

}

void setUpdateTime(SiteData sitedata){
  var local = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
    .parseUTC(sitedata.lastUpdate).toLocal();
  (document.querySelector('#lastUpdate')! as HTMLElement).innerText = 
    DateFormat("MMMM d, h:mm a").format(local);
}

void setSeasonDay(SiteData sitedata){
  var season = sitedata.season;
  var day = int.tryParse(sitedata.day);
  if(day != null && day <= sitedata.daysInSeason){
    (document.querySelector('.wkinfo')! as HTMLElement).innerText = 
      'Season $season: Day $day';
  } else if (day != null && day > sitedata.daysInSeason){
    (document.querySelector('.wkinfo')! as HTMLElement).innerText = 
      'Season $season: Day $day (Postseason)';    
  } else {
    (document.querySelector('.wkinfo')! as HTMLElement).innerText = 
      'Season $season: $day';
  }
}

void addListeners(){
  window.onPopState.listen(handlePopState);
  
  document.querySelector('#viewWinsBehind')!.onClick.listen(selectViewGB);
  document.querySelector('#viewChances')!.onClick.listen(selectViewC);  
  document.querySelector('#viewWinningNumbers')!.onClick.listen(selectViewW);
  document.querySelector('#viewEliminationNumbers')!.onClick.listen(selectViewE);
  document.querySelector('#viewAbout')!.onClick.listen(selectViewAbout);
  document.querySelector('#viewPostseasonChances')!.onClick.listen(selectViewPost);
  //document.querySelector('#viewPlayoffBracket')!.onClick.listen(selectViewBracket);

  document.querySelector('#doGroup')!.onClick.listen(clickGroupBySubLeague);
  
}

void selectLeague1(MouseEvent event) => clickLeague(0);
void selectLeague2(MouseEvent event) => clickLeague(1);

void clickLeague(int league){
  if (league == currentView.activeLeague){
    return;
  }
  currentView.activeLeague = league;

  saveCurrentView();
  pushViewState();
  redisplayData();
  
}

void selectViewAbout(MouseEvent event) => clickView(View.about);
void selectViewC(MouseEvent event) => clickView(View.chances);
void selectViewGB(MouseEvent event) => clickView(View.winsbehind);
void selectViewE(MouseEvent event) => clickView(View.eliminationmagic);
void selectViewPost(MouseEvent event) => clickView(View.postseason);
void selectViewW(MouseEvent event) => clickView(View.winningmagic);
void selectViewBracket(MouseEvent event) => clickView(View.bracket);

void clickView(View view){
  if(view == currentView.activeView){
    return;
  }
  currentView.activeView = view;
  selectViewButton();

  saveCurrentView();
  pushViewState();
  redisplayData();

}

void selectViewButton(){
  switch(currentView.activeView){
    case View.about:
      document.querySelector('#viewAbout')!.classList
        .add('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active');        
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');        
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');

      break;    
    case View.chances:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .add('nav-button-active');        
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');        
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');

      break;       
    case View.winsbehind:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active'); 
      document.querySelector('#viewWinsBehind')!.classList
        .add('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');        
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');

      break;
    case View.winningmagic:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .add('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .remove('nav-button-active');      
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');        
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');
      
      break;
    case View.eliminationmagic:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .add('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');        
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');

      break;
    case View.postseason:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active');        
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .add('nav-button-active');
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');
      
      break;
    case View.bracket:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active');        
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewEliminationNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .add('nav-button-active');
      
      break;
  }  

}

void clickGroupBySubLeague(MouseEvent event) {

  if(currentView.groupBySubLeague){
    currentView.groupBySubLeague = false;
    selectGroupBySubLeague();
  } else {
    currentView.groupBySubLeague = true;
    selectGroupBySubLeague();
  }
  
  saveCurrentView();
  pushViewState();
  redisplayData();
}

void selectGroupBySubLeague(){
  var groupButton = document.querySelector('#doGroup')!;
  if(currentView.groupBySubLeague){
    groupButton.classList.add('nav-button-active');
  } else {
    groupButton.classList.remove('nav-button-active');
  }
}

void redisplayData(){
  switch(currentView.activeView){
  case View.about:
    setMainContent(aboutHTML); 
    break;
  case View.winsbehind:
    setMainContent(gamesbehindHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText = 
      'MMOLB Games Behind'; 
    populateGamesBehindTable(allStandings, sitedata, currentView.groupBySubLeague);
    break;
  case View.chances:
    setMainContent(chancesHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText = 
      'MMOLB Playoff Chances';
    populateChancesTable(allStandings, sitedata, currentView.groupBySubLeague);
    setNotes(chancesNotesHTML);
    break;    
  case View.winningmagic:
    setMainContent(magicHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText =
      'MMOLB Winning Magic Numbers';
    populateWinningTable(allStandings, sitedata, currentView.groupBySubLeague);
    setNotes(winningNotesHTML);
    break;
  case View.eliminationmagic:
    setMainContent(magicHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText =
      'MMOLB Elimination Magic Numbers';
    populateEliminationTable(allStandings, sitedata, currentView.groupBySubLeague);
    setNotes(eliminationNotesHTML);
    break;
  case View.postseason:
    setMainContent(postseasonHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText =
      'MMOLB Post Season Chances';
    populatePostseasonTable(allStandings, sitedata, currentView.groupBySubLeague);
    break;  
  case View.bracket:
    setMainContent(bracketHTML);
    //populatePlayoffBracket(entries);
    break;
  }
  
}

void handlePopState(PopStateEvent event){
  print("PopStateEvent: ${event.toString()} ${event.type.toString()} ${event.state.toString()} ${event.state.runtimeType} ");
  if(event.state != null){
    print('State: ${event.state} ${event.state?.runtimeType}');
    //pushState(currentView.toJson().toJSBox
    currentView = CurrentView.fromHash(event.state.toString());

    selectGroupBySubLeague();
    selectViewButton();
    redisplayData();
  }
}

void pushViewState(){
  //update URL with popstate
   print('Pushing View State: ${currentView.toHash().toJS} ${currentView.toHash().toJS.runtimeType} ${currentView.toJson()}');
  window.history.pushState(currentView.toHash().toJS, '', 
    currentView.toHash());
}

void replaceViewState(){
  //update URL with popstate
  print('Replacing View State: ${currentView.toJson().toJSBox } ${currentView.toJson()}');
  window.history.replaceState(currentView.toHash().toJS, '', currentView.toHash());
}
  
void setMainContent(String html){
  document.querySelector('#mncntnt')!.replaceChildren(js.JSArray());
  document.querySelector('#mncntnt')!.innerHTML = html.toJS;
}

void setNotes(String html){
  document.querySelector('#notes')!.replaceChildren(js.JSArray());
  document.querySelector('#notes')!.innerHTML = html.toJS;  
}

void saveCurrentView(){
  window.localStorage.setItem('current_view', 
    json.encode(currentView.toJson()));
    
  //print("Saved Local storage ${window.localStorage['current_view']}");
}

CurrentView loadCurrentView(){
  //print("Loading Local storage ${window.localStorage['current_view']}");
  if (window.localStorage.getItem('current_view') != null){
    return CurrentView.fromJson(json.decode(
      window.localStorage.getItem('current_view')!));
  } else {
    var view = CurrentView();
    view.activeLeague = 0;
    view.activeView = View.winsbehind;
    view.groupBySubLeague = false;
    return view;
  }
}

