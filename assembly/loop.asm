section .data
    message db 'Hello', 0

section .text
global _start
_start:
    mov ecx, message  ; Pointer to string
    mov edx, 0        ; Counter

print_loop:
    mov al, [ecx + edx]  ; Load next character
    cmp al, 0            ; Check for null terminator
    je exit              ; If null, exit loop
    ; (Print the character here, e.g., via syscall)
    inc edx              ; Move to next character
    jmp print_loop

exit:
    mov eax, 1           ; sys_exit
    int 0x80
