# TMT #

  TMT is tool which manages the automatic tests.

## Supported Operating Systems ##

TMT is designed to run on Linux system. The other systems are not supported.

## Installation ##

Before laucnhing TMT you need to prepare your workstation by installing the following tools:
* GIT,
* Ruby v2.0.0p648,
* libmysqlclient-dev library

In terminal you can go to location where will be installed TMT. Next you should use the following commands:

	```bash
	git clone https://github.com/tritem-eu/TMT.git
	bundle
	rake db:migrate RAILS_ENV=development
    rake db:seed RAILS_ENV=development
	rails s
	```
	
After installing the application you can open Browser and go to http://localhost:3000/users/sign_in page.
In the view you will see two fields "Email" and "Password" where you should fill in respectively "admin@example.com" and "top-secret".
	
## Tools ##
 * git: true
 * dev_webserver: webrick
 * prod_webserver: thin
 * database: sqlite, mysql
 * tests: rspec
 * frontend: bootstrap
 * email: smtp
 * authentication: devise
 * authorization: cancan

## Booting application ##

Below is showed checklist for Sandbox project (with variable TMT_DB=sandbox which uses _mysql_).
Command without TMT_DB variable application should run on default properties which uses _sqlite3_

Step by step

1. Prepare the ground for agent

     RAILS_ENV=production TMT_DB=sandbox rake tmt::agent:prepare

2. Creating tables in empty database

     RAILS_ENV=production TMT_DB=sandbox rake db:migrate db:seed

3. Upload options for project sandbox

     RAILS_ENV=production TMT_DB=sandbox rake tmt:seed:sandbox

4. Upload Scripts with Set structure for projec sandbox
    Adding directories with files into directory 'tmp/script-peron-production'. After it you should run commands
      RAILS_ENV=production TMT_DB=sandbox rake tmt:script:upload_test_cases

5. Running application

    with the Agent

      RAILS_ENV=production TMT_DB=sandbox AGENT=true thin start

    without the Agent

      RAILS_ENV=production TMT_DB=sandbox thin start

## Tests ##

Application has got three type commands to run test for:

* An unit test and an integration

    rspec spec

* Browser tests

    rspec spec --tag @js

* javaScript language

    rake jasmine

## Rake ##
Imporant commands:

* Check DB

    rake tmt:agent:check

* Prepare store and git repoistory for Agent

    rake tmt:agent:prepare

* Upload test cases from directory app_dir/tmp/script-peron-test

    rake tmt:script:upload_test_cases[show_print]

* Upload default variables for project sandbox

    rake tmt:seed:sandbox

* Show all commands

    rake -T

