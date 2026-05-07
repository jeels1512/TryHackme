**Some of the functions that are typically used to send MySQL queries:**\

Database engine: MySQL

Function: mysqli_query(), mysql_query(), mysqli_prepara(), query() and prepare()

All these functions are sinks because user input falling into sink can become dangerous.

**grep -r -n 'mysqli_query('**

- The -r option tells grep to recursively search all files under the current directory, and the -n option indicates that we want grep to tell
- us the number of the line where the pattern was found. 

SAST complements other techniques, such as Dynamic Application Security Testing or Software Composition Analysis, to provide a holistic approach to application security during the development lifecycle. Just as with any of the other techniques, SAST will have its pros and cons that we need to be aware of:

## Pros: 

- it doesn't require a running instance of the target application

- It provides great courage of the application's functionality.

- It runs fast as opposed to other dynamic techniques.

- SAST tools report exactly where vulnerabilities are in the code.

- Easy to integrate into your CI/CD pipeline.


## Cons:

- The sourse code of an application is not always available.

- Prone to false positives.

- Can't identify vulnerabilities that are dynamic in nature.

- SAST tools are mostly language-specific. They can only check languages they know.


Every SAST tool is different, most of them will perform two tasks:

**Transform the code into an abstract model:**

**Analyse the abstract model for security issues:**

## AST: Abstract Syntax Tree

- Normal Code:
  
  if(user == "admin"){
   login();
}

- AST converts:

  IF statement
 ├── condition: user == "admin"
 └── action: login()


## Different analysis techniques commonly used by SAST tools:

1. Semantic tools: SAST tools automatically search for risky code patterns the same way a human reviewer manually searches for suspicious functions.

2. Dataflow Analysis: These are situations where potentially dangerous functions are in use, but it is not clear whether or not a vulnerability is present by analysing the local context around the function call. Take, for example, a function defined as follow: 
