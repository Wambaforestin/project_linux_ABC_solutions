#!/bin/bash

# verifying the root user 
if [ $(id -u) -ne 0 ]; then
    echo "you need to be the root user (super user) to execute the script"
    exit 1
fi

#defining the menu
ps3="choose and option : "
options=("Add a user" "Modify a user" "Delete a user" "exit")

#show the menu  and execute the various options
select opt in "${options[@]}"
do
    case $opt in 
        "Add a user")
        #ask the for the number of users the user want to add
        read -p "How many usrs do you want enter? : " n
        #verify if the number is valid
        if [[ ! $n =~ ^[0-9]+$ ]]; then
            echo "Invalid number."
            exit 2
        fi
        #using a for loop to loop through the number if uers to add
        for ((i=1; i<=n; i++))
        do
            #!asking for user account creation info
            echo "User $i : "
            read -p "Enter the name of the user : " username
            read -p "Enter de path of the folder used : " home
            read -p "Enter the expired date (format YYYY-MM-DD) : " expire
            read -p "Enter the password : " password
            read -p "Enter the identity : " uid
            #verify if the name of the user is empty
            if [ -z "$username" ]; then
                echo "The name of the user cannot be empty".
                exit 3
            fi
            #verify if the path to the folder for the user is empty
            if [ -z "$home" ]; then
                echo "The path to the folder for the user cannot be empty"
                exit 4
            fi
            #verify if the path for the user folder exist
            if [ -d "$home" ]; then
                echo "The path of the folder for the user exist already."
                exit 5
            fi
            #verify if the expired date is empty
            if [ -z "$expire" ]; then
                echo "The expire date cannot be empty."
                exit 6
            fi
            #verify if the date is lessthan the date of today
            today=$(date +%Y-%m-%d)
            if [[ "$expire" < "$today" ]]; then
                echo "the date cannot be lessthan the date of today."
                exit 7
            fi
            #add the user using the command 
            sudo useradd -m -d "$home" -e "$expire" -p "$password" -u "$uid" "$username"
            #verify is the command was successful
            if [ $? -eq 0 ]; then
                echo "The user $username was added successfully!!"
            else 
                echo "And error occured while adding the user $username."
            fi
        done
        ;;
        "Modify a user")
        #ask the name of the user 
        read -p "Enter the name of the user you want to modify : " username
        #verify if the user exist.
        if id -u "$username" > /dev/null 2>&1; then
            #ask for the new user info to modify
            echo "User $username"
            read -p "Enter the new name of the user : " newname
            read -p "Enter the new path for the user folder : " newhome
            read -p "Enter the new expired date (format YYYY-MM-DD) : " newexpire
            read -p "Enter the new password : " newpassword
            read -p "Enter the new identity : " newuid
            #verify if the new user is empty
            if [ -z "$newname" ]; then
                echo "The new user name cannot be empty."
                exit 8
            fi
            #verify if the path to the folder for the user is empty
            if [ -z "$newhome" ]; then
                echo "The new path to the folder for the user cannot be empty"
                exit 9
            fi
            #verify if the path for the user folder exist
            if [ -d "$newhome" ]; then
                echo "The new path of the folder for the user exist already."
                exit 10
            fi
            #verify if the expired date is empty
            if [ -z "$newexpire" ]; then
                echo "The new expire date cannot be empty."
                exit 11
            fi
            #verify if the date is lessthan the date of today
            today=$(date +%Y-%m-%d)
            if [[ "$newexpire" < "$today" ]]; then
                echo "The new date cannot be lessthan the date of today."
                exit 12
            fi
            #to modifying the user using the following command
            sudo usermod -l "$newname" -d "$newhome" -e "$newexpire" -p "$newpassword" -u "$newuid" "$username"
            #verify is the command worked
            if [ $? -eq 0 ]; then
                echo "The user $username was modified successfully!!"
                #change the user folder if modified
                if  [ "$home" != "$newhome" ]; then
                    mv "$home" "$newhome"
                    echo "The user folder has been changed from $home to $newhome"
                fi
            else 
                echo "And error occured while modifying the user $username."
            fi
        else 
            echo "The user $username doesn't exist!!"
        fi
        ;;
        "Delete a user")
        #ask the name of the user to delete
        read -p "Enter the name of the user you want delete : " username
        #verify id the user exist
        if id -u "$username" > /dev/null 2>&1; then
        #Asking the deleting options for the user
            echo "User $username : "
            read -p "Do you want to delete the user folder (yes/no) ? " delhome
            read -p "Do you want to delete the user folder even if you are conncted (yes/no) ? " force
            #verify if the options are valid
            if [[ ! $delhome =~ ^(yes|no)$ ]]; then
                echo "Invalid option"
                exit 13
            fi
             if [[ ! $force =~ ^(yes|no)$ ]]; then
                echo "Invalid option"
                exit 14
            fi    
            #deleting the user using tyhe command userdel
            if [ "$delhome" == "yes" ]; then
                #deleting.
                sudo userdel -r "$username"
            else
                #don't delete the user
                sudo userdel -r "$username"
            fi
           #check if the command was successful or not
            if [ $? -eq 0 ]; then
                echo "The user $username was successfully deleted!!"
            else
                echo "And error occured while deleting the user $username."
            fi
            #forcing the deletion of the user 
            if [ "$force" == "yes" ]; then 
                killall -u "$username"
                echo "the user $username was forced to disconnect."
            fi
        else
            echo "The user $username doesn't exist!!"
        fi    
        ;;
        "exit")
        #end the script
        echo "Good Bye !!"
        break
        ;;
        *)
            #display an error message if the option is invalid
            echo "Invalid option"
        ;;
    esac
done       
