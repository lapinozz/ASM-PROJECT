BITS 32

%include "define.asm"

SECTION .data

    msg db 'testing', 10, 0

    text_left  db 'left' , 10, 0
    text_right db 'right', 10, 0

    line_return       db 10, 0
    comma_char        db ',', 0
    point_char        db '.', 0
    double_point_char db ':', 0

    char_1 db '1', 0

    map_file   db './res/map/map.txt', 0

    file_mode_rb db 'rb', 0

    int_patern   db '%i', 10, 0
    float_patern db '%f', 10, 0
    char_patern db '%c', 10, 0
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

    int_const_n4 dd -4
    int_const_n3 dd -3
    int_const_n2 dd -2
    int_const_n1 dd -1
    int_const_0  dd  0
    int_const_1  dd  1
    int_const_2  dd  2
    int_const_3  dd  3
    int_const_4  dd  4

    float_const_n100 dd -100.0
    float_const_n10 dd -10.0
    float_const_0 dd 0.0
    float_const_0_1 dd 0.1
    float_const_0_45 dd 0.45
    float_const_0_5 dd 0.5
    float_const_0_9 dd 0.9
    float_const_0_99 dd 0.99
    float_const_1 dd 1.0
    float_const_1_1 dd 1.1
    float_const_2 dd 2.0
    float_const_3 dd 3.0
    float_const_4 dd 4.0
    float_const_10 dd 10.0
    float_const_16 dd 16.0
    float_const_30 dd 30.0
    float_const_50 dd 50.0
    float_const_64 dd 64.0
    float_const_100 dd 100.0
    float_const_150 dd 150.0
    float_const_300 dd 300.0
    float_const_500 dd 500.0

SECTION .bss
    window resd 1
    viewManager resb ViewManager.size

    delta_clock resd 1
    delta_time resq 1
    total_time resq 1

    perso_array resb Array.size

    event resb sfEvent.size

;    map         resb Map.size
    circuit     resb Circuit.size

    cellMode    resd 1

    publicSprite resd 1

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

    call load_resources

    call sfSprite_create
    mov  [publicSprite], eax

    push 0x0            ;context setting pointer
    push 0111b          ;window style (titlebar + resize + close)
    push window_title   ;window title
    push 0x20           ;videomode bytedepth
    push 0x258          ;videomode height
    push 0x320          ;videomode width
    call sfRenderWindow_create
    add  esp, 24
    mov [window], eax  ;save the window addresses

    push dword [float_const_0_9]
    push dword [float_const_100]
    push dword [float_const_100]
    push dword [window]
    push dword viewManager
    call ViewManager_init
    add  esp, 20

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

    fld  dword [float_test1] ;do addition using FPU
    fadd dword [float_test2]
    fstp qword [float_result]

    push dword [float_result+4]
    push dword [float_result]
    push float_patern
    call printf
    add  esp, 12

    push dword [float_const_0_45] ;interpolation
    push dword 100   ;value2
    push dword 0     ;value1
    call lerp_i
    add  esp, 12

    push eax
    call print_dword_float
    add  esp, 4

;    push map_file
;    call read_file
;    add  esp, 4

;    push map_file
;    push map
;    call Map_init_from_file
;    add  esp, 8

;    push 4 ;sheetSize.x
;    push 4 ;sheetSize.x
;    push dword [float_const_16] ;tileSize.x
;    push dword [float_const_16] ;tileSize.y
;    push dword [mapTexture]
;    push 5 ;mapSize.y
;    push 5 ;mapSize.x
;    push dword [float_const_100] ;caseSize.y
;    push dword [float_const_100] ;caseSize.x
;    push map
;    call Map_init
;    add esp, 20

    mov  dword [cellMode], CELL_NONE

    push dword [float_const_0_5]
    push 100 ;mapSize.y
    push 100 ;mapSize.x
    push dword [float_const_100] ;caseSize.y
    push dword [float_const_100] ;caseSize.x
    push circuit
    call Circuit_init
    add esp, 20

    push circuit
    push dword 0x0
    push dword 4; y
    push dword 4; x
    push dword COMPONENT_AND; type
    call Component_create
    add  esp, 20

