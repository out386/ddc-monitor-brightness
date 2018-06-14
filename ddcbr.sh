#!/bin/bash

DDC="ddcutil --nodetect --noverify --bus"
BUS="3"
ADDRESS="10"
BASE_DIR=/home/$USER/ddcbr
FILE=$BASE_DIR/.brightness
LOCK_FILE=$BASE_DIR/.lock
NOTIF_FILE=$BASE_DIR/.notifId

function getCurrentBrightness {
    if [ -f $FILE ]
    then
        current_br=$(cat $FILE)
    fi
    if [[ ! $current_br =~ ^[0-9]+$ ]]
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
    sendNotification $new_br
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
    sendNotification $new_br
}

function sendNotification {
    if [ -f $NOTIF_FILE ]
    then
        id=$(cat $NOTIF_FILE)
    else
        id=0
    fi
    if [[ ! $id =~ ^[0-9]+$ ]]
    then
        id=0
    fi

    id=$(gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \
        DDCBR \
        $id \
        notification-display-brightness-full \
        "Brightness" \
        "$1%" \
        [] \
        "{'type':<'int'>, 'name':<'value'>, 'value':<'$1'>, 'type':<'string'>, 'name':<'synchronous'>, 'value':<'volume'>}" 1)
    id=$(echo $id | sed 's/[^ ]* //; s/,.//')

    # Saving the notification ID allows replacing the notification if the script gets called again before the notification closes
    echo $id > $NOTIF_FILE
}

# Do nothing if it is already running. Not a good way to do this.
if [ -f $LOCK_FILE ]
    then
        exit
    else
        touch $LOCK_FILE
fi

if [ "$1" = "i" ]
then
    increaseBrightness
else
    if [ "$1" = "d" ]
    then
        decreaseBrightness
    fi
fi

rm $LOCK_FILE
