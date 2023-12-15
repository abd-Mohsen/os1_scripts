#!/bin/bash


# Check if user is an admin
if grep -Fxq "$USER" /Admins.txt; then
    is_admin=true
else
    is_admin=false
fi


# Get database name and type from user input
echo "Enter database name:"
read dbname
echo "Enter database type (public/private): "
read dbtype


# exit if db already exists
if [[ -d "/Databases/$dbname" ]]; then
    echo "DB: $dbname already exists. Exiting..."
    exit 1
fi


# Create database directory
sudo mkdir /Databases/$dbname


# Set directory permissions based on user input
if [[ $dbtype == "public" ]]; then
    sudo chmod 777 /Databases/$dbname
elif [[ $dbtype == "private" ]]; then
    sudo chmod 770 /Databases/$dbname
else
    echo "Invalid database type. Exiting..."
    sudo rm -r /Databases/$dbname
    exit 1
fi


# Create group with the same name as the database and add owner and admins
sudo groupadd $dbname

sudo usermod -a -G $dbname $USER

while IFS= read -r admin; do
    sudo usermod -a -G $dbname $admin
done < /Admins.txt


# Set group ownership of the database directory
sudo chgrp $dbname /Databases/$dbname

echo "Database created successfully!"

newgrp $dbname #to give user (not admin) access to his new DB, whitout needing to login again