main_loop:
    push dword [window] ;end if window close
    call sfRenderWindow_isOpen
    add esp, 4
    cmp eax, 0
    jz main_end

    push dword [delta_clock]
    push dword delta_time       ;long long pointer
    call sfClock_restart
    add  esp, 4

    fld  dword [microsecond_to_second] ;convert the time to second
    fimul dword [delta_time]
    fst qword [delta_time]
    fadd qword [total_time] ;add the delta time to total times
    fstp qword [total_time]

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
        cmp  dword [event + sfEvent.type], sfEvtMouseButtonPressed
        jz   handle_mouse_event
        cmp  dword [event + sfEvent.type], sfEvtMouseWheelMoved
        jz   handle_wheel_event

        jmp  pollevent_loop
    pollevent_end:

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

    push viewManager
    call ViewManager_update
    add  esp, 4

    push circuit
    call Circuit_update
    add  esp, 4

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
    push dword circuit
    call Circuit_draw
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
    jz  .case_key_left
    cmp dword [event + sfKeyEvent.keyCode], KEY_Right
    jz  .case_key_right
    cmp dword [event + sfKeyEvent.keyCode], KEY_Up
    jz  .case_key_up
    cmp dword [event + sfKeyEvent.keyCode], KEY_Down
    jz  .case_key_down

    cmp dword [event + sfKeyEvent.keyCode], KEY_Esc
    jz  .case_key_esc

    cmp dword [event + sfKeyEvent.keyCode], KEY_A
    jz  .case_key_a
    cmp dword [event + sfKeyEvent.keyCode], KEY_S
    jz  .case_key_s
    cmp dword [event + sfKeyEvent.keyCode], KEY_D
    jz  .case_key_d
    cmp dword [event + sfKeyEvent.keyCode], KEY_1
    jz  .case_key_a
    cmp dword [event + sfKeyEvent.keyCode], KEY_2
    jz  .case_key_s
    cmp dword [event + sfKeyEvent.keyCode], KEY_3
    jz  .case_key_d

    jmp handle_key_event_end

.case_key_left:
    fld  dword [float_const_n100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.x]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.x]
    jmp .case_key_move_end

.case_key_right:
    fld  dword [float_const_100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.x]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.x]
    jmp .case_key_move_end

.case_key_up:
    fld  dword [float_const_n100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.y]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.y]
    jmp .case_key_move_end

.case_key_down:
    fld  dword [float_const_100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.y]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.y]
    jmp .case_key_move_end

.case_key_move_end:
    jmp handle_key_event_end


.case_key_esc:
    jmp main_end

.case_key_a:
    mov  dword [cellMode], CELL_NONE
    jmp handle_key_event_end

.case_key_s:
    mov  dword [cellMode], CELL_OFF
    jmp handle_key_event_end

.case_key_d:
    mov  dword [cellMode], CELL_ACTIVE
    jmp handle_key_event_end

handle_key_event_end:
    jmp pollevent_loop



handle_mouse_event:

    cmp dword [event + sfMouseButtonEvent.button], sfMouseLeft
    jz  .left_button
    cmp dword [event + sfMouseButtonEvent.button], sfMouseRight
    jz  .right_button

    .left_button:
        sub esp, 8
        mov eax, esp

        push dword [viewManager + ViewManager.view]
        push dword [window]
        push eax
        call get_mouse_position
        add  esp, 12

        ;x and y are already pushed
        push esp ;the place x and y are using will be used
        push circuit
        call Circuit_convertWorldToCellCoord
        add  esp, 8

        pop eax
        pop edx

        push dword [cellMode]
        push eax
        push edx
        push circuit
        call Circuit_setCellType
        add  esp, 16
        jmp handle_mouse_event_end

    .right_button:
        push text_right
        call printf
        add  esp, 4
        jmp handle_mouse_event_end

handle_mouse_event_end:
    jmp pollevent_loop

handle_wheel_event:

    fld dword [float_const_0]
    fld dword [event + sfMouseWheelEvent.delta]
    fucomip ST1 ;do something like comparing ST1 and ST0 then pop
    fstp ST0   ;pop
    jbe .greater ;jmp if greater (or less (or whatever i dont remember))
    push dword [float_const_0_9]
    jmp .zoom

    .greater:
    push dword [float_const_1_1]

    .zoom:
    push viewManager
    call ViewManager_zoomAtMouse
    add  esp, 8
    jmp handle_wheel_event_end

handle_wheel_event_end:
    jmp pollevent_loop
