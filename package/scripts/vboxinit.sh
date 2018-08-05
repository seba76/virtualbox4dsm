#!/bin/sh

[ -f /etc/vbox/vbox.cfg ] && . /etc/vbox/vbox.cfg

vboxmanage="$INSTALL_DIR/VBoxManage"

# Implementation of user control, execute several commands as another (predefined) user,
su_command="su - ${VBOXWEB_USER} -s /bin/sh -c"

# Enable/disable service
if [ "${VBOXWEB_USER}" == "" ]; then
    echo "stop vm's is not enabled. add  VBOXWEB_USER="vbox" in /etc/vbox/vbox.cfg to enable"
	exit 0
fi

start()
{
    echo "vboxinit starting VM's"
	# Get all autostart machines
	MACHINES=$($su_command "$vboxmanage list vms | awk '{ print \$NF }' | sed -e 's/[{}]//g'")
	for UUID in $MACHINES; do
		STARTUP=$($su_command "$vboxmanage getextradata $UUID 'pvbx/startupMode'" | awk '{ print $NF }')
		if [ "${STARTUP}" == "auto" ]; then
			VMNAME=$(${su_command} "$vboxmanage showvminfo $UUID | sed -n '0,/^Name:/s/^Name:[ \t]*//p'")
			echo "$0: starting machine ${VMNAME} ..."
			${su_command} "$vboxmanage startvm $UUID --type headless"
		fi
	done
	echo "vboxinit starting done"
}

stop()
{
	echo "vboxinit stopping VM's"
	# vms are saved, instead of stopped.
	#MACHINES=$(${su_command} "$vboxmanage list runningvms | awk '{ print \$NF }' | sed -e 's/[{}]//g'")
	#for UUID in $MACHINES; do
	#	VMNAME=$(${su_command} "$vboxmanage showvminfo $UUID | sed -n '0,/^Name:/s/^Name:[ \t]*//p'")
	#	echo "$0: saving machine ${VMNAME} state ..."
	#	${su_command} "$vboxmanage controlvm $UUID savestate"
	#done
	stop_vms
	echo "vboxinit stopping done"
}

stop_vms()
{
    wait=0
    for i in $SHUTDOWN_USERS; do
        # don't create the ipcd directory with wrong permissions!
        if [ -d /tmp/.vbox-$i-ipc ]; then
            export VBOX_IPC_SOCKETID="$i"
            VMS=`$VBOXMANAGE --nologo list runningvms | sed -e 's/^".*".*{\(.*\)}/\1/' 2>/dev/null`
            if [ -n "$VMS" ]; then
                if [ "$SHUTDOWN" = "poweroff" ]; then
                    echo -n "Powering off remaining VMs"
                    for v in $VMS; do
                        $VBOXMANAGE --nologo controlvm $v poweroff
                    done
                    echo "... Done!"
                elif [ "$SHUTDOWN" = "acpibutton" ]; then
                    echo -n "Sending ACPI power button event to remaining VMs"
                    for v in $VMS; do
                    	echo "acpipower for $v"
                        $VBOXMANAGE --nologo controlvm $v acpipowerbutton
                        wait=30
                    done
                    echo "... Done!"
                elif [ "$SHUTDOWN" = "savestate" ]; then
                    echo -n "Saving state of remaining VMs"
                    for v in $VMS; do
                        $VBOXMANAGE --nologo controlvm $v savestate
                    done
                    echo "... Done!"
                fi
            fi
        fi
    done

    # wait for some seconds when doing ACPI shutdown
    if [ "$wait" -ne 0 ]; then
        echo -n "Waiting for $wait seconds for VM shutdown"
        sleep $wait
        echo "... Done!"
    else
	 echo -n  "VM shutdown"
         echo "... Done!"
    fi
} 

status()
{
	RMS=$(${su_command} "$vboxmanage list runningvms")
	if [ "${RMS}" == "" ]; then
		echo "No running VM's"
	else
		echo "${RMS}"
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
