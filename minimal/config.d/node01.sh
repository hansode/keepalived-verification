#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

function append_networking_param() {
  local ifname=${1:-eth0}
  shift; eval local ${@}

  cat <<-EOS | tee -a /etc/sysconfig/network-scripts/ifcfg-${ifname}
	IPADDR=${ip}
	NETMASK=${mask}
	EOS
}

node=node01
#node=node02

case "${node}" in
  node01) ip4=18 partner_ip4=19 virtual_ip4=17 ;;
  node02) ip4=19 partner_ip4=18 virtual_ip4=17 ;;
esac

mkdir -p /etc/vipple/vip-{up,down}.d

append_networking_param eth1 ip=10.126.5.${ip4} mask=255.255.255.0

##

service network restart

##

prefix_len=24

case "${node}" in
  node01)
    ;;
  node02)
    ping -c 1 -W 3 10.126.5.${partner_ip4}
    ;;
esac
