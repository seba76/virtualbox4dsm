# VirtualBox for Synology DSM

This is build for VirtualBox service running on Synology NAS boxes running appropriate Intel CPU. You 
should be able to build package on your NAS using this repo or you can use Linux box like debian or ubuntu.

Keep in mind installing this package can make your NAS unreachable since it is still in alpha phase.

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
     └── virtualbox/ 
```

Next we need to build our package.
	 
```
sudo ./pkgscripts-ng/PkgCreate.py -I -p bromolow -v 6.1 linux-3.10.x
sudo ./pkgscripts-ng/PkgCreate.py -I -p bromolow -v 6.1 virtualbox
```

After second command you should check if you have spk package.

```
build_env/ds.bromolow-6.1/image/packages/virtualbox-bromolow-5.2.16-123759.spk 
```
If not check log.build and log.install in build_env/ds.bromolow-6.1/ folder to see what went wrong.

## ToDo
- Describe process for other platforms
- Describe prerequisits
- Describe known bugs and warnings
- License
