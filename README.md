# course-compilers
bero tiny pascal porting win32 -> linux64

compile and basic link:

     gcc -c beronew.s
     ld beronew.o -g -o beronew

linker script:

    ld beronew.o -g -o beronew -T linkerScript.ld

remove StdLib (prevents multiple definition of `_start`): (Currently using):

    ld beronew.o -g -o beronew -T linkerScript.ld -nostdlib

remove all symbol info (tables etc.):

    ld beronew.o -g -o beronew -T linkerScript.ld -nostdlib -s
    
Remove ELF sction: `strip -R sectionname beronew`

Read ELF sections: `readelf -S beronew`

Read ELF segments: `readelf -l beronew`

Dump ELF intrails: `hexdump -C beronew`

SASM x64 GAS compiler config:

     as -o $PROGRAM.OBJ$ $SOURCE$
     ld $PROGRAM.OBJ$ -g -o $PROGRAM$

gas: `(IsEOF) == IsEOF`

gdb: `gdb beronewNolib `

    info files
    b *0x4000b0
    run == r
    si 3
    ni 3
    x/5i $pc
    x/8g $sp
    info registers == i r
    p $rax
    set $rax = 0x123
    
btpc64 annotations:
    
    {=} - remained same
    {-} - not used.
    {ab} - successfully changed
    {?} - not yet done. need to think
    {!} - mistake in original code / commentary
    {new} - newly created func/proc/var/etc
    {*} - point of interest. possible mistake
