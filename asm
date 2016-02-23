nasm -f elf32 -g main.asm
gcc -m32 -g -c helper.c -o helper.o
g++ -m32 helper.o main.o -lcsfml-graphics -lcsfml-window -lcsfml-system -o main

