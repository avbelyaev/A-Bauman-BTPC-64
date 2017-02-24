**Bootstrap cycle:**


0.Cd to `berowin` on Linux:

    cd /mnt/c/Users/anthony/Documents/Dropbox/berowin && ls -l
    
0.1 Reassemble stub code and paste into btpc64copy.pas:

    gcc -c rtl64.s && ld 64.o -g -o rtl64 -T linkerScript.ld -nostdlib && ./rtl64    
    
1).**Compile on Windows:**

    btpc.exe <btpc64copy.pas >btpcnew.exe && btpcnew.exe <testFunc.pas >test
    
1.1).**Check expected result on Windows:**
    
    btpcwin.exe <testFunc.pas >testnorm.exe && type testnorm.exe && testnorm.exe
    
2).**Run on Linux:**
   
    cd . && ./test
    
3).**Pray to the God:**

    God have mercy please!

4).**Iterate:**

    goto 1.


