#!/bin/bash

# list only databases that current user can access
echo "choose a DB to add a table to it:"
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
    echo "only owner and admins are alowed to empty a DB. Exiting..."
    exit 1
fi   


#insert table name
echo "enter table name:"
read tableName


#check if table already exist
if [[ -f "/Databases/$dbName/$tableName.txt" ]]; then
    echo "DB: $tableName already exists in $dbName. Exiting..."
    exit 1
fi


#create the table
sudo touch "/Databases/$dbName/$tableName.txt"


#insert columns count
echo "how many columns do you want to create? excluding id column"
read cCount


# ask user to insert columns names
sudo sh -c echo "id" >> "/Databases/$dbName/$tableName.txt"
for ((i=1; i<=$cCount; i++)); do
    echo "Enter a name for column #$((i+1)):"
    read columnName
    sudo sh -c "echo "$columnName" >> "/Databases/$dbName/$tableName.txt""
done


echo "table $tableName created successfully in $dbName!"
