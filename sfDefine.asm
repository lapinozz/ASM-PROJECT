;SFML function
EXTERN sfRenderWindow_create
EXTERN sfRenderWindow_isOpen
EXTERN sfRenderWindow_clear
EXTERN sfRenderWindow_display
EXTERN sfRenderWindow_pollEvent
EXTERN sfRenderWindow_drawSprite
EXTERN sfRenderWindow_drawVertexArray

EXTERN sfTexture_createFromFile

EXTERN sfSprite_create
EXTERN sfSprite_setTexture
EXTERN sfSprite_move

EXTERN sfClock_create
EXTERN sfClock_restart
EXTERN sfClock_getElapsedTime

EXTERN sfVertexArray_create
EXTERN sfVertexArray_clear
EXTERN sfVertexArray_append
EXTERN sfVertexArray_setPrimitiveType

;sfPrimitiveType
sfPoints          equ 0
sfLines           equ 1
sfLinesStrip      equ 2
sfTriangles       equ 3
sfTrianglesStrip  equ 4
sfTrianglesFan    equ 5
sfQuads           equ 6

;Keys
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

struc sfTransform
    .m11 resd 1
    .m12 resd 1
    .m13 resd 1
    .m21 resd 1
    .m22 resd 1
    .m23 resd 1
    .m31 resd 1
    .m32 resd 1
    .m33 resd 1

    .size resb 0
endstruc

struc sfRenderStates
    .blendMode resd 1
    .transform resb sfTransform.size
    .texture   resd 1
    .shader    resd 1

    .size      resb 0
endstruc


struc sfVertex
    .position  resb Vector2.size ;sfVector2f
    .color     resd 1
    .texCoords resb Vector2.size ;sfVector2f

    .size      resb 0
endstruc
