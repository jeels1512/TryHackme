## NMAP

Nmap uses multiple way to specify its target:

**namp -sn <IP_ADD>:** command is useful to discover live hosts on the network.

nmap offers list scan with the option -sL, this scan only lists the targets to scan without actually scanning them


#### Port Scanning:

- -sT: TCP connect scan = complete three way hand-shake
- -sS: TCP SYN = only first step of the three way hand-shake
- -sU: UDP connect scan
- -F: Fast mode
- -p[range]: specific range of port numbers

  
