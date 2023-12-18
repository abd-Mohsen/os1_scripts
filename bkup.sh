#!/bin/bash

# list only databases that current user can access
echo "choose a DB to backup:"
for db in /Databases/*; do
    name="$(basename "$db")"
    if id -nG "$USER" | grep -qw "$name"; then
        echo "-$name"
    fi
done
read dbName


# if selected name is not listed, exit with a msg
if ! [[ -d "/Databases/$dbName" ]]; then
    echo "DB: $dbName does not exist. Exiting..."
    exit 1
fi


#check if current user is admin, or owner of this db
valid_user=false

if grep -Fxq "$USER" /Admins.txt; then
    valid_user=true
fi

if id -nG "$USER" | grep -qw "$dbName"; then
    valid_user=true
fi

if ! $valid_user; then
    echo "only owner and admins are allowed to delete a DB. Exiting..."
    exit 1
fi  

#enter comprission mode then compress the db folder
read -p "Enter compression mode: (zip, tar, gzip)" comp

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

echo "backed-up successfully!"