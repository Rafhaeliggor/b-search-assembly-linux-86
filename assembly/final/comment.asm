section .data
;Strings de exibição
    prompt db "Enter a number (empty to quit): ", 0
    prompt_len equ $ - prompt - 1
    numbers times 256 dd 0 ;Alocando espaço na memória para as respostas 265 com 4 bytes cada e inicializando como 0
    summary db 0xA, "All numbers entered: [", 0
    summary_len equ $ - summary - 1
    number_str db "     ", 0 ;Espaço reservado para conversão da string
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
    mov edi, numbers ;Apontar para o o local onde o registro dos números começa
    mov ebp, 0 ; Contador para quantos números foram adicionados

;Inprimir prompt inicial para o output
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len ;file descriptor (1 = stdout)
    int 0x80

input_loop:
    ; output >
    mov eax, 4
    mov ebx, 1
    mov ecx, input_wait
    mov edx, input_wait_len
    int 0x80

;Regista captura o input e coloca no buffer
    mov eax, 3 ; O retorno vai ser o tamanho do input
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31 ; -1 bit para consider o espaço
    int 0x80

    cmp eax, 1 ;Número de bytes lidos
    jle bubble_sort

    mov byte [buffer + eax - 1], 0 ; Substituir o ultimo caractere \n -> \0

    xor eax, eax ;Apagar os dados em eax e ecx
    xor ecx, ecx
    mov esi, buffer ;Aponta para o inicio do buffer
convert_loop:
    lodsb ;loadstringbyte -> carrega byte na memória apontando por no al e aumenta o esi ( passa para o próximo byte
    test al, al ;Basicamente um and sem modificar al -> verificar se chegou no final \0
    jz store_number ;Se for zero terminou a conversão
    cmp al, '0'
;verificar se digito é valido (dentro do escopo do código ascii ) nada acontece
    jb invalid_input
    cmp al, '9'
    ja invalid_input
    sub al, '0' ;convertendo ASCII em inteiro
    imul ecx, 10 ;Multiplicado o valor atual em 10
    add ecx, eax ; Adiciona o numero completo depois de ter multiplicado o acumulador por 10
    jmp convert_loop

;ex: 53 (valor ASCII de '5') - 48 (valor ASCII de '0') = 5

;A ideia é subtrair o valor do código de zero do valor do código do digito escolhido extraindo ovalor como inteiro no final tudo é acumulado em ecx

;O tratamento de um caractere invalido nesse caso é apenas ignorar, o input nem procesado é
invalid_input:
    jmp input_loop

store_number:
;Joga o resultado final do acumulo em edi, depois disso passa 4 bytes para chegar me um novo endereço de memória ( para o proximo input )
    mov [edi], ecx
    add edi, 4
    inc ebp ;Aumenta o contador de entrada
    jmp input_loop

bubble_sort:
    cmp ebp, 1 ;verificar se no contador existe um ou menos numeros
    jle show_summary

;Configurar para oloop externo
    mov ecx, ebp ;passa a quantidade de numeros
    dec ecx ; diminui ela por 1 
;numero de itens na lista = (n-1)

outer_loop:
    push ecx ;contagem de quantas interações foram feitas pelo loop externo, agora ecx pode ser usado no loop interno
    mov esi, numbers ;aponta para o inicio do array
    xor edx, edx ;limpa o edx -> vai ser usado como o contador do loop

inner_loop:
    mov eax, [esi] ; valor de esi
    mov ebx, [esi+4] ; ebx vira o proximo valor de esi
;fazer o comparativo
    cmp eax, ebx
;se for igual ou menor
    jle no_swap

;caso não for menor essa parte é usada trocando os valores
    mov [esi], ebx ; 
    mov [esi+4], eax

;trocando ou não trocando isso vai ser executado
no_swap:
    add esi, 4 ;ir para o proximo elemento da lista
    inc edx ; aumenta o contador interno
    cmp edx, ecx ; comparar com o limite do array caso adina for menor o loop ocorre novamente
    jl inner_loop 

;se o bubble acabar essa essa linha retorna o ecx e roda novamente o loop maior
    pop ecx
    loop outer_loop


show_summary:

;imprimir a string de summary
    mov eax, 4
    mov ebx, 1
    mov ecx, summary
    mov edx, summary_len
    int 0x80

;Comeaçar a listar os números
    push ebp ; salva o valor na stack ( esse é o contador dos números )

    mov esi, numbers ; inicio do array
    mov ecx, ebp ; quantidade de números
    test ecx, ecx ; verificar se é zero
    jz print_special_items ; caso não sendo zero entra no loop de print

print_loop:
;preperar para converter
    mov eax, [esi] ; numero atual
    mov edi, number_str + 4 ;final do buffer
    mov ebx, 10 ; divisor que vai ser usado para converter cada digito

convert_to_ascii:
;binário -> ascii
    xor edx, edx ; zerar
    div ebx ; divide EAX por 10 -> eax vira o quociente e edx vira o resto ( retornando o digito da vez )
    add dl, '0' ; converte o digito para asci
    mov [edi], dl ; armazena o caractere asci no buffer
    dec edi ;move o ponteiro do buffer para trás buscando a proxima casa
    test eax, eax ; verificar se todos os digitos foram processados
    jnz convert_to_ascii ;repete se eax estiver zerado

    lea edx, [number_str + 5] ;endereço após o buffera terminator
    sub edx, edi ; retorna o tamanho da string para o EDI

;syscall para escrever
    mov eax, 4
    mov ebx, 1
    lea ecx, [edi + 1] ; esquema para apontar ao endereço da string corrigindo o decremento
;edx anteriormente já foi preenchido contendo o tamanho do buffer
    int 0x80

    dec ebp ; verifica se a quantidade de numeros chegou ao fim e não exibe a virgula
    jz no_comma

;salva os valores de esi e ebp para não perder a syscall
    push esi
    push ebp
;print da vírgula
    mov eax, 4
    mov ebx, 1
    mov ecx, comma
    mov edx, 2
    int 0x80
;retorna os valores de ebp e esi
    pop ebp
    pop esi

no_comma:
;print normal caso seja o ultimo numero, sem virgula e ultima ]
    add esi, 4
    test ebp, ebp
    jnz print_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, ending_output
    mov edx, ending_output_len
    int 0x80

