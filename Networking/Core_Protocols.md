**DNS**

**"nslookup" is the command that is helpful to get the IP addresses of example.com any website.**

**When we want to know the information about any domain, like tryhackme.com, there is a command called whois.
By this command, we can get all the information about that particular entity, such as registering a domain name, 
including name, phone number, email, and address.**

HTTP is designed to retrieve web pages, File Transfer Protocol(FTP) is designed to transfer files. 

ftp IP address to connect to the remote FTP server using the local ftp client. This protocol works on port 21.

**STMP: Sending Email**

Simple Mail Transfer Protocol is helpful for sending emails on the server. This protocol works on TCP port 25.

HELO or EHLO initiates an SMTP session,

MAIL FROM specifies the sender’s email address,

RCPT TO specifies the recipient’s email address,

DATA indicates that the client will begin sending the content of the email message,

. is sent on a line by itself to indicate the end of the email message

POP3: Reciving Email: This protocol works on TCP 110 port. 

some common commands: 

USER <username> identifies the user

PASS <password> provides the user’s password

STAT requests the number of messages and total size

LIST lists all messages and their sizes

RETR <message_number> retrieves the specified message

DELE <message_number> marks a message for deletion

QUIT ends the POP3 session applying changes, such as deletions

