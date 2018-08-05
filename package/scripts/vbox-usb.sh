#!/bin/sh

PATH=$PATH:/bin:/sbin:/usr/sbin

[ -f /etc/vbox/vbox.cfg ] && . /etc/vbox/vbox.cfg

start() { 
	lst=$(ls -lR /dev/bus/usb/ | grep crw)
	IFS=$'\n'
	for line in $lst
	do
	  major=$(echo $line | cut -d ' ' -f 17 | cut -d ',' -f 1)
	  minor=$(echo $line | grep crw | cut -d ' ' -f 20)
	  echo Create USB device $major:$minor
	  $INSTALL_DIR/VBoxCreateUSBNode.sh $major $minor
	done
}

stop() { 
	lst=$(ls -lR /dev/bus/usb/ | grep crw)
	IFS=$'\n'
	for line in $lst
	do
	  major=$(echo $line | cut -d ' ' -f 17 | cut -d ',' -f 1)
	  minor=$(echo $line | grep crw | cut -d ' ' -f 20)
	  echo Create USB device $major:$minor
	  $INSTALL_DIR/VBoxCreateUSBNode.sh --remove $major $minor
	done
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
esac 
