Projeto de estrutura de dados apresentado em 04/04/2025
   Objetivo: Implementar um algorítimo de busca binária em assembly
   Informações: 
   - O algorítimo foi escrito usando NASM, Syscall do Linus e arquitetura 32bits (Com compatibilidade para 64bits).
   - Como o projeto foi feito em apenas um arquivo apenas o comando ld precisa ser usado para gerar o Executável.
   - Existe um código "Simplificado" em python para referência

   

Recomendações:

Computador de no mínimo 32bits
Kernel do linux

( Caso queira compilar novamente )
NASM para compilar
GCC para linkar (ld)



Diretório dos arquivos finais ( Executável limpo e arquivo apenas para comentário -> Todos já como executáveis )
   /binarys/assembly/final


Scripts a serem instalados em caso de compilação:

sudo apt update && sudo apt upgrade -y
sudo apt install nasm
sudo apt install gcc

Comandos para criar executável:

!!! Se atentar na extensão dos arquivos

nasm -f elf32 -o [nome_do_arquivo.o] [nome.do.arquivo.asm]
ld -m elf_i386 -o [nome_do_arquivo] [nome.do.arquivo.o]

Comando para rodar (Estando dentro do diretório):

./[nome_do_arquivo]








Recursos de referência:

https://mentebinaria.gitbook.io/assembly
https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/x64-architecture
https://wiki.cdot.senecapolytechnic.ca/wiki/X86_64_Register_and_Instruction_Quick_Start
https://math.hws.edu/eck/cs220/f22/registers.html
https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf

