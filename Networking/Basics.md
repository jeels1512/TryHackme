**OSI Model**

**To remember OSI model layer there is the phrase called: "Do not throw spinach pizza away"**

**1st layer: Physical layer**

This layer is all about wirely connection, to connect the devices or to transmit data via electrical, optical or wireless signal.

**Layer 2nd: Data Link**

layer 2, represents the protocol that enables data transfer between nodes on the same network segment.

Example: Ethernet, wifi addresses are six bytes. Thier address is called MAC(Media Access Control) Address.

MAC address: a4:c3:f0:85:ac:2d

The structure of MAC address is hexadecimal format where each two digits is a byte.

First three bytes represent vendor who build the network interface and last three is a unique address of the network interface.

**Layer 3rd: Network Layer**

The data link layer focuses on sending data between two nodes on the same network segment. The network layer, i.e., layer 3, is concerned with sending data between different networks. In more technical terms, the network layer handles logical addressing and routing, i.e., finding a path to transfer the network packets between the diverse networks.

Examples of the network layer include Internet Protocol (IP), Internet Control Message Protocol (ICMP), and Virtual Private Network (VPN) protocols such as IPSec and SSL/TLS VPN.


 | Layer | Layer Name        | Main Function                                           | Example Protocols & Standards                  |
|-------|------------------|---------------------------------------------------------|------------------------------------------------|
| 7     | Application      | Provides network services to user applications          | HTTP, FTP, DNS, POP3, SMTP, IMAP               |
| 6     | Presentation     | Data encoding, encryption, and compression               | Unicode, MIME, JPEG, PNG, MPEG                 |
| 5     | Session          | Establishes, manages, and terminates communication sessions | NFS, RPC                                   |
| 4     | Transport        | End-to-end communication and data segmentation           | TCP, UDP                                       |
| 3     | Network          | Logical addressing and routing between networks          | IP, ICMP, IPsec                                |
| 2     | Data Link        | Reliable transfer between directly connected nodes       | Ethernet (802.3), Wi-Fi (802.11)               |
| 1     | Physical         | Transmission of raw bits over physical media             | Electrical, Optical, Wireless signals          |


**The table below shows how the TCP/IP model layers map to the ISO/OSI model layers.**

| Layer # | ISO OSI Model        | TCP/IP Model (RFC 1122) | Example Protocols                          |
|--------:|---------------------|-------------------------|---------------------------------------------|
| 7       | Application Layer   | Application Layer       | HTTP, HTTPS, FTP, SMTP, POP3, IMAP, SSH, DNS |
| 6       | Presentation Layer  | Application Layer       | TLS/SSL, MIME, JPEG, PNG                    |
| 5       | Session Layer       | Application Layer       | NetBIOS, RPC                                |
| 4       | Transport Layer     | Transport Layer         | TCP, UDP                                    |
| 3       | Network Layer       | Internet Layer          | IP, ICMP, IPsec                             |
| 2       | Data Link Layer     | Link Layer               | Ethernet (802.3), Wi-Fi (802.11)            |
| 1       | Physical Layer      | Link Layer               | Copper, Fiber, Radio signals                |

**At layer 4, there are two types of protocols to transfer the information: 1. TCP and 2.UDP**

1. TCP(Transmission Control Protocol): While transferring the information, this protocol first makes the connection with the receiver and tries to ensure no data is lost. For this to happen, it uses the three-way handshake method. That is why this protocol is slow while transferring.

2. UDP(User Datagram Protocol): UDP is a simple connectionless protocol. Being connectionless means that it does not need to establish a connection. This protocol does not even provide machenism to know that the packet has been delivered.

One more important concept is **Encapsulation**

encapsulation refers to the process of every layer adding a header (and sometimes a trailer) to the received unit of data and sending the “encapsulated” unit to the layer below.

The TELNET (Teletype Network) protocol is a network protocol for remote terminal connection. In simpler words, telnet, a TELNET client, allows you to connect to and communicate with a remote system and issue text commands. Although initially it was used for remote administration, we can use telnet to connect to any server listening on a TCP port number.

**telnet MACHINE_IP 80
Trying MACHINE_IP...
Connected to MACHINE_IP.
Escape character is '^]'.
GET / HTTP/1.1
Host: telnet.thm

HTTP/1.1 200 OK
Content-Type: text/html
[...]**
