#!/bin/sh 
VirtualBoxVersion=5.2.16-123759
VirtualBoxBase=http://download.virtualbox.org/virtualbox/5.2.16/
VirtualBoxFile=VirtualBox-${VirtualBoxVersion}-Linux_amd64.run
ExtensionPackFile=Oracle_VM_VirtualBox_Extension_Pack-${VirtualBoxVersion}.vbox-extpack
PhpVirtualBoxFile=5.2-0.zip
KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/bromolow-source/linux-3.10.x.txz/download

# If files don't exist they need to be downloaded
VirtualBoxUrl=${VirtualBoxBase}${VirtualBoxFile}
ExtensionPackUrl=${VirtualBoxBase}${ExtensionPackFile}
PhpVirtualBoxUrl=https://github.com/phpvirtualbox/phpvirtualbox/archive/5.2-0.zip

WGET=$(which wget)
UNZIP=$(which unzip)

if [ "$WGET" == "" ]; then
  WGET=./wget
fi

if [ "$UNZIP" == "" ]; then
  UNZIP="./unzip"
fi

function download_vbox()
{
  if [ ! -f ./${VirtualBoxFile} ]; then
	echo "Downloading ${VirtualBoxFile}"
	$WGET ${VirtualBoxUrl} -O ${VirtualBoxFile}
	chmod 755 ${VirtualBoxFile}
  fi

  if [ ! -f ./${ExtensionPackFile} ]; then
	echo "Downloading ${ExtensionPackFile}"
	$WGET ${ExtensionPackUrl} -O ${ExtensionPackFile}
  fi
}

function download_phpvbox()
{
  if [ ! -f ./${PhpVirtualBoxFile} ]; then
	echo "Downloading ${PhpVirtualBoxFile}"
	$WGET ${PhpVirtualBoxUrl} -O ${PhpVirtualBoxFile}
	rm -rf ./package/www/phpvirtualbox
  fi

  if [ ! -d ./package/www/phpvirtualbox ]; then
	$UNZIP ${PhpVirtualBoxFile} -d ./package/www/
	VB=$(ls -d ./package/www/phpvirtualbox-*)
	mv ${VB} ./package/www/phpvirtualbox
	echo "Generating config.php.synology"
	cp ./package/www/phpvirtualbox/config.php-example ./package/www/config.php.synology
	sed -i -e "s|^var \$username = 'vbox';|var \$username = '@user@';|g" ./package/www/config.php.synology
        sed -i -e "s|^var \$password = 'pass';|var \$password = '@pass@';|g" ./package/www/config.php.synology
        sed -i -e "s|^var \$location = 'http://127\.0\.0\.1:18083/';|var \$location = '@location@';|g" ./package/www/config.php.synology
        sed -i -e "s|^#var \$noAuth = true;|var \$noAuth = @noAuth@;|g" ./package/www/config.php.synology
        sed -i -e "s|^#var \$enableAdvancedConfig = true;|var \$enableAdvancedConfig = @enableAdvancedConfig@;|g" ./package/www/config.php.synology
        sed -i -e "s|^#var \$startStopConfig = true;|var \$startStopConfig = @startStopConfig@;|g" ./package/www/config.php.synology
	# fix for not working file browser
	echo "Patching jqueryFileTree.php"
	sed -i -e "s|^header('Content-type', 'application/json');|header('Content-type: application/json');|g" ./package/www/phpvirtualbox/endpoints/jqueryFileTree.php
  fi
}

function download_linux()
{
  if [ ! -d ../linux-3.10.x ]; then
    $WGET $KernelTar -O linux-3.10.x.txz
	tar xf linux-3.10.x.txz -C ../
	rm linux-3.10.x.txz
  fi
}

function generate_config()
{
  echo "Generating .config"
  echo "VirtualBoxVersion=${VirtualBoxVersion}" > .config
  echo "VirtualBoxFile=${VirtualBoxFile}" >> .config
  echo "ExtensionPackFile=${ExtensionPackFile}" >> .config
  echo "PhpVirtualBoxFile=${PhpVirtualBoxFile}" >> .config
}

function update_info()
{
  echo "Update version in INFO.sh"
  sed -i -e "s|^version=.*|version=\"${VirtualBoxVersion}\"|g" INFO.sh
}

function update_vboxcfg()
{
  echo "Update version in vbox.cfg"
  INSTALL_VER=`echo ${VirtualBoxVersion} | cut -d'-' -f 1`
  INSTALL_REV=`echo ${VirtualBoxVersion} | cut -d'-' -f 2`
  sed -i -e "s|^INSTALL_VER=.*|INSTALL_VER='${INSTALL_VER}'|g" package/etc/vbox/vbox.cfg
  sed -i -e "s|^INSTALL_REV=.*|INSTALL_REV='${INSTALL_REV}'|g" package/etc/vbox/vbox.cfg
}

case $1 in
  prep)
    download_vbox
    download_phpvbox
    download_linux
    generate_config
    update_info
    update_vboxcfg
  ;;
  clean)
    rm $PhpVirtualBoxFile
    rm $VirtualBoxFile
    rm $ExtensionPackFile
    rm -rf package/www/phpvirtualbox
    rm .config
  ;;
  *)
    echo "Usage: ./config.sh prep|clean";
  ;;
esac
