## TCPDUMP Room 


"ip address show" is the command to show available interfaces.

- tcpdump -i: interface --> Captures packets on a specific network interface.

- tcpdump -w FILE --> write the captured file

- tcpdump -r FILE --> reads the captured file

- tcpdump -c COUNT --> captures the specific numbers of file

- tcpdump -n --> don't resolve IP address

- tcpdump -n --> don't resolve IP addresses and don't resolve protocol numbers

- tcpdump -v --> verbose display; verbostiy can be increased with -vv and -vvv.


#### Filtering by host

- You can easily limit the captured packets to this host using `host IP` or `host HOSTNAME`.

- It is important to note that capturing packets require you to be logged-in as root or to use sudo.

- If you want to limit the packets to those from a particular source IP address or hostname, you must use `src host IP` or `src host HOSTNAME`. Similarly, you can limit packets to those sent to a specific destination using `dst host IP` or `dst host HOSTNAME`.


### The problem → why we filter
 
A network card sees thousands of packets per second. Watching all of them is useless — like trying to listen to every conversation in a mall. So we **filter**.
 
---
 
## Filtering Packets
 
### 1. Filter by Host (WHO)
 
```bash
tcpdump host example.com        # to/from example.com
tcpdump src host 1.1.1.1        # only FROM 1.1.1.1
tcpdump dst host 1.1.1.1        # only TO 1.1.1.1
```
 
### 2. Filter by Port (WHICH SERVICE / DOOR)
 
```bash
tcpdump port 53                 # to/from port 53 (DNS)
tcpdump src port 443            # only FROM port 443
tcpdump dst port 22             # only TO port 22 (SSH)
```
 
### 3. Filter by Protocol (WHAT TYPE)
 
```bash
tcpdump icmp                    # ping traffic
tcpdump tcp                     # TCP only
tcpdump udp                     # UDP only
tcpdump ip                      # IPv4
tcpdump ip6                     # IPv6
```
 
---
 
## Logical Operators (Combine Filters)
 
| Operator | Meaning | Example |
|----------|---------|---------|
| `and`    | both conditions true | `tcpdump host 1.1.1.1 and tcp` |
| `or`     | either is true | `tcpdump udp or icmp` |
| `not`    | NOT this | `tcpdump not tcp` |
 
---
 
## Common Flags
 
| Flag | What it does |
|------|--------------|
| `-i eth0` | Listen on a specific interface (`-i any` = all interfaces) |
| `-n` | Don't resolve IPs to hostnames (numeric only, faster) |
| `-w file.pcap` | Save capture to a file |
| `-r file.pcap` | Read from a saved capture file |
| `-c 5` | Stop after capturing 5 packets |
| `-v` / `-vv` / `-vvv` | Verbose / more verbose / most verbose output |
 
---
 
## Command Summary Table
 
| Command | Explanation |
|---------|-------------|
| `tcpdump host IP/HOSTNAME` | Filter by IP or hostname |
| `tcpdump src host IP` | Filter by source host |
| `tcpdump dst host IP` | Filter by destination host |
| `tcpdump port PORT` | Filter by port number |
| `tcpdump src port PORT` | Filter by source port |
| `tcpdump dst port PORT` | Filter by destination port |
| `tcpdump PROTOCOL` | Filter by protocol (`ip`, `ip6`, `tcp`, `udp`, `icmp`) |
 
---
 
## Real-World Examples
 
```bash
# Watch SSH traffic on all interfaces
tcpdump -i any tcp port 22
 
# Capture NTP traffic on WiFi
tcpdump -i wlo1 udp port 123
 
# Capture HTTPS to example.com and save it
tcpdump -i eth0 host example.com and tcp port 443 -w https.pcap
 
# Read first 5 packets from a saved file, numeric only
tcpdump -r traffic.pcap -c 5 -n
 
# Count packets coming FROM a specific IP
tcpdump -r traffic.pcap src host 192.168.124.1 -n | wc -l
```
 
---
 
## Quick Mental Model
 
- **host** → WHO
- **port** → WHICH DOOR
- **protocol** → WHAT LANGUAGE
- Combine with `and` / `or` / `not` to zoom in
---
 
## Notes
 
- Live captures require **root** privileges (`sudo`).
- Reading from a `.pcap` file does **not** need sudo.
- Use `-n` to avoid slow DNS lookups when you only need IPs.

  
## Display Options (How Packets Are Shown)
 
| Command | Explanation |
|---------|-------------|
| `tcpdump -q` | Quick and quiet: brief packet info only |
| `tcpdump -e` | Include MAC addresses |
| `tcpdump -A` | Print packets as ASCII (readable text) |
| `tcpdump -xx` | Display packets in hexadecimal format |
| `tcpdump -X` | Show packets in both hexadecimal AND ASCII |
 
**Tip:** `-A` is great for inspecting plain-text protocols (HTTP, FTP).
`-X` is the go-to for digging into packet contents during forensics.
 
---
 
## Command Summary Table
 
