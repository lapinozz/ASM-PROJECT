[BITS 32]

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
    int_const_45 dd  45

    float_const_n100 dd -100.0
    float_const_n90 dd -90.0
    float_const_n10 dd -10.0
    float_const_0 dd 0.0
    float_const_0_00001 dd 0.00001
    float_const_0_001 dd 0.001
    float_const_0_1 dd 0.1
    float_const_0_45 dd 0.45
    float_const_0_5 dd 0.5
    float_const_0_9 dd 0.9
    float_const_0_99 dd 0.99
    float_const_1 dd 1.0
    float_const_1_1 dd 1.1
    float_const_1_5 dd 1.5
    float_const_2 dd 2.0
    float_const_2_5 dd 2.5
    float_const_3 dd 3.0
    float_const_4 dd 4.0
    float_const_10 dd 10.0
    float_const_16 dd 16.0
    float_const_30 dd 30.0
    float_const_45 dd 45.0
    float_const_50 dd 50.0
    float_const_64 dd 64.0
    float_const_90 dd 90.0
    float_const_100 dd 100.0
    float_const_150 dd 150.0
    float_const_180 dd 180.0
    float_const_300 dd 300.0
    float_const_500 dd 500.0
    float_const_800 dd 800.0
    float_const_1000 dd 1000.0

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

    drawComponent resd Component.size

    keyHandler  resb KeyHandler.size

    updateCircuit resb 1;

    cellMode           resd 1
    currentRotation    resd 1
    currentTile        resd Vector2.size

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
    mov  dword [currentRotation], 0

;    push dword [float_const_0_5]
    push dword [float_const_0_00001]
    push 100 ;mapSize.y
    push 100 ;mapSize.x
    push dword [float_const_100] ;caseSize.y
    push dword [float_const_100] ;caseSize.x
    push circuit
    call Circuit_init
    add esp, 20

    mov byte [updateCircuit], 1

    push dword keyHandler
    call KeyHandler_init
    add esp, 4

    %macro setKey 2
        push %2
        push %1
        push dword keyHandler
        call KeyHandler_setKeyPressedFunction
        add  esp, 12
    %endmacro

    %macro setMouse 2
        push %2
        push %1
        push dword keyHandler
        call KeyHandler_setMousePressedFunction
        add  esp, 12
    %endmacro

    setKey KEY_Esc, exit

    setKey KEY_Left,  handle_key_event.case_key_left
    setKey KEY_Right, handle_key_event.case_key_right
    setKey KEY_Up,    handle_key_event.case_key_up
    setKey KEY_Down,  handle_key_event.case_key_down

    setKey KEY_Tab,  handle_key_event.case_key_tab

    setKey KEY_A,  handle_key_event.case_key_a
    setKey KEY_S,  handle_key_event.case_key_s
    setKey KEY_D,  handle_key_event.case_key_d
    setKey KEY_F,  handle_key_event.case_key_f
    setKey KEY_G,  handle_key_event.case_key_g
    setKey KEY_H,  handle_key_event.case_key_h
    setKey KEY_J,  handle_key_event.case_key_j
    setKey KEY_K,  handle_key_event.case_key_k

    setKey KEY_R,  handle_key_event.case_key_r

    setKey KEY_1,  handle_key_event.case_key_a
    setKey KEY_2,  handle_key_event.case_key_s
    setKey KEY_3,  handle_key_event.case_key_d
    setKey KEY_4,  handle_key_event.case_key_f
    setKey KEY_5,  handle_key_event.case_key_g
    setKey KEY_6,  handle_key_event.case_key_h
    setKey KEY_7,  handle_key_event.case_key_j
    setKey KEY_8,  handle_key_event.case_key_k

;    setMouse sfMouseLeft,  handle_mouse_event.left_button
;    setMouse sfMouseRight, handle_mouse_event.right_button

