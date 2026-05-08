## SAST

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

2. Dataflow Analysis: These are situations where potentially dangerous functions are in use, but it is not clear whether or not a vulnerability is present by analysing the local context around the function call. Take, for example, a function defined as follows:

3. Control-flow analysis: Analyses the order of operations in the code in search of a race condition, use of uninitialised variables or resource leaks. As an example,
   Stirng cmd = System.gtProperty("cmd");

   cmd = cmd.trm();

   If the cmd property is not defined, the call to System.getProperty() will return NULL. Calling the trim method from a Null variable will throw an exception on runtime.

4. Structural Analysis: Analyses specific code structures of each programming language. This includes following best practices when declaring classes, evaluating code blaocks that may never execute, correctly using try/catch, and other issues related to using insecure cryptographic material.

5. Configuration Analysis: Searches for application configuration flaws rather than the code itself. As an example, applications running under Internet Information Services will 
have a configuration file called web.config, PHP will hold all of its configuration options in a file called php.ini, and most applications will some configuration file. By checking configurations, the tool will identify possible improvements


PSALM: PHP Static Analysis Linting Machine, a simple tool for analysing PHP code. [Psalm Installation Guide](https://psalm.dev/docs/running_psalm/installation/)

**Run the Psalm using the following command from within the project's directroy:**

.vendor/bin/psalm --no-cache

**Psaml also offers the possibility to run dataflow analysis on our code using the --taint-analysis flag.**

./vendor/bin/psalm --no-cache --taint-analysis

We will generally be concerned with the following two things:

1. False Positives: The tool reports on a vulnerability that is not present in the code.

2. False Negatives: The tool does not report on a vulnerability that is present in the code.


Usually, when we make a pull request or a merge request, SAST tools are attached to GitLab or GitHub so every single time we make a pull requst or a merge request, code is being checked for vulnerability and checking pull request ensures that the code that makes it to merges has udergone at least a basic security check but we want SAST tools running on both developer's IDE and CI/CD pipelines.

**Integrating SAST tools in IDE**

- Psalm: The tool we have been using supports IDE integration by installing the psalm into VS code dirextly form the vs code marketplace. This plugin will check anytime you type in real-time and show you the same alerts as the console version directly into your code. Taint analysis won't available.

- Semgrep: Yet another SAST tool that can be installed into VS code directly from vs code marketplace. Just as Psalm, it will show inline alerts directly in your code. Semgrep even allows us to build custom rules if needed. You can check the rules that are loaded for this project on the semgrep-rules directory inside the project's directory.


## File Inclusion Grep - Missing PHP Filter

### Issue
`grep -rn include(` was run without the PHP-only `--include=*.php` filter, increasing noise.
This is a common mistake — the room notes **'Omitting --include filter'**.

### Impact
Noisy include/require hits slow down quick static sweep for file inclusion risks
during code triage for a junior Application Security Engineer.

### Flow
- Ran broad recursive grep for `include(` across the directory
- Re-ran the same broad grep again, then opened `view.php` to inspect hits
