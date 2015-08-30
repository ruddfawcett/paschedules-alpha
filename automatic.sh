#!/usr/bin/env ruby

#TODO: Comment function of each line.

if ! (([ $# == 1 ] || [ $# == 2 ]) && [ $1 == "--auto" ]); then
    echo "WARNING: If you aren't running this on Rudd's desktop, you probably want to edit this file to get rid of stuff specific to that computer."
    echo "If you still want to run it, run it with the flag --auto."
    exit
else
    cd ~/GitHub/paschedules
    
    rake db:reset
    
    ruby scheduleRestore.rb https://paschedules-archives.s3.amazonaws.com/base_ids-08-19-2015.zip
    
    if [ $2 == "--add-exceptions" ]
        then
            rake schedules:addExceptions
    else
        echo "This will fail -- if you don't have the --add-exceptions flag (after --auto) and teachers are not in the database."
    fi
    
    rake schedules:parseSchedules > log/parser_automatic.log
    rake schedules:purgeBlankSchedules >> log/parser_automatic.log
    rake schedules:convertToCommitments >> log/parser_automatic.log
    
	now=$(date +"%m-%d-%Y") #-%H_%M_%S
	filename="schedules-$now.zip"
	
	bundle exec ruby scheduleDump.rb ~/Desktop/schedule-archive/$filename
	
	aws s3 cp ~/Desktop/schedule-archive/$filename s3://paschedules-archives/ >> log/aws_upload.log
	sleep 10   # S3 takes a little while to process
	
	echo "Restoring to Heroku on $(date)." >> log/heroku_restore.log
	heroku run --app paschedules ruby scheduleRestore.rb "https://paschedules-archives.s3.amazonaws.com/$filename" >> log/heroku_restore.log
fi
