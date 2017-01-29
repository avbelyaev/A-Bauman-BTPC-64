
stack_size = 4194332;
heap_size = 256;

ENTRY(_start)

SECTIONS 
{ 
	. = 0x4000b0;
  	.data : { *(.data) }

  	.bss :  { *(.bss)  *(COMMON) }  
	
	. = 0x6000d3;
	.text : { *(.text) }
} 
