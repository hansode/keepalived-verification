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

function render_keepalived_conf() {
  local ifname=${1:-eth0}

  cat <<-EOS
	! Configuration File for keepalived
	
	vrrp_instance VI_1 {
	    interface ${ifname}
	    state ${state:-BACKUP}
	    virtual_router_id ${virtual_router_id:-17}
	    priority ${priority:-100}
	    advert_int ${advert_int:-1}
	    authentication {
	        auth_type ${auth_type:-PASS}
	        auth_pass ${auth_pass:-1111}
	    }
	    virtual_ipaddress {
	        ${vip}/${prefix:-24} dev ${ifname}
	    }
	}
	EOS
}

function install_keepalived_conf() {
  local ifname=${1:-eth0}
  shift; eval local ${@}

  render_keepalived_conf ${ifname} ${@} | tee /etc/keepalived/keepalived.conf
}

#node=node01
node=node02

case "${node}" in
  node01) ip4=18 partner_ip4=19 virtual_ip4=17 ;;
  node02) ip4=19 partner_ip4=18 virtual_ip4=17 ;;
esac

mkdir -p /etc/vipple/vip-{up,down}.d

append_networking_param eth1 ip=10.126.5.${ip4} mask=255.255.255.0

##

service network restart

##

install_keepalived_conf eth1 vip=10.126.5.${virtual_ip4} prefix=24

chkconfig --list keepalived
chkconfig keepalived on
chkconfig --list keepalived

service keepalived restart

##

prefix_len=24

case "${node}" in
  node01)
    ;;
  node02)
    ping -c 1 -W 3 10.126.5.${partner_ip4}
    ping -c 1 -W 3 10.126.5.${virtual_ip4}
    ;;
esac
