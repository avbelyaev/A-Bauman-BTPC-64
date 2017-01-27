.section .data

LabelByte:
    .byte 0x65

LabelLong:
    .byte 0x37,0x38,0x39,0x65

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

    movq $1, %rax
    andq $80000001, %rax
    
    decq %rax
    incq %rax
    
    #or $-2, %rax
    
    sete %al
    setne %al
    
    setl %al
    setle %al
    
    setg %al
    setge %al
    
    cmpq $1, %rax
    
    xorq %rcx, %rcx
    subq %rcx, %rsp
    
    movq %rsp, %rdi
    
    #add Dword ptr [ESP], byte Value
    pushq %rdx
    xorq %rdx, %rdx
    movb (LabelByte), %dl
    addq %rdx, (%rsp)
    popq %rdx
    
    #add Dword, Dword
    pushq %rdx
    xorq %rdx, %rdx
    movl (LabelLong), %edx
    addq %rdx, (%rsp)
    popq %rdx
    
    #imul eax, byte S
    pushq %rdx
    xorq %rdx, %rdx
    movb (LabelByte), %dl
    
        
    movq    $60, %rax
    movq    $0,  %rdi
    syscall
    