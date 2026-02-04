Get-content: grep/text

Set-location: cd 

For example, if we want to display only the available commands of type “function”, we can use -CommandType "Function", as shown below:

PS C:\Users\captain> Get-Command -CommandType "Function"


### Get-Command Output (What Matters)

| CommandType | Example Name | What it means |
|------------|--------------|---------------|
| Function | `Add-DnsClientDohServerAddress` | PowerShell function loaded in session |
| Cmdlet | `Get-Content` | Compiled PowerShell command |
| Alias | `cd` | Shortcut for a cmdlet |


**To make the transition easier for IT professionals, PowerShell includes aliases —which are shortcuts or alternative names for cmdlets— for many traditional Windows commands. Indispensable for users already familiar with other command-line tools, Get-Alias**

**dir/ls is an alias for Get-ChildItem.**

To search for modules (collections of cmdlets) in online repositories like the PowerShell Gallery, we can use Find-Module. Sometimes, if we don’t know the exact name of the module, it can be useful to search for modules with a similar name. We can achieve this by filtering the Name property and appending a wildcard (*) to the module’s partial name, using the following standard PowerShell syntax: Cmdlet -Property "pattern*".

For example, Find-Module -Name "PowerShell*"  

**To create an item in PowerShell, we can use New-Item. We will need to specify the path of the item and its type (whether it is a file or a directory) -> mkdir/touch**

ex: New-Item -Path ".\captain-cabin\captain-wardrobe" -ItemType "Directory"

**Similarly, the Remove-Item cmdlet removes both directories and files, whereas in Windows CLI we have separate commands rmdir and del.**

EX:  Remove-Item -Path ".\captain-cabin\captain-wardrobe\captain-boots.txt"

Remove-Item -Path ".\captain-cabin\captain-wardrobe" 


**We can copy or move files and directories alike, using respectively Copy-Item (equivalent to copy) and Move-Item (equivalent to move).**

**Finally, to read and display the contents of a file, we can use the Get-Content cmdlet, which works similarly to the type command in Command Prompt (or cat in Unix-like systems).**


**Here, Get-ChildItem retrieves the files (as objects), and the pipe (|) sends those file objects to Sort-Object, which then sorts them by their Length (size) property. This object-based approach allows for more detailed and flexible command sequences.**

EX: Get-ChildItem | Sort-Object Length

**To filter objects based on specified conditions, returning only those that meet the criteria, we can use the Where-Object cmdlet. For instance, to list only .txt files in a directory, we can use:**

EX: get-childitem | where-object -Property "Extention" -eq ".txt"


## PowerShell Comparison Operators

| Operator | Meaning | Comparison Type | Includes Equal? | Example |
|----------|--------|-----------------|-----------------|---------|
| `-eq` | Equal to | Equality | Yes | `$a -eq 10` |
| `-ne` | Not equal to | Inequality | No | `$a -ne 10` |
| `-gt` | Greater than | Strict | No | `$a -gt 10` |
| `-ge` | Greater than or equal to | Non-strict | Yes | `$a -ge 10` |
| `-lt` | Less than | Strict | No | `$a -lt 10` |
| `-le` | Less than or equal to | Non-strict | Yes | `$a -le 10` |


**The next filtering cmdlet, Select-Object, is used to select specific properties from objects or limit the number of objects returned. It’s useful for refining the output to show only the details one needs.**

ex: get-childtem | sort-object name,length


**The last in this set of filtering cmdlets is Select-String. This cmdlet searches for text patterns within files, similar to grep in Unix-based systems or findstr in Windows Command Prompt. It’s commonly used for finding specific content within log files or documents.**

EX: Select-stirng -path ".\captain-hat.txt" -pattern "hat"


**The Get-ComputerInfo cmdlet retrieves comprehensive system information, including operating system information, hardware specifications, BIOS details, and more. It provides a snapshot of the entire system configuration in a single command. Its traditional counterpart systeminfo retrieves only a small set of the same details.**

**Essential for managing user accounts and understanding the machine’s security configuration, Get-LocalUser lists all the local user accounts on the system. The default output displays, for each user, username, account status, and description.**

**Similar to the traditional ipconfig command, the following two cmdlets can be used to retrieve detailed information about the system’s network configuration.

Get-NetIPConfiguration provides detailed information about the network interfaces on the system, including IP addresses, DNS servers, and gateway configurati
**

**In case we need specific details about the IP addresses assigned to the network interfaces, the Get-NetIPAddress cmdlet will show details for all IP addresses configured on the system, including those that are not currently active.**

**Get-Process provides a detailed view of all currently running processes, including CPU and memory usage, making it a powerful tool for monitoring and troubleshooting.**

**Get-Service allows the retrieval of information about the status of services on the machine, such as which services are running, stopped, or paused. It is used extensively in troubleshooting by system administrators, but also by forensics analysts hunting for anomalous services installed on the system.**

**we are going to mention Get-FileHash as a useful cmdlet for generating file hashes, which is particularly valuable in incident response, threat hunting, and malware analysis, as it helps verify file integrity and detect potential tampering.**


** ------------- Example 1: Run a script on a server -------------**
    
    Invoke-Command -FilePath c:\scripts\test.ps1 -ComputerName Server01
    
    The FilePath parameter specifies a script that is located on the local computer. The script runs on the remote computer and the results are returned to the local computer.

    --------- Example 2: Run a command on a remote server ---------

    Invoke-Command -ComputerName Server01 -Credential Domain01\User01 -ScriptBlock { Get-Culture }
    The ComputerName parameter specifies the name of the remote computer. The Credential parameter is used to run the command in the security context of Domain01\User01, a user who has permission to run commands. The ScriptBlock parameter specifies the command to be run on the remote computer.











