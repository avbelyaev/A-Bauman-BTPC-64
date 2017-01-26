# course-compilers
berotiny pascal porting win32 -> linux64

compile:
gcc -c beronew.s
ld beronew.o -g -o beronewNolib
gdb beronewNolib 

SASM compiler config:
x64 GAS
as -o $PROGRAM.OBJ$ $SOURCE$
ld $PROGRAM.OBJ$ -g -o $PROGRAM$

gas:
(IsEOF) == IsEOF
