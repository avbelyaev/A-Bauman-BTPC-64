#==========================================
#------------------data--------------------
#==========================================
.section .data

RTLWriteIntegerBuffer:
    .byte 0x3c,0x3d,0x3e,0x00       #    <=>\0
    .byte 0x3c,0x3d,0x3e,0x00       #    <=>\0
    .byte 0x3c,0x3d,0x3e,0x00       #    <=>\0
         
ReadCharBuffer:
    .byte 0x3d
                  
ReadCharInited: 
    .byte 0
            
IsEOF:
    .byte 0x30

/*
    .set RTLCallHalt, $12
    .set RTLCallWriteChar,      8(%rsi)
    .set RTLCallWriteInteger,   16(%rsi)
    .set RTLCallWriteLn         24(%rsi)
    .set RTLCallReadChar        32(%rsi)
    .set RTLCallReadInteger     40(%rsi)
    .set RTLCallReadLn          48(%rsi)
    .set RTLCallEOF             56(%rsi)
    .set RTLCallEOLN            64(%rsi)   
        */    
RTLFunctionTable:
    .long RTLHalt
    .long RTLWriteChar
    .long RTLWriteInteger
    .long RTLWriteLn
    .long RTLReadChar
    .long RTLReadInteger
    .long RTLReadLn
    .long RTLEOF
    .long RTLEOLN
            
OldStack:
    .byte 0x3c,0x3d,0x3d,0x3d,0x3d,0x3d,0x3e,0x00       # <=====>\0
    #8 bytes because rsp will be stored here

HeapHandle:
    .byte 0x3c,0x3d,0x3d,0x3d,0x3d,0x3d,0x3e,0x00       # <=====>\0
    
HeapMemory:
    .byte 0x3c,0x3d,0x3d,0x3d,0x3d,0x3d,0x3e,0x00       # <=====>\0
            
#==========================================
#-------------------bss--------------------
#==========================================    
.section .bss
   
    .macro pushall
        pushq %rdi
        pushq %rsi
        pushq %rbp
        pushq %rsp
        pushq %rdx
        pushq %rcx
        pushq %rbx
        pushq %rax
        
    .endm
    
    .macro popall
        popq %rax
        popq %rbx
        popq %rcx
        popq %rdx
        popq %rsp
        popq %rbp
        popq %rsi
        popq %rdi
    .endm
    
    .macro parleft
        pushq $'{'
        call RTLWriteChar
        addq $8,    %rsp
    .endm
    
    .macro parright
        pushq $'}'
        call RTLWriteChar
        addq $8,    %rsp
    .endm
    
    .macro space
        pushq $' '
        call RTLWriteChar
        addq $8,    %rsp
    .endm
        
    .macro raxchar
        pushq %rax
        call RTLWriteChar
        addq $8,    %rsp
    .endm
    
    .macro raxint
        pushq %rax
        pushq $1
        call RTLWriteInteger
        addq $16,    %rsp
    .endm
   
#==========================================
#------------------text--------------------
#==========================================
.section .text

.global _start
_start:
    jmp StubEntryPoint

/*
1. X  RTLHalt — остановка программы,
2. X  RTLWriteChar — запись char’а на stdout,
3. X  RTLWriteInteger — запись целого на stdout, принимает два параметра: число и ширину вывода,
4. X  RTLWriteLn — выводит на stdout символ новой строки (13, 10),
5. X  RTLReadChar — считывает символ из stdin, результат кладёт в EAX,
6. X  RTLReadInteger — считывает целое из stdin, результат кладёт в EAX,
7. X  RTLReadLn — пропускает стандартный ввод до конца файла или ближайшего перевода строки,
8. X  RTLEOF — возвращает в EAX число 1, если достигнут конец файла (следующий символ прочитать невозможно) или 0 в противном случае,
9. X  RTLEOLN — возвращает в EAX число 1, если следующий символ \n, 0 — в противном случае.

10.   MMAP - выделить 4МБ 
11.   MUNMAP - очистить
**/
#------------------------------------------
#----------------WriteChar-----------------
#------------------------------------------
RTLWriteChar:
    pushall
    movq    %rsp,   %rbp    #better use base ptr to stack frame
                            #instead of stack itself
    movq    $1,     %rax    #syscall №
    movq    $1,     %rdi    #param1, fd
    movq    %rbp,   %rsi    #p2, buf
    addq    $72,    %rsi    #stack:[0-ret,8-arg1,16-arg2]
    movq    $1,     %rdx    #p3, count

    syscall
    
    popall
    ret 
    
