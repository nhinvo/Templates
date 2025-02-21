# BASH/COMMAND-LINE

## Common Useful Commands
**Storage**
- How much storage is left in the current directory:   
  - `df -h .`  
- How much storage in each subdirectories: 
  - `du -sh <dirname/>`  
    -s=summary; -h=human readable

**Checking files**
- See if files are identical:  
  - `cmp --silent <file1> <file2> || echo "files are different"`   
- See what file system directories/files are in:  
  - `df -P </path/file1> </path/file2> <etc>`  

## Bash variables
**Assigning & using variables**   
- `myvar=”Text”`
  - → using: `$myvar` (easier to write) or `${myvar}` (more correct)  
  - Brackets are better - helps bash understand which part is the variable 
  - Example:  
    - `name=”Nhi”` 
    - `echo “this is ${name}s lunch.”` → stdout: This is Nhis lunch. 
    - `echo “this is $names lunch.”` → stdout: This is  lunch.   
      - `names` is not a variable 

**Run command & capture output**
- Running commands and capture output in variable: enclose in $( ) or `` 
  - `$( )`  is better to use because it is more explicit; ` symbol is very small, can be confused with ‘ (quotation)

