#!/bin/bash

function move {
    src_=$1
    dst_=$2
    type_=$3

    # Check if there are two commandline args.
    [ $# -le 1 ] && { echo "move.sh needs at least two commandline args: src and dst."; return;} 

    # Check if the src directory exists.
    [ ! -d "$src_" ] && { echo "Cannot find directory: $src_"; return; }

    # Check if the src directory is empty
    [ -z "$(ls -A $src_)" ] && { echo "$src_ is empty!"; return; }

    # Check if the dst directory exists. If not user will have the option to create it. 
    if [ ! -d "$dst_" ]; then
        echo "Cannot find directory $dst_. Do you want to create $dst_ as a new directory?"
        select result1 in Yes No 
        do
            if [ $result1 == Yes ]; then 
                echo "Do you want to add the current date to the name of the new directory?"
                select result2 in Yes No
                    do 
                        if [ $result2 == Yes ]; then 
                            date="$(date +%F-%H-%M)"
                            dst_+="-${date}"
                            mkdir $dst_
                        else 
                            mkdir $dst_ 
                        fi 
                        break 
                    done 
            else
                return 
            fi
            break
        done
    fi

    [ ! -z "$type_" ] && mv -v $src_/*$3 $dst_ || mv -v $src_/* $dst_
}




