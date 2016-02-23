COMPONENT_AND equ CELL_NONE
COMPONENT_OR  equ CELL_OFF
COMPONENT_XOR equ CELL_ACTIVE
COMPONENT_NOT equ CELL_ON

COMPONENT_BRIDGE_UP_DOWN equ CELL_TYPE5
COMPONENT_BRIDGE_LEFT_RIGHT equ CELL_TYPE6

struc Component
    .type          resd 1

    .pos           resb Vector2.size ;vector2i
    .componentHalfSize resb Vector2.size ;vector2i eg realSize = 3,3 : halfSize = 1,1

    .rotation      resd 1

    .circuit       resd 19

    .size resb 0
endstruc

%macro  component_move_sprite_and_draw 2
    push dword %2
    push dword %1
    push dword esp
    push dword [ebx + Component.componentHalfSize + Vector2.y]
    push dword [ebx + Component.componentHalfSize + Vector2.x]
    push dword [ebx + Component.rotation]
    call rotate_point_around_origin
    add esp, 16

    mov  eax, [ebx + Component.circuit]
    fld dword [eax + Circuit.caseSize + Vector2.x]
    fmul dword [float_const_0_5]

    fild  dword [ebx + Component.pos + Vector2.x]
    fiadd dword [esp]
    fmul dword [eax + Circuit.caseSize + Vector2.x]
    fild  dword [ebx + Component.pos + Vector2.y]
    fiadd dword [esp + 4]
    fmul dword [eax + Circuit.caseSize + Vector2.y]

    fadd st2  ;compensate for the offset caused by the origin TODO: fix this shit
    fstp dword [esp + 4]
    fadd
    fstp dword [esp]

    push dword [publicSprite]
    call sfSprite_setPosition
    add  esp, 12

    push dword 0x0
    push dword [publicSprite]
    push dword [window]
    call sfRenderWindow_drawSprite
    add  esp, 12
%endmacro

%macro  component_rotate_sprite 0
    push dword [float_const_n90]
    fild dword [ebx + Component.rotation]
    fmul dword [esp]
    fstp dword [esp]
    push dword [publicSprite]
    call sfSprite_setRotation
    add  esp, 8
%endmacro

%macro  component_reset_sprite_rotation 0
    push dword [float_const_0]
    push dword [publicSprite]
    call sfSprite_setRotation
    add  esp, 8
%endmacro

;arg #1 = texture
%macro  component_set_sprite_texture 1
    push dword %1
    push dword [publicSprite]
    call sfSprite_setTexture
    add  esp, 8
%endmacro

;arg #1 = x coord #2 = y coord
%macro  component_get_circuit_cell_component 2
    push dword %2
    push dword %1
    push dword esp
    push dword [ebx + Component.componentHalfSize + Vector2.y]
    push dword [ebx + Component.componentHalfSize + Vector2.x]
    push dword [ebx + Component.rotation]
    call rotate_point_around_origin
    add esp, 16

    mov  dword ecx [ebx + Component.pos + Vector2.y]
    add  dword [esp + 4],ecx
    mov  dword ecx, [ebx + Component.pos + Vector2.x]
    add  dword [esp], ecx
    push dword [ebx + Component.circuit]
    call Circuit_getCellComponent
    add  esp, 12
%endmacro

;arg #1 = x coord #2 = y coord #3 = Component*
%macro  component_set_circuit_cell_component 3
    push dword %3
    push dword %2
    push dword %1
    push dword esp
    push dword [ebx + Component.componentHalfSize + Vector2.y]
    push dword [ebx + Component.componentHalfSize + Vector2.x]
    push dword [ebx + Component.rotation]
    call rotate_point_around_origin
    add esp, 16

    mov  dword ecx, [ebx + Component.pos + Vector2.y]
    add  dword [esp + 4], ecx
    mov  dword ecx, [ebx + Component.pos + Vector2.x]
    add  dword [esp], ecx
    push dword [ebx + Component.circuit]
    call Circuit_setCellComponent
    add  esp, 16
%endmacro

