#!/bin/bash -e

if ! ([ $# == 1 ] && [ $1 == "--auto" ]); then
    echo "WARNING: If you aren't running this on Jake's server, you probably want to edit this file to get rid of stuff specific to that computer."
    echo "If you still want to run it, run it with the flag --auto"
    exit
else
    cd ~/GitHub/paschedules
    rake db:reset
    ruby scheduleRestore.rb https://paschedules-archives.s3.amazonaws.com/base_ids-08_19_2015.zip
    rake schedules:parseSchedules &> log/parser_stdout_stderr.log
    rake schedules:purgeBlankSchedules &> log/parser_stdout_stderr.log
    rake schedules:convertToCommitments &> log/parser_stdout_stderr.log
    now = $(date +"%m_%d_%Y-%H_%M_%S")
    filename = "schedules-$now"
    ruby scheduleDump.rb "~/Desktop/schedule-archive/$filename"
    aws s3 cp "~/Desktop/schedule-archive/$filename" s3://paschedules-archives/
    sleep 10   # S3 takes a little while to process
    echo "Restoring to heroku at $now" >> log/heroku_restore.log
    /usr/local/heroku/bin/heroku run --app paschedules ruby scheduleRestore.rb "https://paschedules-archives.s3.amazonaws.com/$filename" &> log/heroku_restore.log
fi