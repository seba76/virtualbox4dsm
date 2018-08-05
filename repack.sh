#!/bin/sh
DIR=$PWD
. "$DIR/.config"

# $1 - spk file to unpack
# $2 - arch (bromolow or x86_64)
# $3 - destination folder
get_drivers()
{
	if [ ! -f $1 ]; then
		echo "Can't find '$1'"
		return
	fi

	BASE=`mktemp -d`
	echo "Unpacking '$1' into '${BASE}'"
	tar xf  $1 -C ${BASE}
	mkdir ${BASE}/package
	tar zxf ${BASE}/package.tgz -C ${BASE}/package
	rm ${BASE}/package.tgz

	echo "Copy drivers from '$BASE/package/drivers/$2/*' to '$3'"
	cp -Rf ${BASE}/package/drivers/$2/* $3

	echo "Removing '${BASE}'"
	rm -rf ${BASE}
}

# $1 - spk file
# $2 - destination folder
unpack_spk()
{
	if [ ! -f $1 ]; then
		echo "Can't find '$1'"
		exit
	fi

        if [ ! -d $2 ]; then
                echo "Folder '$2' doesn't exist"
                exit
        fi

	echo "Unpacking '$1' into '$2'"
	tar xf  $1 -C $2
	mkdir $2/package
	tar zxf $2/package.tgz -C $2/package
	rm $2/package.tgz
}

# $1 - name of spk file to create
# $2 - base folder for spk file
repack_spk()
{
	if [ ! -d $2 ]; then
                echo "Folder '$2' doesn't exist"
                exit
        fi

	D=`pwd`
	echo "Creating '$D/$1' from '$2'"
	cd $2/package/
	tar zcf ../package.tgz *
	cd ..
	rm -rf package
	tar cf $D/$1 *
	cd $D
}

# .config has ${VirtualBoxVersion} set

OUTPUT=virtualbox-bromolow-x64-${VirtualBoxVersion}.spk

# create base for update
TMP=`mktemp -d`
unpack_spk $PWD/../../build_env/ds.bromolow-5.1/result_spk/virtualbox-bromolow-${VirtualBoxVersion}.spk ${TMP}
get_drivers $PWD/../../build_env/ds.x64-5.1/result_spk/virtualbox-x86-${VirtualBoxVersion}.spk x86_64/3.2.40 ${TMP}/package/drivers/x86_64/3.2.40
get_drivers $PWD/../../build_env/ds.x64-5.2/result_spk/virtualbox-x86-${VirtualBoxVersion}.spk x86_64/3.10.35 ${TMP}/package/drivers/x86_64/3.10.35
get_drivers $PWD/../../build_env/ds.bromolow-5.2/result_spk/virtualbox-bromolow-${VirtualBoxVersion}.spk bromolow/3.10.35 ${TMP}/package/drivers/bromolow/3.10.35
SIZE=`du -s ${TMP} | grep -o -E ^[0-9]+`
sed -i -e "s|^extractsize=.*|extractsize=${SIZE}|g" ${TMP}/INFO
#sed -i -e "s|^extractsize=.*||g" ${TMP}/INFO
repack_spk ${OUTPUT} ${TMP}

echo "Remove '${TMP}'"
rm -rf  ${TMP}