;arg #1 = x coord #2 = y coord
%macro  component_get_circuit_cell_type 2
    push dword %2
    push dword %1
    push dword esp
    push dword [ebx + Component.componentHalfSize + Vector2.y]
    push dword [ebx + Component.componentHalfSize + Vector2.x]
    push dword [ebx + Component.rotation]
    call rotate_point_around_origin
    add esp, 16

    mov  dword ecx, [ebx + Component.pos + Vector2.y]
    add  dword [esp + 4], ecx
    mov  dword ecx, [ebx + Component.pos + Vector2.x]
    add  dword [esp], ecx
    push dword [ebx + Component.circuit]
    call Circuit_getCellType
    add  esp, 12
%endmacro

;arg #1 = x coord #2 = y coord #3 = invert cell or not (type have to be already pushed on the stack)
%macro  component_set_circuit_cell_type 2-3 1
    push dword %2
    push dword %1
    push dword esp
    push dword [ebx + Component.componentHalfSize + Vector2.y]
    push dword [ebx + Component.componentHalfSize + Vector2.x]
    push dword [ebx + Component.rotation]
    call rotate_point_around_origin
    add esp, 16

    mov  dword ecx, [ebx + Component.pos + Vector2.y]
    add  dword [esp + 4], ecx
    mov  dword ecx, [ebx + Component.pos + Vector2.x]
    add  dword [esp], ecx
    push dword [ebx + Component.circuit]

    %if %3 == 1
        call Circuit_invertCell
    %endif

    call Circuit_setCellType

    %if %3 == 1
        call Circuit_invertCell
    %endif

    add  esp, 16
%endmacro

;arg #1 = x coord #2 = y coord #3 = type
%macro  component_set_circuit_cell_type_no_push  3-4 1
    push %3
    component_set_circuit_cell_type %1, %2, %4
%endmacro

;arg #1 = x2 coord #2 = y2 coord #3 = bride abreviation
%macro  component_bridge_case  3

    .case_bridge_%3: ;up/down
        component_get_circuit_cell_type 0, 0

        cmp eax, CELL_OFF
        jz  .case_bridge_%3_off
        cmp eax, CELL_ACTIVE
        jz  .case_bridge_%3_active
        cmp eax, CELL_ON
        jz  .case_bridge_%3_on
        jmp .end_case ;else end

        .case_bridge_%3_off:
            component_get_circuit_cell_type %1, %2
            cmp eax, CELL_ACTIVE
            jz  .case_bridge_%3_off_active
            cmp eax, CELL_ON
            jz  .case_bridge_%3_off_on
            jmp .end_case ;else end

        .case_bridge_%3_active:
            component_get_circuit_cell_type %1, %2
            cmp eax, CELL_OFF
            jz  .case_bridge_%3_active_off
            jmp .end_case ;else end

        .case_bridge_%3_on:
            component_get_circuit_cell_type %1, %2
            cmp eax, CELL_OFF
            jz  .case_bridge_%3_off_on
            jmp .end_case ;else end

        .case_bridge_%3_off_active:
            component_set_circuit_cell_type_no_push 0, 0, CELL_ACTIVE
            jmp .end_case
        .case_bridge_%3_off_on:
            component_set_circuit_cell_type_no_push 0, 0, CELL_OFF
            component_set_circuit_cell_type_no_push  %1, %2, CELL_OFF
            jmp .end_case
        .case_bridge_%3_active_off:
            component_set_circuit_cell_type_no_push  %1, %2, CELL_ACTIVE
            jmp .end_case
%endmacro

