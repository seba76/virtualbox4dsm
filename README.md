VirtualBox for Synology DSM

This is build for VirtualBox service running on Synology NAS boxes running apropriate Intel CPU. You 
should be able to build pacakge on your NAS using this repo. However you can also use any linux box also.

How To Build

 - mkdir toolkit
 - cd toolkit
 - git clone https://github.com/SynologyOpenSource/pkgscripts-ng.git
 - sudo ./pkgscripts-ng/EnvDeploy -v 6.1 -p bromolow
 - mkdir source
 - cd source
 - git clone https://github.com/seba76/virtualbox.git
 - cd virtualbox
 - ./prep_build.sh
 - 

TODO:
 - stop direct access via https://diskstation:5001/webman/3rdparty/virtualbox/phpvirtualbox/index.php
