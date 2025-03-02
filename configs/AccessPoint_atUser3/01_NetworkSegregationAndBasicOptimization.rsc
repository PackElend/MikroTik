###############################################################################
# Topic:		Multi Home Network
# Part:			Network Segregation and Basic Optimization
# Web:			https://github.com/PackElend/MikroTik
# RouterOS:		7.18.0
# Device:		https://mikrotik.com/product/hex_s
# Date:			March 02, 2025
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
/system identity set name="AP+S-USER3_GF-E_MT-cAP-ax"


#######################################
#
# -- WAN + SUBNET & VLAN Overview --
#
#######################################

# ip-range            | vlan-id | comment
# 192.168.066.066/24  |  ----   | WAN INTERFACE IP   
# 010.010.000.000/21  |     x   | COMMON SERVICES AND DEVICES / OFFICE
# 010.010.001.000/24  |     1   |  BLACKHOLE
# 010.010.002.000/24  |     2   |  PRINTERS, SCANNERS
# 010.020.000.000/16  |    xx   | IoT SUBNETS
# 010.020.001.000/24  |    11   |  IoT_INTERCOM
# 010.099.099.000/24  |    99   | BASE (MGMT) VLAN
# 010.1xx.000.000/xx  |   1xx   | PERSONAL VLANs
# 010.110.000.000/24  |   110   |  MAIN VLAN OF USER1 FOR LAN
# 010.110.001.000/24  |   111   |  MAIN VLAN OF USER1 FOR WLAN
# 010.120.000.000/24  |   120   |  MAIN VLAN OF USER2 FOR LAN
# 010.120.001.000/24  |   121   |  MAIN VLAN OF USER2 FOR WLAN
# 010.130.000.000/24  |   130   |  MAIN VLAN OF USER3 FOR LAN
# 010.130.001.000/24  |   131   |  MAIN VLAN OF USER3 FOR WLAN
# 010.140.000.000/24  |   140   |  MAIN VLAN OF USER4 FOR LAN
# 010.140.001.000/24  |   141   |  MAIN VLAN OF USER4 FOR WLAN
# 010.150.000.000/24  |   150   |  MAIN VLAN OF USER5 FOR LAN
# 010.150.001.000/24  |   151   |  MAIN VLAN OF USER5 FOR WLAN
# 010.160.000.000/24  |   160   |  MAIN VLAN OF USER6 FOR LAN
# 010.160.001.000/24  |   161   |  MAIN VLAN OF USER6 FOR WLAN
# 010.170.000.000/24  |   170   |  MAIN VLAN OF USER7 FOR LAN
# 010.170.001.000/24  |   171   |  MAIN VLAN OF USER7 FOR WLAN
# 010.180.000.000/24  |   180   |  MAIN VLAN OF USER8 FOR LAN
# 010.180.001.000/24  |   181   |  MAIN VLAN OF USER8 FOR WLAN
# 010.200.000.000/15  |   2xx   | GUEST VLANs
# 010.200.000.000/16  |   200   | 	 GUEST LAN
# 010.201.000.000/16  |   201   | 	 GUEST WLAN
# 172.016.000.000/12  |   3xx   |  DMZ
# 172.016.001.000/24  |   301   |   NAS(s)
# 192.168.000.000/16  |   4xx   |  LAB
# 192.168.001.000/24  |   401   |   JOB DEVICES


#######################################
# 
# -- Interface Ports --
# comment ports according their role 
#   
#######################################

 /interface ethernet
   set comment="TAGGED PORT, VLAN-TRUNK TO ES, PoE-In" 			[find name=ether1]
   set comment="TAGGED PORT, USER3, PoE-Out"	                [find name=ether2]    


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
  /interface bridge add name=bridge-VLANs vlan-filtering=no pvid=999
  
  # add VLANs
  /interface vlan
	add interface=bridge-VLANs   vlan-id=999	name=VLAN_MGMT	comment="BASE (MGMT) VLAN"

	
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
    add bridge=bridge-VLANs interface=ether2 pvid=130 ingress-filtering=yes\
	    frame-types=admit-only-untagged-and-priority-tagged comment="USER3"

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
#    - the tagged ports trunk all VLANs into the wirde connected to this ports
#    - the bridge "bridge-VLANs" has to be added as port otherwise traffice cannot leave the bridge (L2 + L3 hw-off) and being routed to wwww etc.
#    - no ingress filter as untagged traffic is unknow traffic and shall routed into the blackhole
#
#######################################

  # add tagged ports, which will do VLAN-TRUNKING
  /interface bridge port
	add bridge=bridge-VLANs interface=ether1              comment="TP: Minimum, USER3, WLAN-User  (by roas)"\
      ingress-filtering=yes frame-types=admit-only-vlan-tagged                  
  add bridge=bridge-VLANs interface=ether2 pvid=130     comment="UP_S: VLAN_USER3  (by roas)"\
      ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged 

	
	# add VLANs to be allowed on the tagged ports, only these will be trunked through the connected wire
  /interface bridge vlan
  add bridge=bridge-VLANs vlan-ids=1   comment="BLACKHOLE"  		 			                      tagged=ether1
  add bridge=bridge-VLANs vlan-ids=11  comment="GUEST WLAN"  					                      tagged=ether1
	add bridge=bridge-VLANs vlan-ids=120 comment="USER 2, all devices in one vlan (by roas)" 	tagged=ether1
	add bridge=bridge-VLANs vlan-ids=130 comment="USER 3, all devices in one vlan (by roas)" 	tagged=ether1
	add bridge=bridge-VLANs vlan-ids=150 comment="USER 5, all devices in one vlan (by roas)" 	tagged=ether1
	add bridge=bridge-VLANs vlan-ids=160 comment="USER 6, all devices in one vlan (by roas)" 	tagged=ether1
  add bridge=bridge-VLANs vlan-ids=999 comment="BASE (MGMT) VLAN"  			                    tagged=ether1,bridge-VLANs
	
   

#######################################
#
# -- IP Addressing & Routing - Routes --
#  FYI:
#    - Connected Route is added per address added, see https://wiki.mikrotik.com/wiki/Manual:IP/Route#Connected_routes
#      This means the route from / to the interface where the IP belongs to is added dynamically by ROS 
#
#######################################

  # VLAN interface for access to Switch-CPU
  /ip address  
	add address=10.10.9.122/24 	interface=VLAN_MGMT	 comment="This is my own IP. (by roas)" 
		
  # The route to the router to allow ROS to fetch updates etc. 
  /ip route   
    add gateway=10.10.9.1 distance=1 


#######################################
#
# -- IP Addressing & Routing - DNS -- 
#
#######################################

   # DNS server, to allow ROS to resolve DNS queries from the CPUto fetch updates etc.  
  /ip dns set allow-remote-requests=no servers="10.10.9.1"

#######################################
#
# -- IP Services - DHCP
#
#######################################

  # We have a router that will handle this. Nothing to set here.
  

#######################################
#
# -- Turn on VLAN mode --
#  FYI:
#    - uncomment command below!
#
#######################################
  
  
  
  
