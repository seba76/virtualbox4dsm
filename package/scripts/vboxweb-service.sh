#!/bin/sh

PATH=$PATH:/bin:/sbin:/usr/sbin

[ -f /etc/vbox/vbox.cfg ] && . /etc/vbox/vbox.cfg

binary="$INSTALL_DIR/vboxwebsrv"
vboxmanage="$INSTALL_DIR/VBoxManage"
PIDFILE="/var/run/vboxweb-service"

# Implementation of user control, execute several commands as another (predefined) user,
su_command="su - ${VBOXWEB_USER} -s /bin/sh -c"

fail_msg()
{
    echo "$1"
    exit 4
}

running()
{
    lsmod | grep -q "$1[^_-]"
}

vboxdrvrunning() {
    lsmod | grep -q "vboxdrv[^_-]"
}

check_single_user() {
    if [ -n "$2" ]; then
        echo "VBOXWEB_USER must not contain multiple users!"
        exit 1
    fi
}

start() {
    if [ ! -f ${PIDFILE} ]; then
		echo "Starting VirtualBox web service";
        [ -z "$VBOXWEB_USER" ] && exit 0

        check_single_user $VBOXWEB_USER
        vboxdrvrunning || {
            fail_msg "VirtualBox kernel module not loaded!"
            exit 0
        }
		
        PARAMS="--background"
        [ -n "$VBOXWEB_HOST" ]           && PARAMS="$PARAMS -H $VBOXWEB_HOST"
        [ -n "$VBOXWEB_PORT" ]           && PARAMS="$PARAMS -p $VBOXWEB_PORT"
        [ -n "$VBOXWEB_SSL_KEYFILE" ]    && PARAMS="$PARAMS -s -K $VBOXWEB_SSL_KEYFILE"
        [ -n "$VBOXWEB_SSL_PASSWORDFILE" ] && PARAMS="$PARAMS -a $VBOXWEB_SSL_PASSWORDFILE"
        [ -n "$VBOXWEB_SSL_CACERT" ]     && PARAMS="$PARAMS -c $VBOXWEB_SSL_CACERT"
        [ -n "$VBOXWEB_SSL_CAPATH" ]     && PARAMS="$PARAMS -C $VBOXWEB_SSL_CAPATH"
        [ -n "$VBOXWEB_SSL_DHFILE" ]     && PARAMS="$PARAMS -D $VBOXWEB_SSL_DHFILE"
        [ -n "$VBOXWEB_SSL_RANDFILE" ]   && PARAMS="$PARAMS -r $VBOXWEB_SSL_RANDFILE"
        [ -n "$VBOXWEB_TIMEOUT" ]        && PARAMS="$PARAMS -t $VBOXWEB_TIMEOUT"
        [ -n "$VBOXWEB_CHECK_INTERVAL" ] && PARAMS="$PARAMS -i $VBOXWEB_CHECK_INTERVAL"
        [ -n "$VBOXWEB_THREADS" ]        && PARAMS="$PARAMS -T $VBOXWEB_THREADS"
        [ -n "$VBOXWEB_KEEPALIVE" ]      && PARAMS="$PARAMS -k $VBOXWEB_KEEPALIVE"
        [ -n "$VBOXWEB_AUTHENTICATION" ] && PARAMS="$PARAMS -A $VBOXWEB_AUTHENTICATION"
        [ -n "$VBOXWEB_LOGFILE" ]        && PARAMS="$PARAMS -F $VBOXWEB_LOGFILE"
        [ -n "$VBOXWEB_ROTATE" ]         && PARAMS="$PARAMS -R $VBOXWEB_ROTATE"
        [ -n "$VBOXWEB_LOGSIZE" ]        && PARAMS="$PARAMS -S $VBOXWEB_LOGSIZE"
        [ -n "$VBOXWEB_LOGINTERVAL" ]    && PARAMS="$PARAMS -I $VBOXWEB_LOGINTERVAL"
        # set authentication method + password hash
        if [ -n "$VBOXWEB_AUTH_LIBRARY" ]; then
            ${su_command} "$vboxmanage setproperty websrvauthlibrary \"$VBOXWEB_AUTH_LIBRARY\""
            if [ $? -ne 0 ]; then
                echo "Error $? setting webservice authentication library to $VBOXWEB_AUTH_LIBRARY"
            fi
        fi
        if [ -n "$VBOXWEB_AUTH_PWHASH" ]; then
            ${su_command} "$vboxmanage setextradata global \"VBoxAuthSimple/users/$VBOXWEB_USER\" \"$VBOXWEB_AUTH_PWHASH\""
            if [ $? -ne 0 ]; then
                echo "Error $? setting webservice password hash"
            fi
        fi

        # prevent inheriting this setting to VBoxSVC
        unset VBOX_RELEASE_LOG_DEST
        
        #start_daemon $VBOXWEB_USER $binary $PARAMS > /dev/null 2>&1
        ${su_command} "$binary $PARAMS" > /dev/null 2>&1

        # ugly: wait until the final process has forked
        sleep 1
        PID=`pidof vboxwebsrv 2>/dev/null`
        if [ -n "$PID" ]; then
            echo "$PID" > $PIDFILE
            RETVAL=0
	    echo "Starting SUCCESS!"
        else
            RETVAL=1
            echo "Starting FAIL!"
        fi
	else
		echo "It looks like VirtualBox is running, delete ${PIDFILE} if it's not.";
    fi

    echo "Starting VirtualBox web service. Done!";
    return $RETVAL
}

stop() {
    if test -f $PIDFILE; then
        echo "Stopping VirtualBox web service";
        PID=`pidof vboxwebsrv 2>/dev/null`
        kill $PID
        RETVAL=$?
        if ! pidof vboxwebsrv > /dev/null 2>&1; then
            rm -f $PIDFILE
            echo "Stopping SUCESS!"
        else
            echo "Stopping FAIL!"
        fi
		
		echo "Stopping VirtualBox web service. Done!";
    fi

    return $RETVAL
}

restart() {
    stop && start
}

status() {
    echo -n "Checking status of VBox Web Service. Service is "
    if [ -f $PIDFILE ]; then
        RETVAL=0
        echo " ...running"
    else
        RETVAL=3
        echo " ...not running"
    fi
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    restart
    ;;
status)
    status
    ;;
*)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
esac

exit $RETVAL
