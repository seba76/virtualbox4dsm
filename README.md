# virtualbox4dsm

This is build of VirtualBox app and service running on Synology NAS boxes with appropriate Intel CPU. This repo doesn't contain GUI for that head to [phpvirtualbox4dsm](https://github.com/seba76/phpvirtualbox4dsm).

Keep in mind installing this package can make your NAS unreachable since it is still in beta phase.

# Installation

Latest spk file can be found in [release](https://github.com/seba76/virtualbox4dsm/releases). First you need to find out what arch your Synology NAS belongs to, you can
consult [here](https://www.synology.com/en-global/knowledgebase/DSM/tutorial/Compatibility_Peripherals/What_kind_of_CPU_does_my_NAS_have). Not all arch are supported.
Once you know what arch you need download appropriate package for you Synology box and install it manually in package center. During installation you will be asked few questions. 
If all goes well you will have VirtualBox running. For remote management access you will need PhpVirtualBox or some other application like VBoxManage for Android.

## Requirements
- This package will work only on Intel boxes.
- You need to have enough memory.
- Other virtualization applications have to be un-installed (like VMM), otherwise you can lose access to your box.
- Control Panel -> Network -> Network Interface -> Manage -> Open vSwitch Settings -> Enable Open vSwitch 
	- must be unchecked.

## Contributing

If you find this project useful you can mark it by leaving a Github **\*Star**.</br>
If you would like to support the Project and help me buy new Synology box by making a Donation ($10) *#BuyMeBeer*, you are welcome to do so:<br>
[![Donate](https://img.shields.io/badge/donate-PayPal-yellow.svg)](https://paypal.me/seba76/10)
