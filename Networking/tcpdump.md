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

  

