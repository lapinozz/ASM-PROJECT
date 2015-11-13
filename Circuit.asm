
struc Circuit
    .caseSize resb Vector2.size ;float
    .CircuitSize  resb Vector2.size ;int

    .cells1    resb Array.size
    .cells2    resb Array.size

    .currentCells resb 1

    .components   resb Array.size

    .vertexArray resd 1 ;pointer

    .timeSinceUpdate resd 1
    .updateTime resd 1

    .text       resd 1

    .size resb 0
endstruc

struc Cell
    .type resd 1

    .component resd 1 ;Component*

    .size resb 0
endstruc

CELL_NONE   equ 0
CELL_OFF    equ 1
CELL_ACTIVE equ 2 ;invered ACTIVE and ON because ACTIVE is more used
CELL_ON     equ 3
CELL_TYPE5  equ 4
CELL_TYPE6  equ 5
CELL_TYPE7  equ 6
CELL_TYPE8  equ 7

CELL_COLOR_NONE   equ 0xFF0F0F0F
CELL_COLOR_OFF    equ 0xFF0000FF
CELL_COLOR_ON     equ 0xFF00FF00
CELL_COLOR_ACTIVE equ 0xFFFFFFFF

; void Circuit_init(Circuit*, Vector2f caseSize, Vector2i CircuitSize, (dword)float updateTime)
Circuit_init:
    push ebp
    mov  ebp, esp
    push ebx

    call sfText_create
    mov ebx, [ebp + 8]
    mov [ebx + Circuit.text], eax

    push eax

    push dword [font]
    push eax
    call sfText_setFont
    add  esp, 8

    pop eax

    push font_file
    push eax
    call sfText_setString
    add  esp, 8

    mov eax, [ebp + 8]

    mov byte [eax + Circuit.currentCells], byte 0

    mov  ebx, [ebp + 12 + Vector2.x]
    mov dword [eax + Circuit.caseSize + Vector2.x], ebx
    mov  ebx, [ebp + 12 + Vector2.y]
    mov dword [eax + Circuit.caseSize + Vector2.y], ebx

    mov  ebx, [ebp + 20 + Vector2.x]
    mov dword [eax + Circuit.CircuitSize + Vector2.x], ebx
    mov  ebx, [ebp + 20 + Vector2.y]
    mov dword [eax + Circuit.CircuitSize + Vector2.y], ebx

    mov  ebx, [ebp + 28]
    mov  dword [eax + Circuit.updateTime], ebx

    mov  eax, [ebp + 20 + Vector2.x]
    imul eax, [ebp + 20 + Vector2.y]
    inc  eax

    push eax

    push dword 0x0 ;isPointer
    push dword 0 ;count
    push dword 4;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + Circuit.components]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    push dword 0x0 ;isPointer
    push dword eax ;count
    push dword Cell.size ;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + Circuit.cells1]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    pop eax
    push eax

    push dword 0x0 ;isPointer
    push dword eax ;count
    push dword Cell.size ;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + Circuit.cells2]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    pop edx
    push edx

    mov  ebx, [ebp + 8]
    mov  ebx, [ebx + Circuit.cells1 + Array.start]
    xor ecx, ecx
    Circuit_init_loop:
        cmp edx, ecx
        jz Circuit_init_loop_end

;        mov dword [ebx + ecx*Cell.size + Cell.type], dword CELL_NONE
        mov dword [ebx + ecx*Cell.size + Cell.type], dword CELL_OFF
        mov dword [ebx + ecx*Cell.size + Cell.component], dword 0x0

        inc ecx
        jmp Circuit_init_loop
    Circuit_init_loop_end:

    pop edx

    mov  ebx, [ebp + 8]
    mov  ebx, [ebx + Circuit.cells2 + Array.start]
    xor ecx, ecx
    Circuit_init_loop2:
        cmp edx, ecx
        jz Circuit_init_loop_end2

        mov dword [ebx + ecx*Cell.size + Cell.type], dword CELL_NONE
        mov dword [ebx + ecx*Cell.size + Cell.component], dword 0x0

        inc ecx
        jmp Circuit_init_loop2
    Circuit_init_loop_end2:

    mov  ebx, [ebp + 8]
    call sfVertexArray_create
    mov  [ebx + Circuit.vertexArray], eax

    push sfQuads
    push dword [ebx + Circuit.vertexArray]
    call sfVertexArray_setPrimitiveType
    add  esp, 8

