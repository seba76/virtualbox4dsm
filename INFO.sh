# INFO.sh
[ -f /pkgscripts/include/pkg_util.sh ] && . /pkgscripts/include/pkg_util.sh
[ -f /pkgscripts-ng/include/pkg_util.sh ] && . /pkgscripts-ng/include/pkg_util.sh
package="virtualbox"
version="5.2.16-123759"
displayname="VirtualBox"
maintainer="seba"
maintainer_url="http://github.com/seba76/virtualbox/"
distributor="seba"
description="VirtualBox is a powerful x86 and AMD64/Intel64 virtualization product for enterprise as well as home use. For front-end phpVirtualBox is used, if authentication is used default user/pass is admin/admin."
report_url="https://github.com/seba-0/virtualbox/"
support_url="https://github.com/seba-0/virtualbox/"
install_dep_package="WebStation:PHP7.0"
#install_dep_services="WebStation:Apache2.4:PHP5.6"
startstop_restart_services="nginx"
instuninst_restart_services="nginx"
thirdparty="true"
support_conf_folder="yes"
#support_aaprofile="yes"
#install_reboot="yes"
changelog="Version: 5.1.28-114008"
reloadui="yes"
displayname="VirtualBox"
dsmuidir="www"
#adminurl="/phpvirtualbox/"
arch="$(pkg_get_platform)"
firmware="$1"
[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info
