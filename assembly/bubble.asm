section .data
    prompt db "Enter a number (empty to quit): ", 0xA
    prompt_len equ $ - prompt
    numbers times 256 dd 0 ; Espaço para as respostas // aloca 256 x 4bytes ( 32bits for each number ) 0 is the initial value
    summary db "All numbers entered: [", 0
    summary_len equ $ - summary
    number_str db "     ", 0 ; Espaço de 5 + newline
    input_wait db "> ", 0
    input_wait_len equ $ - input_wait
    ending_output db "]", 0xA
    ending_output_len equ $ - ending_output
    comma db ", ", 0

section .bss
    buffer resb 32

section .text
global _start
_start:
    mov edi, numbers ; nessa caso vai apontar para onde o proximo input vai ser escrito
    mov ebp, 0       ; Number counter

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

    ; Read input -> resrvando espaço para o enter
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31 ; -1 bit do terminator
    int 0x80

    ; Check for empty input
    cmp eax, 1 ; newline
    jle bubble_sort

    ; Null-terminate the input -> troca o \n do input por 0 para o dado se manter contínuo -> eax recebe da syscall o tamanho do input
    mov byte [buffer + eax - 1], 0

    ;Verificar por digito se é valido e converter
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
    mov [edi], ecx  ; guardar o numer no endereço da proxima memória 
    add edi, 4      ; Mover memória
    inc ebp         ; Passar o contador
    jmp input_loop

bubble_sort:
    ; verificar se ainda tem dois numeros para serem trocados
    cmp ebp, 1
    jle show_summary

    mov ecx, ebp        ; loop externo 
    dec ecx             ; n-1 -> menos 1 loop 

outer_loop:
    push ecx            ; salvar contador externo
    mov esi, numbers    ; apontar inicio do array
    xor edx, edx        ; inner counter

inner_loop:
    mov eax, [esi]      ; numero atual
    mov ebx, [esi+4]    ; proximo num
    cmp eax, ebx
    jle no_swap         ; se tiver em ordem pular para o label sem swap

    ; Swap 
    mov [esi], ebx
    mov [esi+4], eax

no_swap:
    add esi, 4          ; ir para  o proximo elemento
    inc edx
    cmp edx, ecx        ; comparar com o elemento de fora
    jl inner_loop

    pop ecx             ; restaurar contador externo
    loop outer_loop

show_summary:
    ; Print summary header
    mov eax, 4
    mov ebx, 1
    mov ecx, summary
    mov edx, summary_len
    int 0x80

    ;Setup to printar todos numeros 
    mov esi, numbers
    mov ecx, ebp
    test ecx, ecx
    jz exit_loop

print_loop:
    ; Convert number to ASCII
    mov eax, [esi]
    mov edi, number_str + 4 ; Vai para o final do buffer da resposta
    mov ebx, 10             ; dividor

convert_to_ascii:
    xor edx, edx
    div ebx             ; Divide por 10
    add dl, '0'         ; Segurar digito
    mov [edi], dl       ; Segurar digito
    dec edi             ; Move o ponteiro para esquerda <-
    test eax, eax       ; checar se é zero
    jnz convert_to_ascii

    ; Calcular largura da string
    lea edx, [number_str + 5]
    sub edx, edi

    ; Print the number
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi + 1] ; apontar para o inicio da string
    int 0x80

    ; Print virgula (menos no ultimo numero)
    dec ebp
    jz no_comma         ; vai passar se for o último numero

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
    ; printa apenas o ultimo numero
    add esi, 4
    test ebp, ebp
    jnz print_loop

    ; "]" final
    mov eax, 4
    mov ebx, 1
    mov ecx, ending_output
    mov edx, ending_output_len
    int 0x80

exit_loop:
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
