#!/bin/bash

rake db:reset
cp db/fresh-preSchedules.yml db/data.yml
rake db:data:load
DISPLAY=:77 rake schedules:parseSchedules
rake schedules:purgeBlankSchedules
rake schedules:convertToCommitments
./dumpDB.sh --auto
# Eww Eww Eww Eww Eww
cat data.tar.gz | nc -lcp 1357 & heroku run 'nc jherman.no-ip.org 1357 > /app/data.tar.gz'
heroku run '/app/restoreDB.sh'
