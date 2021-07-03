###############################################################################
# Topic:		Multi Home Network
# Part:			Network Segregation and Basic Optimization
# Web:			https://github.com/PackElend/MikroTik
# RouterOS:		6.48.3
# Device:		https://mikrotik.com/product/CCR1009-8G-1S-1Splus
# Date:			June 18, 2021
# Notes:		Start with a reset (/system reset-configuration)
# Thanks:		anyone supporting me in the conversations in
#  Talks GER    https://administrator.de/forum/mikrotik-kaskadisches-core-netzwerk-ccr-crs-crs-vielen-satelliten-swichtes-versuch-anleitung-a-z-667592.html
#  Talks ENG    https://forum.mikrotik.com/viewtopic.php?t=???????
###############################################################################

#######################################
#
# -- Naming --
#
#######################################

# name the device being configured
/system identity set name="CR_2B_MT-CCR1009-8G-1S-1S+"


#######################################
#
# -- WAN + SUBNET & VLAN Overview --
#
#######################################

# ip-range           	subnet		   | vlan-id | comment
# 192.168.066.066/24 				   |  ----   | WAN INTERFACE IP   
# 010.010.000.000/21	255.255.248.0  |     x   | COMMON SERVICES AND DEVICES / OFFICE
# 010.010.001.000/24 				   |     1   |  BLACKHOLE
# 010.010.002.000/24 				   |     2   |  PRINTERS, SCANNERS
# 010.020.000.000/16 	255.255.0.0	   |    xx   | IoT SUBNETS
# 010.020.001.000/24 				   |    11   |  IoT_INTERCOM
# 010.099.099.000/24 				   |    99   | BASE (MGMT) VLAN
# 010.1xx.000.000/xx 				   |   1xx   | PERSONAL VLANs
# 010.110.000.000/24 	255.255.0.0	   |   110   |  MAIN VLAN OF USER1 FOR LAN
# 010.110.001.000/24 				   |   111   |  MAIN VLAN OF USER1 FOR WLAN
# 010.120.000.000/24 	255.255.0.0    |   120   |  MAIN VLAN OF USER2 FOR LAN
# 010.120.001.000/24 				   |   121   |  MAIN VLAN OF USER2 FOR WLAN
# 010.130.000.000/24 	255.255.0.0    |   130   |  MAIN VLAN OF USER3 FOR LAN
# 010.130.001.000/24 				   |   131   |  MAIN VLAN OF USER3 FOR WLAN
# 010.140.000.000/24 	255.255.0.0    |   140   |  MAIN VLAN OF USER4 FOR LAN
# 010.140.001.000/24 				   |   141   |  MAIN VLAN OF USER4 FOR WLAN
# 010.150.000.000/24 	255.255.0.0    |   150   |  MAIN VLAN OF USER5 FOR LAN
# 010.150.001.000/24 				   |   151   |  MAIN VLAN OF USER5 FOR WLAN
# 010.160.000.000/24 	255.255.0.0    |   160   |  MAIN VLAN OF USER6 FOR LAN
# 010.160.001.000/24 				   |   161   |  MAIN VLAN OF USER6 FOR WLAN
# 010.170.000.000/24 	255.255.0.0    |   170   |  MAIN VLAN OF USER7 FOR LAN
# 010.170.001.000/24 				   |   171   |  MAIN VLAN OF USER7 FOR WLAN
# 010.180.000.000/24 	255.255.0.0    |   180   |  MAIN VLAN OF USER8 FOR LAN
# 010.180.001.000/24 				   |   181   |  MAIN VLAN OF USER8 FOR WLAN
# 010.200.000.000/15 	255.254.0.0    |   2xx   | GUEST VLANs
# 010.200.000.000/16 				   |   200   | 	 GUEST LAN
# 010.201.000.000/16 				   |   201   | 	 GUEST WLAN
# 172.016.000.000/12	255.240.0.0	   |   3xx   |  DMZ   
# 172.016.001.000/24 				   |   301   |   NAS(s)
# 192.168.000.000/16	255.255.0.0    |   4xx   |  LAB
# 192.168.001.000/24 				   |   401   |   JOB DEVICES


