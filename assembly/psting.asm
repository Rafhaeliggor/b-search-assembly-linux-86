section .data:
	arr db "teste", 0xA
	arr_len equ $ - arr
	arr_2 dd 2
section .text:
global _start
_start:
	mov esi, arr
print_loop:
	
	mov eax, 4
	mov ebx, 1
	mov ecx, esi
	mov edx, 1
	int 0x80
	lodsb
	
	mov eax, 1
	xor ebx, ebx
	int 0x80