;Component* Component_create(int type, vector2i pos, int rotation, Circuit*)
Component_create:
    push ebp
    mov  ebp, esp
    sub  esp, 4

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
    push ebx

    lea  eax,  [eax + Circuit.components]
    push eax
    call Array_insert
    add  esp, 8

    pop ebx
    mov eax, [ebp + 8]

    push ebx
    add dword [esp], Component.componentHalfSize
    push dword [ebp + 8]
    push dword [ebp + 24]
    call Circuit_getHalfsizeFromComponentType
    add esp, 12

    cmp dword [ebx + Component.rotation], 0
    jz .no_swap_halfsize
    cmp dword [ebx + Component.rotation], 2
    jz .no_swap_halfsize
        push eax
        mov eax, dword [ebx + Component.componentHalfSize + Vector2.x]
        sub eax, dword [ebx + Component.componentHalfSize + Vector2.y]

        sar edx, 0x1f ;get absolute value
        xor eax, edx
        sub eax, edx

        sub dword [ebx + Component.pos + Vector2.x], eax
        add dword [ebx + Component.pos + Vector2.y], eax

        pop eax
    .no_swap_halfsize:

    cmp eax, COMPONENT_AND
    jz  .basic_gate_init
    cmp eax, COMPONENT_OR
    jz  .basic_gate_init
    cmp eax, COMPONENT_XOR
    jz  .basic_gate_init
    cmp eax, COMPONENT_NOT
    jz  .gate_not
    cmp eax, COMPONENT_BRIDGE_UP_DOWN
    jz  .bridge_ud
    cmp eax, COMPONENT_BRIDGE_LEFT_RIGHT
    jz  .bridge_lr

    jmp .end_case

    .bridge_ud:
        component_set_circuit_cell_component 0, 1, ebx
        component_set_circuit_cell_component 0, 2, ebx
        component_set_circuit_cell_component 0, 3, ebx
        jmp .end_case

    .bridge_lr:
        component_set_circuit_cell_component 1, 0, ebx
        component_set_circuit_cell_component 2, 0, ebx
        component_set_circuit_cell_component 3, 0, ebx
        jmp .end_case

    .basic_gate_init:
        component_get_circuit_cell_type 0, 0
        cmp eax, CELL_NONE      ;if cell is already set we dont touch it
        jnz .basic_gate_skip_0_0
        component_set_circuit_cell_type_no_push 0, 0, CELL_OFF, 0 ;else we set it to off
        .basic_gate_skip_0_0:

        component_get_circuit_cell_type 0, 2
        cmp eax, CELL_NONE      ;if cell is already set we dont touch it
        jnz .basic_gate_skip_0_2
        component_set_circuit_cell_type_no_push 0, 2, CELL_OFF, 0 ;else we set it to off
        .basic_gate_skip_0_2:

        component_get_circuit_cell_type 2, 1
        cmp eax, CELL_NONE      ;if cell is already set we dont touch it
        jnz .basic_gate_skip_2_1
        component_set_circuit_cell_type_no_push 2, 1, CELL_OFF, 0 ;else we set it to off
        .basic_gate_skip_2_1:

        component_set_circuit_cell_component 0, 0, ebx
        component_set_circuit_cell_component 1, 0, ebx
        component_set_circuit_cell_component 0, 1, ebx
        component_set_circuit_cell_component 1, 1, ebx
        component_set_circuit_cell_component 2, 1, ebx
        component_set_circuit_cell_component 0, 2, ebx
        component_set_circuit_cell_component 1, 2, ebx

        jmp .end_case

    .gate_not:
        component_get_circuit_cell_type 0, 0
        cmp eax, CELL_NONE      ;if cell is already set we dont touch it
        jnz .not_gate_skip_0_0
        component_set_circuit_cell_type_no_push 0, 0, CELL_OFF, 0 ;else we set it to off
        .not_gate_skip_0_0:

        component_get_circuit_cell_type 2, 0
        cmp eax, CELL_NONE      ;if cell is already set we dont touch it
        jnz .not_gate_skip_2_0
        component_set_circuit_cell_type_no_push 2, 0, CELL_OFF, 0 ;else we set it to off
        .not_gate_skip_2_0:

        component_set_circuit_cell_component 0, 0, ebx
        component_set_circuit_cell_component 1, 0, ebx
        component_set_circuit_cell_component 2, 0, ebx

        jmp .end_case

    .end_case:

Component_create_end:
    mov esp, ebp
    pop ebp
    ret

