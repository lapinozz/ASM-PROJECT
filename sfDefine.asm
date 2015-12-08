;SFML function
EXTERN sfRenderWindow_create
EXTERN sfRenderWindow_isOpen
EXTERN sfRenderWindow_clear
EXTERN sfRenderWindow_display
EXTERN sfRenderWindow_setView
EXTERN sfRenderWindow_getDefaultView
EXTERN sfRenderWindow_pollEvent
EXTERN sfRenderWindow_drawSprite
EXTERN sfRenderWindow_drawText
EXTERN sfRenderWindow_drawVertexArray
EXTERN sfRenderWindow_mapCoordsToPixel
EXTERN sfRenderWindow_mapPixelToCoords

EXTERN sfMouse_getPositionRenderWindow

EXTERN sfView_move
EXTERN sfView_zoom
EXTERN sfView_setCenter
EXTERN sfView_getCenter

EXTERN sfTexture_createFromFile

EXTERN sfSprite_create
EXTERN sfSprite_setTexture
EXTERN sfSprite_setPosition
EXTERN sfSprite_move

EXTERN sfClock_create
EXTERN sfClock_restart
EXTERN sfClock_getElapsedTime

EXTERN sfVertexArray_create
EXTERN sfVertexArray_clear
EXTERN sfVertexArray_append
EXTERN sfVertexArray_setPrimitiveType

EXTERN sfText_create
EXTERN sfText_setCharacterSize
EXTERN sfText_setFont
EXTERN sfText_setColor
EXTERN sfText_setPosition
EXTERN sfText_setString

EXTERN sfFont_createFromFile

;sfPrimitiveType
sfPoints          equ 0
sfLines           equ 1
sfLinesStrip      equ 2
sfTriangles       equ 3
sfTrianglesStrip  equ 4
sfTrianglesFan    equ 5
sfQuads           equ 6

;Keys
KEY_Esc   equ 36

sfKeyLShift equ 38

KEY_Tab   equ 60

KEY_Left  equ 71
KEY_Right equ 72
KEY_Up    equ 73
KEY_Down  equ 74

KEY_A  equ 0
KEY_B  equ 1
KEY_C  equ 2
KEY_D  equ 3
KEY_E  equ 4
KEY_F  equ 5
KEY_G  equ 6
KEY_H  equ 7
KEY_I  equ 8
KEY_J  equ 9
KEY_K  equ 10
KEY_L  equ 11
KEY_M  equ 12
KEY_N  equ 13
KEY_O  equ 14
KEY_P  equ 15
KEY_Q  equ 16
KEY_R  equ 17
KEY_S  equ 18
KEY_T  equ 19
KEY_U  equ 20
KEY_V  equ 21
KEY_W  equ 22
KEY_X  equ 23
KEY_Y  equ 24
KEY_Z  equ 25

KEY_0  equ 25
KEY_1  equ 26
KEY_2  equ 27
KEY_3  equ 28
KEY_4  equ 29
KEY_5  equ 20
KEY_6  equ 31
KEY_7  equ 32
KEY_8  equ 33
KEY_9  equ 34

sfMouseLeft  equ 0
sfMouseRight equ 1

sfEvtClosed equ 0

sfEvtKeyPressed equ 5
sfEvtKeyReleased equ 6

sfEvtMouseWheelMoved equ 7
sfEvtMouseButtonPressed equ 8
sfEvtMouseButtonReleased equ 9

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

struc sfMouseButtonEvent
            resd 1 ; type
    .button resd 1
    .x      resd 1
    .y      resd 1
endstruc

struc sfMouseWheelEvent
            resd 1 ; type
    .delta  resd 1
    .x      resd 1
    .y      resd 1
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
