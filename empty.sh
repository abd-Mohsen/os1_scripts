#!/bin/bash

# list only databases that current user can access
echo "choose a DB to empty:"
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
    echo "only owner and admins are allowed to empty a DB. Exiting..."
    exit 1
fi   


#check if empty
if [[ -z $(find /Databases/$dbName/ -type f -print -quit) ]]; then
    echo "DB is already empty. Exiting..."
    exit 1
fi


# delete all files in current DB
rm -f /Databases/$dbName/*


echo "emptied successfully!"
