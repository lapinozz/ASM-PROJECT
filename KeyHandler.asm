KEY_COUNT   equ 101
MOUSE_COUNT equ 5

struc KeyHandler
    .keyStatus   resb Array.size
    .mouseStatus resb Array.size

    .keyFunctionTable   resb Array.size
    .mouseFunctionTable resb Array.size

    .size resb 0
endstruc

; void KeyHandler_init(KeyHandler*)
KeyHandler_init:
    push ebp
    mov  ebp, esp
    push ebx

    push dword 0x0 ;isPointer
    push dword KEY_COUNT ;count
    push dword 1;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + KeyHandler.keyStatus]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    push dword 0x0 ;isPointer
    push dword MOUSE_COUNT ;count
    push dword 1 ;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + KeyHandler.mouseStatus]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    push dword 0x0 ;isPointer
    push dword KEY_COUNT*2 ;count
    push dword 4;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + KeyHandler.keyFunctionTable]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

    push dword 0x0 ;isPointer
    push dword MOUSE_COUNT*2 ;count
    push dword 4 ;dataSize
    mov  eax, [ebp + 8]
    lea  eax, [eax + KeyHandler.mouseFunctionTable]
    push dword eax ;Array*
    call Array_init
    add  esp, 16

;    jmp test_function_end
;
;    test_function:
;    push msg
;    call printf
;    add  esp, 4
;    test_function_end:
;
;    push test_function
;    push KEY_J
;    push dword [ebp + 8]
;    call KeyHandler_setKeyPressedFunction
;    add  esp, 12

KeyHandler_init_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret

%macro  KeyHandler_macro_pressed 2
; void KeyHandler_keyPressed(KeyHandler*, int key)
KeyHandler_%1%2:
%define Pressed  1
%define Released 0

    push ebp
    mov  ebp, esp

    mov  eax, [ebp + 8]
    mov  eax, [eax + KeyHandler.%1Status + Array.start]
    mov  edx, [ebp + 12]
    mov  byte [eax + edx], %2

    mov  eax, [ebp + 8]
    mov  eax, [eax + KeyHandler.%1FunctionTable + Array.start]
    mov  eax, [eax + edx*8 + %2*4]

    cmp  eax, 0
    jz   KeyHandler_%1%2_end

    call eax

%undef Pressed
%undef Released
KeyHandler_%1%2_end:
    mov esp, ebp
    pop ebp
    ret
%endmacro

KeyHandler_macro_pressed key, Pressed
KeyHandler_macro_pressed key, Released
KeyHandler_macro_pressed mouse, Pressed
KeyHandler_macro_pressed mouse, Released

%macro  KeyHandler_macro_isPressed 2
; int KeyHandler_isKeyPressed(KeyHandler*, int key)
KeyHandler_is%2Pressed:
    push ebp
    mov  ebp, esp
    push ebx

    mov  ecx, [ebp + 8]
    mov  ecx, [ecx + KeyHandler.%1Status + Array.start]
    mov  edx, [ebp + 12]
    xor  eax, eax
    mov  al, byte [ecx + edx]

KeyHandler_is%2Pressed_end:
    pop ebx
    mov esp, ebp
    pop ebp
    ret
%endmacro

KeyHandler_macro_isPressed key, Key
KeyHandler_macro_isPressed mouse, Mouse

%macro  KeyHandler_macro_setFunction 3
; void KeyHandler_setKeyPressedFunction(KeyHandler*, int key, void* function)
KeyHandler_set%2%3Function:
%define Pressed  1
%define Released 0
    push ebp
    mov  ebp, esp

    mov  eax, [ebp + 8]
    mov  edx, [ebp + 12]
    mov  eax, [eax + KeyHandler.%1FunctionTable + Array.start]
    lea  eax, [eax + edx*8 + %3*4]
    mov  edx, [ebp + 16]
    mov  [eax], edx

%undef Pressed
%undef Released
KeyHandler_set%2%3Function_end:
    mov esp, ebp
    pop ebp
    ret
%endmacro

KeyHandler_macro_setFunction key, Key, Pressed
KeyHandler_macro_setFunction key, Key, Released
KeyHandler_macro_setFunction mouse, Mouse, Pressed
KeyHandler_macro_setFunction mouse, Mouse, Released