#######################################
# 
# -- Interface Ports --
# comment ports according their role 
#   
#######################################

  /interface ethernet
    set comment="WAN" [find name=combo1]
    set comment="MANAGEMENT TERMINAL" [find name=ether1]
    set comment="(main) NAS" [find name=ether2]
    set comment="TAGGED PORT, VLAN-TRUNK TO CORE-SWITCH-SFP" [find name=sfp-sfpplus1]


#######################################
#
# -- Bridge & VLANs --
#  default Options: 
#    STP=RSTP
#    fast-forward=yes
#    vlan-filtering=off (but set to be sure, safety first)
#
#######################################

  # create one bridge, with defaults only
  /interface bridge add name=bridge-VLANs vlan-filtering=no pvid=99		comment="BASE (MGMT) VLAN"
  
  # add VLANs
  /interface vlan
	add interface=bridge-VLANs   vlan-id=001	name=VLAN_001 	comment="BLACKHOLE" 
	add interface=bridge-VLANs   vlan-id=002	name=VLAN_002 	comment="PRINTERS"
	add interface=bridge-VLANs   vlan-id=011	name=VLAN_011 	comment="IoT_INTERCOM"
	add interface=bridge-VLANs   vlan-id=099	name=VLAN_099 	pvid=99 	comment="BASE (MGMT) VLAN"
	add interface=bridge-VLANs   vlan-id=110	name=VLAN_110 	comment="MAIN VLAN OF USER1 FOR LAN"
	add interface=bridge-VLANs   vlan-id=111	name=VLAN_111 	comment="MAIN VLAN OF USER1 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=120	name=VLAN_120 	comment="MAIN VLAN OF USER2 FOR LAN"
	add interface=bridge-VLANs   vlan-id=121	name=VLAN_121 	comment="MAIN VLAN OF USER2 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=130	name=VLAN_130 	comment="MAIN VLAN OF USER3 FOR LAN"
	add interface=bridge-VLANs   vlan-id=131	name=VLAN_131 	comment="MAIN VLAN OF USER3 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=140	name=VLAN_140 	comment="MAIN VLAN OF USER4 FOR LAN"
	add interface=bridge-VLANs   vlan-id=141	name=VLAN_141 	comment="MAIN VLAN OF USER4 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=150	name=VLAN_150 	comment="MAIN VLAN OF USER5 FOR LAN"
	add interface=bridge-VLANs   vlan-id=151	name=VLAN_151 	comment="MAIN VLAN OF USER5 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=160	name=VLAN_160 	comment="MAIN VLAN OF USER6 FOR LAN"
	add interface=bridge-VLANs   vlan-id=161	name=VLAN_161 	comment="MAIN VLAN OF USER6 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=170	name=VLAN_170 	comment="MAIN VLAN OF USER7 FOR LAN"
	add interface=bridge-VLANs   vlan-id=171	name=VLAN_171 	comment="MAIN VLAN OF USER7 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=180	name=VLAN_180 	comment="MAIN VLAN OF USER8 FOR LAN"
	add interface=bridge-VLANs   vlan-id=181	name=VLAN_181 	comment="MAIN VLAN OF USER8 FOR WLAN"
	add interface=bridge-VLANs   vlan-id=200	name=VLAN_200 	comment="GUEST LAN"
	add interface=bridge-VLANs   vlan-id=201	name=VLAN_201 	comment="GUEST WLAN"
	add interface=bridge-VLANs   vlan-id=301	name=VLAN_301 	comment="DMZ - NAS(s)"
	add interface=bridge-VLANs   vlan-id=401	name=VLAN_401 	comment="LAB"

	
