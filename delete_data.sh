#!/bin/bash

# list only databases that current user can access
echo "choose a DB to delete data from:"
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
    echo "only owner and admins are alowed to delete data from their DB. Exiting..."
    exit 1
fi   


# list tables in current DB, then enter a table name
echo "choose a table to delete from:"
for table in /Databases/$dbName/*; do
    name="$(basename "$table" .txt)"
    if [[ $table != *"schema"* ]]; then
        echo "-$name"
    fi
done
read tableName


# if selected name is not listed, exit with a msg
tableFile="/Databases/$dbName/$tableName.txt"
if ! [[ -f $tableFile ]]; then
    echo "DB: $tableName does not exist in $dbName. Exiting..."
    exit 1
fi


# if selected table is a schema, exit with a msg
if [[ $tableName == *"schema"* ]]; then
    echo "you can not delete from schemas, please just enter the table name. Exiting..."
    exit 1
fi


# delete all data or search for a record?
echo "clear all data(all) or delete records that contains certain word(search)?"
read choice

if [[ $choice == 'all' ]]; then
    sed -i "/./s/.*/deleted/" "$tableFile"
elif [[ $choice == 'search' ]]; then
    echo "enter a word to search for:"
    read query
    sed -i "/$query/s/.*/deleted/" "$tableFile"
else
    echo "invalid input. Exiting..."
    exit 1
fi
