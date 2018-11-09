#!/bin/sh

[ -f /etc/vbox/vbox.cfg ] && . /etc/vbox/vbox.cfg

# Linux kernel module init script
PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
DEVICE=/dev/vboxdrv
# INSTALL_DIR is from vbox.cfg
VBOXMANAGE="$INSTALL_DIR/VBoxManage"
PACKAGE=virtualbox4dsm
PACKAGE_DIR="/var/packages/${PACKAGE}"

export BUILD_TYPE
export USERNAME
export USER=$USERNAME

#inserts a module into kernel space
# $1 - module actual file name $2 - module kernel display name (might be different from the above) $3 - path to modules
insert_module () {
	#check if module is already loaded
  	lsmod | grep -q $2
  	if [ $? != 0 ]; then
    		insmod "$3"/"$1".ko
    		#check if module was actually loaded
    		lsmod | grep -q $2
    		if [ $? != 0 ]; then
      			echo "Failed to load $1, use dmesg to find out why."
				exit 4
    		else
      			echo "$1 loaded successfully"
    		fi
  	else
    		echo "$1 is already loaded"
  	fi
}

remove_module() {
	lsmod | grep -q $2
	if [ $? != 0 ]; then
		echo "$1 module is not loaded"
	else
		rmmod $1
		lsmod | grep -q $2
		if [ $? != 0 ]; then
			echo "$1 removed successfully"
		else
			echo "Failed to remove $1"
		fi
	fi
}

running()
{
    lsmod | grep -q "$1[^_-]"
}

runningvm()
{
    VMS=`$VBOXMANAGE --nologo list runningvms | sed -e 's/^".*".*{\(.*\)}/\1/' 2>/dev/null`
    if [ ! "$VMS" == "" ]; then
        return 0
    fi

    return 1
}

failure()
{
    echo "$1"
    exit 4
}

start()
{
    echo "Starting VirtualBox kernel modules"
    if [ -d /proc/xen ]; then
        failure "Running VirtualBox in a Xen environment is not supported"
    fi

	# determine on what platform we are running
	KERNEL=$(uname -a | awk '{print $3}')
	DIST=$(uname -a | awk '{print $14}' | awk '{split($0,a,"_"); print a[2]}')
	case $DIST in
		bromolow)
			PLATFORM=bromolow
		;;
		broadwell)
			PLATFORM=broadwell
		;;
		braswell)
			PLATFORM=braswell
		;;
		cedarview)
			PLATFORM=cedarview
		;;
		avoton)
			PLATFORM=avoton
		;;
		*)
			PLATFORM=x86_64
		;;
	esac
	
	echo "Loading driver from: ${PACKAGE_DIR}/target/drivers/${PLATFORM}/${KERNEL}"
	
    # load vboxdrv
    insert_module vboxdrv vboxdrv "${PACKAGE_DIR}/target/drivers/${PLATFORM}/${KERNEL}"
    sleep 2

    # ensure the character special exists
    if [ ! -c $DEVICE ]; then
        MAJOR=`sed -n 's;\([0-9]\+\) vboxdrv;\1;p' /proc/devices`
        if [ ! -z "$MAJOR" ]; then
            MINOR=0
        else
            MINOR=`sed -n 's;\([0-9]\+\) vboxdrv$;\1;p' /proc/misc`
            if [ ! -z "$MINOR" ]; then
                MAJOR=10
            fi
        fi
        if [ -z "$MAJOR" ]; then
            remove_module vboxdrv vboxdrv
            failure "Cannot locate the VirtualBox device"
        fi
        if ! mknod -m 0660 $DEVICE c $MAJOR $MINOR 2>/dev/null; then
            remove_module vboxdrv vboxdrv
            failure "Cannot create device $DEVICE with major $MAJOR and minor $MINOR"
        fi
    fi

    # ensure permissions
    if ! chown :root $DEVICE 2>/dev/null; then
        remove_module vboxpci vboxpci
        remove_module vboxnetadp vboxnetadp
        remove_module vboxnetflt vboxnetflt
        remove_module vboxdrv vboxdrv
        failure "Cannot change group root for device $DEVICE"
    fi

    # load other modules
    insert_module vboxnetflt vboxnetflt "${PACKAGE_DIR}/target/drivers/${PLATFORM}/${KERNEL}"
    insert_module vboxnetadp vboxnetadp "${PACKAGE_DIR}/target/drivers/${PLATFORM}/${KERNEL}"
    insert_module vboxpci vboxpci "${PACKAGE_DIR}/target/drivers/${PLATFORM}/${KERNEL}"

    # Create the /dev/vboxusb directory if the host supports that method
    # of USB access.  The USB code checks for the existence of that path.
    if grep -q usb_device /proc/devices; then
        mkdir -p -m 0750 /dev/vboxusb 2>/dev/null
        chown vbox:root /dev/vboxusb 2>/dev/null
    fi

    echo "Starting VirtualBox kernel modules. Done!"
}

stop()
{
    echo "Stopping VirtualBox kernel modules"
    remove_module vboxpci vboxpci
    remove_module vboxnetadp vboxnetadp
    remove_module vboxnetflt vboxnetflt
    remove_module vboxdrv vboxdrv

    if ! rm -f $DEVICE; then
      failure "Cannot unlink $DEVICE"
    fi

    echo "Stopping VirtualBox kernel modules. Done!"
}

# enter the following variables in vbox.cfg:
#   SHUTDOWN_USERS="foo bar"  
#     check for running VMs of user foo and user bar
#   SHUTDOWN=poweroff
#   SHUTDOWN=acpibutton
#   SHUTDOWN=savestate
#     select one of these shutdown methods for running VMs
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

dmnstatus()
{
    if running vboxdrv; then
        str="vboxdrv"
        if running vboxnetflt; then
            str="$str, vboxnetflt"
            if running vboxnetadp; then
                str="$str, vboxnetadp"
            fi
        fi
        if running vboxpci; then
            str="$str, vboxpci"
        fi
        echo "VirtualBox kernel modules ($str) are loaded."
        for i in $SHUTDOWN_USERS; do
            # don't create the ipcd directory with wrong permissions!
            if [ -d /tmp/.vbox-$i-ipc ]; then
                export VBOX_IPC_SOCKETID="$i"
                VMS=`$VBOXMANAGE --nologo list runningvms | sed -e 's/^".*".*{\(.*\)}/\1/' 2>/dev/null`
                if [ -n "$VMS" ]; then
                    echo "The following VMs are currently running:"
                    for v in $VMS; do
                       echo "  $v"
                    done
                fi
            fi
        done
    else
        echo "VirtualBox kernel module is not loaded."
    fi
}

case "$1" in
start)
    start
    ;;
stop)
    if runningvm; then
        stop_vms
    fi
    stop
    ;;
stop_vms)
    stop_vms
    ;;
restart)
    stop && start
    ;;
force-reload)
    stop && start
    ;;
status)
    dmnstatus
    ;;
*)
    echo "Usage: $0 {start|stop|stop_vms|restart|force-reload|status}"
    exit 1
esac

exit 0