#######################################
#
# -- Access Ports (APs)--
#  default Options: 
#    broadcast-flood=yes  
#    hw=yes
#    multicast-router=temporary-query
#    unknown-multicast-flood=yes
#    unknown-unicast-flood=yes     
#  FYI: 
#    - Addded PVID to ingress, thus allocation each end-user devices to the desired VLAN
#    - Bridge VLAN table gets dynamic entry for each PVID. Port is added as an untagged port (AP)
#    - Needed as VLANs that don't exist in the bridge VLAN table are dropped before egress
#
#######################################

  # ingress behavior
  /interface bridge port
    add bridge=bridge-VLANs interface=ether1 pvid=99 ingress-filtering=yes\ 
	    frame-types=admit-only-untagged-and-priority-tagged comment="MANAGEMENT TERMINAL"
    add bridge=bridge-VLANs interface=ether2 pvid=301 ingress-filtering=yes\
	    frame-types=admit-only-untagged-and-priority-tagged comment="(main) NAS"

  # egress behavior, handled automatically as PVID is removed at egress

  
#######################################
#
# -- Tagged Ports (TPs) -- 
#  default Options: 
#    - as APs, plus below 
#    - PVID=1
#    - frame-types=admit-all
#    - ingress-filtering=no
#  FYI:     
#    - the tagged ports trunk all VLANs into the wire connected to this port
#    - the bridge "bridge-VLANs" has to be added as port otherwise traffice cannot leave the bridge (L2 + L3 hw-off) and being routed to wwww etc.
#    - no ingress filter as untagged traffic is unknow traffic and shall routed into the blackhole
#
#######################################

  # add tagged ports, which will do VLAN-TRUNKING
  /interface bridge port
    add bridge=bridge-VLANs interface=sfp-sfpplus1 comment="VLAN-TRUNK TO CORE-SWITCH-SFP"
	
  # add VLANs to be allowed on the tagged ports Only these will be trunked through the connected wire
  /interface bridge vlan
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=1       comment="BLACKHOLE" 
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=2       comment="PRINTERS"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=11      comment="IoT_INTERCOM"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=99      comment="BASE (MGMT) VLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=110     comment="MAIN VLAN OF USER1 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=111     comment="MAIN VLAN OF USER1 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=120     comment="MAIN VLAN OF USER2 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=121     comment="MAIN VLAN OF USER2 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=130     comment="MAIN VLAN OF USER3 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=131     comment="MAIN VLAN OF USER3 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=140     comment="MAIN VLAN OF USER4 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=141     comment="MAIN VLAN OF USER4 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=150     comment="MAIN VLAN OF USER5 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=151     comment="MAIN VLAN OF USER5 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=160     comment="MAIN VLAN OF USER6 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=161     comment="MAIN VLAN OF USER6 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=170     comment="MAIN VLAN OF USER7 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=171     comment="MAIN VLAN OF USER7 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=180     comment="MAIN VLAN OF USER8 FOR LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=181     comment="MAIN VLAN OF USER8 FOR WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=200     comment="GUEST LAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=201     comment="GUEST WLAN"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=301     comment="DMZ - NAS(s)"
    add bridge=bridge-VLANs tagged=bridge-VLANs,sfp-sfpplus1  vlan-ids=401     comment="LAB"
   

