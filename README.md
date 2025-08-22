# MMOLB Playoff Status

## About
An attempt to replicate [Playoff Status](http://playoffstatus.com)
 behavior, but for [MMOLB](https://mmolb.com).
 
Published at https://mmolbplayofstat.us

## TODO
* Fix back button state restore bug
* Fix dev/prod environment switching in web app
* Bring back Group by League on all pages
* Better wild card playoff spot handling
* Add Dark Mode support
* Lesser League stat pages
* Add unit tests
* Create a github action for testing code
* Setup multiple development environments for testing data/web changes
* Figure out what's up with tied records getting weird sim results
* Display Postseason bracket schedule
* Handle postseason data live
* Team schedule pages
* Factor future schedule into magic numbers
* Reduce API calls during breaks

## Planned release schedule
* v0.0.1 
- [x] Publish a broken site again
- [x] Update About page info
- [x] Remove blaseball references
- [x] Disable the rest

* v0.0.2
- [x] Get Wins Behind data working
- [x] Remove Divine Favor
- [x] Remove Group By Div
- [x] Restore data update automation

* v0.0.3
- [x] Fix Wild Card games behind
- [x] Fix tie breaking
- [x] Automate web update deployment

* v0.0.4
- [x] Fix Magic Number calculations

* v0.1.0
- [x] Fix mid-season simulations
- [x] Fix postseason simulations
- [x] Fix mid-season chances pages
- [x] Fix postseason chances pages
- [x] Replace references to "Party Time" with "Elimination"

* v0.1.1
- [x] Get a new domain and off github pages
- [x] Single league view on end of season chances
- [x] Setup multiple development environments for testing data/web changes


* v0.1.2
- [ ] Add Group By League button for all pages
- [ ] Handle wild card positioning better
- [ ] Add unit tests back in
- [ ] Create a github action for testing code

* v0.1.3
- [ ] Lesser League stats
- [ ] Cleanup small TODO items

## Contributing

### Installing Dart
You will need Dart installed and on your $PATH to build and test 
the app.

On Linux
```
cd ~
wget --quiet https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
unzip -q -o dartsdk-linux-x64-release.zip -d ~
export PATH=$PATH:~/dart-sdk/bin:~/.pub-cache/bin
pub global activate peanut
pub get
```
On Windows, get the Windows Dart SDK zip, unzip it somewhere,
and add that unzip's bin folder to your PATH variable. You also need
to add the Pub Cache bin folder to your PATH, which may be in 
`c:\Users\<username>\AppData\Roaming\Pub\Cache\bin`.

You typically need to call the '.bat' versions of the helper tools
in Windows.

```
pub.bat global activate peanut
pub.bat get
```

### Building and testing
You can run all unit-tests with `pub.bat run test` or
a specific test with `dart test\test-file.dart`.

To serve up the app and test it in your browser run
```
pub.bat global activate webdev
webdev.bat serve [--debug]
```
And go to `http://localhost:8080/`.

On Windows, there doesn't seem to be a clean way to shutdown
the local webdev server, so you may have to kill the process
from Task Manager, or with `taskkill -f -pid ###`.

I find the Windows Git Shell from Github that emulates a lot of Linux
stuff to be really useful.

```
alias killdart='tasklist |grep dart |head -1 |awk '\''{print $2}'\'' | xargs taskkill -f -pid '
```

### Deploying
The Peanut plugin will automatically build your static web content
and commit it to the gh-pages branch. Then you can push the gh-pages
branch up to github.

```
peanut.bat
git push origin --set-upstream gh-pages
```

Your site should eventually get published to 
`yourusername.github.io/mmolb-playoff-status`.

## Architecture
There are two main code components, and three infrastructure components.

### Code components
1. `tools/update_stats.dart` - a CLI script which generates the json data files
for the site and uploads them to an S3 bucket in AWS.
2. `web` - All of the web site code that gets published to the gh-pages branch
by the dart plugin Peanut.

### Infrastructure components
1. AWS S3 - A public data bucket for holding the json data structures with all of the stats and season
data.
2. AWS EC2 - A very simple server with a cronjob for periodically running
`tools\update_stats.dart`
3. *TODO: Find a codeship replacement* Codeship - An automated build service which automatically tests the code
and deploys the published web site to the gh-pages branch, which is picked up
by github and deployed to the site.


## Acknowledgements
Huge thanks to:
* [The Game Band](https://thegameband.com/)
* [The Blaseball Discord](https://discord.gg/3uFgJhu) community
* The [SIBR](https://github.com/Society-for-Internet-Blaseball-Research) Discord community
* [PlayoffStatus.com](http://PlayoffStatus.com)
* [Dart](https://dart.dev/) for being an awesome language!
* [Peanut and Git plugins](https://github.com/kevmoo) for Dart to auto deploy to gh-pages
* [Codeship](https://codeship.com) for continuous integration and automated deployment
* [Codecov](https://app.codecov.io) for code coverage report viewing

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
