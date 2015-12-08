
struc Map
    .caseSize resb Vector2.size ;float
    .mapSize  resb Vector2.size ;int

    .tileIDs     resb Array.size
    .vertexArray resd 1 ;pointer

    .texture  resd 1 ;point
    .tileSize resb Vector2.size ;float
    .sheetSize resb Vector2.size ;int

    .size resb 0
endstruc

; void Map_init(Map*, Vector2f caseSize, Vector2i mapSize, sfTexture* texture, Vector2f tileSize, Vector2i SheetSize)
Map_init:
    push ebp
    mov  ebp, esp
    push ebx

    mov  eax, [ebp + 8]

    mov  ebx, [ebp + 12 + Vector2.x]
    mov dword [eax + Map.caseSize + Vector2.x], ebx
    mov  ebx, [ebp + 12 + Vector2.y]
    mov dword [eax + Map.caseSize + Vector2.y], ebx

    mov  ebx, [ebp + 20 + Vector2.x]
    mov dword [eax + Map.mapSize + Vector2.x], ebx
    mov  ebx, [ebp + 20 + Vector2.y]
    mov dword [eax + Map.mapSize + Vector2.y], ebx

    mov  ebx, [ebp + 28]
    mov dword [eax + Map.texture], ebx

    mov  ebx, [ebp + 32 + Vector2.x]
    mov dword [eax + Map.tileSize + Vector2.x], ebx
    mov  ebx, [ebp + 32 + Vector2.y]
    mov dword [eax + Map.tileSize + Vector2.y], ebx

    mov  ebx, [ebp + 40 + Vector2.x]
    mov dword [eax + Map.sheetSize + Vector2.x], ebx
    mov  ebx, [ebp + 40 + Vector2.y]
    mov dword [eax + Map.sheetSize + Vector2.y], ebx

    mov  eax, [ebp + 20 + Vector2.x]
    imul eax, [ebp + 20 + Vector2.y]
    inc  eax

    push eax

    push dword 0x0 ;isPointer
    push dword eax ;count
    push dword 4 ;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + Map.tileIDs]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    pop edx

    mov  ebx, [ebp + 8]
    mov  ebx, [ebx + Map.tileIDs + Array.start]
    xor ecx, ecx
    Map_init_loop:
        cmp edx, ecx
        jz Map_init_loop_end

        mov dword [ebx + ecx*4], dword 0x0

        inc ecx
        jmp Map_init_loop
    Map_init_loop_end:

    mov dword [ebx + 11*4], dword 0 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 12*4], dword 1 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 13*4], dword 2 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 14*4], dword 3 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 16*4], dword 4 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 17*4], dword 5 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 18*4], dword 6 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT
    mov dword [ebx + 19*4], dword 7 ;ONLY FORFREAKING TEST PURPOSE AKA DONT FORGET TO REMOVE THIS SHIT

    mov  ebx, [ebp + 8]
    call sfVertexArray_create
    mov  [ebx + Map.vertexArray], eax

    push sfQuads
    push dword [ebx + Map.vertexArray]
    call sfVertexArray_setPrimitiveType
    add  esp, 8

Map_init_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret

