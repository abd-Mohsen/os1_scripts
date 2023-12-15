#!/bin/bash

# list only databases that current user can access
echo "choose a DB to delete a table from:"
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
    echo "only owner and admins are alowed to delete a DB. Exiting..."
    exit 1
fi   


# list tables in current DB, then enter a table name to delete
echo "choose a table to delete:"
for table in /Databases/$dbName/*; do
    name="$(basename "$table")"
    if [[ $table != *"schema"* ]]; then
        echo "-$name"
    fi
done
read tableName


# if selected name is not listed, exit with a msg
if ! [[ -f "/Databases/$dbName/$tableName.txt" ]]; then
    echo "DB: $tableName does not exist in $dbName. Exiting..."
    exit 1
fi


# if selected table is a schema, exit with a msg
if [[ $tableName == *"schema"* ]]; then
    echo "you can not delete schemas directly, please just enter the table name"
    exit 1
fi


# delete table and its schema
sudo rm /Databases/$dbName/$tableName.txt
sudo rm "/Databases/$dbName/$tableName schema.txt"


echo "table deleted successfully!"
