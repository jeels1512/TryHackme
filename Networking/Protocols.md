# 📡 Common Network Protocols and Their Default Ports

This document lists important networking protocols and their default port numbers.  
These are commonly required for CCNA, networking labs, and cybersecurity basics.

---

## 🔐 Remote Access Protocols

| Protocol | Port | Purpose |
|----------|------|----------|
| Telnet | 23 | Remote login (insecure) |
| SSH | 22 | Secure remote login |
| RDP | 3389 | Remote Desktop (Windows) |

---

## 🌐 Web Protocols

| Protocol | Port | Purpose |
|----------|------|----------|
| HTTP | 80 | Web traffic (insecure) |
| HTTPS | 443 | Secure web traffic |

---

## 📁 File Transfer Protocols

| Protocol | Port | Purpose |
|----------|------|----------|
| FTP | 21 | File transfer |
| FTPS | 990 | Secure FTP |
| SFTP | 22 | Secure file transfer (over SSH) |
| TFTP | 69 (UDP) | Lightweight file transfer |

---

## 📧 Email Protocols

| Protocol | Port | Purpose |
|----------|------|----------|
| SMTP | 25 | Mail sending (server-to-server) |
| SMTP Submission | 587 | Mail sending (client-to-server) |
| POP3 | 110 | Retrieve email |
| IMAP | 143 | Retrieve/sync email |
| POP3S | 995 | Secure POP3 |
| IMAPS | 993 | Secure IMAP |

---

## 🌍 Network & Infrastructure Protocols

| Protocol | Port | Purpose |
|----------|------|----------|
| DNS | 53 (TCP/UDP) | Domain name resolution |
| DHCP | 67 / 68 (UDP) | IP address assignment |
| SNMP | 161 | Network management |
| NTP | 123 (UDP) | Time synchronization |
| LDAP | 389 | Directory services |
| LDAPS | 636 | Secure LDAP |

---

## 🛠 Security & File Sharing

| Protocol | Port | Purpose |
|----------|------|----------|
| SMB | 445 | File sharing (Windows) |
| NetBIOS | 137-139 | Legacy Windows networking |
| Kerberos | 88 | Authentication protocol |
| Syslog | 514 | Log management |
| OpenVPN | 1194 | VPN connection |

---

## 📌 Important Notes

- These are **default ports**.
- Services can be configured to run on different ports.
- Ports 0–1023 are called **Well-Known Ports**.
- Ports 1024–49151 are **Registered Ports**.
- Ports 49152–65535 are **Dynamic/Ephemeral Ports**.

---

### 🚀 Networking Concept Reminder

- **IP Address** → Identifies the machine.
- **Port Number** → Identifies the service.
- **Protocol** → Defines how communication happens.
- **Service** → The actual application running on that port.

Understanding these relationships is more important than memorizing numbers.
