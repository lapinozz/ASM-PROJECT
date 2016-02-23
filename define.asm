BITS 32

%include "sfDefine.asm"
%include "Ressources.asm"
%include "Vector2.asm"
%include "utility.asm"
%include "Perso.asm"
%include "Array.asm"
%include "Map.asm"
%include "ViewManager.asm"
%include "Component.asm"
%include "Circuit.asm"
%include "KeyHandler.asm"

;standard function
EXTERN printf

EXTERN time

EXTERN exit

EXTERN malloc
EXTERN calloc
EXTERN realloc
EXTERN free

EXTERN atoi
EXTERN atof


EXTERN fopen
EXTERN fclose
EXTERN fread
EXTERN fseek
EXTERN ftell

;standard define
SEEK_SET equ 0
SEEK_END equ 2