#######################################
#
# -- IP Addressing & Routing - Routes --
#  FYI:
#    - Connected Route is added per address added, see https://wiki.mikrotik.com/wiki/Manual:IP/Route#Connected_routes
#      This means the route from / to the interface where the IP belongs to is added dynamically by ROS 
#
#######################################

  # WAN facing port with IP Address definined in ISP's router
  /ip address  
    add interface=combo1 address=192.168.66.66/24	comment="WAN"   

  #VLAN-interfaces
    add address=10.10.1.1/24   	interface=VLAN_001	 comment="BLACKHOLE"  
	add address=10.10.2.1/24   	interface=VLAN_002	 comment="PRINTERS"
	add address=10.20.1.1/24   	interface=VLAN_011	 comment="IoT_INTERCOM"
	add address=10.99.99.1/24 	interface=VLAN_099	 comment="BASE (MGMT) VLAN"
	add address=10.110.0.1/24  	interface=VLAN_110	 comment="MAIN VLAN OF USER1 FOR LAN"
	add address=10.110.1.1/24  	interface=VLAN_111	 comment="MAIN VLAN OF USER1 FOR WLAN"
	add address=10.120.0.1/24  	interface=VLAN_120	 comment="MAIN VLAN OF USER2 FOR LAN"
	add address=10.120.1.1/24  	interface=VLAN_121	 comment="MAIN VLAN OF USER2 FOR WLAN"
	add address=10.130.0.1/24  	interface=VLAN_130	 comment="MAIN VLAN OF USER3 FOR LAN"
	add address=10.130.1.1/24  	interface=VLAN_131	 comment="MAIN VLAN OF USER3 FOR WLAN"
	add address=10.140.0.1/24  	interface=VLAN_140	 comment="MAIN VLAN OF USER4 FOR LAN"
	add address=10.140.1.1/24  	interface=VLAN_141	 comment="MAIN VLAN OF USER4 FOR WLAN"
	add address=10.150.0.1/24  	interface=VLAN_150	 comment="MAIN VLAN OF USER5 FOR LAN"
	add address=10.150.1.1/24  	interface=VLAN_151	 comment="MAIN VLAN OF USER5 FOR WLAN"
	add address=10.160.0.1/24  	interface=VLAN_160	 comment="MAIN VLAN OF USER6 FOR LAN"
	add address=10.160.1.1/24  	interface=VLAN_161	 comment="MAIN VLAN OF USER6 FOR WLAN"
	add address=10.170.0.1/24  	interface=VLAN_170	 comment="MAIN VLAN OF USER7 FOR LAN"
	add address=10.170.1.1/24  	interface=VLAN_171	 comment="MAIN VLAN OF USER7 FOR WLAN"
	add address=10.180.0.1/24  	interface=VLAN_180	 comment="MAIN VLAN OF USER8 FOR LAN"
	add address=10.180.1.1/24  	interface=VLAN_181	 comment="MAIN VLAN OF USER8 FOR WLAN"
	add address=10.200.0.1/24  	interface=VLAN_200	 comment="GUEST LAN"
	add address=10.201.0.1/24  	interface=VLAN_201	 comment="GUEST WLAN"
	add address=172.16.1.1/24  	interface=VLAN_301	 comment="DMZ - NAS(s)"
    add address=192.168.1.1/24	interface=VLAN_401	 comment="LAB"
		
  # Default route, this is added dynamically by ROS when WAN is detected but we want to be on the safe side
  /ip route   
    add gateway=192.168.66.1 distance=1 


#######################################
#
# -- IP Addressing & Routing - DNS -- 
#  FYI: 
#    - DNS service is avaiable at each IP capable interface
#    - OpenDSN Home is going to be used 
#
#######################################

  # DNS server, set to cache for LAN
  /ip dns set allow-remote-requests=yes servers="208.67.222.222, 208.67.220.220" 

  # Static DNS entries to IoT devices
  /ip dns static
    add address=10.20.1.11 		disabled=no name=ugost.kuerberg.ch ttl=1d
    add address=10.20.1.12 		disabled=no name=ugnord.kuerberg.ch ttl=1d
    add address=10.20.1.13 		disabled=no name=ugwest.kuerberg.ch ttl=1d
    add address=10.20.1.21 		disabled=no name=egost.kuerberg.ch ttl=1d
    add address=10.20.1.22 		disabled=no name=egnord.kuerberg.ch ttl=1d
    add address=10.20.1.23 		disabled=no name=egwest.kuerberg.ch ttl=1d
    add address=10.20.1.31 		disabled=no name=1ogost.kuerberg.ch ttl=1d
    add address=10.20.1.33 		disabled=no name=1ogwest.kuerberg.ch ttl=1d
    add address=10.20.1.42 		disabled=no name=2ognord.kuerberg.ch ttl=1d
    add address=10.20.1.52 		disabled=no name=3ognord.kuerberg.ch ttl=1d
	add address=10.99.99.1 		disabled=no name=cr.kuerberg.ch ttl=1d
	add address=10.99.99.2 		disabled=no name=cs-sfp.kuerberg.ch ttl=1d
	add address=10.99.99.3 		disabled=no name=cs-poe.kuerberg.ch ttl=1d
	add address=10.99.99.100	disabled=no name=es-poe.kuerberg.ch ttl=1d
	add address=10.99.99.102	disabled=no name=apes-1b.kuerberg.ch ttl=1d
	add address=10.99.99.103	disabled=no name=apes-gf.kuerberg.ch ttl=1d
	add address=10.99.99.104	disabled=no name=apes-1f.kuerberg.ch ttl=1d
	add address=10.99.99.130	disabled=no name=es-u3.kuerberg.ch ttl=1d
	add address=10.99.99.131	disabled=no name=ap-u3.kuerberg.ch ttl=1d
    add address=192.168.66.1 	disabled=no name=fritzbox.kuerberg.ch ttl=1d


