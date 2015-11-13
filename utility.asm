SECTION .data
    RAND_MAX dd 2147483647

SECTION .bss
    rand_seed resd 1

SECTION .text

print_dword_float:
    push ebp
    mov  ebp, esp

    sub  esp, 8
    fld  dword [ebp + 8]
    fstp qword [esp]
    push float_patern
    call printf
    add  esp, 12

print_dword_float_end:
    mov esp, ebp
    pop ebp
    ret

;int rand()
rand:
    push ebp
    mov  ebp, esp

    mov  eax, [rand_seed]
    imul eax, 0x41c64e6d
    add  eax, 0x3039
    and  eax, [RAND_MAX]
    mov  [rand_seed], eax

rand_end:
    mov esp, ebp
    pop ebp
    ret

;void srand(int seed)
srand:
    push ebp
    mov  ebp, esp

    mov  eax, [ebp - 4]
    mov  [rand_seed], eax

srand_end:
    mov esp, ebp
    pop ebp
    ret


;int rand_min_max(int min, int max)
rand_min_max:
    push ebp
    mov  ebp, esp
    push edx
    call rand

    mov  ebx, [ebp + 12];max
    sub  ebx, [ebp + 8] ;min
    add  ebx, 1

    div  ebx

    add  edx, [ebp + 8];min
    mov  eax, edx

rand_min_max_end:
    pop edx
    mov esp, ebp
    pop ebp
    ret


;dword float rand_float()
rand_float:
    push ebp
    mov  ebp, esp
    sub  esp, 4
    call rand

    mov  dword [ebp - 4], eax
    fild dword [ebp - 4]
    fidiv dword [RAND_MAX]
    fstp dword [ebp - 4]
    mov  eax, dword [ebp - 4]

rand_float_end:
    mov esp, ebp
    pop ebp
    ret


;dword float rand_float(float min, float max)
rand_float_min_max:
    push ebp
    mov  ebp, esp
    sub  esp, 4

    call rand_float
    mov  dword [ebp - 4], eax
    fld  dword [ebp + 12]
    fsub dword [ebp + 8]
    fmul dword [ebp - 4]
    fadd dword [ebp + 8]
    fstp dword [ebp - 4]
    mov  eax, [ebp - 4]

rand_float_min_max_end:
    mov esp, ebp
    pop ebp
    ret

;(dword)float lerp_f(float value1, float value2, float interpolation)
lerp_f:
    push ebp
    mov  ebp, esp

    ;(value1 * (1.0f - interpolation)) + (value2 * interpolation);
    fld  dword [float_const_1]
    fsub dword [ebp + 16] ;interpolation
    fmul dword [ebp + 8]  ;value1

    fld  dword [ebp + 12] ;value2
    fmul dword [ebp + 16] ;interpolation

    fadd st1

    fstp dword [ebp + 8]
    mov  eax, [ebp + 8]

lerp_f_end:
    mov esp, ebp
    pop ebp
    ret

;(dword)float lerp_i(int value1, int value2, float interpolation)
lerp_i:
    push ebp
    mov  ebp, esp

    push dword [ebp + 16] ;interpolation
    sub  esp, 8
    fild dword [ebp + 12] ;value2
    fstp dword [esp + 4]
    fild dword [ebp + 8] ;value1
    fstp dword [esp]

    call lerp_f
    add  esp, 12

lerp_i_end:
    mov esp, ebp
    pop ebp
    ret

;char* read_file(char* filepath)
read_file:
    push ebp
    mov  ebp, esp
    sub  esp, 8

    push file_mode_rb
    push dword [ebp + 8]
    call fopen
    add  esp, 8
    mov  [ebp - 4], eax

    push SEEK_END
    push 0x0
    push dword [ebp - 4]
    call fseek
    add  esp, 12

    push dword [ebp - 4]
    call ftell
    add  esp, 4

    push eax

    inc  eax
    push eax
    call malloc
    add  esp, 4
    mov  [ebp - 8], eax

    push SEEK_SET
    push 0x0
    push dword [ebp - 4]
    call fseek
    add  esp, 12

    mov  eax, dword [esp]

    push dword [ebp - 4]
    push dword 1
    push eax
    push dword [ebp - 8]
    call fread
    add  esp, 16

    mov  edx, dword [esp]
    dec  edx
    mov  eax, [ebp - 8]
    mov  dword [eax + edx], 0

read_file_end:
    mov esp, ebp
    pop ebp
    ret

;void get_mouse_position(Vector2f* returnAddr, sfRenderWindow*, sfView*)
get_mouse_position:
    push ebp
    mov  ebp, esp

    sub esp, 8
    mov eax, esp
    push dword [ebp + 12]
    push eax
    call sfMouse_getPositionRenderWindow
    add  esp, 4

    pop  eax
    pop  ebx

    sub  esp, 8
    mov  edx, esp

    push dword [ebp + 16]
    push ebx
    push eax
    push dword [ebp + 12]
    push edx
    call sfRenderWindow_mapPixelToCoords
    add  esp, 16

;    fld dword [esp]     since we return float no need to do conversion
;    fistp dword [esp]
;    fld dword [esp + 4]
;    fistp dword [esp + 4]

    pop eax
    pop edx

    mov ebx, [ebp + 8]
    mov [ebx + Vector2.x], eax
    mov [ebx + Vector2.y], edx

get_mouse_position_end:
    mov esp, ebp
    pop ebp
    ret


;function patern

;function definition
;function_name:
;    push ebp
;    mov  ebp, esp

;    [ebp + 8] = arg1
;    [ebp + 12] = arg2 assuming dword size

;    sub esp, 8 ; make qword place on the stack
;    [ebp - 4]  ; first allocated space
;    [ebp - 8]  ; second allocated space (Assuming dword size)
;    add esp, 8
;
;function_name_end:
;    mov esp, ebp
;    pop ebp
;    ret


;div
;mov eax, 123 ;to divide
;cdq          ;since it's 32bit need to extand sign in EDX
;mov ebx, 100 ;dividend
;div ebx      ;divide
;             ;quotient in EAX and remainder in EDX


;GLOBAL breakpoint
;breakpoint:
