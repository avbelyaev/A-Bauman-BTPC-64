stack_size = 4194332;
heap_size = 256;

ENTRY(_start)

PHDRS
{
   headers PT_PHDR PHDRS ;
   data PT_LOAD ;
   rodata PT_LOAD ;
   bss PT_LOAD ;
   text PT_LOAD ;
}

SECTIONS 
{ 
	. = 0x200000;
  	.data :  
  	{ 
  		*(.data) 
  		*(COMMON) 
  	}  :data

  	.bss :
  	{
  		*(.bss)
  	} :bss

	.text : 
	{ 
		*(.text) 
	} :text
} 
