#!/usr/bin/python 
import socket
import sys
import struct
import os
import re
import vboxwebclient
from subprocess import Popen, PIPE
import ConfigParser
import argparse
import atexit
import signal
import base64
import logging
import logging.handlers 

HOST = ''   # Symbolic name meaning all available interfaces
PORT = 9    # Arbitrary port
VBOX = "/opt/VirtualBox/VBoxManage" # location of VBoxManage

#logger = logging.getLogger(__name__)
logger = logging.getLogger('vboxwolservice')

class Service(object):
    def __init__(self, pidfile):
        self.pidfile = pidfile
        self.running = False

    def daemonize(self):
        try:
            pid = os.fork()
            if pid > 0:  # exit first parent
                sys.exit(0)
        except OSError, e:
            sys.stderr.write('Fork #1 failed: %d (%s)\n' % (e.errno, e.strerror))
            sys.exit(1)

        # decouple from parent environment
        #os.chdir('/')
        os.setsid()
        os.umask(0)

        # do second fork
        try:
            pid = os.fork()
            if pid > 0:  # exit from second parent
                sys.exit(0)
        except OSError, e:
            sys.stderr.write('Fork #2 failed: %d (%s)\n' % (e.errno, e.strerror))
            sys.exit(1)

        # write pidfile
        atexit.register(self.delpid)
        file(self.pidfile, 'w+').write('%s\n' % str(os.getpid()))

    def delpid(self):
        if os.path.exists(self.pidfile):
            os.remove(self.pidfile)

    def ConfigSectionMap(self, section):
        dict1 = {}
        options = self.Config.options(section)
        for option in options:
            try:
                dict1[option] = self.Config.get(section, option)
                if dict1[option] == -1:
                    DebugPrint("skip: %s" % option)
            except:
				logger.error('exception on %r', option)
				dict1[option] = None
        return dict1

    def start(self, iniFile):
        """Start the application and demonize"""
        file(self.pidfile, 'w+').write('%s\n' % str(os.getpid()))
        self.iniFile = iniFile
        self.daemonize()
        self.run()

    def stop(self):
        """Stop the application"""
        self.running = False

    def run(self):
        self.running = True

        # Plug signals
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)

        # Init SOAP proxy
        self.Config = ConfigParser.ConfigParser()
        self.Config.read(self.iniFile)
        url = self.ConfigSectionMap('Credentials')['url']
        u = self.ConfigSectionMap('Credentials')['user']
        p = base64.b64decode(self.ConfigSectionMap('Credentials')['pass'])
        self.proxy = vboxwebclient.vboxwebclient(url, u, p)

        # Run the server
        # Datagram (udp) socket
        try :
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            logger.info('Socket opened 0.0.0.0:%d', PORT)
        except socket.error, msg :
            logger.error('Failed to create socket. Error Code : %d (%r)\n', msg.errno, msg.strerror)
            sys.stderr.write('Failed to create socket. Error Code : %d (%s)\n' % (msg.errno, msg.strerror))
            sys.exit(1)

        # Bind socket to local host and port
        try:
            s.bind((HOST, PORT))
        except socket.error , msg:
            logger.error('Failed to create socket. Error Code : %d (%r)\n', msg.errno, msg.strerror)
            sys.stderr.write('Bind failed. Error Code : %d (%s)\n' % (msg.errno, msg.strerror))
            sys.exit(1)
     
        logger.debug('Socket bind complete')
 
        #now keep talking with the client
        while self.running:
            try:
                # receive data from client (data, addr)
                d = s.recvfrom(1024)
                data = d[0]
                addr = d[1]
     
                if not data: 
                    continue

                # check magic    
                if len(data) < 18 or (ord(data[0]) != 0xff or ord(data[1]) != 0xff or ord(data[2]) != 0xff or ord(data[3]) != 0xff or ord(data[4]) != 0xff or ord(data[5]) != 0xff):
					logger.debug('Received unknown data from %r', addr[0])
					continue

                mac = "".join("{:02X}".format(ord(c)) for c in data[6:12])
                logger.debug('Got MAC: %r', mac)
            
                #try_start_vm(mac)
                self.proxy.start(mac)

            except Exception, msg:
				logger.error('Failed to create socket. Error Code : %d (%r)\n', msg.errno, msg.strerror)

        s.close()

    def signal_handler(self, *args):
        self.stop()
        exit(0)

    def create_magic_packet(macaddress):
        """
        Create a magic packet which can be used for wake on lan using the
        mac address given as a parameter.
        Keyword arguments:
        :arg macaddress: the mac address that should be parsed into a magic
                         packet.
        """
        if len(macaddress) == 12:
            pass
        elif len(macaddress) == 17:
            sep = macaddress[2]
            macaddress = macaddress.replace(sep, '')
        else:
            raise ValueError('Incorrect MAC address format')

        # Pad the synchronization stream
        data = b'FFFFFFFFFFFF' + (macaddress * 20).encode()
        send_data = b''

        # Split up the hex values in pack
        for i in range(0, len(data), 2):
            send_data += struct.pack(b'B', int(data[i: i + 2], 16))
        return send_data

    def try_start_vm(mac):
        """
        Find out if VM with that MAC exists and start it
        """
        process = Popen([VBOX, "list", "-l", "vms"], stdout=PIPE)
        (output, err) = process.communicate()
        exit_code = process.wait()

        mac2uuid = dict()
        for line in output.splitlines():
            m = re.match('^UUID:[ \t]+([a-zA-Z0-9\-]+)', line)
            if m:
                uuid = m.group(1)
            
            m = re.match('^NIC [0-9]:[ \t]+MAC: ([a-zA-Z0-9]+)', line)
            
            if m:
                mac2uuid[m.group(1)] = uuid
    
        if mac2uuid.has_key(mac):
            process = Popen([VBOX, "list", "runningvms"], stdout=PIPE)
            (output, err) = process.communicate()
            exit_code = process.wait()
            if mac2uuid[mac] not in output:
				logger.info("Starting %r", mac2uuid[mac])
				process = Popen([VBOX, "startvm", mac2uuid[mac], "--type", "headless"], stdout=PIPE)
				(output, err) = process.communicate()
				exit_code = process.wait()
				logger.info('%r', output)
            else:
				logger.info('"%r" is already started' % mac2uuid[mac])

def initLogging(logfile):
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)
    handler = logging.handlers.RotatingFileHandler(logfile, maxBytes=2097152, backupCount=3, encoding='utf-8')
    handler.setFormatter(logging.Formatter('%(asctime)s:%(levelname)s:%(name)s:%(message)s', datefmt='%m/%d/%Y %H:%M:%S'))
    root.handlers = [handler] 
	
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='VM WOL service.')
    parser.add_argument('--ini', help="path to 'vboxwolservice.ini' file", default="/etc/vbox/vboxwolservice.ini")
    parser.add_argument('--pid', help="path to 'vboxwolservice.pid' file", default="/run/vboxwolservice.pid")
    parser.add_argument('--log', help="path to 'vboxwolservice.log' file", default="/var/log/vboxwolservice.log")
    args = vars(parser.parse_args())
    pidfile = args['pid']
    iniFile = args['ini']
    logFile = args['log']
    if os.path.exists(pidfile):
        sys.stderr.write('Pid file ''%s'' exists, delete if server is not running!\n' % (pidfile))
        exit(1)

    initLogging(logFile) 
    svc = Service(pidfile)
    svc.start(iniFile)