Circuit_init_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret

;void Circuit_invertCell(Circuit*)
Circuit_invertCell:
    push ebp
    mov  ebp, esp
    push ebx

    mov  ebx, [ebp + 8]
    xor [ebx + Circuit.currentCells], byte 1

Circuit_invertCell_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret

;void Circuit_draw(Circuit*, sfRenderWindow*)
Circuit_draw:
    push ebp
    mov  ebp, esp
    sub  esp, 20
    push ebx

    mov ebx, [ebp + 8]

    cmp [ebx + Circuit.currentCells], byte 0
    lea eax, [ebx + Circuit.cells1]
    je Circuit_getVertexs_cellChoice_end
    lea eax, [ebx + Circuit.cells2]
    Circuit_getVertexs_cellChoice_end:
    mov [ebp - 20], eax

    push dword [ebx + Circuit.vertexArray]
    call sfVertexArray_clear
    add  esp, 4

    mov  ebx, [ebp + 8]
    mov  edx, [ebx + Circuit.CircuitSize + Vector2.x]
    imul edx, [ebx + Circuit.CircuitSize + Vector2.y]
    inc  edx

    mov  eax, [float_const_0]
    mov  [ebp - 4], eax
    mov  [ebp - 8], eax

    xor ecx, ecx
    Circuit_getVertexs_loop:
        cmp edx, ecx
        jz Circuit_getVertexs_loop_end

        push edx
        push ecx
        push ebx

        mov  eax, [ebp - 20]
        mov  eax, [eax + Array.start]
        mov  eax, [eax + ecx*Cell.size + Cell.type] ;now contain type of current cell

        cmp eax, CELL_NONE
        mov edx, CELL_COLOR_NONE
        je Circuit_getVertexs_colorTest_end
        cmp eax, CELL_OFF
        mov edx, CELL_COLOR_OFF
        je Circuit_getVertexs_colorTest_end
        cmp eax, CELL_ON
        mov edx, CELL_COLOR_ON
        je Circuit_getVertexs_colorTest_end
        cmp eax, CELL_ACTIVE
        mov edx, CELL_COLOR_ACTIVE
        je Circuit_getVertexs_colorTest_end

        Circuit_getVertexs_colorTest_end:
        mov [ebx - 16], edx

        push  dword [float_const_0] ;y texture coord
        push  dword [float_const_0] ;x texture coord
        push  dword [ebx - 16]      ;color
        sub  esp, 8
        fld  dword [float_const_0]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]       ;unload on the stack at pos.y
        fld  dword [float_const_0]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]           ;unload on the stack at pos.x
        push dword [ebx + Circuit.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  ebx, [esp]
        push  dword [float_const_0] ;y texture coord
        push  dword [float_const_0] ;x texture coord
        push dword [ebx - 16]      ;color
        sub  esp, 8
        fld  dword [float_const_0]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]
        fld  dword [ebx + Circuit.caseSize + Vector2.x]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]
        push dword [ebx + Circuit.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  ebx, [esp]
        push  dword [float_const_0] ;y texture coord
        push  dword [float_const_0] ;x texture coord
        push dword [ebx - 16]      ;color
        sub  esp, 8
        fld  dword [ebx + Circuit.caseSize + Vector2.y]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]
        fld  dword [ebx + Circuit.caseSize + Vector2.x]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]
        push dword [ebx + Circuit.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  ebx, [esp]
        push  dword [float_const_0] ;y texture coord
        push  dword [float_const_0] ;x texture coord
        push dword [ebx - 16]      ;color
        sub  esp, 8
        fld  dword [ebx + Circuit.caseSize + Vector2.y]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]
        fld  dword [float_const_0]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]
        push dword [ebx + Circuit.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  eax, [esp + 4]
        cdq
        mov  ebx, [esp]
        div  dword [ebx + Circuit.CircuitSize + Vector2.x]
        mov  [ebp - 4], edx
        mov  [ebp - 8], eax

        fild dword [ebp - 4]
        fmul dword [ebx + Circuit.caseSize + Vector2.x]
        fstp dword [ebp - 4]

        fild dword [ebp - 8]
        fmul dword [ebx + Circuit.caseSize + Vector2.y]
        fstp dword [ebp - 8]

        pop ebx
        pop ecx
        pop edx

        inc ecx
        jmp Circuit_getVertexs_loop
    Circuit_getVertexs_loop_end:

;    mov eax,  dword [ebx + Circuit.texture]
;    mov [renderState + sfRenderStates.texture],  eax
;    mov [renderState + sfRenderStates.texture], dword 0x000

    push dword renderState
    push dword [ebx + Circuit.vertexArray]
    push dword [ebp + 12]
    call sfRenderWindow_drawVertexArray
    add  esp, 12

    mov  ebx, [ebp + 8]

    mov  eax, [ebx + Circuit.components + Array.start]

    mov  edx, [ebx + Circuit.components + Array.count]
    xor  ecx, ecx
    .components_loop:
        cmp edx, ecx
        jz .components_loop_end

        push eax
        push edx
        push ecx

        push dword [ebp + 12]
        push dword [eax + ecx*4]
        call Component_draw
        add  esp, 8

        pop ecx
        pop edx
        pop eax

        inc ecx
        jmp .components_loop
    .components_loop_end:

Circuit_draw_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret

;void Circuit_setCellType(Circuit*, Vector2i tileCoords, int type)
Circuit_setCellType:
    push ebp
    mov  ebp, esp

    push ebx
    push eax
    push ecx
    push edx

    mov  ebx, [ebp + 8]

    mov  eax, [ebp + 12 + Vector2.y]
    imul eax, [ebx + Circuit.CircuitSize + Vector2.x]
    add  eax, [ebp + 12 + Vector2.x]
    inc eax

    mov  ecx, [ebp + 20]

    cmp [ebx + Circuit.currentCells], byte 0
    mov edx, Circuit.cells1
    je .cellChoice_end
    mov edx, Circuit.cells2
    .cellChoice_end:

    mov ebx, [ebx + edx + Array.start]

    mov [ebx + eax*Cell.size + Cell.type], ecx

    pop  edx
    pop  ecx
    pop  eax
    pop  ebx

Circuit_setCellType_end:
    mov esp, ebp
    pop ebp
    ret

;void Circuit_setCellComponent(Circuit*, Vector2i tileCoords, Component* ptr)
Circuit_setCellComponent:
    push ebp
    mov  ebp, esp

    push ebx
    push eax
    push ecx
    push edx

    mov  ebx, [ebp + 8]

    mov  eax, [ebp + 12 + Vector2.y]
    imul eax, [ebx + Circuit.CircuitSize + Vector2.x]
    add  eax, [ebp + 12 + Vector2.x]
    inc eax

    mov  ecx, [ebp + 20]

    cmp [ebx + Circuit.currentCells], byte 0
    mov edx, Circuit.cells1
    je .cellChoice_end
    mov edx, Circuit.cells2
    .cellChoice_end:

    mov ebx, [ebx + edx + Array.start]

    mov [ebx + eax*Cell.size + Cell.component], ecx

    pop  edx
    pop  ecx
    pop  eax
    pop  ebx

Circuit_setCellComponent_end:
    mov esp, ebp
    pop ebp
    ret

;int Circuit_getCellType(Circuit*, Vector2i tileCoord)
Circuit_getCellType:
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx

    mov  ebx, [ebp + 8]

    mov  eax, [ebp + 12 + Vector2.y]
    imul eax, [ebx + Circuit.CircuitSize + Vector2.x]
    add  eax, [ebp + 12 + Vector2.x]
    inc eax

    mov  ecx, [ebp + 20]

    cmp [ebx + Circuit.currentCells], byte 0
    mov edx, Circuit.cells1
    je .cellChoice_end
    mov edx, Circuit.cells2
    .cellChoice_end:

    mov ebx, [ebx + edx + Array.start]

    mov eax, [ebx + eax*Cell.size + Cell.type]

    pop  edx
    pop  ecx
    pop  ebx

Circuit_getCellType_end:
    mov esp, ebp
    pop ebp
    ret

;Component* Circuit_getCellComponent(Circuit*, Vector2i tileCoord)
Circuit_getCellComponent:
    push ebp
    mov  ebp, esp

    push ebx
    push ecx
    push edx

    mov  ebx, [ebp + 8]

    mov  eax, [ebp + 12 + Vector2.y]
    imul eax, [ebx + Circuit.CircuitSize + Vector2.x]
    add  eax, [ebp + 12 + Vector2.x]
    inc eax

    mov  ecx, [ebp + 20]

    cmp [ebx + Circuit.currentCells], byte 0
    mov edx, Circuit.cells1
    je .cellChoice_end
    mov edx, Circuit.cells2
    .cellChoice_end:

    mov ebx, [ebx + edx + Array.start]

    mov eax, [ebx + eax*Cell.size + Cell.component]

    pop  edx
    pop  ecx
    pop  ebx

Circuit_getCellComponent_end:
    mov esp, ebp
    pop ebp
    ret

;void Circuit_update(Circuit*)
Circuit_update:
    push ebp
    mov  ebp, esp
    sub  esp, 16

    ;note to myself: you cant use if in assembly x)

    mov  ebx, [ebp + 8]

    fld qword [delta_time]
    fadd dword [ebx + Circuit.timeSinceUpdate]
    fst dword [ebx + Circuit.timeSinceUpdate]
    fld  dword [ebx + Circuit.updateTime]
    fxch ST1   ;exchange ST1 and ST0
    fucomip ST1 ;do something like comparing ST1 and ST0 then pop
    fstp ST0   ;pop
    jbe Circuit_update_end ;jmp if greater (or less (or whatever i dont remember))

    fld  dword [ebx + Circuit.timeSinceUpdate]
    fsub dword [ebx + Circuit.updateTime]
    fstp dword [ebx + Circuit.timeSinceUpdate]

    cmp [ebx + Circuit.currentCells], byte 0
    lea eax, [ebx + Circuit.cells1]
    lea edx, [ebx + Circuit.cells2]
    je Circuit_update_cellChoice_end
    lea eax, [ebx + Circuit.cells2]
    lea edx, [ebx + Circuit.cells1]
    Circuit_update_cellChoice_end:
    mov [ebp - 4], edx
    mov [ebp - 8], eax

    mov ecx, ebx

    mov ebx, [edx + Array.start]
    mov eax, [eax + Array.start]

    mov  edx, [ecx + Circuit.CircuitSize + Vector2.x]
    imul edx, [ecx + Circuit.CircuitSize + Vector2.y]
    inc  edx

    xor ecx, ecx
    inc ecx
    Circuit_update_loop:
        cmp edx, ecx
        jz  Circuit_update_loop_end

        push edx
        push ebx

        mov edx, dword [eax + ecx*Cell.size + Cell.type]
        push edx

        mov edx, [eax + ecx*Cell.size + Cell.component]
        mov [ebx + ecx*Cell.size + Cell.component], edx

        mov [ebp - 4], dword CELL_NONE
        mov [ebp - 16], dword CELL_NONE
        mov [ebp - 8], dword CELL_NONE
        mov [ebp - 12], dword CELL_NONE

        mov ebx, [ebp + 8]

        cmp ecx, [ebx + Circuit.CircuitSize + Vector2.x] ; check if top row
        jl  .skip_top_row

        mov edx, [ebx + Circuit.CircuitSize + Vector2.x] ; up neighbor
        sub ecx, edx
        mov edx, dword [eax + ecx*Cell.size + Cell.type]
        mov [ebp - 4], edx
        mov edx, [ebx + Circuit.CircuitSize + Vector2.x]
        add ecx, edx

        .skip_top_row:

        push eax
        mov eax, ecx                                      ; check if right row
        cdq
        div dword [ebx + Circuit.CircuitSize + Vector2.x]
        pop eax
        cmp edx, 0
        je .skip_right_row

        push edx
        mov edx, dword [eax + (ecx+1)*Cell.size + Cell.type] ; right neighbor
        mov [ebp - 8], edx
        pop edx

        .skip_right_row:

        cmp edx, 1                                           ;check if left row
        je  .skip_left_row

        mov edx, dword [eax + (ecx-1)*Cell.size + Cell.type]  ;left neighbor
        mov [ebp - 16], edx

        .skip_left_row:

        push eax                                               ;check if bottom row
        mov eax, ecx
        dec eax
        cdq
        div dword [ebx + Circuit.CircuitSize + Vector2.x]
        mov edx, [ebx + Circuit.CircuitSize + Vector2.y]
        dec edx
        cmp eax, edx
        pop eax
        je .skip_bottom_row

        mov edx, [ebx + Circuit.CircuitSize + Vector2.x]      ;down neighbor
        add ecx, edx
        mov edx, dword [eax + ecx*Cell.size + Cell.type]
        mov [ebp - 12], edx
        mov edx, [ebx + Circuit.CircuitSize + Vector2.x]
        sub ecx, edx

        .skip_bottom_row:

        pop edx
        pop ebx

        push eax

        cmp edx, CELL_NONE
        je Circuit_update_loop_case_none
        cmp edx, CELL_OFF
        je Circuit_update_loop_case_off
        cmp edx, CELL_ON
        je Circuit_update_loop_case_on
        cmp edx, CELL_ACTIVE
        je Circuit_update_loop_case_active
        jmp Circuit_update_loop_case_end

        Circuit_update_loop_case_none:
            mov dword [ebx + ecx*Cell.size + Cell.type], 0
            jmp Circuit_update_loop_case_end

        Circuit_update_loop_case_off:
            cmp [ebp - 4], dword CELL_ACTIVE
            je .case_neighbor_active
            cmp [ebp - 8], dword CELL_ACTIVE
            je .case_neighbor_active
            cmp [ebp - 12], dword CELL_ACTIVE
            je .case_neighbor_active
            cmp [ebp - 16], dword CELL_ACTIVE
            je .case_neighbor_active
            jmp .case_neighbor_active_end

            .case_neighbor_active:
                mov dword [ebx + ecx*Cell.size + Cell.type], CELL_ACTIVE
                jmp Circuit_update_loop_case_end
            .case_neighbor_active_end:

            mov dword [ebx + ecx*Cell.size + Cell.type], CELL_OFF
            jmp Circuit_update_loop_case_end

        Circuit_update_loop_case_on:
            cmp [ebp - 4], dword CELL_OFF
            je  .case_neighbor_off
            cmp [ebp - 8], dword CELL_OFF
            je  .case_neighbor_off
            cmp [ebp - 12], dword CELL_OFF
            je  .case_neighbor_off
            cmp [ebp - 16], dword CELL_OFF
            je  .case_neighbor_off
            jmp .case_neighbor_off_end

            .case_neighbor_off:
                mov dword [ebx + ecx*Cell.size + Cell.type], CELL_OFF
                jmp Circuit_update_loop_case_end

            .case_neighbor_off_end:
                mov dword [ebx + ecx*Cell.size + Cell.type], CELL_ON
                jmp Circuit_update_loop_case_end

        Circuit_update_loop_case_active:
            mov dword [ebx + ecx*Cell.size + Cell.type], CELL_ON
            jmp Circuit_update_loop_case_end

        Circuit_update_loop_case_end:

        pop eax

        pop edx

        inc ecx
        jmp Circuit_update_loop
    Circuit_update_loop_end:

    mov  ebx, [ebp + 8]
    mov  eax, [ebx + Circuit.components + Array.start]
    mov  edx, [ebx + Circuit.components + Array.count]
    xor  ecx, ecx
    .components_loop:
        cmp edx, ecx
        jz .components_loop_end

        push eax
        push edx
        push ecx

        push dword [eax + ecx*4]
        call Component_update
        add  esp, 4

        pop ecx
        pop edx
        pop eax

        inc ecx
        jmp .components_loop
    .components_loop_end:

    mov  ebx, [ebp + 8]
    xor [ebx + Circuit.currentCells], byte 1

Circuit_update_end:
    mov esp, ebp
    pop ebp
    ret

;void Circuit_convertWorldToCellCoord(Circuit*, Vector2i* returnAddr, Vector2f coord)
Circuit_convertWorldToCellCoord:
    push ebp
    mov  ebp, esp

    sub  esp, 8

    mov  ebx, [ebp + 8]
    fld   dword [ebp + 16 + Vector2.x]
    fdiv  dword [ebx + Circuit.caseSize + Vector2.x]
    fsub  dword [float_const_0_5]
    fistp dword [esp]

    fld   dword [ebp + 16 + Vector2.y]
    fdiv  dword [ebx + Circuit.caseSize + Vector2.y]
    fsub  dword [float_const_0_5]
    fistp dword [esp + 4]

    mov  ebx, [ebp + 12]
    pop  dword [ebx + Vector2.y]
    pop  dword [ebx + Vector2.x]

Circuit_convertWorldToCellCoord_end:
    mov esp, ebp
    pop ebp
    ret

