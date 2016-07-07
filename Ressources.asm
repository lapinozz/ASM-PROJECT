SECTION .data
    perso_texture_file db './res/img/perso.png', 0
    map_texture_file   db './res/img/map.png'  , 0
    font_file          db './res/font/default_font.ttf' , 0
    maptileset_texture_file   db './res/img/tileset.png', 0

    selector_texture_file  db './res/img/selector.png', 0

    input_texture_file  db './res/img/component_input.png', 0
    output_texture_file db './res/img/component_output.png', 0

    top_down_texture_file            db './res/img/component_top_down.png', 0
    left_right_texture_file          db './res/img/component_left_right.png', 0
    top_left_texture_file            db './res/img/component_top_left.png', 0
    top_right_texture_file           db './res/img/component_top_right.png', 0
    down_left_texture_file           db './res/img/component_down_left.png', 0
    down_right_texture_file          db './res/img/component_down_right.png', 0
    top_left_right_texture_file      db './res/img/component_top_left_right.png', 0
    down_left_right_texture_file     db './res/img/component_down_left_right.png', 0
    top_down_left_texture_file       db './res/img/component_top_down_left.png', 0
    top_down_right_texture_file      db './res/img/component_top_down_right.png', 0
    top_down_left_right_texture_file db './res/img/component_top_down_left_right.png', 0

    component_and_texture_file db './res/img/component_and.png', 0
    component_or_texture_file db './res/img/component_or.png', 0
    component_xor_texture_file db './res/img/component_xor.png', 0
    component_not_texture_file db './res/img/component_not.png', 0

SECTION .bss
    perso_texture resd 1

    mapTexture  resd 1
    font        resd 1

    renderState resb sfRenderStates.size

    inputTexture resd 1
    outputTexture resd 1

    selectorTexture resd 1

    topDownTexture          resd 1
    leftRightTexture        resd 1
    topLeftTexture          resd 1
    topRightTexture         resd 1
    downRightTexture        resd 1
    downLeftTexture         resd 1
    topLeftRightTexture     resd 1
    downLeftRightTexture    resd 1
    topDownLeftTexture      resd 1
    topDownRightTexture     resd 1
    topDownLeftRightTexture resd 1

    componentAndTexture resd 1
    componentOrTexture  resd 1
    componentXorTexture resd 1
    componentNotTexture resd 1


SECTION .text

;arg #1 is texture path arg #2 is where to put it
%macro  loadTexture 2
        push 0x0 ;rect pointer
        push dword %1
        call sfTexture_createFromFile
        add esp, 8
        mov [%2], eax
%endmacro


;void load_resources
load_resources:
    push ebp
    mov  ebp, esp

    push font_file
    call sfFont_createFromFile
    add  esp, 4
    mov  [font], eax

;    push 0x0 ;rect pointer
;    push dword maptileset_texture_file
;    call sfTexture_createFromFile
;    add esp, 8
;    mov [mapTexture], eax

    loadTexture maptileset_texture_file, mapTexture
    loadTexture perso_texture_file, perso_texture


    loadTexture input_texture_file, inputTexture
    loadTexture output_texture_file, outputTexture

    loadTexture selector_texture_file, selectorTexture

    loadTexture top_down_texture_file, topDownTexture
    loadTexture left_right_texture_file, leftRightTexture
    loadTexture top_left_texture_file, topLeftTexture
    loadTexture top_right_texture_file, topRightTexture
    loadTexture down_left_texture_file, downLeftTexture
    loadTexture down_right_texture_file, downRightTexture
    loadTexture top_down_left_texture_file, topDownLeftTexture
    loadTexture top_down_right_texture_file, topDownRightTexture
    loadTexture top_left_right_texture_file, topLeftRightTexture
    loadTexture down_left_right_texture_file, downLeftRightTexture
    loadTexture top_down_left_right_texture_file, topDownLeftRightTexture

    loadTexture component_and_texture_file, componentAndTexture
    loadTexture component_or_texture_file, componentOrTexture
    loadTexture component_xor_texture_file, componentXorTexture
    loadTexture component_not_texture_file, componentNotTexture

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

load_resources_end:
    mov esp, ebp
    pop ebp
    ret


