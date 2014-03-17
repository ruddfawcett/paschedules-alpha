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

if [ ! -e "data.tar.gz" ]; then
    echo "ERROR: data.tar.gz not found!"
    echo "Aborting..."
    exit
fi

echo "Extracting tar file"
tar xzf data.tar.gz
echo "Restoring data"
dir=data bundle exec rake db:data:load_dir
echo "Cleaning up"
rm -r db/data
