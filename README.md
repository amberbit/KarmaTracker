KarmaTracker
============

[![Build Status](https://travis-ci.org/amberbit/KarmaTracker.png)](https://travis-ci.org/amberbit/KarmaTracker)

KarmaTracker is a time tracking and reporting tool for teams and individuals who use Pivotal Tracker

Requirements
============

* JRuby - version 1.7.9
* PostgreSQL - version >= 9.2
* ElasticSearch - version 0.90.5
* PhantomJS - version >= 1.9 (for running tests only)

Setup
=====

Clone KarmaTracker repository:

    git clone https://github.com/amberbit/KarmaTracker.git

In KarmaTracker directory run Bundler:

    cd KarmaTracker/
    bundle install

If you face a problem with too low memory on bundle install use command with following jruby flags:

    jruby -J-Xms2048m -J-Xmx2048m -w -S bundle install

Poltergeist gem requires PhantomJS to run tests. To install PhantomJS follow instructions in [poltergeist readme](https://github.com/jonleighton/poltergeist/blob/master/README.md#installing-phantomjs).

Create database configuration file /config/database.yml using template from /config/database.template.yml. Fill in username and password of your PostgreSQL user.

**Note:** Postgres 9.2 might need to use port 5432.

**Note:** You might need to edit pg_hba config file to allow connections via TCP/IP.

Populate database for development and test.

    rake db:schema:load
    rake db:test:prepare

**Note:** Do not populate database with `rake db:migrate`.

To run project on Torquebox server first we must deploy it:

    torquebox deploy .
    torquebox run


To get the latest model diagram (located at /doc):
    bundle exec rake erd  filename='karmatracker_model_diagram' title='KarmaTracket model diagram' polymorphism=true inheritance=true

License
=======

Copyright (2013) AmberBit sp. z o. o.

KarmaTracker is licensed under the [MIT License](http://www.opensource.org/licenses/MIT).
