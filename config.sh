#!/bin/sh 
VirtualBoxVersion=5.2.16-123759
VirtualBoxBase=http://download.virtualbox.org/virtualbox/5.2.16/
VirtualBoxFile=VirtualBox-${VirtualBoxVersion}-Linux_amd64.run
ExtensionPackFile=Oracle_VM_VirtualBox_Extension_Pack-${VirtualBoxVersion}.vbox-extpack

# If files don't exist they need to be downloaded
VirtualBoxUrl=${VirtualBoxBase}${VirtualBoxFile}
ExtensionPackUrl=${VirtualBoxBase}${ExtensionPackFile}

WGET=$(which wget)
UNZIP=$(which unzip)

if [ "$WGET" == "" ]; then
  WGET=./wget
fi

if [ "$UNZIP" == "" ]; then
  UNZIP="./unzip"
fi

function prompt_for_source()
{
	PS3='Please enter your choice: '
	options=("Bromolow DSM 6.1 (15152)" "Bromolow DSM 6.2 (22259)" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Bromolow DSM 6.1 (15152)")
				echo "Setting kernel download link for branch 15152, bromolow platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/bromolow-source/linux-3.10.x.txz/download
				break
				;;
			"Bromolow DSM 6.2 (22259)")
				echo "Setting kernel download link for branch 22259, bromolow platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/bromolow-source/linux-3.10.x.txz/download
				break
				;;
			"Quit")
				exit 1
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
}

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

function download_linux()
{
  if [ ! -d ../linux-3.10.x ]; then
	echo "Downloading ${KernalTar}"
	$WGET $KernelTar -O linux-3.10.x.txz
	tar xf linux-3.10.x.txz -C ../
	rm linux-3.10.x.txz
  else
	echo "Kernel exists, delete to download again."
  fi
}

function generate_config()
{
  echo "Generating .config"
  echo "VirtualBoxVersion=${VirtualBoxVersion}" > .config
  echo "VirtualBoxFile=${VirtualBoxFile}" >> .config
  echo "ExtensionPackFile=${ExtensionPackFile}" >> .config
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
    prompt_for_source
    download_vbox
    download_linux
    generate_config
    update_info
    update_vboxcfg
  ;;
  clean)
    rm $VirtualBoxFile
    rm $ExtensionPackFile
    rm -rf package/www/phpvirtualbox
    rm .config
  ;;
  *)
    echo "Usage: ./config.sh prep|clean";
  ;;
esac
