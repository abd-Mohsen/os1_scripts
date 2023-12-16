#!/bin/bash

# list only databases that current user can access
echo "choose a DB to insert data in its table:"
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
    echo "only owner and admins are allowed to insert in a table in their DB. Exiting..."
    exit 1
fi   


# list tables in current DB, then enter a table name to insert data in it
echo "choose a table to insert in:"
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


# Read schema file to get column names
schemaFile="/Databases/$dbName/$tableName schema.txt"
columns=()
while IFS= read -r column; do
    columns+=("$column")
done < "$schemaFile"


# Prompt user to enter data for each column
data=()
for ((i=1; i< ${#columns[@]}; i++)); do
    echo "Enter data for column \"${columns[i]}\":"
    read inputData
    data+=("$inputData") # do not let commas
done


# Generate unique ID for new row
lastID=$(awk '/./{line=$0} END{print NR}' "$tableFile")
newID=$((lastID + 1))


# Combine ID and entered data into a single line
line="id = $newID, "
for ((i=1; i<${#columns[@]}; i++)); do
    line+="${columns[i]} = ${data[i-1]}, "
done


# Append the line to the table file
echo "$line" | sudo tee -a "$tableFile" > /dev/null


echo "row inserted successfully!"