#######################################
#
# -- IP Services - DHCP
#  FYI
#    - Intercom devices have fixed IP leases (static IP via DHCP) 
#    - client-id is the identifier other properties for information only, https://forum.mikrotik.com/viewtopic.php?t=173790
#    - DHCP Server finds its corresponding settings for its clients by comparing subnets of /... address-pool & /... network address
#    - Gateway is the path to an interface from where the traffic can enter the CPU though the CPU Port.
#      Due to bridge based VLAN configuration the gate to the CPU is the bridge interface. 
#      Access to the this interface is according VLAN Table. This is the reason why the bridge is added as port in the VLAN Table
#
#######################################

  #Address Pool per VLAN 
  /ip pool
    add ranges=10.10.1.2-10.10.1.249		name=VLAN_001 	comment="BLACKHOLE" 
    add ranges=10.10.2.2-10.10.2.249  		name=VLAN_002 	comment="PRINTERS"
    add ranges=10.20.1.2-10.20.1.249	  	name=VLAN_011 	comment="IoT_INTERCOM"
    add ranges=10.99.99.100-10.99.99.249  	name=VLAN_099 	comment="BASE (MGMT) VLAN"
    add ranges=10.110.0.2-10.110.0.249		name=VLAN_110 	comment="MAIN VLAN OF USER1 FOR LAN"
    add ranges=10.110.1.2-10.110.1.249  	name=VLAN_111 	comment="MAIN VLAN OF USER1 FOR WLAN"
    add ranges=10.120.0.2-10.120.0.249  	name=VLAN_120 	comment="MAIN VLAN OF USER2 FOR LAN"
    add ranges=10.120.1.2-10.120.1.249  	name=VLAN_121 	comment="MAIN VLAN OF USER2 FOR WLAN"
    add ranges=10.130.0.2-10.130.0.249  	name=VLAN_130 	comment="MAIN VLAN OF USER3 FOR LAN"
    add ranges=10.130.1.2-10.130.1.249  	name=VLAN_131 	comment="MAIN VLAN OF USER3 FOR WLAN"
    add ranges=10.140.0.2-10.140.0.249  	name=VLAN_140 	comment="MAIN VLAN OF USER4 FOR LAN"
    add ranges=10.140.1.2-10.140.1.249  	name=VLAN_141 	comment="MAIN VLAN OF USER4 FOR WLAN"
    add ranges=10.150.0.2-10.150.0.249		name=VLAN_150 	comment="MAIN VLAN OF USER5 FOR LAN"
    add ranges=10.150.1.2-10.150.1.249  	name=VLAN_151 	comment="MAIN VLAN OF USER5 FOR WLAN"
    add ranges=10.160.0.2-10.160.0.249  	name=VLAN_160 	comment="MAIN VLAN OF USER6 FOR LAN"
    add ranges=10.160.1.2-10.160.1.249  	name=VLAN_161 	comment="MAIN VLAN OF USER6 FOR WLAN"
    add ranges=10.170.0.2-10.170.0.249  	name=VLAN_170 	comment="MAIN VLAN OF USER7 FOR LAN"
    add ranges=10.170.1.2-10.170.1.249  	name=VLAN_171 	comment="MAIN VLAN OF USER7 FOR WLAN"
    add ranges=10.180.0.2-10.180.0.249  	name=VLAN_180 	comment="MAIN VLAN OF USER8 FOR LAN"
    add ranges=10.180.1.2-10.180.1.249  	name=VLAN_181 	comment="MAIN VLAN OF USER8 FOR WLAN"
    add ranges=10.200.0.2-10.200.0.249  	name=VLAN_200 	comment="GUEST LAN"
    add ranges=10.201.0.2-10.201.0.249  	name=VLAN_201 	comment="GUEST WLAN"
    add ranges=172.16.1.2-172.16.1.249  	name=VLAN_301 	comment="DMZ - NAS(s)"
    add ranges=192.168.1.2-192.168.1.249	name=VLAN_401 	comment="LAB"

  #DHCP-Server per VLAN-Interface, DON'T COPY COMMENT!!!
  /ip dhcp-server
    add address-pool=VLAN_001	interface=VLAN_001	name=VLAN_001_DHCP	disabled=no		comment="BLACKHOLE"  
    add address-pool=VLAN_002	interface=VLAN_002	name=VLAN_002_DHCP	disabled=no     comment="PRINTERS"
    add address-pool=VLAN_011	interface=VLAN_011	name=VLAN_011_DHCP	disabled=no     comment="IoT_INTERCOM"
    add address-pool=VLAN_099	interface=VLAN_099	name=VLAN_099_DHCP	disabled=no     comment="BASE (MGMT) VLAN"
    add address-pool=VLAN_110	interface=VLAN_110	name=VLAN_110_DHCP	disabled=no     comment="MAIN VLAN OF USER1 FOR LAN"
    add address-pool=VLAN_111	interface=VLAN_111	name=VLAN_111_DHCP	disabled=no     comment="MAIN VLAN OF USER1 FOR WLAN"
    add address-pool=VLAN_120	interface=VLAN_120	name=VLAN_120_DHCP	disabled=no     comment="MAIN VLAN OF USER2 FOR LAN"
    add address-pool=VLAN_121	interface=VLAN_121	name=VLAN_121_DHCP	disabled=no 	comment="MAIN VLAN OF USER2 FOR WLAN"
    add address-pool=VLAN_130	interface=VLAN_130	name=VLAN_130_DHCP	disabled=no     comment="MAIN VLAN OF USER3 FOR LAN"
    add address-pool=VLAN_131	interface=VLAN_131	name=VLAN_131_DHCP	disabled=no     comment="MAIN VLAN OF USER3 FOR WLAN"
    add address-pool=VLAN_140	interface=VLAN_140	name=VLAN_140_DHCP	disabled=no     comment="MAIN VLAN OF USER4 FOR LAN"
    add address-pool=VLAN_141	interface=VLAN_141	name=VLAN_141_DHCP	disabled=no     comment="MAIN VLAN OF USER4 FOR WLAN"
    add address-pool=VLAN_150	interface=VLAN_150	name=VLAN_150_DHCP	disabled=no     comment="MAIN VLAN OF USER5 FOR LAN"
    add address-pool=VLAN_151	interface=VLAN_151	name=VLAN_151_DHCP	disabled=no     comment="MAIN VLAN OF USER5 FOR WLAN"
    add address-pool=VLAN_160	interface=VLAN_160	name=VLAN_160_DHCP	disabled=no     comment="MAIN VLAN OF USER6 FOR LAN"
    add address-pool=VLAN_161	interface=VLAN_161	name=VLAN_161_DHCP	disabled=no 	comment="MAIN VLAN OF USER6 FOR WLAN"
    add address-pool=VLAN_170	interface=VLAN_170	name=VLAN_170_DHCP	disabled=no     comment="MAIN VLAN OF USER7 FOR LAN"
    add address-pool=VLAN_171	interface=VLAN_171	name=VLAN_171_DHCP	disabled=no     comment="MAIN VLAN OF USER7 FOR WLAN"
    add address-pool=VLAN_180	interface=VLAN_180	name=VLAN_180_DHCP	disabled=no     comment="MAIN VLAN OF USER8 FOR LAN"
	add address-pool=VLAN_181	interface=VLAN_181	name=VLAN_181_DHCP	disabled=no     comment="MAIN VLAN OF USER8 FOR WLAN"
    add address-pool=VLAN_200	interface=VLAN_200	name=VLAN_200_DHCP	disabled=no     comment="GUEST LAN"
    add address-pool=VLAN_201	interface=VLAN_201	name=VLAN_201_DHCP	disabled=no     comment="GUEST WLAN"
	add address-pool=VLAN_301	interface=VLAN_301	name=VLAN_301_DHCP	disabled=no     comment="DMZ - NAS(s)"
    add address-pool=VLAN_401	interface=VLAN_401	name=VLAN_401_DHCP	disabled=no     comment="LAB"
  
  #DHCP settings per subnet
  /ip dhcp-server network 
    add address=10.10.1.0/24 	dns-server=10.10.1.1 		gateway=10.10.1.1 		comment="BLACKHOLE"  
    add address=10.10.2.0/24 	dns-server=10.10.2.1 		gateway=10.10.2.1     	comment="PRINTERS"
    add address=10.20.1.0/24 	dns-server=10.20.1.1 		gateway=10.20.1.1     	comment="IoT_INTERCOM"
    add address=10.99.99.0/24 	dns-server=10.99.99.1 		gateway=10.99.99.1 	    comment="BASE (MGMT) VLAN"
    add address=10.110.0.0/24 	dns-server=10.110.0.1 		gateway=10.110.0.1      comment="MAIN VLAN OF USER1 FOR LAN"
    add address=10.110.1.0/24 	dns-server=10.110.1.1 		gateway=10.110.1.1      comment="MAIN VLAN OF USER1 FOR WLAN"
    add address=10.120.0.0/24 	dns-server=10.120.0.1 		gateway=10.120.0.1      comment="MAIN VLAN OF USER2 FOR LAN"
    add address=10.120.1.0/24 	dns-server=10.120.1.1 		gateway=10.120.1.1   	comment="MAIN VLAN OF USER2 FOR WLAN"
    add address=10.130.0.0/24 	dns-server=10.130.0.1 		gateway=10.130.0.1      comment="MAIN VLAN OF USER3 FOR LAN"
    add address=10.130.1.0/24 	dns-server=10.130.1.1 		gateway=10.130.1.1      comment="MAIN VLAN OF USER3 FOR WLAN"
    add address=10.140.0.0/24 	dns-server=10.140.0.1 		gateway=10.140.0.1      comment="MAIN VLAN OF USER4 FOR LAN"
    add address=10.140.1.0/24 	dns-server=10.140.1.1 		gateway=10.140.1.1      comment="MAIN VLAN OF USER4 FOR WLAN"
    add address=10.150.0.0/24 	dns-server=10.150.0.1 		gateway=10.150.0.1      comment="MAIN VLAN OF USER5 FOR LAN"
    add address=10.150.1.0/24 	dns-server=10.150.1.1 		gateway=10.150.1.1      comment="MAIN VLAN OF USER5 FOR WLAN"
    add address=10.160.0.0/24 	dns-server=10.160.0.1 		gateway=10.160.0.1      comment="MAIN VLAN OF USER6 FOR LAN"
    add address=10.160.1.0/24 	dns-server=10.160.1.1 		gateway=10.160.1.1   	comment="MAIN VLAN OF USER6 FOR WLAN"
    add address=10.170.0.0/24 	dns-server=10.170.0.1 		gateway=10.170.0.1      comment="MAIN VLAN OF USER7 FOR LAN"
    add address=10.170.1.0/24 	dns-server=10.170.1.1 		gateway=10.170.1.1      comment="MAIN VLAN OF USER7 FOR WLAN"
    add address=10.180.0.0/24 	dns-server=10.180.0.1 		gateway=10.180.0.1      comment="MAIN VLAN OF USER8 FOR LAN"
    add address=10.180.1.0/24 	dns-server=10.180.1.1 		gateway=10.180.1.1      comment="MAIN VLAN OF USER8 FOR WLAN"
    add address=10.200.0.0/24 	dns-server=10.200.0.1 		gateway=10.200.0.1      comment="GUEST LAN"
    add address=10.201.0.0/24 	dns-server=10.201.0.1 		gateway=10.201.0.1      comment="GUEST WLAN"
    add address=172.16.1.0/24 	dns-server=172.16.1.1 		gateway=172.16.1.1      comment="DMZ - NAS(s)"
    add address=192.168.1.0/24 	dns-server=192.168.1.1 		gateway=192.168.1.1     comment="LAB"

  #IP per intercome device					
  /ip dhcp-server lease
    add address=10.20.1.11 address-lists="" client-id=1:7c:1e:b3:4:bf:34 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:04:BF:34 server=VLAN_011_DHCP
    add address=10.20.1.12 address-lists="" client-id=1:7c:1e:b3:ff:af:66 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:FF:AF:66 server=VLAN_011_DHCP  
    add address=10.20.1.13 address-lists="" client-id=1:7c:1e:b3:ff:bc:ea dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:FF:BC:EA server=VLAN_011_DHCP
    add address=10.20.1.21 address-lists="" client-id=1:7c:1e:b3:ff:bc:da dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:FF:BC:DA server=VLAN_011_DHCP	  
    add address=10.20.1.22 address-lists="" client-id=1:7c:1e:b3:f0:c7:15 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:F0:C7:15 server=VLAN_011_DHCP
    add address=10.20.1.23 address-lists="" client-id=1:7c:1e:b3:ff:bc:a9 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:FF:BC:A9 server=VLAN_011_DHCP	
    add address=10.20.1.31 address-lists="" client-id=1:7c:1e:b3:4:bc:a6 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:04:BC:A6 server=VLAN_011_DHCP
    add address=10.20.1.33 address-lists="" client-id=1:7c:1e:b3:4:94:8d dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:04:94:8D server=VLAN_011_DHCP
    add address=10.20.1.42 address-lists="" client-id=1:7c:1e:b3:4:95:77 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:04:95:77 server=VLAN_011_DHCP
    add address=10.20.1.52 address-lists="" client-id=1:7c:1e:b3:4:77:6 dhcp-option="" disabled=no !insert-queue-before\
      mac-address=7C:1E:B3:04:77:06 server=VLAN_011_DHCP


