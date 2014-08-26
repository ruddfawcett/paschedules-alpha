#!/bin/bash -e

if ! ([ $# == 1 ] && [ $1 == "--auto" ]); then
    echo "WARNING: If you aren't running this on Jake's server, you probably want to edit this file to get rid of stuff specific to that computer."
    echo "If you still want to run it, run it with the flag --auto"
    exit
else
    cd /home/jake/final-project/
    source /usr/local/rvm/environments/ruby-2.0.0-p451@rails
    rake db:reset
    ruby scheduleRestore.rb https://paschedules_archive.s3.amazonaws.com/base_ids-08_26_2014
    xpra start :77
    DISPLAY=:77 rake schedules:parseSchedules
    rake schedules:purgeBlankSchedules
    rake schedules:convertToCommitments
    # Dump the database. -T users excludes the users table
    now=$(date +"%m_%d_%Y-%H_%M_%S")
    filename="data-$now.gz"
    ruby scheduleDump.rb "/home/jake/scheduleArchive/$filename"
    aws s3 cp "/home/jake/scheduleArchive/$filename" s3://paschedules_archive/
    echo "Restoring to heroku at $now" >> log/heroku_restore.log
    heroku run ruby scheduleRestore.rb "https://paschedules_archive.s3.amazonaws.com/$filename" &>> log/heroku_restore.log
fi
