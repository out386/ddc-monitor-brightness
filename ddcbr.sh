#!/bin/bash

DDC="ddcutil --nodetect --noverify --bus"
BUS="3"
ADDRESS="10"
BASE_DIR=/home/$USER/ddcbr
FILE=$BASE_DIR/.brightness

function getCurrentBrightness {
    if [ -f $FILE ]
    then
        current_br=$(cat $FILE)
    fi
    if [ -z "$current_br" ]
    then
        current_br=$($DDC $BUS getvcp $ADDRESS | awk '{print $9}' | awk -F ',' '{print $1}')
    fi
}

function increaseBrightness {
    getCurrentBrightness
    if [ "$current_br" -le 90 ]
    then
        new_br=$((current_br + 10))
    else
        if [ "$current_br" -lt 100 ]
        then
            new_br=100
        else
            return 0
        fi
    fi
    $DDC $BUS setvcp $ADDRESS $new_br
    echo $new_br
    echo $new_br > $FILE
}

function decreaseBrightness {
    getCurrentBrightness
    if [ "$current_br" -ge 10 ]
    then
        new_br=$((current_br - 10))
    else
        if [ "$current_br" -gt 0 ]
        then
            new_br=0
        else
            return 0
        fi
    fi
    $DDC $BUS setvcp $ADDRESS $new_br
    echo $new_br
    echo $new_br > $FILE
}


if [ "$1" = "i" ]
then
    increaseBrightness
else
    if [ "$1" = "d" ]
    then
        decreaseBrightness
    fi
fi
