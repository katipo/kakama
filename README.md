# Kakama
## An open source staff and event rostering application by Katipo Communications Ltd.

### Basic Installation
* Clone
  * git clone git://github.com/katipo/kakama.git
* Create databases
  * mysql> create database kakama;
  * mysql> grant all on kakama.* to 'kakama'@'localhost' identified by 'kakama';
* Configure
  * cp config/database.yml.example config/database.yml
  * Adjust config/database.yml as needed
* Prepare
  * bundle install
  * rake db:setup
  * rake db:seed_fu
  * whenever --update-crontab
  * ruby script/delayed_job start
* Run
  * rails server

### Known issues:
* Date selectors on event page don't show
* Need to fix 'Create event' button so that the button text is not displayed twice
* Nice to have: Confirmation of Site settings after clicking save
* If you have trouble installing 'therubyracer' gem, on Mac OS X, try the
  following suggestion on StackOverflow:
    http://stackoverflow.com/questions/19630154/gem-install-therubyracer-v-0-10-2-on-osx-mavericks-not-installing/20145328#20145328