print_special_items:
;recuperar o valor inicial d eebp
    pop ebp

;verificar se tem algum nuemro dentro do contador ebp ( se tem algo no array )
    cmp ebp, 0
    je search_loop

;print do primeiro numero
;menssagem
    mov eax, 4
    mov ebx, 1
    mov ecx, first_msg
    mov edx, first_msg_len
    int 0x80

;imprime o numero
    mov esi, numbers
    mov eax, [esi]
    call print_number ; "função" que vai formatar e exibir corretametne

;pular para o ultimo item se não tiver mais de dois numeros
    cmp ebp, 2
    jle print_last_item

;indice do meio
    mov eax, ebp ; total de numero
    mov edx, 0 ; zernado edx para dividir
    mov ecx, 2 ; dvisor
    div ecx ; divide EAX por 2 -> eax vira o indice do meio, edx recebe o resto
    mov ecx, 4 ; definir tamanho do dado ( 4 bytes )
    mul ecx ; multiplica pela quantidade de bytes
    mov esi, numbers ; aponta para o inico do array
    add esi, eax ; encontrar o endeço do meio

;imprimir o endereço do meio
;texto
    mov eax, 4
    mov ebx, 1
    mov ecx, middle_msg
    mov edx, middle_msg_len
    int 0x80

;numero efetivamente
    mov eax, [esi]
    call print_number

print_last_item:
;mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, last_msg
    mov edx, last_msg_len
    int 0x80

;local do ultimo item 
    mov eax, ebp
    dec eax
    mov ecx, 4
    mul ecx
    mov esi, numbers
    add esi, eax
    mov eax, [esi]
    call print_number

search_loop:
    cmp ebp, 0 ; verifica se o loop chegou ao final (input = "")
    je exit_loop
;msg da pesquisa do loop
    mov eax, 4
    mov ebx, 1
    mov ecx, search_prompt
    mov edx, search_prompt_len
    int 0x80

;pegar o input
; inprimir >
    mov eax, 4
    mov ebx, 1
    mov ecx, input_wait
    mov edx, input_wait_len
    int 0x80

;entrada do user
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 31
    int 0x80

;verifica se a entrada não foi um enter para sair
    cmp eax, 1
    jle exit_loop

;remover a o simbolo de enter
    mov byte [buffer + eax - 1], 0

;converter a string em numero
    xor eax, eax  
    xor ecx, ecx 
    mov esi, buffer ; inicio do buffer
convert_search_loop:
;mais uma conversão de entrara
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
    mov [search_num], ecx ; salva o numero a ser buscado

    xor ebx, ebx ;inicio do intervalo
    mov eax, ebp ;fim do intervalo + 1
    dec eax       ; ajusta para o indice do ultimo dado
    mov edi, numbers ;unicio do array

binary_search:
    cmp ebx, eax ; verificar se o numero existe dento do menor e maior numero recrusivamente vai fazer isso para cada novo baixo e alto
    jg not_found

;calcular o indice do meio
    mov ecx, ebx
    add ecx, eax 
    shr ecx, 1 ;apos somar faz a divisão inteira

    mov esi, ecx ;copia o indice do meio para o o esi
    shl esi, 2  ;da 2 shift left para encontrar ocupar os 4 endereços de byte do numero
    add esi, edi ; apontando para o meio
    mov edx, [esi] ;buscando o valor do meio

;verifica se o numero procurado é o numero do meio
    cmp edx, [search_num]
;se for igual , achou ele
    je found
; se o numero for maior pula para procurar na direita
    jl search_right         
;caso nada seja atendido vai para a parte da esquerda
search_left:              
;modifica o indice do maior numero para ser o meio anterior
    lea eax, [ecx-1]      
    jmp binary_search

search_right:
;modifica o indice do menor numero para ser o meio anterior
    lea ebx, [ecx+1]     
    jmp binary_search

found:
;salva o numero em uma pilha
    push ecx                

;mensagem de que foi achadado
    mov eax, 4
    mov ebx, 1
    mov ecx, found_msg
    mov edx, found_msg_len
    int 0x80
    
;recupera o index e chama o label de print
    pop eax                 
    call print_number
;na volta repete o loop de busca
    jmp search_loop

not_found:
;mensagem quando o valor não é encontrado
    mov eax, 4
    mov ebx, 1
    mov ecx, not_found_msg
    mov edx, not_found_msg_len
    int 0x80
;volta para o loop de busca
    jmp search_loop

exit_loop:
;terminar o programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
;apontar para o ultimo byte do buffer
    mov edi, number_str + 4
;extrair digitos decimais
    mov ebx, 10

convert_loop_print:
;converter novamente inteiro para string
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