;void Map_draw(Map*, sfRenderWindow*)
Map_draw:
    push ebp
    mov  ebp, esp
    sub  esp, 12
    push ebx

    mov  ebx, [ebp + 8]
    push dword [ebx + Map.vertexArray]
    call sfVertexArray_clear
    add  esp, 4

    mov  ebx, [ebp + 8]
    mov  edx, [ebx + Map.mapSize + Vector2.x]
    imul edx, [ebx + Map.mapSize + Vector2.y]
    inc  edx

    mov  eax, [float_const_0]
    mov  [ebp - 4], eax
    mov  [ebp - 8], eax

    xor ecx, ecx
    Map_getVertexs_loop:
        cmp edx, ecx
        jz Map_getVertexs_loop_end

        push edx
        push ecx
        push ebx

        mov  eax, [ebx + Map.tileIDs + Array.start]
        mov  eax, [eax + ecx*4] ;now contain tileID of current tile
        cdq
        div dword [ebx + Map.sheetSize + Vector2.x]
        mov  [ebp - 12], edx
        mov  [ebp - 16], eax

        fild dword [ebp - 12]
        fmul dword [ebx + Map.tileSize + Vector2.x]
        fstp dword [ebp - 12]

        fild dword [ebp - 16]
        fmul dword [ebx + Map.tileSize + Vector2.y]
        fstp dword [ebp - 16]

        sub  esp, 8
        fld  dword [float_const_0]
        fadd dword [ebp - 16]       ;y textureCoords
        fstp dword [esp + 4]       ;unload on the stack at textureCoords.y
        fld  dword [float_const_0]
        fadd dword [ebp - 12]       ;x textureCoords
        fstp dword [esp]           ;unload on the stack at textureCoords.x
        push dword 0xFFFFFFFF      ;color
        sub  esp, 8
        fld  dword [float_const_0]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]       ;unload on the stack at pos.y
        fld  dword [float_const_0]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]           ;unload on the stack at pos.x
        push dword [ebx + Map.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  ebx, [esp]
        sub  esp, 8
        fld  dword [float_const_0]
        fadd dword [ebp - 16]       ;y textureCoords
        fstp dword [esp + 4]       ;unload on the stack at textureCoords.y
        fld  dword [ebx + Map.tileSize + Vector2.x]
        fadd dword [ebp - 12]       ;x textureCoords
        fstp dword [esp]           ;unload on the stack at textureCoords.x
        push dword 0xFFFFFFFF      ;color
        sub  esp, 8
        fld  dword [float_const_0]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]
        fld  dword [ebx + Map.caseSize + Vector2.x]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]
        push dword [ebx + Map.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  ebx, [esp]
        sub  esp, 8
        fld  dword [ebx + Map.tileSize + Vector2.x]
        fadd dword [ebp - 16]       ;y textureCoords
        fstp dword [esp + 4]       ;unload on the stack at textureCoords.y
        fld  dword [ebx + Map.tileSize + Vector2.x]
        fadd dword [ebp - 12]       ;x textureCoords
        fstp dword [esp]           ;unload on the stack at textureCoords.x
        push dword 0xFFFFFFFF      ;color
        sub  esp, 8
        fld  dword [ebx + Map.caseSize + Vector2.y]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]
        fld  dword [ebx + Map.caseSize + Vector2.x]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]
        push dword [ebx + Map.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  ebx, [esp]
        sub  esp, 8
        fld  dword [ebx + Map.tileSize + Vector2.x]
        fadd dword [ebp - 16]       ;y textureCoords
        fstp dword [esp + 4]       ;unload on the stack at textureCoords.y
        fld  dword [float_const_0]
        fadd dword [ebp - 12]       ;x textureCoords
        fstp dword [esp]           ;unload on the stack at textureCoords.x
        push dword 0xFFFFFFFF      ;color
        sub  esp, 8
        fld  dword [ebx + Map.caseSize + Vector2.y]
        fadd dword [ebp - 8]       ;y pos
        fstp dword [esp + 4]
        fld  dword [float_const_0]
        fadd dword [ebp - 4]       ;x pos
        fstp dword [esp]
        push dword [ebx + Map.vertexArray]
        call sfVertexArray_append
        add  esp, 24

        mov  eax, [esp + 4]
        cdq
        mov  ebx, [esp]
        div  dword [ebx + Map.mapSize + Vector2.x]
        mov  [ebp - 4], edx
        mov  [ebp - 8], eax

        fild dword [ebp - 4]
        fmul dword [ebx + Map.caseSize + Vector2.x]
        fstp dword [ebp - 4]

        fild dword [ebp - 8]
        fmul dword [ebx + Map.caseSize + Vector2.y]
        fstp dword [ebp - 8]

        pop ebx
        pop ecx
        pop edx

        inc ecx
        jmp Map_getVertexs_loop
    Map_getVertexs_loop_end:

    mov eax,  dword [ebx + Map.texture]
;    mov [renderState + sfRenderStates.texture],  eax
    mov [renderState + sfRenderStates.texture], dword 0x000

    push dword renderState
    push dword [ebx + Map.vertexArray]
    push dword [ebp + 12]
    call sfRenderWindow_drawVertexArray
    add  esp, 12

Map_draw_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret

;void Map_setTitle(Map*, Vector2i tileCoords, int tile)
Map_setTile:
    push ebp
    mov  ebp, esp



Map_setTile_end:
    mov esp, ebp
    pop ebp
    ret
