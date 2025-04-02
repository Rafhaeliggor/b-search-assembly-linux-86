section .data:
	msg1 db 0xA, "message 1 teste"
	msg1_len equ $ - msg1

	msg2 db 0xA, "message 2 teste"
	msg2_len equ $ - msg2

	msg3 db 0xA, "message 3 teste"
	msg3_len equ $ - msg3

	msg4 db 0xA, "message 4 teste"
	msg4_len equ $ - msg4

section .text:
global _start
_start:
	;msg1
	mov eax, 4
	mov ebx, 1
	mov ecx, msg1
	mov edx, msg1_len
	int 0x80

	;msg2
	mov eax, 4
	mov ebx, 1
	mov ecx, msg2
	mov edx, msg2_len
	int 0x80

	;msg3
	mov eax, 4
	mov ebx, 1
	mov ecx, msg3
	mov edx, msg3_len
	int 0x80

	;msg4
	mov eax, 4
	mov ebx, 1
	mov ecx, msg4
	mov edx, msg4_len
	int 0x80

	;exit
	mov eax, 1
	mov ebx, 0
	int 0x80
