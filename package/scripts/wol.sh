#!/bin/sh

[ -f /etc/vbox/vbox.cfg ] && . /etc/vbox/vbox.cfg

WOL="/var/packages/virtualbox/enabled_wol" 
PIDFILE=/run/vboxwolservice.pid
PACKAGE_DIR=/var/packages/virtualbox

start()
{
    echo "vbox wol starting"
	if [ -f ${WOL} ]; then
		cd "${PACKAGE_DIR}/target/wol/"
		"${PACKAGE_DIR}/target/wol/vboxwolservice.py" --pid ${PIDFILE} --log "${PACKAGE_DIR}/target/share/vboxwolservice.log"
	fi 
	echo "vbox wol done"
}

stop()
{
	echo "vbox wol stopping"
	if [ -f ${WOL} ]; then
		if [ -f ${PIDFILE} ]; then
			echo "Stopping VirtualBox WOL service"
			PID=`cat ${PIDFILE}`
			kill -9 $PID
			rm -f ${PIDFILE}
		fi
	fi 
	echo "vbox wol stopping done"
}

status()
{
	RMS=$(ps | grep vboxwolservice.py | grep -v grep)
	if [ "${RMS}" == "" ]; then
		echo "WOL service not running"
	else
		echo "WOL service is running"
	fi
}

case "$1" in

	start)
		start
		;;
	stop)
		stop
  		;;
	status)
		status
		;;
	restart)
		stop && start
		;;
	*)
	    echo "Usage: $0 {start|stop|restart|status}"
	    exit 1
		;;
esac
