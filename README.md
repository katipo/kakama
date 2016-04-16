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
