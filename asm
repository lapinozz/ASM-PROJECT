nasm -f elf -g main.asm
gcc -g -c helper.c -o helper.o
g++ helper.o main.o -lcsfml-graphics -lcsfml-window -lcsfml-system -o main

