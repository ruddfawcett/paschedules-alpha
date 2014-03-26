#!/bin/bash -e

if ! ([ $# == 1 ] && [ $1 == "--auto" ]); then
    echo "WARNING: If you aren't running this on Jake's server, you probably want to edit this file to get rid of stuff specific to that computer."
    echo "If you still want to run it, run it with the flag --auto"
    exit
else
    cd /home/jake/final-project/
    source /usr/local/rvm/environments/ruby-2.0.0-p451@rails
    rake db:reset
    cp db/fresh-preSchedules.yml db/data.yml
    rake db:data:load
    DISPLAY=:77 rake schedules:parseSchedules
    rake schedules:purgeBlankSchedules
    rake schedules:convertToCommitments
    # Dump the database. -T users excludes the users table
    pg_dump -Fc --no-acl --no-owner -h localhost -U jake -T users final_project_development > /tmp/data.dump
    cp /tmp/data.dump /srv/http/
    # ;)
    now=$(date +"%m-%d-%Y--%H:%M:%S")
    filename="data-$now.gz"
    gzip /tmp/data.dump
    mv /tmp/data.dump.gz "/home/jake/scheduleArchive/$filename"
    # Eww Eww Eww Eww Eww
    # cat data.tar.gz | nc -lcp 1357 & heroku run 'nc jherman.no-ip.org 1357 > /app/data.tar.gz'
    # I'm not sure if this is even more disgusting than the first one...
    sudo systemctl start httpd
    heroku pgbackups:restore DATABASE_URL 'http://jherman.no-ip.org/data.dump' --confirm=paschedules &>> log/heroku_restore.log
    sudo systemctl stop httpd
    heroku run rake schedules:updateUserCounter
    rm /srv/http/data.dump
fi
