#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# functions

## common

function gen_ifcfg_path() {
  local ifname=${1:-eth0}
  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg

  echo ${ifcfg_path}-${ifname}
}

function install_ifcfg_file() {
  local ifname=${1:-eth0}

  tee $(gen_ifcfg_path ${ifname}) </dev/stdin
}

function render_ifcfg_eth() {
  local ifname=${1:-eth0}
  
  cat <<-EOS
	DEVICE=${ifname}
	BOOTPROTO=none
	ONBOOT=yes
	EOS
}

#

render_ifcfg_eth eth1 | install_ifcfg_file eth1