#------------------------------------------
#--------------WriteInteger----------------
#------------------------------------------    
RTLWriteInteger:
    pushq %rbp
    movq %rsp,  %rbp
    
    movq 16(%rbp),  %rbx    #arg: count (stdout width)
    movq 24(%rbp),  %rax    #arg: num
    
    cmpq $0,    %rax
    jnl RTLWriteIntegerNotSigned
        
        negq %rax
        decq %rbx
        pushq $'-'              #dont forget to pop
        call RTLWriteChar 
        addq $8, %rsp           #pop
    
    RTLWriteIntegerNotSigned:
    xorq %rcx,  %rcx
    pushq %rax
    pushq %rbx
    
    RTLWriteIntegerPreCheckLoop:
        testq %rax, %rax
        jz RTLWriteIntegerPreCheckLoopDone
        incq %rcx
        movq $10,   %rbx
        xorq %rdx,  %rdx
        idiv %rbx          
        
        jmp RTLWriteIntegerPreCheckLoop
        
    RTLWriteIntegerPreCheckLoopDone:
    testq %rcx, %rcx
    setz %dl                        #dl: 0 == rcx ? 1 : 0
    orb %dl,    %cl
    
    popq %rbx
    popq %rax
    subq %rcx,  %rbx
    
    cmpq $0,    %rbx
    jle RTLWriteIntegerNotPadding
        pushq %rcx
    
        RTLWriteIntegerPaddingLoop:
            pushq $' '              #pop!
            call RTLWriteChar
            addq $8,    %rsp        #pop
            decq %rbx
        jnz RTLWriteIntegerPaddingLoop
        popq %rcx
    
    RTLWriteIntegerNotPadding:
    #find last digit's address:     
    #we write from right to left cuz each time we divide number by 10, we only know it's right-most digit
    #so we need to write right-most digit into right-most byte:
    
    #e.g: num=-123; count=4
    #init buffer:   |0x3b|0x3d|0x3e|0x00|0x3b|...
    #1st iter:      |0x3b|0x3d| 3d |0x00|0x3b|...
    #2st iter:      |0x3b| 2d | 3d |0x00|0x3b|...
    #3st iter:      | 1d | 2d | 3d |0x00|0x3b|...
    
    movq $RTLWriteIntegerBuffer, %rdi   #leaq RTLWriteIntegerBuffer-1(%rcx), %rdi 
    addq %rcx,  %rdi                    #-||-
    decq %rdi                           #-||-
    #LEA EDI,[OFFSET RTLWriteIntegerBuffer+ECX-1]
    
    pushq %rcx              #we dont care if (count < real_num_width)

    RTLWriteIntegerLoop:
        movq $10,   %rsi
        xorq %rdx,  %rdx
        idiv %rsi
        #convert to string
        movq %rdx,  %rbx    #leaq '0'(%rdx), %rbx equivalent
        addq $'0',  %rbx    #-||-
        
        movb %bl, (%rdi)
        decq %rdi
    loop RTLWriteIntegerLoop
    
    popq %rcx
    
    #invoke WriteFile
    movq $1,    %rax                    #syscall
    movq $1,    %rdi                    #param1, fd
    movq $RTLWriteIntegerBuffer,  %rsi  #p2, buf
    movq %rcx,    %rdx                  #p3, count

    syscall
    
    popq %rbp
    ret
    
#------------------------------------------
#-----------------WriteLn------------------
#------------------------------------------    
RTLWriteLn: 
    pushq   $13
    call    RTLWriteChar
    addq    $8, %rsp
    
    pushq   $10
    call    RTLWriteChar
    addq    $8, %rsp

    ret
   
     
ReadCharEx:
    pushall
    movq    %rsp, %rbp
    
    movq    %rax, %rbx         #copy rax to rbx cuz of rax's usage in syscall
    
    xorq    %rax, %rax          #syscall read(#0)
    xorq    %rdi, %rdi          #p1:stdin(0)
    movq    $ReadCharBuffer, %rsi #p2:buffer
    movq    $1, %rdx            #p3:count
    syscall

    testq   %rbx, %rbx    
    setz    %bl                    #al: 0 == rbx ? 1:0 == rax? 1:0
    orb     %bl, (IsEOF)

    popall
    ret
    
ReadCharInit:
    cmpb    $0, (ReadCharInited)
    jnz     ReadInitDone
    
        call    ReadCharEx
        movb    $1, (ReadCharInited)

    ReadInitDone:
    ret

#------------------------------------------
#----------------ReadChar------------------
#------------------------------------------    
RTLReadChar:
    call    ReadCharInit

    xorq    %rax, %rax
    movb    (ReadCharBuffer), %al    #movzx (ReadCharBuffer), %rax
    #movzx  %al, %rax
    
    call    ReadCharEx

    ret

