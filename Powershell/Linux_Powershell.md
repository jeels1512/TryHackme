**To just know which shell you working in type: echo $SHELL**

**To print all the shells in the system type: cat /etc/shells**

**To change the default shell permanently, you can use the command chsh -s /usr/bin/zsh**

**to display all the commands that we have used previously type: history**

**Unlike the other commands we type in the shell, we first need to create a file using any text editor for the script. The file must be named with an extension .sh, the default extension for bash scripts. The following terminal shows the script file creation:**

ex: nano first_script.sh

**Every script should start from shebang. Shebang is a combination of some characters that are added at the beginning of a script, starting with #! followed by the name of the interpreter to use while executing the script.**

**First, we need to get the access of the file by: chmod +x first_script.sh**

**To execute script: ./first_script.sh**

**Loop Script**

for i in {1..10};

do // To start loop

echo $i

done // To finish loop

**Conditiona Script**

echo "Please enter your name first:"

read name

if [ "$name" = "Stewart" ]; then

        echo "Welcome Stewart! Here is the secret: THM_Script"
        
else

        echo "Sorry! You are not authorized to access the secret."
        
fi //To finish condition.


**To change the user in the linux shell: sudo su**
