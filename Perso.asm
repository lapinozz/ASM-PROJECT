%include "Vector2.asm"

struc Perso
    .sprite resd 1
    .texture resd 1

    .velocity resb Vector2.size

    .size resb 0
endstruc

; void Perso_update(Peros*)
Perso_update:
    push ebp
    mov  ebp, esp

    ;[ebp + 8] = first param
    ;[ebp + 12] = second param (assuming dword size)

    sub  esp, 16
    mov  eax, [ebp + 8]

    fld  qword [delta_time]
    fmul dword [eax + Perso.velocity + Vector2.x]
    fstp dword [ebp - 4]

;    fld  qword [delta_time]
;    fmul dword [eax + Perso.velocity + Vector2.y]
;    fstp qword [ebp - 8]

    push dword [ebp - 4]
    push int_patern
    call printf
    add  esp, 8

    add esp, 16
    mov esp, ebp
    pop ebp
    ret
Perso_update_end:
