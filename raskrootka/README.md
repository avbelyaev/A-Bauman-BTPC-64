**Bootstrap cycle:**


0.Cd to `berowin` on Linux:

    cd /mnt/c/Users/anthony/Documents/Dropbox/berowin && ls -l
    
1.**Compile on Windows:**

    btpc.exe <btpc64copy.pas >btpcnew.exe && btpcnew.exe <testBranch.pas >test
    
1.1 **Check expected result on Windows:**
    
    btpcwin.exe <testBranch.pas >testnorm.exe && type testnorm.exe && testnorm.exe
    
2.**Run on Linux:**
   
    cd . && ./test
    
3.**Pray to the God:**

    God have mercy please!

4.**Iterate:**

    goto 1.

Reassemble stub code:

    gcc -c beronew.s && ld beronew.o -g -o beronew -T linkerScript.ld -nostdlib
