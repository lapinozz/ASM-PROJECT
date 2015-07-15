BITS 32

%include "define.asm"

SECTION .data

    msg db 'testing', 10, 0

    perso_texture_file db './res/img/perso.png', 0
    map_texture_file   db './res/img/map.png'  , 0

    int_patern   db '%i', 10, 0
    float_patern db '%f', 10, 0
    long_long_patern db "%lld", 10, 0

    delta_time_partern db 'Delta Time %i', 10, 0

    msg_left  db 'left' , 10, 0
    msg_right db 'right', 10, 0
    msg_up    db 'up'   , 10, 0
    msg_down  db 'down' , 10, 0

    window_title db 'Super Duper Window From Asm', 0

    microsecond_to_second dd 0.000001

    float_test1 dd 2.55
    float_test2 dd 1.44
    float_result dq 1.44

    float_const_n100 dd -100.0
    float_const_0 dd 0.0
    float_const_1 dd 1.0
    float_const_2 dd 2.0
    float_const_3 dd 3.0
    float_const_4 dd 4.0
    float_const_10 dd 10.0
    float_const_30 dd 30.0
    float_const_50 dd 50.0
    float_const_100 dd 100.0
    float_const_150 dd 150.0
    float_const_300 dd 300.0
    float_const_500 dd 500.0

SECTION .bss
    window resd 1
    view   resd 1

    delta_clock resd 1
    delta_time resq 1
    total_time resq 1

    perso_array resb Array.size

    event resb sfEvent.size

    map         resb Map.size

    mapTexture  resd 1

    renderState resb sfRenderStates.size

SECTION .text

GLOBAL main
main:
    push ebp
    mov  ebp, esp

    push 0x0 ;NULL
    call time
    add  esp, 4

    push eax
    call srand
    add  esp, 4

    push 0x0            ;context setting pointer
    push 0111b          ;window style (titlebar + resize + close)
    push window_title   ;window title
    push 0x20           ;videomode bytedepth
    push 0x258          ;videomode height
    push 0x320          ;videomode width
    call sfRenderWindow_create
    add  esp, 24
    mov [window], eax  ;save the window addresses

    push eax
    call sfRenderWindow_getDefaultView
    mov  [view], eax

    call sfClock_create
    mov dword [delta_clock], dword eax

    push dword 0x1 ;isPointer
    push dword 100 ;count
    push dword 4 ;dataSize
    push perso_array ;Array*
    call Array_init
    add  esp, 16

    xor edx, edx
    perso_array_init_loop:
        cmp edx, [perso_array + Array.count]
        jz perso_array_init_loop_end

        push edx

        push perso_texture_file
        call Perso_create
        add  esp, 4

        push eax
        push eax

        push dword [float_const_100]
        push dword [float_const_n100]
        call rand_float_min_max
        add  esp, 8

        pop edx

        mov [edx + Perso.velocity + Vector2.x], eax

        push edx

        push dword [float_const_100]
        push dword [float_const_n100]
        call rand_float_min_max
        add  esp, 8

        pop edx

        mov [edx + Perso.velocity + Vector2.y], eax

        pop eax
        pop edx

        mov  ebx, [perso_array + Array.dataSize]
        imul ebx, edx

        mov  ecx, [perso_array + Array.start]
        mov  dword [ecx + ebx], eax

        inc edx
        jmp perso_array_init_loop
    perso_array_init_loop_end:

    mov  eax, [float_const_100]
    mov  ebx, [perso_array + Array.start]
    mov  edx, [ebx]
    mov  [edx + Perso.velocity + Vector2.y], eax

    push msg
    call printf
    add  esp, 4

    fld  dword [float_test1] ;do addition using FPU
    fadd dword [float_test2]
    fstp qword [float_result]

    push dword [float_result+4]
    push dword [float_result]
    push float_patern
    call printf
    add  esp, 12

    push 0x0 ;rect pointer
    push dword map_texture_file
    call sfTexture_createFromFile
    add esp, 8
    mov [mapTexture], eax

    push 4 ;sheetSize.x
    push 4 ;sheetSize.x
    push dword [float_const_100] ;tileSize.x
    push dword [float_const_100] ;tileSize.y
    push dword [mapTexture]
    push 5 ;mapSize.y
    push 5 ;mapSize.x
    push dword [float_const_100] ;caseSize.y
    push dword [float_const_100] ;caseSize.x
    push map
    call Map_init
    add esp, 20

    mov eax, [float_const_0]
    mov ebx, [float_const_1]
    mov [renderState + sfRenderStates.transform + sfTransform.m11], ebx
    mov [renderState + sfRenderStates.transform + sfTransform.m12], eax
    mov [renderState + sfRenderStates.transform + sfTransform.m13], eax
    mov [renderState + sfRenderStates.transform + sfTransform.m21], eax
    mov [renderState + sfRenderStates.transform + sfTransform.m22], ebx
    mov [renderState + sfRenderStates.transform + sfTransform.m23], eax
    mov [renderState + sfRenderStates.transform + sfTransform.m31], eax
    mov [renderState + sfRenderStates.transform + sfTransform.m32], eax
    mov [renderState + sfRenderStates.transform + sfTransform.m33], ebx

    mov [renderState + sfRenderStates.blendMode], dword 3
    mov [renderState + sfRenderStates.shader],  dword 0x0

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
    call sfClock_restart
    add  esp, 4

    fld  dword [microsecond_to_second] ;convert the time to second
    fimul dword [delta_time]
    fst qword [delta_time]
    fadd qword [total_time] ;add the delta time to total times
    fstp qword [total_time]

;    push dword [total_time + 4] ; print the time
;    push dword [total_time]
;    push float_patern
;    call printf
;    add  esp, 12

    xor edx, edx
    perso_array_update_loop:
        cmp edx, [perso_array + Array.count]
        jz perso_array_update_loop_end

        push edx

        mov  ebx, edx
        imul  ebx, [perso_array + Array.dataSize]
        mov  eax, [perso_array + Array.start]
        push dword [eax + ebx]
        call Perso_update
        add  esp, 4

        pop edx

        inc edx
        jmp perso_array_update_loop
    perso_array_update_loop_end:

;    push word 0xFF ;a
;    push word 0xFF ;b
;    push word 0xFF ;g
;    push word 0xFF ;r
    push dword 0xFF000000 ; abgr black
    push dword [window]
    call sfRenderWindow_clear
    add  esp, 8

    xor edx, edx
    perso_array_draw_loop:
        cmp edx, [perso_array + Array.count]
        jz perso_array_draw_loop_end

        push edx

        push dword [window]
        mov  ebx, edx
        imul  ebx, [perso_array + Array.dataSize]
        mov  eax, [perso_array + Array.start]
        push dword [eax + ebx]
        call Perso_draw
        add  esp, 8

        pop edx

        inc edx
        jmp perso_array_draw_loop
    perso_array_draw_loop_end:

    push dword [window]
    push dword map
    call Map_draw
    add  esp, 8

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
    cmp dword [event + sfKeyEvent.keyCode], KEY_Left
    jz  case_key_left
    cmp dword [event + sfKeyEvent.keyCode], KEY_Right
    jz  case_key_right
    cmp dword [event + sfKeyEvent.keyCode], KEY_Up
    jz  case_key_up
    cmp dword [event + sfKeyEvent.keyCode], KEY_Down
    jz  case_key_down

    cmp dword [event + sfKeyEvent.keyCode], KEY_Esc
    jz  case_key_esc

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

case_key_esc:
    jmp main_end


handle_key_event_end:
    jmp pollevent_loop

