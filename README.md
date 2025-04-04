Projeto de estrutura de dados apresentado em 04/04/2025
   Objetivo: Implementar um algorítimo de busca binária em assembly
   Informações: O algorítimo foi escrito usando NASM, Syscall do Linus e arquitetura 32bits (Com compatibilidade para 64bits)

Recomendações:

Computador no mínimo 32bits
Kernel do linux

( Caso queira compilar novamente )
NASM para compilar
GCC para linkar (ld)

Diretório dos arquivos finais ( Executável limpo e arquivo apenas para comentário - Todos já como executáveis )

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
