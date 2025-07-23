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
late String chancesNotesHTML;
late String winsbehindHTML;
late String magicHTML;
late String partytimeNotesHTML;
late String postseasonHTML;
late String winningNotesHTML;
late SiteData sitedata;

CurrentView currentView = CurrentView();
List<PlayoffBracketEntry> entries = [];

List<List<TeamStandings>> subStandings = [];

void main() {

  //String envBucket = js.globalContext.getProperty('envBucket'.toJS) ?? "";
  String envBucket = "prod";
  s3.envBucket = envBucket;
  
  print ("EnvBucket: $envBucket");

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

    selectLeagueButton();
    selectViewButton();
    redisplayData();
    
    addListeners();
    
    //setup auto refresh
    var cron = Cron();
    //Every five minutes from 20-50
    cron.schedule(Schedule.parse('1,21,26,31,36,41,46,51 * * * *'), () async {
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

  entries = await s3.getPlayoffBracketEntries();
  
  setUpdateTime(sitedata);
  
  (document.querySelector('#pickLeague1')! as HTMLElement).innerText = sitedata.subNicknames[0];
  (document.querySelector('#pickLeague2')! as HTMLElement).innerText = sitedata.subNicknames[1];

  if(sitedata.leagueWildCards || sitedata.leagueMildCards){
    winsbehindHTML = await read(Uri.parse('winsbehind_wc.html'));
    setMainContent(winsbehindHTML);
    magicHTML = await read(Uri.parse('magic_wc.html'));
    postseasonHTML = await read(Uri.parse('postseason_wc.html'));
  } else {
    winsbehindHTML = await read(Uri.parse('winsbehind.html'));
    setMainContent(winsbehindHTML);
    //magicHTML = await HttpRequest.getString('magic.html');
    //postseasonHTML = await HttpRequest.getString('postseason.html');
  }
  aboutHTML = await read(Uri.parse('about.html'));
  //bracketHTML = await HttpRequest.getString('bracket.html');
  //chancesNotesHTML = await HttpRequest.getString('chancesNotes.html');
  //partytimeNotesHTML = await HttpRequest.getString('partytimeNotes.html');
  //winningNotesHTML = await HttpRequest.getString('winningNotes.html');
}

Future<void> refreshData() async{
  //get all data for displaying
  print('Refreshing data');
  sitedata = await s3.getSiteData();
  print('Updated sitedata: $sitedata');
  
  setSeasonDay(sitedata);
  subStandings = await s3.getSubStandings(sitedata);
  
  entries = await s3.getPlayoffBracketEntries();
  
  var standingsTable = document.querySelector('#standingsTable') as HTMLTableElement?;
  if(standingsTable != null){
    while (standingsTable.rows.length > 2){
      standingsTable.deleteRow(2);
    }
  }
  
  switch(currentView.activeView){
  case View.winsbehind:
    populateWinsBehindTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    break;
  case View.winningmagic:
    populateWinningTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    break;
  case View.partytimemagic:
    populatePartyTimeTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    break;
  case View.chances:
    populateChancesTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    break;    
  case View.postseason:
    populatePostseasonTable(subStandings, currentView.groupByDiv, sitedata);
    break; 
  case View.bracket:
    populatePlayoffBracket(entries);
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

void setNavButtonStates(){
 switch(currentView.activeView){
  case View.about:
    (document.querySelector('#pickLeague1')! as HTMLButtonElement).disabled = true;
    (document.querySelector('#pickLeague2')! as HTMLButtonElement).disabled = true;
    break;    
  case View.postseason:
    (document.querySelector('#pickLeague1')! as HTMLButtonElement).disabled = true;
    (document.querySelector('#pickLeague2')! as HTMLButtonElement).disabled = true;  
    break; 
  case View.bracket:
    (document.querySelector('#pickLeague1')! as HTMLButtonElement).disabled = true;
    (document.querySelector('#pickLeague2')! as HTMLButtonElement).disabled = true; 
    break;    
  default:
    (document.querySelector('#pickLeague1')! as HTMLButtonElement).disabled = false;
    (document.querySelector('#pickLeague2')! as HTMLButtonElement).disabled = false;
    break;
  }  
  
}

void setSeasonDay(SiteData sitedata){
  var season = sitedata.season + 1;
  var day = sitedata.day + 1;
  if(day <= sitedata.daysInSeason){
    (document.querySelector('.wkinfo')! as HTMLElement).innerText = 
      'Season $season: Day $day';
  } else {
    (document.querySelector('.wkinfo')! as HTMLElement).innerText = 
      'Season $season: Day $day (Postseason)';    
  }
}

void addListeners(){
  window.onPopState.listen(handlePopState);
  
  document.querySelector('#pickLeague1')!.onClick.listen(selectLeague1);
  document.querySelector('#pickLeague2')!.onClick.listen(selectLeague2);
  
  document.querySelector('#viewWinsBehind')!.onClick.listen(selectViewGB);
  document.querySelector('#viewChances')!.onClick.listen(selectViewC);  
  document.querySelector('#viewWinningNumbers')!.onClick.listen(selectViewW);
  document.querySelector('#viewPartyTimeNumbers')!.onClick.listen(selectViewPT);
  document.querySelector('#viewAbout')!.onClick.listen(selectViewAbout);
  document.querySelector('#viewPostseasonChances')!.onClick.listen(selectViewPost);
  //document.querySelector('#viewPlayoffBracket')!.onClick.listen(selectViewBracket);
  
}

void handlePopState(PopStateEvent event){
  //print("PopStateEvent: ${event.toString()} ${event.type.toString()} ${event.timeStamp.toString()} ");
  if(event.state != null){
    print('State: ${event.state}');
    //pushState(currentView.toJson().toJSBox
    var jsonState = Map.from( (event.state as js.JSBoxedDartObject).toDart as Map<String, dynamic>
      ).map((k, v) => MapEntry<String, dynamic>(k.toString(), v));
    currentView = CurrentView.fromJson(jsonState);
    selectLeagueButton();
    selectViewButton();
    redisplayData();
  }
}

void selectLeague1(MouseEvent event) => clickLeague(0);
void selectLeague2(MouseEvent event) => clickLeague(1);

void clickLeague(int league){
  if (league == currentView.activeLeague){
    return;
  }
  currentView.activeLeague = league;
  selectLeagueButton();

  saveCurrentView();
  pushViewState();
  redisplayData();
  
}

void selectLeagueButton() {
  if(currentView.activeLeague == 0){
    document.querySelector('#pickLeague1')!.classList
      .add('nav-button-active');
    document.querySelector('#pickLeague2')!.classList
      .remove('nav-button-active');
  } else {
    document.querySelector('#pickLeague1')!.classList
      .remove('nav-button-active');
    document.querySelector('#pickLeague2')!.classList
      .add('nav-button-active');
  }
}


void selectViewAbout(MouseEvent event) => clickView(View.about);
void selectViewC(MouseEvent event) => clickView(View.chances);
void selectViewGB(MouseEvent event) => clickView(View.winsbehind);
void selectViewPT(MouseEvent event) => clickView(View.partytimemagic);
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
      document.querySelector('#viewPartyTimeNumbers')!.classList
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
      document.querySelector('#viewPartyTimeNumbers')!.classList
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
      document.querySelector('#viewPartyTimeNumbers')!.classList
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
      document.querySelector('#viewPartyTimeNumbers')!.classList
        .remove('nav-button-active');      
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');        
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .remove('nav-button-active');
      
      break;
    case View.partytimemagic:
      document.querySelector('#viewAbout')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewChances')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinsBehind')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewWinningNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPartyTimeNumbers')!.classList
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
      document.querySelector('#viewPartyTimeNumbers')!.classList
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
      document.querySelector('#viewPartyTimeNumbers')!.classList
        .remove('nav-button-active');
      document.querySelector('#viewPostseasonChances')!.classList
        .remove('nav-button-active');
      //document.querySelector('#viewPlayoffBracket')!.classList
      //  .add('nav-button-active');
      
      break;
  }  

}

void redisplayData(){
  switch(currentView.activeView){
  case View.about:
    setMainContent(aboutHTML); 
    populateAboutPageData(subStandings);
    break;
  case View.winsbehind:
    setMainContent(winsbehindHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText = 
      sitedata.subNicknames[currentView.activeLeague]; 
    populateWinsBehindTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    break;
  case View.chances:
    setMainContent(magicHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText = 
      '${sitedata.subNicknames[currentView.activeLeague]} League Playoff Chances';
    populateChancesTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    setNotes(chancesNotesHTML);
    break;    
  case View.winningmagic:
    setMainContent(magicHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText =
      '${sitedata.subNicknames[currentView.activeLeague]} League Winning Magic Numbers';
    populateWinningTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    setNotes(winningNotesHTML);
    break;
  case View.partytimemagic:
    setMainContent(magicHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText =
      '${sitedata.subNicknames[currentView.activeLeague]} League Party Time Magic Numbers';
    populatePartyTimeTable(subStandings[currentView.activeLeague], currentView.groupByDiv, sitedata);
    setNotes(partytimeNotesHTML);
    break;
  case View.postseason:
    setMainContent(postseasonHTML);
    (document.querySelector('#leagueTitle')! as HTMLElement).innerText =
      'MMOLB Post Season Chances';
    populatePostseasonTable(subStandings, currentView.groupByDiv, sitedata);
    break;  
  case View.bracket:
    setMainContent(bracketHTML);
    populatePlayoffBracket(entries);
    break;
  }
  
  setNavButtonStates();
}

void pushViewState(){
  //update URL with popstate
  window.history.pushState(currentView.toJson().toJSBox, '', 
    currentView.toHash());
}

void replaceViewState(){
  //update URL with popstate
  window.history.replaceState(currentView.toJson().toJSBox, '', 
    currentView.toHash());
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
    view.groupByDiv = false;
    return view;
  }
}

