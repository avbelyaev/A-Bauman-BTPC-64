#==========================================
#------------------data--------------------
#==========================================
.section .data

RTLWriteIntegerBuffer:              #literally
    .byte 0x3c,0x57,0x72
    .byte 0x69,0x74,0x65,0x49,0x6e
    .byte 0x74,0x65,0x67,0x65,0x72
    .byte 0x42,0x75,0x66,0x66,0x65
    .byte 0x72,0x3e
         
ReadCharBuffer:
    .byte 0x40
                  
ReadCharInited: 
    .byte 0
            
IsEOF:
    .byte 0
  
RTLFunctionTable:
    .quad RTLHalt
    .quad RTLWriteChar
    .quad RTLWriteInteger
    .quad RTLWriteLn
    .quad RTLReadChar
    .quad RTLReadInteger
    .quad RTLReadLn
    .quad RTLEOF
    .quad RTLEOLN
            
OldStack:                           #literally
    .byte 0x4f,0x6c,0x64,0x53
    .byte 0x74,0x61,0x63,0x6b
      
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
    .endm
    
    .macro parright
        pushq $'}'
        call RTLWriteChar
    .endm
    
    .macro space
        pushq $' '
        call RTLWriteChar
    .endm
        
    .macro raxchar
        pushq %rax
        call RTLWriteChar
    .endm
    
    .macro raxint
        pushq %rax
        pushq $1
        call RTLWriteInteger
        addq $16, %rsp
    .endm
   
#==========================================
#------------------text--------------------
#==========================================
.section .text

.global _start
_start:
    jmp StubEntryPoint

/*
1. X  RTLHalt           — остановка программы,
2. X  RTLWriteChar      — запись char’а на stdout,
3. X  RTLWriteInteger   — запись целого на stdout, принимает два параметра: число и ширину вывода,
4. X  RTLWriteLn        — выводит на stdout символ новой строки (13, 10),
5. X  RTLReadChar       — считывает символ из stdin, результат кладёт в EAX,
6. X  RTLReadInteger    — считывает целое из stdin, результат кладёт в EAX,
7. X  RTLReadLn         — пропускает стандартный ввод до конца файла или ближайшего перевода строки,
8. X  RTLEOF            — возвращает в EAX число 1, если достигнут конец файла (следующий символ прочитать невозможно) или 0 в противном случае,
9. X  RTLEOLN           — возвращает в EAX число 1, если следующий символ \n, 0 — в противном случае.
**/
#------------------------------------------
#----------------WriteChar-----------------
#------------------------------------------
RTLWriteChar:
    pushall
    movq    %rsp,   %rbp    #make stack frame
                            
    movq    $1,     %rax    #syscall #1 == Write();
    movq    $1,     %rdi    #param1 == write_to == 1 == stdout

    movq    %rbp,   %rsi    #p2 == write_from == %rbp == top_of_stack
    addq    $72,    %rsi    #reach top of stack:[0-ret,8-arg1,16-arg2]
                            #we have all regs pushed so top is really really far
    
    movq    $1,     %rdx    #p3 == count == single_byte

    syscall
    
    popall
    ret     $8
    
