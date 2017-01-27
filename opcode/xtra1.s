.section .data

LabelByte:
    .byte 0x65

LabelDword:
    .long 0x37,0x38,0x39,0x65,0x0

.section .text

.global _start
_start:
    jmp Entry
    #movq $LabelByte, %rax
    #pushq (%rax)
    #pushq (%rsp)

    #pushb
    #xorq %rax, %rax
    #movb (LabelByte), %al
    #pushq %rax

Entry:

    #movzx %al, %rax

    #movq %rax, (%rbx)
    #movq %rax, (%rsp)

    #lea
    #xorq %rax, %rax
    #movb (LabelByte), %al
    #addq %rbp, %rax
    
    movq $1, %rcx
    imul %rbx
        
    xorq %rdx, %rdx
    
    movq $10, %rax
    movq $5, %rbx
    idiv %rbx
    
    cmpq %rbx, %rax
    
    xchgq %rsi, %rdx
    
    cld #should be 0xFC
    
    movq $3, %rcx
    #rep movsb
    
    testq %rax, %rax
    
    pushq %rcx
    negq (%rsp)
    popq %rcx
    
    movq $LabelByte, %rbx
    movq $2, %rax
    cmpq %rax, (%rbx)

    pushq $1337
    addq %rax, (%rsp)
    sarq $1, (%rsp)
    addq $8, %rsp
        
    
        
    movq    $60, %rax
    movq    $0,  %rdi
    syscall
    