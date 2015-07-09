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

    push eax
    push eax
    call print_dword_float
    add  esp, 4
    pop  eax

rand_float_min_max_end:
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
