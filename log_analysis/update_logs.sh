#!/bin/bash

if [ ! -f ./mapper.rb ]; then
    echo "You must run this from the log_analysis directory"
    exit 1
fi

if [ -f ./mapped_logs ]; then
    rm mapped_logs
fi

s3cmd sync s3://paschedules-logs ./paschedules-logs
zcat old_mapped_logs.gz > mapped_logs
shopt -s globstar
zcat paschedules-logs/090a84bc-flydata/**/*.gz | ruby mapper.rb >> mapped_logs