#------------------------------------------
#--------------ReadInteger-----------------
#------------------------------------------    
RTLReadInteger:
    call ReadCharInit
    
    pushall
    movq %rsp,  %rbp
    
    movq $1, %rcx    #leaq 1(%rax,%rbx=0,1), %rcx  equivalent
    
    ReadIntegerSkipWhiteSpace:
        cmpb $'1',    IsEOF
        jnz ReadIntegerDone
        cmpb $0,    (ReadCharBuffer)
        je ReadIntegerSkipWhiteSpaceDone
        cmpb $32,   (ReadCharBuffer)          #$32=space
        ja ReadIntegerSkipWhiteSpaceDone
        
        call ReadCharEx
        
        jmp ReadIntegerSkipWhiteSpace
        
    ReadIntegerSkipWhiteSpaceDone:
    cmpb $'-',  (ReadCharBuffer)
    jne ReadIntegerNotSigned
        
        negq %rcx
        call ReadCharEx
        
    ReadIntegerNotSigned:
    ReadIntegerLoop:
        xorq %rbx, %rbx
        movb (ReadCharBuffer),  %bl
        
        cmpb $'0',  %bl 
        jb ReadIntegerDone
        cmpb $'9',  %bl
        ja ReadIntegerDone
        
        imul $10,   %rax            #rax *= 10
        #cast string to int:
        subq $'0',  %rbx            #lea -'0'(%rax,%rbx,1),  %rax
        addq %rbx,  %rax            #-||-
        
        call ReadCharEx
        jmp ReadIntegerLoop
    
    ReadIntegerDone:
    imul %rcx               #rax *= rcx  (rcx={1;-1})
    
    movq %rax, (%rsp)
    
    popall
    ret

#------------------------------------------
#------------------ReadLn------------------
#------------------------------------------        
RTLReadLn:
    call ReadCharInit
    
    parleft
    xor     %rbx, %rbx
    movb    (ReadCharBuffer), %bl
    pushq   %rbx
    pushq   $1
    call    RTLWriteInteger
    addq    $16, %rsp
    
    space
    
    movb    (IsEOF), %bl
    pushq   %rbx
    call    RTLWriteChar
    addq    $8, %rsp
    parright
    
    
    cmpb    $'1', (IsEOF)
    jne     ReadLnDone
    
        movb    (ReadCharBuffer), %bl    
        cmpb    $10, %bl                 #cmp to LF
        je      ReadLnDone
    
    call    ReadCharEx
    jmp     RTLReadLn
    
    ReadLnDone:
    ret

#------------------------------------------
#-------------------EOF--------------------
#------------------------------------------         
RTLEOF:
    xorq    %rax, %rax

    cmpb    $'1', (IsEOF)
    jne     noteof
        movq    $1, %rax
        ret
    
    noteof:
    movq    $0, %rax
    ret

#------------------------------------------
#------------------EOLN--------------------
#------------------------------------------    
RTLEOLN:
    cmpb    $10, (ReadCharBuffer)
    sete    %dl
    ret

#------------------------------------------
#------------------Halt--------------------
#------------------------------------------        
RTLHalt:
    #unmap
    movq    $60, %rax
    movq    $0,  %rdi
    syscall


#------------------------------------------#
#-                 Tests                  -#
#------------------------------------------#
Test1:
    #test 1: ReadInt, WriteChar, WriteInt, WriteLine
    #test input(-1337 + space): "-1337 "
    call RTLReadInteger

    pushq %rax
    pushq $5
    call RTLWriteInteger
    addq $16, %rsp
    
    space

    pushq $-123
    pushq $6
    call RTLWriteInteger   
    addq $16, %rsp
    call RTLWriteLn

    pushq $'A'
    call RTLWriteChar  
    addq $8,    %rsp
    call RTLWriteLn
    
    call RTLHalt
    
Test2:
    #test 2: ReadChar, EndOfLine, EndOfFile, WriteInt
    #test input(B + linebreak): "B\n"
    call RTLReadChar
    parleft
    raxchar
    raxint
    parright
    
    xorq %rdx, %rdx
    call RTLEOLN
    parleft
    pushq %rdx
    pushq $4
    call RTLWriteInteger
    addq $16, %rsp
    parright
    
    call RTLEOF
    parleft
    raxchar
    raxint
    parright
    
    call RTLHalt

#//==----------------------------------==//
#//----------------ENTRY-----------------//
#//==----------------------------------==//
StubEntryPoint:

    call RTLReadLn
    
    call RTLReadChar
    raxchar
    space
    raxint

    call RTLEOF
    parleft
    raxint
    parright
    
    #call Prepare
    
    call RTLHalt
    
    
#------------------------------------------
#------------Preapare to start-------------
#------------------------------------------    
Prepare:
    movq    %rsp, (OldStack)
    #allocate 4Mb mmap
    #set heapHandle
    #set heapMemory
    addq    $4194304, %rax
    #movq    %rax, %rsp     ???
    #movq    %rsp, %rbp
    movq    $RTLFunctionTable, %rsi

ProgramEntryPoint:
    call RTLHalt
    