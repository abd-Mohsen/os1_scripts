#!/bin/bash

#check if current user is admin
valid_user=false

if grep -Fxq "$USER" /Admins.txt; then
    valid_user=true
fi

if ! $valid_user; then
    echo "only owner and admins are allowed to do that. Exiting..."
    exit 1
fi  

# let admin choose, bkup all or just those updated at some date
# then ask for comprission mode
read -p "backup all DBs(all) or select those updated at a certain date(date)" choice

read -p "Enter compression mode: (zip, tar, gzip)" comp

if [[$choice == 'all']]; then
    for dbName in /Databases/*; do
        if [[ $comp == "zip" ]]; then
        sudo zip -r "/opt/backups/"$dbName".zip" "/Databases/"$dbName""
        elif [[ $comp == "tar" ]]; then
            sudo tar -cvf "/opt/backups/"$dbName".tar" "/Databases/"$dbName""
        elif [[ $comp == "gzip" ]]; then
            sudo tar -czvf "/opt/backups/"$dbName".tar.gz" "/Databases/"$dbName""
        else
            echo "please choose one of the previous 3 options. Exiting..."
            exit 1
        fi
    done

elif [[$choice == 'date']]; then
    read -p "Enter a date (YYYY-MM-DD): " userDate
    userTimestamp=$(date -d "$userDate" +%s)

    for dbName in /Databases/*; do
        directoryDate=$(stat -c %y /Databases/$dbName)
        directoryTimestamp=$(date -d "$directoryDate" +%s)
        if [[ $userTimestamp -eq $directoryTimestamp ]]; then
            if [[ $comp == "zip" ]]; then
            sudo zip -r "/opt/backups/"$dbName".zip" "/Databases/"$dbName""
            elif [[ $comp == "tar" ]]; then
                sudo tar -cvf "/opt/backups/"$dbName".tar" "/Databases/"$dbName""
            elif [[ $comp == "gzip" ]]; then
                sudo tar -czvf "/opt/backups/"$dbName".tar.gz" "/Databases/"$dbName""
            else
                echo "please choose one of the previous 3 options. Exiting..."
                exit 1
            fi
        fi
    done
else
    echo "invalid. Exiting..."
    exit 1
fi

echo "backed-up successfully!"