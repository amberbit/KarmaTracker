KarmaTracker
============

KarmaTracker is a time tracking and reporting tool for teams and individuals who use Pivotal Tracker

Requirements
============

* JRuby - version 1.7.4
* PostgreSQL - version > 9.2
* PhantomJS - version > 1.9

Setup
=====

Clone KarmaTracker repository:

    git clone https://github.com/amberbit/KarmaTracker.git

In KarmaTracker directory run Bundler in jruby with following options which are required to properly install torquebox-server gem:

    cd KarmaTracker/
    jruby -J-Xms2048m -J-Xmx2048m -w -S bundle install

Poltergeist gem requires PhantomJS. To install PhantomJS follow instructions in [poltergeist readme](https://github.com/jonleighton/poltergeist/blob/master/README.md#installing-phantomjs).

Create database configuration file /config/database.yml using template from /config/database.template.yml. Fill in username and password of your PostgreSQL user.

Run database migration for development and test.

    rake db:schema:load
    rake db:test:prepare

To run project on Torquebox server first we must deploy it:

    torquebox deploy .
    torquebox run

License
=======

Copyright (2013) AmberBit sp. z o. o.

KarmaTracker is licensed under the [MIT License](http://www.opensource.org/licenses/MIT).
