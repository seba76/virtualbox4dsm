#!/bin/sh 
VirtualBoxVersion=6.1.12-139181
VirtualBoxBase=https://download.virtualbox.org/virtualbox/6.1.12/
VirtualBoxFile=VirtualBox-${VirtualBoxVersion}-Linux_amd64.run
ExtensionPackFile=Oracle_VM_VirtualBox_Extension_Pack-${VirtualBoxVersion}.vbox-extpack

# If files don't exist they need to be downloaded
VirtualBoxUrl=${VirtualBoxBase}${VirtualBoxFile}
ExtensionPackUrl=${VirtualBoxBase}${ExtensionPackFile}

BUILD_CONFIG=build.config
PACKAGE_CONFIG=package/etc/vbox4dsm.config

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
	options=("DSM 6.1 (15152)" "DSM 6.2 (22259)" "DSM 6.2.3 (24922)" "Quit")
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
			"DSM 6.2.3 (24922)")
				DSM_VER=dsm623
				DSM_BRANCH=24922
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
	if [ "$DSM_VER" == "dsm623" ]; then
		options=("bromolow" "x64" "broadwell" "braswell" "cedarview" "avoton" "denverton" "Quit")
	else
		options=("bromolow" "x64" "broadwell" "braswell" "cedarview" "avoton" "Quit")
	fi
	
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
			"denverton")
				DSM_PLAT=denverton
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
				KernalDir=linux-3.10.x
			;;
			x64)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/x64-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			broadwell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/broadwell-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			braswell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/braswell-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			cedarview)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/cedarview-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			avoton)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/15152branch/avoton-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
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
				KernalDir=linux-3.10.x
			;;
			x64)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/x64-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			broadwell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/broadwell-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			braswell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/braswell-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			cedarview)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/cedarview-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			avoton)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/avoton-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			*)
				echo "Unexpected platform: $DSM_PLAT";
				exit 1
			;;
		esac	
	fi
	if [ "$DSM_VER" == "dsm623" ]; then
		case $DSM_PLAT in
			bromolow)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/bromolow-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			x64)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/x64-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			broadwell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/broadwell-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			braswell)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/braswell-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			cedarview)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/cedarview-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			avoton)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/avoton-source/linux-3.10.x.txz/download
				KernalDir=linux-3.10.x
			;;
			denverton)
				echo "Setting kernel download link for branch $DSM_BRANCH, $DSM_PLAT platform"
				KernelTar=https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/24922branch/denverton-source/linux-4.4.x.txz/download
				KernalDir=linux-4.4.x
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
  if [ ! -f "${DSM_PLAT}_${KernalDir}.txz" ]; then
	echo "Downloading $KernelTar into '${DSM_PLAT}_${KernalDir}.txz'"
	$WGET $KernelTar -O "${DSM_PLAT}_${KernalDir}.txz"
  else
	echo "Archive '${DSM_PLAT}-${KernalDir}.txz' exists, delete to download again."
  fi

  if [ ! -d ../$KernalDir ]; then
	echo "Extracting ${DSM_PLAT}-${KernalDir}.txz"
	tar xf "${DSM_PLAT}_${KernalDir}.txz" -C ../
  else
	echo "Kernel folder '../$KernalDir' exists, will delete and extract again."
	rm -rf ../$KernalDir
	tar xf "${DSM_PLAT}_${KernalDir}.txz" -C ../
  fi
}

function generate_build_config()
{
  echo "Generating ${BUILD_CONFIG}"
  echo "# platform: ${DSM_PLAT}" > ${BUILD_CONFIG}
  echo "VirtualBoxVersion=${VirtualBoxVersion}" >> ${BUILD_CONFIG}
  echo "VirtualBoxFile=${VirtualBoxFile}" >> ${BUILD_CONFIG}
  echo "ExtensionPackFile=${ExtensionPackFile}" >> ${BUILD_CONFIG}
  echo "KVER=${KVER}" >> ${BUILD_CONFIG}
}

function generate_packge_config()
{
  if [ -f ../$KernalDir/Makefile ]; then
    VERSION=$(awk "/^VERSION = / {print \$3}" ../$KernalDir/Makefile)
    PATCHLEVEL=$(awk "/^PATCHLEVEL = / {print \$3}" ../$KernalDir/Makefile)
    SUBLEVEL=$(awk "/^SUBLEVEL = / {print \$3}" ../$KernalDir/Makefile)
	KVER=${VERSION}.${PATCHLEVEL}.${SUBLEVEL}
    echo "Kernal version from Makefile ... ${KVER}"
  else
    KVER=3.10.105
    echo "Can't read Kernal version from Makefile, using ${KVER}"
  fi

  echo "Generating vbox4dsm.config in package/etc folder"
  echo "# platform: ${DSM_PLAT}" > ${PACKAGE_CONFIG}
  #set_key_value ${PACKAGE_CONFIG} KVER ${KVER}
  echo "KVER=${KVER}" >> ${PACKAGE_CONFIG}
  echo "" >> ${PACKAGE_CONFIG}
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

# get_key_value is in bin dir i.e. "get_key_value xfile key"
# set_key_value xfile key value
function set_key_value() {
	xfile="$1"
	param="$2"
	value="$3"
	grep -q "${param}" ${xfile} && \
		/bin/sed -i "s/^${param}.*/${param}=\"${value}\"/" ${xfile} || \
		echo "${param}=\"${value}\"" >> ${xfile}
}

case $1 in
  prep)
    prompt_for_source
    download_vbox
    download_linux
	generate_packge_config
    generate_build_config
    update_info
    update_vboxcfg
	echo "Ready to exec:"
	echo "         'sudo ../../pkgscripts-ng/PkgCreate.py --print-log -I -S -p ${DSM_PLAT} -v 6.2 ${KernalDir}'"
	echo "         'sudo ../../pkgscripts-ng/PkgCreate.py --print-log -c -I -S -p ${DSM_PLAT} -v 6.2 -x0 -c virtualbox4dsm'"
  ;;
  clean)
    rm ${BUILD_CONFIG}
    rm -rf ${PACKAGE_CONFIG}
	rm -rf ../linux-3.10.x 
	rm -rf ../linux-4.4.x
  ;;
  purge)
    rm ${BUILD_CONFIG}
    rm -rf ${PACKAGE_CONFIG}
	rm -rf ../linux-3.10.x 
	rm -rf ../linux-4.4.x
    rm $VirtualBoxFile
    rm $ExtensionPackFile
	rm *-linux-4.4.x.txz 
	rm *-linux-3.10.x.txz
  ;;
  *)
    echo "Usage: ./config.sh prep|clean|purge";
  ;;
esac