;    push circuit
;    push dword 0x0
;    push dword 4; y
;    push dword 4; x
;    push dword COMPONENT_AND; type
;    call Component_create
;    add  esp, 20
;
;    push dword 0
;    lea  eax, [circuit + Circuit.components]
;    push eax
;    call Array_remove ;im still shoked that this function work
;    add  esp, 8

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
        jz   .key_pressed
        cmp  dword [event + sfEvent.type], sfEvtKeyReleased
        jz   .key_released
        cmp  dword [event + sfEvent.type], sfEvtMouseButtonPressed
        jz   .mouse_pressed
        cmp  dword [event + sfEvent.type], sfEvtMouseButtonReleased
        jz   .mouse_released
        cmp  dword [event + sfEvent.type], sfEvtMouseWheelMoved
        jz   handle_wheel_event
        jmp pollevent_loop

        .key_pressed:
            push dword [event + sfKeyEvent.keyCode]
            push dword keyHandler
            call KeyHandler_keyPressed
            add  esp, 8
        jmp  pollevent_loop

        .key_released:
            push dword [event + sfKeyEvent.keyCode]
            push dword keyHandler
            call KeyHandler_keyReleased
            add  esp, 8
        jmp  pollevent_loop

        .mouse_pressed:
            push dword [event + sfMouseButtonEvent.button]
            push dword keyHandler
            call KeyHandler_mousePressed
            add  esp, 8
        jmp  pollevent_loop

        .mouse_released:
            push dword [event + sfMouseButtonEvent.button]
            push dword keyHandler
            call KeyHandler_mouseReleased
            add  esp, 8
        jmp  pollevent_loop

    pollevent_end:

;    push dword [total_time + 4] ; print the time
;    push dword [total_time]
;    push float_patern
;    call printf
;    add  esp, 12

    call handle_mouse_event

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

    cmp byte [updateCircuit], 0
    jz .skip_circuit_update
        push circuit
        call Circuit_update
        add  esp, 4
    .skip_circuit_update:

    push dword 0xFF111111 ; abgr black
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

    push dword sfKeyLShift
    push dword keyHandler
    call KeyHandler_isKeyPressed
    cmp eax, 1
    jne .dontDrawPreview
    call draw_component_preview
    .dontDrawPreview:

    mov ebx, drawComponent
    mov dword [drawComponent + Component.circuit], circuit
    push dword [currentTile + Vector2.y]
    push dword [currentTile + Vector2.x]
    pop  dword [drawComponent + Component.pos + Vector2.x]
    pop  dword [drawComponent + Component.pos + Vector2.y]
    mov  byte [drawComponent + Component.rotation], 0
    component_set_sprite_texture [selectorTexture]
    component_move_sprite_and_draw [int_const_0], [int_const_0]

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

.case_key_left:
    dec dword [currentTile + Vector2.x]

    fld  dword [float_const_n100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.x]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.x]
    ret

.case_key_right:
    inc dword [currentTile + Vector2.x]

    fld  dword [float_const_100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.x]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.x]
    ret

.case_key_up:
    dec dword [currentTile + Vector2.y]

    fld  dword [float_const_n100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.y]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.y]
    ret

.case_key_down:
    inc dword [currentTile + Vector2.y]

    fld  dword [float_const_100]
    fadd dword [viewManager + ViewManager.targetCoord + Vector2.y]
    fstp dword [viewManager + ViewManager.targetCoord + Vector2.y]
    ret

.case_key_tab:
    xor [updateCircuit], byte 1
    ret

.case_key_a:
    mov  dword [cellMode], CELL_NONE
    ret
.case_key_s:
    mov  dword [cellMode], CELL_OFF
    ret
.case_key_d:
    mov  dword [cellMode], CELL_ACTIVE
    ret
.case_key_f:
    mov  dword [cellMode], CELL_ON
    ret
.case_key_g:
    mov  dword [cellMode], CELL_TYPE5
    ret
.case_key_h:
    mov  dword [cellMode], CELL_TYPE6
    ret
.case_key_j:
    mov  dword [cellMode], CELL_TYPE7
    ret
.case_key_k:
    mov  dword [cellMode], CELL_TYPE8
    ret

.case_key_r: ;set rotation
    inc dword [currentRotation]
    cmp dword [currentRotation], 4
    jz .reset
    ret
    .reset:
        mov dword [currentRotation], 0
    ret

handle_key_event_end:
    jmp pollevent_loop


handle_mouse_event:
    push ebp
    mov  ebp, esp

;    push dword sfMouseLeft
    push dword KEY_Q
    push dword keyHandler
;    call KeyHandler_isMousePressed
    call KeyHandler_isKeyPressed
    add  esp, 8
    cmp eax, 1
    jz .left_button

;    push dword sfMouseRight
    push dword KEY_E
    push dword keyHandler