#------------------------------------------
#--------------WriteInteger----------------
#------------------------------------------    
RTLWriteInteger:
    pushq %rsi
    #pushq %rbp
    #movq %rsp,  %rbp
    
    movq 16(%rsp),  %rbx    #arg: count (stdout width). we do NOT care if it == 1
    movq 24(%rsp),  %rax    #arg: num
    
    cmpq $0,    %rax
    jnl RTLWriteIntegerNotSigned

        negq %rax
        decq %rbx
        pushq $'-'
        call RTLWriteChar 

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
    setz %dl                    #dl: (0 == rcx) ? 1 : 0
    orb %dl,    %cl
    
    popq %rbx
    popq %rax
    subq %rcx,  %rbx
    
    cmpq $0,    %rbx
    jle RTLWriteIntegerNotPadding
        pushq %rcx
    
        RTLWriteIntegerPaddingLoop:
            pushq $' '
            call RTLWriteChar
            decq %rbx
        jnz RTLWriteIntegerPaddingLoop
        popq %rcx
    
    RTLWriteIntegerNotPadding:
    #find last digit's address:     
    #we write from right to left cuz each time we divide number by 10, we only know it's right-most digit
    #so we need to write right-most digit into right-most byte:
    
    #e.g: num=-123; count=4
    #               |  < |  = |  > |    |  < |... 
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
        movq %rdx,  %rbx    # ~= lea '0'(%rdx), %rbx
        addq $'0',  %rbx    
        
        movb %bl, (%rdi)
        decq %rdi
    loop RTLWriteIntegerLoop
    
    popq %rcx
    
    #invoke WriteFile (look at WriteChar)
    #pushall
    movq $1,    %rax                    #syscall
    movq $1,    %rdi                    #param1, fd
    movq $RTLWriteIntegerBuffer,  %rsi  #p2, buf
    movq %rcx,  %rdx                    #p3, count

    syscall
    #popall

    
    #popq %rbp
    pop %rsi
    ret
    
#------------------------------------------
#-----------------WriteLn------------------
#------------------------------------------    
RTLWriteLn: 
    pushq   $13             #13 == 0xD == CR
    call    RTLWriteChar
    #addq    $8, %rsp
    
    pushq   $10             #10 == 0xA == LF
    call    RTLWriteChar
    #addq    $8, %rsp

    ret
   
     



ReadCharEx:
    pushall
    movq    %rsp, %rbp
    
    movq    %rax, %rbx              #copy to %rbx cuz %rax will be used for syscall
    
    xorq    %rax, %rax              #syscall #0 == Read();
    xorq    %rdi, %rdi              #p1 == read_from == 0 == stdin
    movq    $ReadCharBuffer, %rsi   #p2 == write_to == buffer
    movq    $1, %rdx                #p3 == count == single_byte
    syscall

    #test against value read on prev. step 
    #beware of empty %rbx if ReadCharEx is the first function to be called
    testq   %rbx, %rbx    
    setz    %bl                     #al: (0 == rbx) ? 1:0
    orb     %bl, (IsEOF)

    #test against num of bytes that were actually read
    cmpq    $0, %rax
    setz    %bl                     #bl: (0 == bytes_read) ? 1:0
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
    movb    (ReadCharBuffer), %al    # == movzxbl (ReadCharBuffer), %rax
    
    call    ReadCharEx

    ret

#------------------------------------------
#--------------ReadInteger-----------------
#------------------------------------------    
RTLReadInteger:
    call ReadCharInit
    
    pushall
    movq %rsp,  %rbp
    
    lea 1(%rax), %rcx
    
    ReadIntegerSkipWhiteSpace:
        cmpb $1,    (IsEOF)                 #cmp with $1 and it works. no idea why {!}
        jnz ReadIntegerDone
        cmpb $0,    (ReadCharBuffer)
        je ReadIntegerSkipWhiteSpaceDone
        cmpb $32,   (ReadCharBuffer)        #32d == 0x20 == space
        ja ReadIntegerSkipWhiteSpaceDone
        
        call ReadCharEx
        
        jmp ReadIntegerSkipWhiteSpace
        
    ReadIntegerSkipWhiteSpaceDone:
    cmpb $'-',  (ReadCharBuffer)
    jne ReadIntegerNotSigned
        
        negq %rcx                   #rcx stores -1 or 1 and will multiply the result
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
        subq $'0',  %rbx            # == lea -'0'(%rax,%rbx,1),  %rax
        addq %rbx,  %rax            
        
        call ReadCharEx
        jmp ReadIntegerLoop
    
    ReadIntegerDone:
    imul %rcx               #rax *= rcx  (rcx={1;-1})
    
    movq %rax, (%rsp)       #rax is on top of stack (look at pushall())
    
    popall
    ret

