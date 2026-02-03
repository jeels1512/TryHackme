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

