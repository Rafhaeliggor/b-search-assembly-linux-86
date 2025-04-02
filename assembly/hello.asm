;hello world.asm

global _start

section .text:

_start:
	mov eax, 0x4
	mov ebx, 1
	mov ecx, message
	mov edx, len
	int 0x80



	mov eax, 0x1
	mov ebx, 0
	int 0x80

section .data:
	message db "Hello", 0xA, "world", 0xA;mensagem + enter
	len equ 6
