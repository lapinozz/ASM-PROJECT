BITS 32

%include "define.asm"

SECTION .data

    msg db 'testing', 10, 0

    perso_texture_file db './res/img/perso.png', 0

    int_patern   db '%i', 10, 0
    float_patern db '%f', 10, 0
    long_long_patern db "%lld", 10, 0

    delta_time_partern db 'Delta Time %i', 10, 0

    msg_left  db 'left' , 10, 0
    msg_right db 'right', 10, 0
    msg_up    db 'up'   , 10, 0
    msg_down  db 'down' , 10, 0

    window_title db 'Super Duper Window From Asm', 0

    window dd 1

    delta_clock dd 1
    delta_time dq 1

    microsecond_to_second dd 0.000001

    float_test1 dd 2.55
    float_test2 dd 1.44
    float_result dq 1.44

SECTION .bss
    event resb sfEvent.size

    perso resb Perso.size

SECTION .text

GLOBAL main
main:
    push ebp
    mov  ebp, esp

    push 0x0            ;context setting pointer
    push 0111b          ;window style (titlebar + resize + close)
    push window_title   ;window title
    push 0x20           ;videomode bytedepth
    push 0x258          ;videomode height
    push 0x300          ;videomode width
    call sfRenderWindow_create
    add  esp, 24
    mov dword [window], dword eax  ;save the window addresses

    push 0x0 ;rect pointer
    push perso_texture_file
    call sfTexture_createFromFile
    add esp, 8
    mov dword [perso + Perso.texture], dword eax

    call sfSprite_create
    mov dword [perso + Perso.sprite], dword eax

    push 0x1 ;reset rect
    push dword [perso + Perso.texture]
    push dword [perso + Perso.sprite]
    call sfSprite_setTexture
    add  esp, 12

    mov  dword [perso + Perso.velocity + Vector2.x], dword 0x2
    mov  dword [perso + Perso.velocity + Vector2.y], dword 0x2

    call sfClock_create
    mov dword [delta_clock], dword eax

    push msg
    call printf
    add  esp, 4

;    fld  dword [float_test1] ;do addition using FPU
;    fadd dword [float_test2]
;    fstp qword [float_result]
    movsd xmm0, [float_test1] ;do addition using SSE
    addsd xmm0, [float_test2]
    movsd [float_result], xmm0

    push dword [float_result+4]
    push dword [float_result]
    push float_patern
    call printf
    add  esp, 12

main_loop:
    push dword [window] ;end if window close
    call sfRenderWindow_isOpen
    add esp, 4
    cmp eax, 0
    jz main_end

    pollevent_loop:
        push dword event
        push dword [window]
        call sfRenderWindow_pollEvent
        add  esp, 8
        cmp  eax, 0
        jz   pollevent_end

        cmp  dword [event + sfEvent.type], sfEvtClosed
        jz   main_end
        cmp  dword [event + sfEvent.type], sfEvtKeyPressed
        jz   handle_key_event

        jmp  pollevent_loop
    pollevent_end:

    push dword [delta_clock]
    push dword delta_time       ;long long pointer
    call sfClock_getElapsedTime
    add  esp, 4

    fld  dword [microsecond_to_second] ;convert the time to second
    fimul dword [delta_time]
    fstp qword [delta_time]

    push dword [delta_time + 4] ; print the time
    push dword [delta_time]
    push float_patern
    call printf
    add  esp, 12

    push dword perso
    call Perso_update
    add  esp, 4

;    push word 0xFF ;a
;    push word 0xFF ;g
;    push word 0xFF ;b
;    push word 0xFF ;r
    push dword 0xFF000000 ; agbr black
    push dword [window]
    call sfRenderWindow_clear
    add  esp, 8

    push dword 0x0 ;renderstate pointer
    push dword [perso + Perso.sprite]
    push dword [window]
    call sfRenderWindow_drawSprite
    add  esp, 12

    push dword [window]
    call sfRenderWindow_display
    add  esp, 4

    jmp main_loop
main_end:
    mov esp, ebp
    pop ebp

    mov eax, 0
    ret


handle_key_event:

    ;pass float argument with conversion so we are sure it's in the good format
;    sub  esp, 8		        ; make room for the float
;	fld dword [float_test1]	; load our float onto the floating point stack
;	fstp dword [esp + 4]	; push our float onto the stack
;	fld  dword [float_test2]; load our float onto the floating point stack
;	fstp dword [esp]		; push our float onto the stack

    ;we already know it's in the good format so we just push it
    push dword [float_test1]
    push dword [float_test2]
    push dword [perso + Perso.sprite]
    call sfSprite_move
    add  esp, 12

    cmp dword [event + sfKeyEvent.keyCode], KEY_Left
    jz  case_key_left
    cmp dword [event + sfKeyEvent.keyCode], KEY_Right
    jz  case_key_right
    cmp dword [event + sfKeyEvent.keyCode], KEY_Up
    jz  case_key_up
    cmp dword [event + sfKeyEvent.keyCode], KEY_Down
    jz  case_key_down

    jmp handle_key_event_end

case_key_left:
    push dword msg_left
    call printf
    add  esp, 4
    jmp case_key_move_end

case_key_right:
    push dword msg_right
    call printf
    add  esp, 4
    jmp case_key_move_end

case_key_up:
    push dword msg_up
    call printf
    add  esp, 4
    jmp case_key_move_end

case_key_down:
    push dword msg_down
    call printf
    add  esp, 4
    jmp case_key_move_end


case_key_move_end:


handle_key_event_end:
    jmp pollevent_loop

