#!/bin/bash
# Use ps and grep to check if the program is running
ps -ef | grep -v grep | grep ExecuterDaemon.rb # grep -v grep, keeps grep command itself out of the question
# if it is not running, start it.
if [ $? -eq 1 ]
then
# Your code to start the program goes here
# Could be something like:
cd /var/www/html/smartteam/ && nohup ruby ExecuterDaemon.rb & 
fi

