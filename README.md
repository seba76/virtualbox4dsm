# VirtualBox for Synology DSM

This is build for VirtualBox service running on Synology NAS boxes running appropriate Intel CPU. You 
should be able to build package on your NAS (with some manual work) using this repository or you can use 
Linux box like Debian or Ubuntu.

Keep in mind installing this package can make your NAS unreachable since it is still in beta phase.

# Installation

Latest spk file for bromolow can be found in release. Download latest spk for you Synology box and
install it manually in package center. During installation you will be asked few questions. If all 
goes well you will have VirtualBox running. For remote management access you will need PhpVirtualBox
or some other application like VBoxManage for Android.

PhpVirtualBox spk you can find here.

## Requirements
- This package will work only on Intel boxes.
- You need to have enough memory.
- Other visualization applications have to be un-installed. If not you can lose access to your box.
- Control Panel -> Network -> Network Interface -> Manage -> Open vSwitch Settings -> Enable Open vSwitch 
	- must be unchecked, or you could lose access to your box.

## How To Build

Assuming we are building for bromolow platform and DSM version 6.1 following commands need to be executed.

```
 mkdir toolkit
 cd toolkit
 git clone https://github.com/SynologyOpenSource/pkgscripts-ng.git
 sudo ./pkgscripts-ng/EnvDeploy -v 6.1 -p bromolow
 mkdir source
 cd source
 git clone https://github.com/seba76/virtualbox.git
 cd virtualbox
 ./config.sh prep
 cd ../..
```
 
 At this point you should have something like this.
```
 toolkit/
 ├── build_env/
 |   └── ds.bromolow-6.1/
 ├── pkgscripts-ng/
 └── source/
     ├── linux-3.10.x/         
     └── virtualbox4dsm/ 
```

Next we need to build our package.
	 
```
sudo ./pkgscripts-ng/PkgCreate.py -I -p bromolow -v 6.1 linux-3.10.x
sudo ./pkgscripts-ng/PkgCreate.py -I -p bromolow -v 6.1 virtualbox4dsm
```

After second command you should check if you have spk package.

```
build_env/ds.bromolow-6.1/image/packages/virtualbox4dsm-bromolow-5.2.16-123759.spk 
```
If not check log.build and log.install in build_env/ds.bromolow-6.1/ folder to see what went wrong.

## ToDo
- Describe process for other platforms
- Describe prerequisites
- License