;    call KeyHandler_isMousePressed
    call KeyHandler_isKeyPressed
    add  esp, 8
    cmp eax, 1
    jz .right_button

    jmp handle_mouse_event_end

    .left_button:

        sub esp, 8
        mov eax, esp

;        push dword [viewManager + ViewManager.view]
;        push dword [window]
;        push eax
;        call get_mouse_position
;        add  esp, 12

;        ;x and y are already pushed
;        push esp ;the place x and y are using will be used
;        push circuit
;        call Circuit_convertWorldToCellCoord
;        add  esp, 8

;        pop eax
;        pop edx
;        push edx
;        push eax


;        push eax
;        push edx
        push dword [currentTile + Vector2.x]
        push dword [currentTile + Vector2.y]
        push dword [currentTile + Vector2.x]
        push dword [currentTile + Vector2.y]
        push circuit
        call Circuit_getCellComponent
        add  esp, 12

        cmp  eax, 0  ;if no component just set cell, else remove component first
        jz   .set_cell

        push eax
        call Component_delete
        add  esp, 4

        .set_cell:
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

        sub esp, 8
        mov eax, esp

;        push dword [viewManager + ViewManager.view]
;        push dword [window]
;        push eax
;        call get_mouse_position
;        add  esp, 12
;
;        ;x and y are already pushed
;        push esp ;the place x and y are using will be used
;        push circuit
;        call Circuit_convertWorldToCellCoord
;        add  esp, 8
;
;        pop eax
;        pop edx
;        push edx
;        push eax
;
;        push eax
;        push edx
        push dword [currentTile + Vector2.x]
        push dword [currentTile + Vector2.y]
        push dword [currentTile + Vector2.x]
        push dword [currentTile + Vector2.y]
        push circuit
        call Circuit_getCellComponent
        add  esp, 12

        cmp  eax, 0  ;if no component just set cell, else remove component first
        jz   .right_set_cell

        push eax
        call Component_delete
        add  esp, 4

        .right_set_cell:
        pop eax
        pop edx

        push circuit
        push dword [currentRotation] ;rotation
        push dword eax; y
        push dword edx; x
        push dword [cellMode]; type
        call Component_create
        add  esp, 20

        jmp handle_mouse_event_end

handle_mouse_event_end:
    mov esp, ebp
    pop ebp
    ret

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

;void draw_component_preview
draw_component_preview:
    push ebp
    mov  ebp, esp

    sub esp, 8
    mov ebx, esp

    mov eax, [cellMode]
    mov [drawComponent + Component.type], eax
    mov eax, [currentRotation]
    mov [drawComponent + Component.rotation], eax

    push drawComponent
    add dword [esp], Component.componentHalfSize
    push dword [cellMode]
    push dword circuit
    call Circuit_getHalfsizeFromComponentType
    add esp, 12

    push dword [viewManager + ViewManager.view]
    push dword [window]
    push ebx
    call get_mouse_position
    add  esp, 12

    push esp ;the place x and y are using will be used
    push circuit
    call Circuit_convertWorldToCellCoord
    add  esp, 8

;center around origin
    mov eax, dword [drawComponent + Component.componentHalfSize + Vector2.y]
    sub [esp], eax
;center around origin

    pop dword [drawComponent + Component.pos + Vector2.y]

;center around origin
    mov eax, dword [drawComponent + Component.componentHalfSize + Vector2.x]
    sub [esp], eax
;center around origin

    pop dword [drawComponent + Component.pos + Vector2.x]

;center around top left corner
;    cmp dword [drawComponent + Component.rotation], 0
;    jz .no_swap_halfsize
;    cmp dword [drawComponent + Component.rotation], 2
;    jz .no_swap_halfsize
;        push eax
;        mov eax, dword [drawComponent + Component.componentHalfSize + Vector2.x]
;        sub eax, dword [drawComponent + Component.componentHalfSize + Vector2.y]
;
;        sar edx, 0x1f ;get absolute value
;        xor eax, edx
;        sub eax, edx
;
;        sub dword [drawComponent + Component.pos + Vector2.x], eax
;        add dword [drawComponent + Component.pos + Vector2.y], eax
;
;        pop eax
;    .no_swap_halfsize:
;center around top left corner

    mov dword [drawComponent + Component.circuit], circuit

    push dword [window]
    push drawComponent
    call Component_draw
    add esp, 8

;    add esp, 8
draw_component_preview_end:
    mov esp, ebp
    pop ebp
    ret
