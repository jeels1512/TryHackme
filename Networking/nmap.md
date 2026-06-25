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


#### Version detection:

- you can enable OS detection by adding the -O option. As the name implies, the OS detection triggers Nmap to rely on various indicators to make an educated guess about the target OS.

- **Commands:** nmap -O <target_machine_IP>
- **Service and version detection:** namp -sV -O <target_machine_IP>
- **OS Detection, version detection and other additions:** namp -A <taget_machine_IP>


#### Nmap to work fast:

There are several options that Nmap has, to make scan fast, There are 5 timings: -T<0-5>

-T0: Paranoid

-T1: Sneaky

-T2: Polite

-T3: Normal

-T4: Aggressive

- One more helpful option is the number of parallel service probes. The number od parallel can be controlled with --min-parallelism <numprobes> and --max-parallelism <numprobes>


-A similar helpful option is the --min-rate <number> and --max-rate <number>. As the names indicate, they can control the minimum and maximum rates at which nmap sends packets. The rate is provided as the number of packets per second. It is worth mentioning that the specified rate applies to the whole scan and not to a single host.

- The last option we will cover in this task is --host-timeout <time>. This option specifies the maximum time you are willing to wait, and it is suitable for slow hosts or hosts with slow network connections.
  
#### Verbosity and Debugging

- In some cases, the scan takes a long way to finish or to produce any output that will be displayed on the screen, Furthermore, sometimes you might be interested in more real-time information about the scan progress. The best way to get more updates about what is happening is to enable verbose output by adding the -v.

- If all this verbosity does not satisfy your needs, you must consider the -d for debugging-level output. Similarly, you can increase the debugging level by adding one more d

**Saving and Scan Report:**

- in many cases, we would need to save the scan result. Nmap gives us various formats. The three most useful are normal output, XML output and grepable output, in reference to the grep command.

- -oN <filename>: Normal Output

- -oX <filename>: XML output

- -oG <filename>: grep-able output

- oA <filename>: Output in all formats
  
