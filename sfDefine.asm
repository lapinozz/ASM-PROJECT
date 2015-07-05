;SFML function
EXTERN sfRenderWindow_create
EXTERN sfRenderWindow_isOpen
EXTERN sfRenderWindow_clear
EXTERN sfRenderWindow_display
EXTERN sfRenderWindow_pollEvent
EXTERN sfRenderWindow_drawSprite

EXTERN sfTexture_createFromFile

EXTERN sfSprite_create
EXTERN sfSprite_setTexture
EXTERN sfSprite_move

EXTERN sfClock_create
EXTERN sfClock_restart
EXTERN sfClock_getElapsedTime

KEY_Left  equ 71
KEY_Right equ 72
KEY_Up    equ 73
KEY_Down  equ 74

sfEvtClosed equ 0

sfEvtKeyPressed equ 5
sfEvtKeyReleased equ 6

struc sfEvent
    .type resd 1

    resd 5;biggest event struct

    .size resb 0
endstruc

struc sfKeyEvent
             resd 1 ; type

    .keyCode resd 1
    .alt     resd 1
    .control resd 1
    .shift   resd 1
    .system  resd 1

    .size resb 0
endstruc
