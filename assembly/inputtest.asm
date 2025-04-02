section .data
    ; Prompts
    prompt db "Enter a number: "
    prompt_len equ $ - prompt

    ; Output message
    output db "This was the input: "
    output_len equ $ - output

    newline db 0xA  ; new line character

section .bss
    buffer resb 32  ; Input buffer (32 bytes)

section .text
global _start
_start:
    ; 1. Print prompt
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; 2. Read input
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    mov ecx, buffer
    mov edx, 32
    int 0x80

    ; Save input length
    mov esi, eax

    ; 3. Print output message
    mov eax, 4
    mov ebx, 1
    mov ecx, output
    mov edx, output_len
    int 0x80

    ; 4. Print input number
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, esi
    int 0x80

    ; 5. Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
