#!/bin/bash

# list only databases that current user can access
echo "choose a DB to update a record in its table:"
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
    echo "only owner and admins are allowed to update a record in their DB. Exiting..."
    exit 1
fi   


# list tables in current DB, then enter a table name to update record in it
echo "choose a table to update a record in it:"
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
    echo "you can not insert to schemas, please just enter the table name. Exiting..."
    exit 1
fi


# Read id and validate it
lastID=$(awk '/./{line=$0} END{print NR}' "$tableFile")
lastID=$((lastID))
echo "select record to update (enter id from 1-$lastID):"
read id
if [[ $id > $lastID ]]; then
    echo "record doesn't exist. Exiting..."
    exit 1
fi

if  sed -n "${id}p" $tableFile | grep -q "^deleted"; then # test this ===============
    echo "record is deleted. Exiting..."
    exit 1
fi



# list and Read a column to update it in the selected row
schemaFile="/Databases/$dbName/$tableName schema.txt"
echo "choose a column to update in :"
while IFS= read -r c; do
    echo "-$c"
done < "$schemaFile"
read column


# check if column exist and is not id
if ! grep -Fxq "$column" "$schemaFile"; then
    echo "column doesn't exist. Exiting..."
    exit 1
elif [[ $column == "id" ]]; then
    echo "u cant change id. Exiting..."
    exit 1
fi


# read new data and replace
echo "Enter new value for $column at record $id:"
read newVal
line=$(sed -n "${id}p" "$tableFile")
echo $line
oldVal=$(echo "$line" | grep -oP ""$column" = \K[^,]*")
echo "oldval ==== $oldVal"
sed -i "${id}s~${column} = ${oldVal}~${column} = ${newVal}~" "$tableFile"


echo "row updated successfully!"