| Command | Explanation |
|---------|-------------|
| `tcpdump host IP/HOSTNAME` | Filter by IP or hostname |
| `tcpdump src host IP` | Filter by source host |
| `tcpdump dst host IP` | Filter by destination host |
| `tcpdump port PORT` | Filter by port number |
| `tcpdump src port PORT` | Filter by source port |
| `tcpdump dst port PORT` | Filter by destination port |
| `tcpdump PROTOCOL` | Filter by protocol (`ip`, `ip6`, `tcp`, `udp`, `icmp`) |
 
---
 
# Advanced Filtering
 
## Filter by Packet Size
 
```bash
tcpdump greater 100      # packets >= 100 bytes
tcpdump less 100         # packets <= 100 bytes
```
 
Useful for spotting unusually large packets (possible data exfiltration) or tiny ones (scans, probes).
 
---
 
## Binary Operations (Quick Refresher)
 
Used when filtering on raw header bytes or TCP flags.
 
| Operator | Name | Rule |
|----------|------|------|
| `&` | AND | Both bits must be 1 to get 1 |
| `\|` | OR | At least one bit must be 1 to get 1 |
| `!` | NOT | Flips the bit (1 → 0, 0 → 1) |
 
### Truth Tables
 
**AND (`&`)**
 
| A | B | A & B |
|---|---|-------|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |
 
**OR (`|`)**
 
| A | B | A \| B |
|---|---|--------|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |
 
**NOT (`!`)**
 
| A | !A |
|---|----|
| 0 | 1 |
| 1 | 0 |
 
---
 
## Filtering by Header Bytes
 
Syntax: `proto[expr:size]`
 
- **proto** → protocol (`arp`, `ether`, `icmp`, `ip`, `ip6`, `tcp`, `udp`)
- **expr** → byte offset (0 = first byte)
- **size** → number of bytes (1, 2, or 4 — defaults to 1)
### Examples (from the man page)
 
```bash
# Show packets sent to a multicast Ethernet address
ether[0] & 1 != 0
 
# Catch all IP packets that have options set
ip[0] & 0xf != 5
```
 
You don't need to memorize these — just know it's possible to filter any byte in any header.
 
---
 
## Filtering by TCP Flags ⭐ (Most Important)
 
Every TCP packet carries **flags** — tiny switches that say what the packet is doing.
 
| Flag | Meaning |
|------|---------|
| **SYN** | "Hi, I want to start a connection" 👋 |
| **ACK** | "Got it" 👍 |
| **FIN** | "I'm done, closing" 👋 |
| **RST** | "STOP / reset this connection" 🛑 |
| **PUSH** | "Send this immediately" ⚡ |
 
**Normal 3-way handshake:** `SYN` → `SYN-ACK` → `ACK`
 
### Flag references in tcpdump
 
| tcpdump keyword | Flag |
|-----------------|------|
| `tcp-syn` | SYN |
| `tcp-ack` | ACK |
| `tcp-fin` | FIN |
| `tcp-rst` | RST |
| `tcp-push` | PUSH |
 
### Example Filters
 
```bash
# Only the SYN flag set (nothing else)
tcpdump "tcp[tcpflags] == tcp-syn"
 
# At least the SYN flag set (others may be too)
tcpdump "tcp[tcpflags] & tcp-syn != 0"
 
# At least SYN OR ACK set
tcpdump "tcp[tcpflags] & (tcp-syn|tcp-ack) != 0"
 
# Only RST flag set (useful for detecting connection resets / scans)
tcpdump "tcp[tcpflags] == tcp-rst"
```
 
### How to read these
 
- `==` → exact match (only that flag, nothing else)
- `& flag != 0` → that flag is ON (other flags may also be on)
- `|` between flags → OR
### Why this matters for security
 
- Lots of SYNs with no ACKs → **SYN flood attack** (DDoS)
- Weird flag combos (FIN-only, NULL, XMAS) → **port scanning** (Nmap stealth scans)
- Many RSTs → connections being forcibly closed (could indicate scanning)
---
 
## Real-World Examples
 
```bash
# Watch SSH traffic on all interfaces
tcpdump -i any tcp port 22
 
# Capture NTP traffic on WiFi
tcpdump -i wlo1 udp port 123
 
# Capture HTTPS to example.com and save it
tcpdump -i eth0 host example.com and tcp port 443 -w https.pcap
 
# Read first 5 packets from a saved file, numeric only
tcpdump -r traffic.pcap -c 5 -n
 
# Count packets coming FROM a specific IP
tcpdump -r traffic.pcap src host 192.168.124.1 -n | wc -l
 
# Count ICMP packets in a capture file
tcpdump -r traffic.pcap icmp -n | wc -l
 
# Find packets larger than 15000 bytes
tcpdump -r traffic.pcap greater 15000 -n
 
# Inspect HTTP payload in ASCII
tcpdump -r traffic.pcap port 80 -A
```
 
---
 
## Quick Mental Model
 
- **host** → WHO
- **port** → WHICH DOOR
- **protocol** → WHAT LANGUAGE
- **size** → HOW BIG
- **flags** → WHAT'S THE PACKET DOING
- Combine with `and` / `or` / `not` to zoom in
---
 
## Notes
 
- Live captures require **root** privileges (`sudo`).
- Reading from a `.pcap` file does **not** need sudo.
- Use `-n` to avoid slow DNS lookups when you only need IPs.
- Use `man pcap-filter` for the full list of filter expressions.
