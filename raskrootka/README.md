## Bootstrap cycle


0.Cd to `berowin` on Linux:

    cd /mnt/c/Users/anthony/Documents/Dropbox/berowin && ls -l
    
0.1 Reassemble stub code and paste into btpc64copy.pas:

    gcc -c rtl64.s && ld rtl64.o -g -o rtl64 -T linkerScript.ld -nostdlib && ./rtl64    
    
1).**Compile on Windows:**

    btpc.exe <btpc64copy.pas >btpcnew.exe && btpcnew.exe <testFunc.pas >test
    
2).**Run on Linux:**
   
    cd . && ./test
    
3).**Pray to the God:**

    God have mercy please!

4).**Iterate:**

    goto 1.


## Useful commands

replace verbose with custom linker script:

    ld beronew.o -g -o beronew -T linkerScript.ld

remove StdLib (prevents multiple definition of `_start`):

    ld beronew.o -g -o beronew -T linkerScript.ld -nostdlib

remove all symbol info (tables etc.):

    ld beronew.o -g -o beronew -T linkerScript.ld -nostdlib -s
    
Remove ELF sction: `strip -R sectionname rtl64`

Read ELF sections: `readelf -S rtl64`

Read ELF segments: `readelf -l rtl64`

Dump ELF intrails: `hexdump -C rtl64`

SASM x64 GAS compiler config:

     as -o $PROGRAM.OBJ$ $SOURCE$
     ld $PROGRAM.OBJ$ -g -o $PROGRAM$

gas note: `(IsEOF) == IsEOF`

gdb: `gdb rtl64`

    info files
    b *0x4000b0
    run == r
    si 3    //step into
    ni 3    //step over
    x/5i $pc
    x/8g $sp
    info registers == i r
    p $rax
    set $rax = 0x123
    