;void Component_update(Component)
Component_update:
    push ebp
    mov  ebp, esp

    mov  ebx, [ebp + 8]
    mov  eax, [ebx + Component.type]

    cmp eax, COMPONENT_AND
    jz  .case_and
    cmp eax, COMPONENT_OR
    jz  .case_or
    cmp eax, COMPONENT_XOR
    jz  .case_xor
    cmp eax, COMPONENT_NOT
    jz  .gate_not
    cmp eax, COMPONENT_BRIDGE_UP_DOWN
    je  .case_bridge_ud ;up/down
    cmp eax, COMPONENT_BRIDGE_LEFT_RIGHT
    je  .case_bridge_lr ;left/right

    jmp .end_case

    component_bridge_case 0, 4, ud ;big hax
    component_bridge_case 4, 0, lr

    .gate_not:
        component_get_circuit_cell_type 0, 0

        ;if off turn on else turn off
        cmp eax, CELL_OFF
        jz  .gate_not_on
        jmp .gate_not_off

        .gate_not_on:
            push CELL_ACTIVE
            jmp .gate_not_set
        .gate_not_off:
            push CELL_OFF
            jmp .gate_not_set

        .gate_not_set:
            component_set_circuit_cell_type 2, 0
        jmp .end_case

    .case_and:
        call .basic_gate_get_cell
        ;if both cell are off then the output is off else it's on
        cmp  eax, CELL_OFF  ;if first input is off the output is off
        jz  .basic_gate_off
        cmp  edx, CELL_OFF  ;if second input is off the output is off
        jz  .basic_gate_off
        jmp .basic_gate_on ;else it's on
    .case_or:
        call .basic_gate_get_cell
        ;if any cell is on then the output is on else it's off
        cmp  eax, CELL_OFF  ;if first input is not off the output is on
        jnz  .basic_gate_on
        cmp  edx, CELL_OFF ;if second input is not off the output is on
        jnz  .basic_gate_on
        jmp .basic_gate_off ;else it's off
    .case_xor:
        call .basic_gate_get_cell
        ;if cells are different then output is on
        cmp  eax, edx  ;if first input and second input are different output is off
        jnz  .basic_gate_on
        jmp .basic_gate_off ;else it's off

    .basic_gate_on:
            push CELL_ACTIVE
            jmp .basic_gate_set_cell
    .basic_gate_off:
            push CELL_OFF
            jmp .basic_gate_set_cell

    .basic_gate_get_cell:
        component_get_circuit_cell_type 0, 0
        mov edx, eax
        component_get_circuit_cell_type 0, 2
    .basic_gate_get_cell_end:
        ret

    .basic_gate_set_cell:
        component_set_circuit_cell_type 2, 1
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

    component_rotate_sprite

    mov  eax, [ebx + Component.circuit]

    sub  esp, 8
    fld  dword [eax + Circuit.caseSize]
    fmul dword [float_const_0_5]
    fst  dword [esp + 4]
    fstp dword [esp]
    push dword [publicSprite]
    call sfSprite_setOrigin
    add  esp, 8

    mov  eax, [ebx + Component.type]

    cmp eax, COMPONENT_AND
    je  .case_and
    cmp eax, COMPONENT_OR
    je  .case_or
    cmp eax, COMPONENT_XOR
    je  .case_xor
    cmp eax, COMPONENT_NOT
    je  .gate_not
    cmp eax, COMPONENT_BRIDGE_UP_DOWN
    je  .case_bridge_ud ;up/down
    cmp eax, COMPONENT_BRIDGE_LEFT_RIGHT
    je  .case_bridge_lr ;left/right

    jmp .end_case

    .case_bridge_ud: ;up/down
        component_set_sprite_texture [topDownTexture]
        component_move_sprite_and_draw [int_const_0], [int_const_1]
        component_move_sprite_and_draw [int_const_0], [int_const_2]
        component_move_sprite_and_draw [int_const_0], [int_const_3]
        jmp .end_case

    .case_bridge_lr: ;left/right
        component_set_sprite_texture [leftRightTexture]
        component_move_sprite_and_draw [int_const_1], [int_const_0]
        component_move_sprite_and_draw [int_const_2], [int_const_0]
        component_move_sprite_and_draw [int_const_3], [int_const_0]
        jmp .end_case

    .gate_not:
        component_set_sprite_texture [inputTexture]
        component_move_sprite_and_draw [int_const_0], [int_const_0]
        component_set_sprite_texture [outputTexture]
        component_move_sprite_and_draw [int_const_2], [int_const_0]
        component_set_sprite_texture [componentNotTexture]
        component_reset_sprite_rotation
        component_move_sprite_and_draw [int_const_1], [int_const_0]
        jmp .end_case
    .case_and:
        push dword [componentAndTexture]
        jmp .basic_gate
    .case_or:
        push dword [componentOrTexture]
        jmp .basic_gate
    .case_xor:
        push dword [componentXorTexture]
        jmp .basic_gate

    .basic_gate:
        call draw_basic_gate
        add  esp, 4
        component_reset_sprite_rotation
        component_set_sprite_texture dword [esp]
        component_move_sprite_and_draw [int_const_1], [int_const_1]
        jmp .end_case

    .end_case:

