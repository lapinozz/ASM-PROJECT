struc ViewManager
    .view        resd 1
    .window      resd 1
    .targetCoord resb Vector2.size
    .speed       resb Vector2.size
    .smoothness  resd 1 ;float

    .size  resb 0
endstruc


;void ViewManager_init(ViewManager*, sfRenderWindow* window, Vector2f speed, float smoothness)
ViewManager_init:
    push ebp
    mov  ebp, esp

    push dword [ebp + 12] ;window
    call sfRenderWindow_getDefaultView
    add  esp, 4
    mov  ebx, [ebp + 8]
    mov  [ebx + ViewManager.view], eax

    mov  eax, [ebp + 12]
    mov  [ebx + ViewManager.window], eax

    mov  eax, [ebp + 16 + Vector2.x]
    mov  [ebx + ViewManager.speed + Vector2.x], eax
    mov  eax, [ebp + 16 + Vector2.y]
    mov  [ebx + ViewManager.speed + Vector2.y], eax

    mov  eax, [ebp + 24]
    mov  [ebx + ViewManager.smoothness], eax

ViewManager_init_end:
    mov esp, ebp
    pop ebp
    ret

;void ViewManager_update(ViewManager*)
ViewManager_update:
    push ebp
    mov  ebp, esp

    ;getView()->setCenter(lerp(targetPos, getView()->getCenter(), getSmooth()));

    mov  ebx, [ebp + 8]
    sub  esp, 8 ;make some place for the return value
    lea  eax, [ebp - 8]
    push dword [ebx + ViewManager.view]
    push eax
    call sfView_getCenter
    add  esp, 4

    mov  ebx, [ebp + 8]
    push dword [ebx + ViewManager.smoothness]
    push dword [ebp - 8]
    push dword [ebx + ViewManager.targetCoord + Vector2.x]
    call lerp_f
    add  esp , 12
    mov  [ebp - 8], eax
;
    mov  ebx, [ebp + 8]
    push dword [ebx + ViewManager.smoothness]
    push dword [ebp - 4]
    push dword [ebx + ViewManager.targetCoord + Vector2.y]
    call lerp_f
    add  esp , 12
    mov  [ebp - 4], eax

    mov  ebx, [ebp + 8]
    push dword [ebp - 4]
    push dword [ebp - 8]
    push dword [ebx + ViewManager.view]
    call sfView_setCenter
    add  esp, 12

    mov  ebx, [ebp + 8]
    push dword [ebx + ViewManager.view]
    push dword [ebx + ViewManager.window]
    call sfRenderWindow_setView
    add  esp, 8

ViewManager_update_end:
    mov esp, ebp
    pop ebp
    ret

;void ViewManager_zoomAtMouse(ViewManager*, float zoom)
ViewManager_zoomAtMouse:
    push ebp
    mov  ebp, esp

    push 1000
    push int_patern
    call printf
    add  esp, 8

    mov  ebx, [ebp + 8]

    sub esp, 8
    mov eax, esp

    push dword [ebx + ViewManager.view]
    push dword [ebx + ViewManager.window]
    push eax
    call get_mouse_position
    add  esp, 12

    mov  ebx, [ebp + 8]
    fld  dword [esp]
    fadd dword [ebx + ViewManager.targetCoord + Vector2.x]
    fstp dword [ebx + ViewManager.targetCoord + Vector2.x]
    fld  dword [esp + 4]
    fadd dword [ebx + ViewManager.targetCoord + Vector2.y]
    fstp dword [ebx + ViewManager.targetCoord + Vector2.y]

    push dword [ebp + 12]
    push dword [ebx + ViewManager.view]
    call sfView_zoom
    add  esp, 8
;
    mov eax, esp
    mov ebx, [ebp + 8]

    push dword [ebx + ViewManager.view]
    push dword [ebx + ViewManager.window]
    push eax
    call get_mouse_position
    add  esp, 12

    mov ebx, [ebp + 8]
    fld  dword [ebx + ViewManager.targetCoord + Vector2.x]
    fsub dword [esp]
    fstp dword [ebx + ViewManager.targetCoord + Vector2.x]
    fld  dword [ebx + ViewManager.targetCoord + Vector2.y]
    fsub dword [esp + 4]
    fstp dword [ebx + ViewManager.targetCoord + Vector2.y]
;
;ViewManager_zoomAtMouse_end:
    mov esp, ebp
    pop ebp
    ret
