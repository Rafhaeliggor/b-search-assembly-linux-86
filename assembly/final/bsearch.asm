section .data
    prompt db "Enter a number (empty to quit): ", 0
    prompt_len equ $ - prompt - 1
    numbers times 256 dd 0
    summary db 0xA, "All numbers entered: [", 0
    summary_len equ $ - summary - 1
    number_str db "     ", 0
    input_wait db "> ", 0
    input_wait_len equ $ - input_wait - 1
    ending_output db "]", 0xA, 0
    ending_output_len equ $ - ending_output - 1
    comma db ", ", 0
    comma_len equ $ - comma - 1
    first_msg db "First item: ", 0
    first_msg_len equ $ - first_msg - 1
    middle_msg db "Middle item: ", 0
    middle_msg_len equ $ - middle_msg - 1
    last_msg db "Last item: ", 0
    last_msg_len equ $ - last_msg - 1
    search_prompt db 0xA, "Enter number to search (empty to exit): ", 0
    search_prompt_len equ $ - search_prompt - 1
    found_msg db "Found at index: ", 0
    found_msg_len equ $ - found_msg - 1
    not_found_msg db "Not found", 0xA, 0
    not_found_msg_len equ $ - not_found_msg - 1
    newline db 0xA, 0
    newline_len equ $ - newline - 1

section .bss
    buffer resb 32
    search_num resd 1

section .text
global _start
_start:
    mov edi, numbers
    mov ebp, 0

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

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31
    int 0x80

    cmp eax, 1
    jle bubble_sort

    mov byte [buffer + eax - 1], 0

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
    mov eax, 4
    mov ebx, 1
    mov ecx, summary
    mov edx, summary_len
    int 0x80

    push ebp

    mov esi, numbers
    mov ecx, ebp
    test ecx, ecx
    jz print_special_items

print_loop:
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

    lea edx, [number_str + 5]
    sub edx, edi

    mov eax, 4
    mov ebx, 1
    lea ecx, [edi + 1]
    int 0x80

    dec ebp
    jz no_comma

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

    mov eax, 4
    mov ebx, 1
    mov ecx, ending_output
    mov edx, ending_output_len
    int 0x80

print_special_items:
    pop ebp

    cmp ebp, 0
    je search_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, first_msg
    mov edx, first_msg_len
    int 0x80

    mov esi, numbers
    mov eax, [esi]
    call print_number

    cmp ebp, 2
    jle print_last_item

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

search_loop:
    cmp ebp, 0
    je exit_loop
    mov eax, 4
    mov ebx, 1
    mov ecx, search_prompt
    mov edx, search_prompt_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, input_wait
    mov edx, input_wait_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31
    int 0x80

    cmp eax, 1
    jle exit_loop

    mov byte [buffer + eax - 1], 0

    xor eax, eax
    xor ecx, ecx
    mov esi, buffer
convert_search_loop:
    lodsb
    test al, al
    jz start_binary_search
    cmp al, '0'
    jb search_loop
    cmp al, '9'
    ja search_loop
    sub al, '0'
    imul ecx, 10
    add ecx, eax
    jmp convert_search_loop

start_binary_search:
    mov [search_num], ecx

    xor ebx, ebx  
    mov eax, ebp
    dec eax        
    mov edi, numbers

binary_search:
    cmp ebx, eax
    jg not_found

    mov ecx, ebx
    add ecx, eax
    shr ecx, 1

    mov esi, ecx
    shl esi, 2   
    add esi, edi
    mov edx, [esi]

    cmp edx, [search_num]
    je found
    jl search_right         

search_left:               
    lea eax, [ecx-1]      
    jmp binary_search

search_right:
    lea ebx, [ecx+1]     
    jmp binary_search

found:
    push ecx                
    mov eax, 4
    mov ebx, 1
    mov ecx, found_msg
    mov edx, found_msg_len
    int 0x80
    
    pop eax                 
    call print_number
    jmp search_loop

not_found:
    mov eax, 4
    mov ebx, 1
    mov ecx, not_found_msg
    mov edx, not_found_msg_len
    int 0x80
    jmp search_loop

exit_loop:
    mov eax, 1
    xor ebx, ebx
    int 0x80

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

    lea edx, [number_str + 5]
    sub edx, edi

    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi + 1]
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop ebx
    pop eax
    ret
