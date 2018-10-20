#!/bin/sh

[ -f /etc/vbox/vbox.cfg ] && . /etc/vbox/vbox.cfg

PIDFILE=/run/vboxwolservice.pid
PACKAGE_DIR=/var/packages/virtualbox4dsm
WOL="${PACKAGE_DIR}/enabled_wol" 

vboxdrvrunning() {
    lsmod | grep -q "vboxdrv[^_-]"
}

start()
{
    echo "vbox wol starting"
	cd "${PACKAGE_DIR}/target/wol/"
	"${PACKAGE_DIR}/target/wol/vboxwolservice.py" --pid ${PIDFILE} --log "${PACKAGE_DIR}/target/share/vboxwolservice.log"
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
		if [ ! -f "${WOL}" ]; then
			exit 0;
		fi

		vboxdrvrunning || {
			echo "VirtualBox kernel module not loaded, aborting!"
			exit 4
		}

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
