**TLS: Transfer Layer Security is a cryptographic protocol that secures communications over a network.**

**The TLS was named SSL(Secure Socket Layer) before.**

**HTTPS: Hyper Text Transfer Protocol Secure is basically HTTP over TLS.**

Requesting pages over HTTPS requires three steps to follow.

1. Establish a TCP three-way handshake with the target server.

2. Establish TLS session.

3. Communicate using the HTTP protocol, for example, issue HTTP requests, such as GET / HTTP/1.1.

Here, First three packets are for TCP session, then, several packets are exchanged to negotiate the TLS protocol.

This is called TLS negotiation and establishment.

 **It is improbable that we will have access to the keys used for encryption in a TLS session**

 ## Secure Protocols and Their Default Ports

| Protocol | Default Port Number |
|----------|--------------------|
| HTTPS    | 443                |
| SMTPS    | 465, 587           |
| POP3S    | 995                |
| IMAPS    | 993                |


## OpenSSH Overview

**OpenSSH** is a secure networking utility used to access remote systems and transfer data safely over an untrusted network.

---

## Key Benefits

### 🔐 Secure Authentication
OpenSSH supports multiple authentication methods:
- Password-based authentication  
- Public key authentication  
- Two-factor authentication (2FA)

Public key authentication improves security by avoiding password transmission over the network.

---

### 🔒 Confidentiality
OpenSSH provides end-to-end encryption, protecting data from eavesdropping.

It also alerts users when a server’s host key changes, helping prevent man-in-the-middle (MITM) attacks.

---

### 🛡 Integrity
SSH uses cryptographic mechanisms to ensure that data is not altered during transmission.  
This guarantees the data received is exactly what was sent.

---

### 🌐 Tunneling
SSH can create secure tunnels to forward other protocols through an encrypted connection.

This allows you to:
- Secure insecure services
- Access internal resources safely
- Create VPN-like connections

---

### 🖥 X11 Forwarding
When connecting to a Unix-like system with a graphical interface, SSH allows you to run graphical applications remotely and display them locally.

---

## Connecting to an SSH Server

To connect to a remote server:

bash
ssh username@hostname


The argument -X is required to support running graphical interfaces, 
for example, ssh 192.168.124.148 -X. (The local system needs to have a suitable graphical system installed.)

SFTP stands for SSH File Transfer Protocol and allows secure file transfer. It is part of the SSH protocol suite and shares the same port number, 22. If enabled in the OpenSSH server configuration, you can connect using a command such as sftp username@hostname.


# VPN (Virtual Private Network) – Core Concept Notes

## Why Companies Use VPN

A company with multiple offices across different geographical locations can connect all branches to the main office using a VPN.

This allows:
- Devices in remote branches to access shared resources
- Secure communication over the Internet
- Remote users to work as if physically inside the main branch network

VPN is the most economical solution because it uses existing Internet infrastructure.

---

# Understanding VPN Meaning

## V = Virtual
The connection is not physically private.
It uses the public Internet but behaves like a private network.

---

## P = Private
TCP/IP was designed for packet delivery, not security.

Problems with normal Internet communication:
- No built-in confidentiality
- No guaranteed protection against data modification
- No protection from interception

VPN solves this by:
- Encrypting traffic
- Protecting data from disclosure
- Preventing alteration

---

# Basic Requirements for VPN

- Internet connectivity
- VPN server (usually at main branch)
- VPN client (remote branch or user device)

---

# How VPN Works (Branch-to-Branch)

1. Remote branch VPN client connects to main branch VPN server.
2. Encrypted tunnel is created.
3. Traffic is encrypted before leaving remote branch.
4. Data travels securely over the Internet.
5. Main branch decrypts the traffic.

Encrypted traffic = VPN tunnel  
Decrypted traffic = Internal network communication  

---

# Remote Access VPN (Single User)

- A remote employee connects using a VPN client.
- Only that device becomes part of the private network.
- Secure access to company resources from anywhere.

---

# VPN and Internet Traffic

After VPN tunnel is established:

- All traffic is usually routed through VPN.
- Websites see VPN server’s public IP.
- Real public IP is hidden.
- ISP sees only encrypted traffic.

Example:
If connected to a VPN server in Japan,
Web services detect you as located in Japan.

---

# Important Security Considerations

Not all VPN setups route all traffic.

Possible issues:
- Split tunneling (only some traffic goes through VPN)
- DNS leaks (real IP or DNS exposed)
- Misconfigured VPN server
- Some VPN providers log user data

Always test:
- IP leak
- DNS leak

---

# Legal Consideration

Some countries restrict or ban VPN usage.
Always check local laws before using VPN.

---

# Key Cybersecurity Exam Points

- VPN creates an encrypted tunnel over public Internet.
- VPN provides confidentiality and integrity.
- VPN can connect networks (site-to-site) or individuals (remote access).
- VPN hides real IP address (if fully routed).
- VPN does NOT automatically guarantee anonymity.
- VPN relies on encryption + authentication.

---

# One-Line Definition

VPN = Encrypted virtual tunnel over the Internet that connects users or networks securely.


