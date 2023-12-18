#!/bin/bash

# to schedule a cron job (d,w,m) , the command is bkup2

read -p "daily(d), weekly(w), monthly(m)": choice

crontab -l > temp_crontab

sudo chmod +x bkup.sh,

if [[ $choice == "d" ]]; then
    echo "0 0 * * * "/os1/bkup2.sh" " >> temp_crontab
elif [[ $choice == "w" ]]; then
    echo "0 0 * * 0 "/os1/bkup2.sh" " >> temp_crontab
elif [[ $choice == "m" ]]; then
    echo "0 0 1 * * "/os1/bkup2.sh" " >> temp_crontab
else
    echo "please choose one of the previous 3 options. Exiting..."
    exit 1
fi

crontab temp_crontab

rm temp_crontab