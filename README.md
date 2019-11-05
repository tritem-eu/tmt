# TMT #

  TMT is tool which manages the automatic tests.

## Tools ##
 * git: true
 * dev_webserver: webrick
 * prod_webserver: thin
 * database: sqlite, mysql
 * templates: erb
 * tests: rspec
 * frontend: bootstrap
 * email: smtp
 * authentication: devise
 * authorization: cancan
 * rvm: true

## Requirements

System should have:
 * '/tmp' directory

System should have installed libmysqlclient-dev library

## How to run sunspot ##

bundle exec rake sunspot:solr:start


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
    Running sunspot if it is not running

      RAILS_ENV=production TMT_DB=sandbox rake sunspot:solr:start

    Adding directories with files into directory 'tmp/script-peron-production'. After it you should run commands

      RAILS_ENV=production TMT_DB=sandbox rake sunspot:solr:start

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

* Drop and then reindex all solr models that are located in your application's models directory

    rake sunspot:reindex[batch_size,models]

* Start the Solr instance

    rake sunspot:solr:start

* Stop the Solr instance

    rake sunspot:solr:stop

* Show all commands

    rake -T

## Curl ##
    internal server:

    curl -X PUT --user bench@example.com http://10.11.0.155:3001/tmt_test/oslc/qm/service-proviplans/3/set-status-executing.json

    external server:

    curl -X PUT --user bench@example.com -x '' 10.11.0.155:3001/tmt_test/oslc/qm/service-providers/1/test-plans/4/set-status-executing.json
