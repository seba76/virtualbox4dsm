# INFO.sh
[ -f /pkgscripts/include/pkg_util.sh ] && . /pkgscripts/include/pkg_util.sh
[ -f /pkgscripts-ng/include/pkg_util.sh ] && . /pkgscripts-ng/include/pkg_util.sh
package="virtualbox4dsm"
version="6.0.8-130520"
displayname="VirtualBox"
maintainer="seba"
maintainer_url="http://github.com/seba76/"
distributor="seba"
description="VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product for enterprise as well as home use."
report_url="https://github.com/seba76/virtualbox4dsm/"
support_url="https://github.com/seba76/virtualbox4dsm/"
distributor_url="https://github.com/seba76/virtualbox4dsm/releases"
thirdparty="true"
support_conf_folder="yes"
#support_aaprofile="yes"
#install_reboot="yes"
changelog="Version: 5.1.28-114008"
#reloadui="yes"
displayname="VirtualBox"
if [ "$(pkg_get_platform)" == "x86" ]; then
arch="x86_64"
exclude_arch="x86 dockerx64 kvmx64"
else
arch="$(pkg_get_platform)"
fi
os_min_ver="$1"
[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info
