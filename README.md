Recomendações:

Computador no mínimo 32bits
Kernel do linux

NASM para compilar
GCC para linkar (ld)

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
