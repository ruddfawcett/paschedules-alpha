#!/bin/bash

if ! ([ $# == 1 ] && [ $1 == "--auto" ]); then
    echo "WARNING: If you aren't running this on Jake's server, you probably want to edit this file to get rid of stuff specific to that computer."
    echo "If you still want to run it, run it with the flag --auto"
    exit
else
    rake db:reset
    cp db/fresh-preSchedules.yml db/data.yml
    rake db:data:load
    DISPLAY=:77 rake schedules:parseSchedules
    rake schedules:purgeBlankSchedules
    rake schedules:convertToCommitments
    ./dumpDB.sh --auto
    # ;)
    cp data.tar.gz /home/jake/scheduleArchive/
    # Eww Eww Eww Eww Eww
    cat data.tar.gz | nc -lcp 1357 & heroku run 'nc jherman.no-ip.org 1357 > /app/data.tar.gz'
    heroku run '/app/restoreDB.sh'
fi
