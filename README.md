# Kakama
## An open source staff and event rostering application by Katipo Communications Ltd.

### Basic Installation
* Clone
  * git clone git://github.com/katipo/kakama.git
* Install database. Kakama works with MySQL or Postgres
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
* Nice to have: Confirmation of Site settings after clicking save
* If you have trouble installing 'therubyracer' gem, on Mac OS X, try the
  following suggestion on StackOverflow:
    http://stackoverflow.com/questions/19630154/gem-install-therubyracer-v-0-10-2-on-osx-mavericks-not-installing/20145328#20145328
