
struc Array
    .start resd 1

    .count resd 1
    .dataSize resd 1
    .isPointer resd 1

    .size resb 0
endstruc


;void Array_init(Array*, int data_size, int count, dword isPointer)
Array_init:
    push ebp
    mov  ebp, esp

    mov  eax, [ebp + 8]
    mov  ebx, [ebp + 20]
    mov  dword  [eax + Array.isPointer], ebx
    mov  ebx, [ebp + 12]
    mov  dword [eax + Array.dataSize], ebx
    mov  ecx, [ebp + 16]
    mov  dword [eax + Array.count], ecx

    imul  ecx, ebx ; count * dataSize
    push ecx
    call malloc
    add  esp, 8
    mov  ebx, [ebp + 8]
    mov [ebx + Array.start], eax

Array_init_end:
    mov esp, ebp
    pop ebp
    ret

;void Array_resize(Array*, int newCount)
Array_resize:
    push ebp
    mov  ebp, esp

    mov  eax, [ebp + 8]
    mov  ebx, [ebp + 12]
    mov  ecx, [eax + Array.dataSize]
    imul  ebx, ecx ; newCount * Array.dataSize
    push ebx
    push dword [eax + Array.start]
    call realloc
    add  esp, 8

Array_resize_end:
    mov esp, ebp
    pop ebp
    ret

;void Array_insert(Array*, int value)
Array_insert:
    push ebp
    mov  ebp, esp

    mov ebx, [ebp + 8]
    mov eax, [ebx + Array.count]
    inc eax

    push eax
    push dword [ebp + 8]
    call Array_resize
    add  esp, 8

    mov  ebx, [ebp + 8]
    mov  edx, [ebp + 12]
    mov  ecx, [ebx + Array.start]
    mov  eax, [ebx + Array.count]
    imul  eax, [ebx + Array.dataSize]

    mov  [ecx + eax], edx

Array_insert_end:
    mov esp, ebp
    pop ebp
    ret

