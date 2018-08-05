#!/usr/bin/python 
import sys
import SOAPpy
import json
import ctypes
import ConfigParser
import base64
import argparse
import logging
import logging.handlers 

import ssl

try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context

logger = logging.getLogger(__name__)

class vboxwebclient(object):
    def __init__(self, url, username, password):
        SOAPpy.WSDL.Config.simplify_objects = 1
        SOAPpy.WSDL.Config.typed = 0
        self.client = SOAPpy.WSDL.Proxy("vboxwebService-5.0.wsdl")
        self.username = username
        self.password = password
        # fix-up for namespace issue
        for method in self.client.methods.values():
            method.namespace = u'http://www.virtualbox.org/'
            method.location = url

    def methods(self):
        self.client.show_methods()

    def start(self, mac):
        # login
        login = self.client.IWebsessionManager_logon(username=self.username, password=self.password)

        # let's see what do we have
        vms = self.client.IVirtualBox_getMachines(_this=login)
        mac_vm = dict()
        for vm in vms:
            netadp = self.client.IMachine_getNetworkAdapter(_this=vm, slot=SOAPpy.unsignedIntType(0))
            macAdrr = self.client.INetworkAdapter_getMACAddress(_this=netadp)
            mac_vm[macAdrr] = self.client.IMachine_getId(_this=vm)

        vm = self.client.IVirtualBox_findMachine(_this=login, nameOrId=mac_vm[mac])
        if (vm != None) :
           vmstate = self.client.IMachine_getState(_this=vm)
           if (vmstate == "PoweredOff" or vmstate == "Aborted"):
				try: 
					logger.info('Starting "%r"', self.client.IMachine_getName(_this=vm))
					# to work with vm we need session
					sess = self.client.IWebsessionManager_getSessionObject(refIVirtualBox=login)
					#self.client.IMachine_lockMachine(_this=vm, session=sess, lockType='Shared')
					progress = self.client.IMachine_launchVMProcess(_this=vm, session=sess, name='headless')
					p = self.client.IProgress_waitForCompletion(_this=progress)
					#self.client.ISession_unlockMachine(_this=sess)
					self.client.IWebsessionManager_logoff(refIVirtualBox=sess)
				except Exception, msg:
					logger.error('Failed to create socket. Error Code : %d (%r)\n', msg.errno, msg.strerror)

    def test(self, mac):
        login = self.client.IWebsessionManager_logon(username=self.username, password=self.password)
        vms = self.client.IVirtualBox_getMachines(_this=login)
        mac_vm = dict()
        for vm in vms:
            netadp = self.client.IMachine_getNetworkAdapter(_this=vm, slot=SOAPpy.unsignedIntType(0))
            macAdrr = self.client.INetworkAdapter_getMACAddress(_this=netadp)
            mac_vm[macAdrr] = self.client.IMachine_getId(_this=vm)

        logger.info('%r', mac_vm)
        vm = self.client.IVirtualBox_findMachine(_this=login, nameOrId=mac_vm[mac])
        vmstate = self.client.IMachine_getState(_this=vm)
        if (vmstate == "PoweredOff" or vmstate == "Aborted"):
			try: 
				logger.info('Starting "%r"', self.client.IMachine_getName(_this=vm))
				sess = self.client.IWebsessionManager_getSessionObject(refIVirtualBox=login)
				#self.client.IMachine_lockMachine(_this=vm, session=sess, lockType='Shared')
				progress = self.client.IMachine_launchVMProcess(_this=vm, session=sess, name='headless')
				p = self.client.IProgress_waitForCompletion(_this=progress)
				#self.client.ISession_unlockMachine(_this=sess)
				self.client.IWebsessionManager_logoff(refIVirtualBox=sess)
			except Exception, msg:
				logger.error('Failed to create socket. Error Code : %d (%r)\n', msg.errno, msg.strerror)

    def list(self):
        login = self.client.IWebsessionManager_logon(username=self.username, password=self.password)
        vms = self.client.IVirtualBox_getMachines(_this=login)
        mac_vm = dict()
        for vm in vms:
            netadp = self.client.IMachine_getNetworkAdapter(_this=vm, slot=SOAPpy.unsignedIntType(0))
            macAdrr = self.client.INetworkAdapter_getMACAddress(_this=netadp)
            mac_vm[macAdrr] = self.client.IMachine_getId(_this=vm)

        print mac_vm


def ConfigSectionMap(section):
    dict1 = {}
    options = Config.options(section)
    for option in options:
        try:
            dict1[option] = Config.get(section, option)
            if dict1[option] == -1:
                DebugPrint("skip: %s" % option)
        except:
			logger.error('exception on %r!', option)
			dict1[option] = None
    return dict1

if __name__ == "__main__" :
    parser = argparse.ArgumentParser(description='VM WOL service.')
    parser.add_argument('--hash', help='create hash from password')
    parser.add_argument('--ini', help='path to "vboxwolservice.ini" file')
    args = vars(parser.parse_args())
    if args['hash'] != None :
        print base64.b64encode(args['hash'])
    else :
        iniFile = "/etc/vbox/vboxwolservice.ini"
        if args['ini'] != None :
            iniFile = args['ini']

        Config = ConfigParser.ConfigParser()
        Config.read(iniFile)
        url = ConfigSectionMap('Credentials')['url']
        u = ConfigSectionMap('Credentials')['user']
        p = base64.b64decode(ConfigSectionMap('Credentials')['pass'])
        proxy = vboxwebclient(url, u, p)
        #proxy.test('080027CEB023')
        proxy.list()
