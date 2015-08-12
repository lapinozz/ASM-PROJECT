COMPONENT_AND equ 0

struc Component
    .type          resd 1

    .componentSize resb Vector2.size ;vector2i
    .pos           resb Vector2.size ;vector2i

    .rotation      resd 1

    .circuit       resd 1

    .size resb 0
endstruc


;Component* Component_create(int type, vector2i pos, int rotation, Circuit*)
Component_create:
    push ebp
    mov  ebp, esp

    push Component.size
    call malloc
    mov ebx, eax

    mov eax, [ebp + 8]
    mov [ebx + Component.type], eax

    mov eax, [ebp + 12 + Vector2.x]
    mov [ebx + Component.pos + Vector2.x], eax
    mov eax, [ebp + 12 + Vector2.y]
    mov [ebx + Component.pos + Vector2.y], eax

    mov eax, [ebp + 20]
    mov [ebx + Component.rotation], eax

    mov eax, [ebp + 24]
    mov [ebx + Component.circuit], eax

    push ebx
    lea  eax,  [eax + Circuit.components]
    push eax
    call Array_insert
    add  esp, 8



Component_create_end:
    mov esp, ebp
    pop ebp
    ret

;void Component_update(Component*)
Component_update:
    push ebp
    mov  ebp, esp

    mov  ebx, [ebp + 8]
    mov  eax, [ebx + Component.type]

    cmp eax, COMPONENT_AND
    jz  .case_and

    jmp Component_update_end

    .case_and:
        push dword [ebx + Component.pos + Vector2.y] ;get the 0, 0 case
        push dword [ebx + Component.pos + Vector2.x]
        push dword [ebx + Component.circuit]
        call Circuit_getCellType
        add  esp, 12
        push eax

        push dword [ebx + Component.pos + Vector2.y] ;get the 0, 3 case
        add  dword [esp], 2
        push dword [ebx + Component.pos + Vector2.x]
        push dword [ebx + Component.circuit]
        call Circuit_getCellType
        add  esp, 12

        ;if both cell are off then the output is off else it's on
        cmp  eax, CELL_OFF
        jz  .case_and_off
        cmp  dword [esp], CELL_OFF
        jz  .case_and_off

        .case_and_on:
            push CELL_ACTIVE
            jmp .case_and_set_cell
        .case_and_off:
            push CELL_OFF

        .case_and_set_cell:
        ;set the output cell
        push dword [ebx + Component.pos + Vector2.y]
        add  dword [esp], 1
        push dword [ebx + Component.pos + Vector2.x]
        add  dword [esp], 2
        push dword [ebx + Component.circuit]
        call Circuit_setCellType
        add  esp, 16
        jmp .end_case

    .end_case:

Component_update_end:
    mov esp, ebp
    pop ebp
    ret;    push map_file
;    call read_file
;    add  esp, 4


;void Component_draw(Component*, sfRenderWindow*)
Component_draw:
    push ebp
    mov  ebp, esp
    sub  esp, 8

    mov  ebx, [ebp + 8]
    mov  eax, [ebx + Component.type]

    cmp eax, COMPONENT_AND
    jz  .case_and


    jmp Component_draw_end

    .case_and:
        ;arg #1 = x offset #2 = y offset
        %macro  component_move_sprite_and_draw 2
            mov  eax, [ebx + Component.circuit]
            fild  dword [ebx + Component.pos + Vector2.x]
            fiadd dword %1
            fmul dword [eax + Circuit.caseSize + Vector2.x]
            fild  dword [ebx + Component.pos + Vector2.y]
            fiadd dword %2
            fmul dword [eax + Circuit.caseSize + Vector2.y]

            sub   esp, 8
            fstp dword [esp + 4]
            fstp dword [esp]
            push dword [publicSprite]
            call sfSprite_setPosition
            add  esp, 12

            push dword 0x0
            push dword [publicSprite]
            push dword [window]
            call sfRenderWindow_drawSprite
            add  esp, 8
        %endmacro

        ;arg #1 = texture
        %macro  component_set_sprite_texture 1
            push dword %1
            push dword [publicSprite]
            call sfSprite_setTexture
            add  esp, 8
        %endmacro

        component_set_sprite_texture [inputTexture]
        component_move_sprite_and_draw [int_const_0], [int_const_0]
        component_move_sprite_and_draw [int_const_0], [int_const_2]


        component_set_sprite_texture [outputTexture]
        component_move_sprite_and_draw [int_const_2], [int_const_1]

        component_set_sprite_texture [downLeftTexture]
        component_move_sprite_and_draw [int_const_1], [int_const_0]

        component_set_sprite_texture [topLeftTexture]
        component_move_sprite_and_draw [int_const_1], [int_const_2]

        component_set_sprite_texture [topLeftTexture]
        component_move_sprite_and_draw [int_const_1], [int_const_2]

        component_set_sprite_texture [componentAndTexture]
        component_move_sprite_and_draw [int_const_1], [int_const_1]


        jmp .end_case

    .end_case:

Component_draw_end:
    mov esp, ebp
    pop ebp
    ret
