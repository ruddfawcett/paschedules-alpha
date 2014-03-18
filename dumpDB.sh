#!/bin/bash

if [ -d "db/data" ]; then
    echo "WARNING: db/data/ exists. OK to delete it? [Y/n]"
    read a
    if [[ $a = "Y" || $a = "y" || $a = "" ]]; then
	rm -r db/data
    else
	echo "Aborting..."
	exit
    fi
fi

if [ -e "data.tar.gz" ]; then
    if [ $# == 1 ] && [ $1 == "--auto" ]; then
	rm data.tar.gz
    else
	echo "WARNING: data.tar.gz exists. OK to delete it? [Y/n]"
	read a
	if [[ $a = "Y" || $a = "y" || $a = "" ]]; then
	    rm data.tar.gz
	else
	    echo "Aborting..."
	    exit
	fi
    fi
fi

echo "Dumping data"
dir=data bundle exec rake db:data:dump_dir
rm db/data/users.yml
echo "Creating tar file"
tar czf data.tar.gz db/data
echo "Deleting db/data"
rm -r db/data
