%include "Vector2.asm"

struc Perso
    .sprite resd 1

    .velocity resb Vector2.size

    .size resb 0
endstruc

; void Perso_update(Peros*)
Perso_update:
    push ebp
    mov  ebp, esp

    ;[ebp + 8] = first param
    ;[ebp + 12] = second param (assuming dword size)

    sub  esp, 8
    mov  eax, [ebp + 8]
    fld  qword [delta_time]
    fmul dword [eax + Perso.velocity + Vector2.x]
    fstp dword [esp]

    fld  qword [delta_time]
    fmul dword [eax + Perso.velocity + Vector2.y]
    fstp dword [esp + 4]

;    push dword [ebp - 4]
;    call print_dword_float
;    push dword [ebp - 8]
;    call print_dword_float

    mov  eax, [ebp + 8]
    push dword [eax + Perso.sprite]
    call sfSprite_move
    add esp, 20

Perso_update_end:
    mov esp, ebp
    pop ebp
    ret

;void Perso_draw(Perso*, sfWindow*)
Perso_draw:
    push ebp
    mov  ebp, esp

    push dword 0x0 ;renderstate pointer
    mov  eax, [ebp + 8]
    push dword [eax + Perso.sprite]
    push dword [ebp + 12]
    call sfRenderWindow_drawSprite
    add  esp, 12

Perso_draw_end:
    mov esp, ebp
    pop ebp
    ret

;Perso* Perso_create(void)
Perso_create:
    push ebp
    mov  ebp, esp

    push Perso.size
    call malloc
    mov  [ebp - 4], eax

    call sfSprite_create
    mov  ebx, [ebp - 4]
    mov dword [ebx + Perso.sprite], dword eax

    push 0x1 ;reset rect
    push dword [perso_texture]
    push dword [ebx + Perso.sprite]
    call sfSprite_setTexture
    add  esp, 12

    mov  ebx, [ebp - 4]
    mov  eax, dword [float_const_2]
    mov  [ebx + Perso.velocity + Vector2.x], eax
    mov  eax, dword [float_const_0]
    mov  [ebx + Perso.velocity + Vector2.y], eax

    mov  eax, [ebp - 4]

Perso_create_end:
    mov esp, ebp
    pop ebp
    ret
