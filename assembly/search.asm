section .data
    prompt db "Enter a number (empty to quit): ", 0xA
    prompt_len equ $ - prompt
    numbers times 256 dd 0
    summary db "All numbers entered: [", 0
    summary_len equ $ - summary
    number_str db "     ", 0
    input_wait db "> ", 0
    input_wait_len equ $ - input_wait
    ending_output db "]", 0xA
    ending_output_len equ $ - ending_output
    comma db ", ", 0
    first_msg db "First item: ", 0
    first_msg_len equ $ - first_msg
    middle_msg db "Middle item: ", 0
    middle_msg_len equ $ - middle_msg
    last_msg db "Last item: ", 0
    last_msg_len equ $ - last_msg
    newline db 0xA

section .bss
    buffer resb 32

section .text
global _start
_start:
    mov edi, numbers
    mov ebp, 0

    ; Print prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

input_loop:
    ; output >
    mov eax, 4
    mov ebx, 1
    mov ecx, input_wait
    mov edx, input_wait_len
    int 0x80

    ; Read input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31
    int 0x80

    ; Check for empty input
    cmp eax, 1
    jle bubble_sort

    ; Null-terminate the input
    mov byte [buffer + eax - 1], 0

    ; Convert ASCII to integer
    xor eax, eax
    xor ecx, ecx
    mov esi, buffer
convert_loop:
    lodsb
    test al, al
    jz store_number
    cmp al, '0'
    jb invalid_input
    cmp al, '9'
    ja invalid_input
    sub al, '0'
    imul ecx, 10
    add ecx, eax
    jmp convert_loop

invalid_input:
    jmp input_loop

store_number:
    mov [edi], ecx
    add edi, 4
    inc ebp
    jmp input_loop

bubble_sort:
    cmp ebp, 1
    jle show_summary

    mov ecx, ebp
    dec ecx

outer_loop:
    push ecx
    mov esi, numbers
    xor edx, edx

inner_loop:
    mov eax, [esi]
    mov ebx, [esi+4]
    cmp eax, ebx
    jle no_swap

    ; Swap
    mov [esi], ebx
    mov [esi+4], eax

no_swap:
    add esi, 4
    inc edx
    cmp edx, ecx
    jl inner_loop

    pop ecx
    loop outer_loop

show_summary:
    ; Print summary header
    mov eax, 4
    mov ebx, 1
    mov ecx, summary
    mov edx, summary_len
    int 0x80

    ; Save original count
    push ebp

    ; Setup to print all numbers
    mov esi, numbers
    mov ecx, ebp
    test ecx, ecx
    jz print_special_items

print_loop:
    ; Convert number to ASCII
    mov eax, [esi]
    mov edi, number_str + 4
    mov ebx, 10

convert_to_ascii:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz convert_to_ascii

    ; Calculate string length
    lea edx, [number_str + 5]
    sub edx, edi

    ; Print the number
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi + 1]
    int 0x80

    ; Print comma (except for last number)
    dec ebp
    jz no_comma

    ; Print comma
    push esi
    push ebp
    mov eax, 4
    mov ebx, 1
    mov ecx, comma
    mov edx, 2
    int 0x80
    pop ebp
    pop esi

no_comma:
    add esi, 4
    test ebp, ebp
    jnz print_loop

    ; Print ending bracket
    mov eax, 4
    mov ebx, 1
    mov ecx, ending_output
    mov edx, ending_output_len
    int 0x80

print_special_items:
    ; Restore original count
    pop ebp

    ; Check if we have any numbers
    cmp ebp, 0
    je exit_loop

    ; Print first item
    mov eax, 4
    mov ebx, 1
    mov ecx, first_msg
    mov edx, first_msg_len
    int 0x80

    mov esi, numbers
    mov eax, [esi]
    call print_number

    ; Print middle item if we have more than 2 items
    cmp ebp, 2
    jle print_last_item

    ; Calculate middle index (ebp//2)
    mov eax, ebp
    mov edx, 0
    mov ecx, 2
    div ecx
    mov ecx, 4
    mul ecx
    mov esi, numbers
    add esi, eax

    mov eax, 4
    mov ebx, 1
    mov ecx, middle_msg
    mov edx, middle_msg_len
    int 0x80

    mov eax, [esi]
    call print_number

print_last_item:
    ; Print last item
    mov eax, 4
    mov ebx, 1
    mov ecx, last_msg
    mov edx, last_msg_len
    int 0x80

    mov eax, ebp
    dec eax
    mov ecx, 4
    mul ecx
    mov esi, numbers
    add esi, eax
    mov eax, [esi]
    call print_number

exit_loop:
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Helper function to print a number
print_number:
    mov edi, number_str + 4
    mov ebx, 10

convert_loop_print:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz convert_loop_print

    ; Calculate string length
    lea edx, [number_str + 5]
    sub edx, edi

    ; Print the number
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi + 1]
    int 0x80

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop ebx
    pop eax
    ret
