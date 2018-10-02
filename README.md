# VirtualBox for Synology DSM

This is build for VirtualBox service running on Synology NAS boxes running appropriate Intel CPU. This repo doesn't contain GUI for that head to phpvirtualbox4dsm repo.

Keep in mind installing this package can make your NAS unreachable since it is still in beta phase.

# Installation

Latest spk file for bromolow can be found in release. Download latest spk for you Synology box and
install it manually in package center. During installation you will be asked few questions. If all 
goes well you will have VirtualBox running. For remote management access you will need PhpVirtualBox
or some other application like VBoxManage for Android.

VirtualBox4DSM spk you can find [here](./releases).

## Requirements
- This package will work only on Intel boxes.
- You need to have enough memory.
- Other virtualization applications have to be un-installed. If not you can lose access to your box.
- Control Panel -> Network -> Network Interface -> Manage -> Open vSwitch Settings -> Enable Open vSwitch 
	- must be unchecked.
