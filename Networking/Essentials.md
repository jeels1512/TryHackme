**Just Connect to the wifi:**

**If you want to access a network, at the very least, we need to configure:**

**IP address along with subnet mask**

**Router**

**DNS server**


**Having an automated way to configure connected devices has many advantages.**

The advantage of automatically connecting to Wi-Fi is that we don't need to manually assign an IP address. **

This thing can save us from IP address conflicts, especially on mobile devices, where two devices can be configured with the same IP.

If an IP address conflict happens, it would prevent the involved hosts from using the network resources.

The solution lies in using **Dynamic Host Configuration Protocol** 

DHCP is an application-level protocol that relies on UDP

The server listens on port 67, and the client sends on port 68.

**For bridging, layer 2 and layer 3, we use the ARP(Address Resolution Protocol).**

**Internet Control Message Protocol is mainly used for network diagnostics and error reporting.**

**Two main commands mainly reply on this protocol. 1. ping 2 .traceroute**

**Ping: This command uses ICMP to test connectivity to a target system and measures the round-trip time.**

In other words, it can be used to learn that the target is alive and that its reply can reach our system.

**traceroute: this command is called tracert on MS Windows systems. It uses ICMP to discover the termroute from 
your host to the target.**