#------------------------------------------
#------------------ReadLn------------------
#------------------------------------------  
#it does NOT skip input if %RAX is nulled
#so put there some trash before calling it
#------------------------------------------   
RTLReadLn:
    call ReadCharInit
    
    cmpb    $0, (IsEOF)
    jne     ReadLnDone
      
        movb (ReadCharBuffer), %bl
        cmpb    $10, %bl  #cmp to LF
        jne      ReadLnDone
    
            call    ReadCharEx
            jmp     RTLReadLn
    
    ReadLnDone:
    ret

#------------------------------------------
#-------------------EOF--------------------
#------------------------------------------         
RTLEOF:
    xorq    %rax, %rax
    movb    (IsEOF), %al
    ret

#------------------------------------------
#------------------EOLN--------------------
#------------------------------------------    
RTLEOLN:
    cmpb    $10, (ReadCharBuffer)       #cmp to LF
    sete    %dl                         #bero's legacy
    ret

#------------------------------------------
#------------------Halt--------------------
#------------------------------------------        
RTLHalt:
    movq    $60, %rax                   #syscall #60d == Exit()
    movq    $0,  %rdi                   #exit process state
    syscall


#------------------------------------------#
#-                 Tests                  -#
#------------------------------------------#
Test1:
    #test 1: ReadInt, WriteChar, WriteInt, WriteLine
    #test input(-1337 + space): "-1337 "

    #expected: 
    #%entered_num%- 1234
    #A

    call RTLReadInteger
    call RTLReadLn

    pushq %rax
    pushq $1
    call RTLWriteInteger
    addq $16, %rsp
    
    #space

    pushq $-1234
    pushq $6
    call RTLWriteInteger   
    addq $16, %rsp
    call RTLWriteLn

    pushq $'A'
    call RTLWriteChar  
    call RTLWriteLn
    
    ret
    call RTLHalt
    
Test2:
    #test 2: ReadChar, EndOfLine, EndOfFile, WriteInt
    #test input(B + linebreak): "B\n"

    #expected
    #{B66}{10}{1}{*1}

    call RTLReadChar
    parleft
    raxchar                     #should be "B"
    raxint                      #should be 66(B)
    parright
    
    #
    parleft
    xorq %rax, %rax
    movb (ReadCharBuffer), %al #should be 10 == LF
    raxint
    parright
    #
    
    xorq %rdx, %rdx
    call RTLEOLN
    parleft
    pushq %rdx
    pushq $1
    call RTLWriteInteger        #should be 1 cuz of linebreak
    addq $16, %rsp
    parright
    

    call RTLEOF
    parleft
    raxchar
    raxint
    parright
    
    call RTLHalt

Test3:
    #test3: ReadLn, ReadChar
    #test input(linebreak + A):"\nA" 

    #expected
    #{A 65}
    
#put smth into %rax in case IsEOF wont be triggered after first char
    movq $1, %rax   
    call RTLReadLn
    
    call RTLReadChar
    parleft
    raxchar             #should be "A"
    space
    raxint              #should be 65(A)
    parright
    
    call RTLHalt
    
#//==----------------------------------==//
#//----------------ENTRY-----------------//
#//==----------------------------------==//
#call some tests here or post introduction
#------------------------------------------
StubEntryPoint:

    pushq $'X'
    call RTLWriteChar
    call RTLWriteLn
    
#------------------------------------------
#------------Preapare to start-------------
#------------------------------------------    
#dont need to allocate(prepare) stack pages:
#http://stackoverflow.com/questions/31328349/stack-memory-management-in-linux
#------------------------------------------

    movq %rsp, %rbp                 #bero's legacy
    movq $RTLFunctionTable, %rsi    #store functionTable and don't change %rsi
    
ProgramEntryPoint:
    
Simulation:
    
#------------------------------------------
#code generated by btpc.dpr goes here

