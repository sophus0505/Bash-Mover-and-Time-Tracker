#!/bin/bash

# Check if there is a .bash_profile in the home directory, if not we create one. 
# Also check if the environmental variable LOGFILE is already created to avoid duplicate lines. 
if [ ! -f ~/.bash_profile ]; then
    touch ~/.bash_profile
    grep "LOGFILE=~/.local/share/.timer_logfile" ~/.bash_profile ||\
    echo export LOGFILE=~/.local/share/.timer_logfile >> ~/.bash_profile
fi 

function track {
    time_now=$(date)

    # Check if the first word in the last sentence of the logfile is LABEL, 
    # in that case we set task_running to true. 
    first_word="$(tail -n1 $LOGFILE | cut -d' ' -f1)"
    [ "$first_word" == "LABEL" ] && task_running=0 || task_running=1
    
    # Write the intended text to the logfile 
    if [ $1 == "start" ] && [ $task_running -eq 1 ]; then 
        echo "START $time_now" >> $LOGFILE
        echo "LABEL ${@:2}" >> $LOGFILE
        label="${@:2}"
    
    # Give message to user if they try to start two tasks at the same time. 
    elif [ $1 == "start" ] && [ $task_running -eq 0 ]; then 
        echo "Task is already running!"

    # Stop logging the file.
    elif [ $1 == "end" ] && [ $task_running -eq 0 ]; then 
        echo "END $time_now" >> $LOGFILE
        echo "" >> $LOGFILE
    
    # Give message to user if there is no task to stop. 
    elif [ $1 == "end" ] && [ $task_running -eq 1 ]; then 
        echo "There is no task to stop!"

    # Give descriptive status message to user 
    elif [ $1 == "status" ] && [ $task_running -eq 0 ]; then 
        echo "$label is running!"

    # Give descriptive status message to user 
    elif [ $1 == "status" ] && [ $task_running -eq 1 ]; then 
        echo "No task is running!"

    elif [ $1 == "log" ]; then
        # Get the number of lines in the logfile
        num_lines=$(wc -l $LOGFILE | cut -d "/" -f 1)

        # Calculate the number of tasks
        num_tasks=$(($num_lines / 4)) 

        declare -i i=1
        while [ $i -le $num_tasks ]; do

            # Find start and end date for each task and convert to seconds since epoch
            start_date=$(grep START $LOGFILE | cut -d " " -f2- | head -n $i | tail -n 1)
            start_date=$(date -j -f "%a %b %d %T %Z %Y" "$start_date" +"%s")

            end_date=$(grep END $LOGFILE | cut -d " " -f2- | head -n $i | tail -n 1)
            end_date=$(date -j -f "%a %b %d %T %Z %Y" "$end_date" +"%s")

            # Calculate the difference in seconds and convert to hours:minutes:seconds
            seconds=$(($end_date - $start_date))

            hours=$((${seconds} / 3600))
            seconds=$((${seconds} % 3600))
            minutes=$((${seconds} / 60))
            seconds=$((${seconds} % 60))

            final_time="$(($hours)):$(($minutes)):$(($seconds))"

            # Find the label of the task and print the result 
            label=$(grep LABEL $LOGFILE | cut -d " " -f2- | head -n $i | tail -n 1)
            echo $label: $final_time

            (( i++ ))
        done 
    fi
}



