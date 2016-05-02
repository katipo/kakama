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
* TODO: Delete config/initializers/new_rails_defaults.rb
* TODO: Check other TODO buried in code
* Nice to have: Confirmation of Site settings after clicking save

### Notes for peer review:
  * Please could you check all changes to the features/ folder? I want to be
  sure that I haven't relaxed any important rules.
  * In particular, one change to the RolesController and VenuesController is
  that when validation prevents deletion, an error is not returned, but a
  message is displayed. Is this acceptable?