#######################################
#
# -- Turn on VLAN mode --
#  FYI:
#    - uncomment command below!
#
#######################################

#  /interface bridge set bridge-VLANs vlan-filtering=yes


#######################################
#
# -- Optimization --
#  FYI:
#   - The following options are set active by default but listed here to to draw attention to the possible optimisation
#	- HARDWARE OFFLOADING (hw): Anything happens on the Switch-Chip, traffic will never touch the CPU. This depends on settings and Chip
#       check https://help.mikrotik.com/docs/display/ROS/Switch+Chip+Features and https://help.mikrotik.com/docs/display/ROS/Bridge#Bridge-BridgeHardwareOffloading for details
# 	- FAST-FORWARD: allow direct port to port forwarding https://help.mikrotik.com/docs/display/ROS/Bridge#Bridge-FastForward but is probably not required when Hardware Offloading is active and working.
#       As VLAN filtering is active fast-path is not used in this configuration
#       Do not confuse this with fast-path & fasttrack which are "CPU skipping / leaving" features as well but rather belong to firewall configuration. 
#   - FAST-PATH, https://wiki.mikrotik.com/wiki/Manual:Fast_Path, allows to forward packets without additional processing in the Linux kernel, be it on 
#       Layer3+ (check /ip settings) or on a Layer 2 Bridge ( check /Bridge fast path)
#       In this overall configruation it won't be used on all devices as VLAN filtering is active but offloaded to the Switch-Chip on the core devices, so the impact is low.
#       Its mentioned here as it allows FastTrack, which is covered in the firewall configuration chapters.
#
#######################################

  #ensure that FAST-FORWARD is set active on the BRIDGE
	/interface bridge set fast-forward=yes [find name=bridge-VLANs]

  #ensure that FAST-PATH is set active on the BRIDGE
	/interface bridge settings set allow-fast-path=yes 

  #ensure that HARDWARE OFFLOADING is set active on all connected PORTS of our bridge
    /interface bridge port set bridge=bridge-VLANs  hw=yes [find]