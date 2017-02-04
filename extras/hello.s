.data
    msg: .asciz "hallo\n"

.text
.global _start

_start:
    movl $4, %eax   # use the write syscall
    movl $1, %ebx   # write to stdout
    movl $msg, %ecx # use string "Hello World"
    movl $12, %edx  #write 12 characters
    int $0x80       # make syscall
    
    movl $1, %eax   # use the _exit syscall
    movl $0, %ebx   # error code 0
    int $0x80       # make syscall
    ret

