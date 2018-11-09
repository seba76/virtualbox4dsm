#!/bin/sh 
VirtualBoxVersion=5.2.20-125813
VirtualBoxBase=http://download.virtualbox.org/virtualbox/5.2.20/
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
	DSM_VER=dsm62
	DSM_BRANCH=22259
	DSM_PLAT=bromolow
	PS3='Please select DSM varsion: '
	options=("DSM 6.1 (15152)" "DSM 6.2 (22259)" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"DSM 6.1 (15152)")
				DSM_VER=dsm61
				DSM_BRANCH=15152
				break
				;;
			"DSM 6.2 (22259)")
				DSM_VER=dsm62
				DSM_BRANCH=22259
				break
				;;
			"Quit")
				exit 1
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
	
	# when you add new platform you need to add it to build, install and vboxdrv.sh
	PS3='Please select platform: '
	options=("bromolow" "x64" "broadwell" "braswell" "cedarview" "avoton" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"bromolow")
				DSM_PLAT=bromolow
				break
				;;
			"x64")
				DSM_PLAT=x64
				break
				;;
			"broadwell")
				DSM_PLAT=broadwell
				break
				;;
			"braswell")
				DSM_PLAT=braswell
				break
				;;
			"cedarview")
				DSM_PLAT=cedarview
				break
				;;
			"avoton")
				DSM_PLAT=avoton
				break
				;;
			"Quit")
				exit 1
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
	
	if [ "$DSM_VER" == "dsm61" ]; then
		case $DSM_PLAT in
			bromolow)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/bromolow-source/linux-3.10.x.txz/download
			;;
			x64)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/x64-source/linux-3.10.x.txz/download
			;;
			broadwell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/broadwell-source/linux-3.10.x.txz/download
			;;
			braswell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/braswell-source/linux-3.10.x.txz/download
			;;
			cedarview)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/cedarview-source/linux-3.10.x.txz/download
			;;
			avoton)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/avoton-source/linux-3.10.x.txz/download
			;;
			*)
				echo "Unexpected platform: $DSM_PLAT";
				exit 1
			;;
		esac	
	fi
	if [ "$DSM_VER" == "dsm62" ]; then
		case $DSM_PLAT in
			bromolow)
				echo "Setting kernel download link for branch 22259, bromolow platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/bromolow-source/linux-3.10.x.txz/download
			;;
			x64)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/x64-source/linux-3.10.x.txz/download
			;;
			broadwell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/broadwell-source/linux-3.10.x.txz/download
			;;
			braswell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/braswell-source/linux-3.10.x.txz/download
			;;
			cedarview)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/cedarview-source/linux-3.10.x.txz/download
			;;
			avoton)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/avoton-source/linux-3.10.x.txz/download
			;;
			*)
				echo "Unexpected platform: $DSM_PLAT";
				exit 1
			;;
		esac	
	fi
	
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
  echo "# platform: ${DSM_PLAT}" > .config
  echo "VirtualBoxVersion=${VirtualBoxVersion}" >> .config
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
	echo "Ready to exec:"
	echo "         'sudo ./pkgscripts-ng/PkgCreate.py --print-log -I -p ${DSM_PLAT} -v 6.2 linux-3.10.x'"
	echo "         'sudo ./pkgscripts-ng/PkgCreate.py --print-log -c -I -S -p ${DSM_PLAT} -v 6.2 -x0 -c virtualbox4dsm'"
  ;;
  clean)
    rm $VirtualBoxFile
    rm $ExtensionPackFile
    rm -rf package/www/phpvirtualbox
    rm .config
  ;;
  cleanall)
    rm $VirtualBoxFile
    rm $ExtensionPackFile
    rm -rf package/www/phpvirtualbox ../linux-3.10.x
    rm .config
  ;;
  *)
    echo "Usage: ./config.sh prep|clean|cleanall";
  ;;
esac