Component_draw_end:
    mov esp, ebp
    pop ebp
    ret

;void Component_delete(Component*)
Component_delete:
    push ebp
    mov  ebp, esp
    sub  esp, 4

    mov ebx, [ebp + 8]
    mov eax, [ebx + Component.type]

    cmp eax, COMPONENT_AND
    jz  .basic_gate
    cmp eax, COMPONENT_OR
    jz  .basic_gate
    cmp eax, COMPONENT_XOR
    jz  .basic_gate
    cmp eax, COMPONENT_NOT
    jz  .gate_not
    cmp eax, COMPONENT_BRIDGE_UP_DOWN
    jz  .bridge_ud
    cmp eax, COMPONENT_BRIDGE_LEFT_RIGHT
    jz  .bridge_lr

    jmp .end_case

    .basic_gate:
        component_set_circuit_cell_component 0, 0, 0
        component_set_circuit_cell_component 1, 0, 0
        component_set_circuit_cell_component 0, 1, 0
        component_set_circuit_cell_component 1, 1, 0
        component_set_circuit_cell_component 2, 1, 0
        component_set_circuit_cell_component 0, 2, 0
        component_set_circuit_cell_component 1, 2, 0

        jmp .end_case

    .gate_not:
        component_set_circuit_cell_component 0, 0, 0
        component_set_circuit_cell_component 1, 0, 0
        component_set_circuit_cell_component 2, 0, 0
        jmp .end_case

    .bridge_ud:
        component_set_circuit_cell_component 0, 1, 0
        component_set_circuit_cell_component 0, 2, 0
        component_set_circuit_cell_component 0, 3, 0
        jmp .end_case

    .bridge_lr:
        component_set_circuit_cell_component 1, 0, 0
        component_set_circuit_cell_component 2, 0, 0
        component_set_circuit_cell_component 3, 0, 0
        jmp .end_case
;
    .end_case:

    mov  ebx, [ebp + 8]

    push ebx
    mov  eax, [ebx + Component.circuit]
    lea  eax, [eax + Circuit.components]
    push eax
    call Array_find
    add  esp, 8

    push eax
    mov  eax, [ebx + Component.circuit]
    lea  eax, [eax + Circuit.components]
    push eax
    call Array_remove
    add  esp, 8

Component_delete_end:
    mov esp, ebp
    pop ebp
    ret

draw_basic_gate:
    component_set_sprite_texture [inputTexture]
    component_move_sprite_and_draw [int_const_0], [int_const_0]
    component_move_sprite_and_draw [int_const_0], [int_const_2]

    component_set_sprite_texture [outputTexture]
    component_move_sprite_and_draw [int_const_2], [int_const_1]

    component_set_sprite_texture [downLeftTexture]
    component_move_sprite_and_draw [int_const_1], [int_const_0]

    component_set_sprite_texture [topLeftTexture]
    component_move_sprite_and_draw [int_const_1], [int_const_2]
draw_basic_gate_end:
    ret
