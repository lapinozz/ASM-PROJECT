
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

    imul ecx, ebx ; count * dataSize
    push ecx
    push 1
    call calloc
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
;
;    global b
;    b:

    mov  eax, [ebp + 8]
    mov  ebx, [ebp + 12]
    mov  [eax + Array.count], ebx
    mov  ecx, [eax + Array.dataSize]
    imul ebx, ecx ; newCount * Array.dataSize
    push ebx
    push dword [eax + Array.start]
    call realloc
    add  esp, 8

    mov  ebx, [ebp + 8]
    mov  [ebx + Array.start], eax

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

    dec  eax
    imul  eax, [ebx + Array.dataSize]

    mov  [ecx + eax], edx

Array_insert_end:
    mov esp, ebp
    pop ebp
    ret

;void Array_remove(Array*, int pos(start from 0)
Array_remove:
    push ebp
    mov  ebp, esp

    mov  ebx, [ebp + 8]
    mov  ecx, [ebx + Array.start]
    mov  eax, [ebp + 12]
    imul eax, [ebx + Array.dataSize]
    add  eax, ecx ;calculate the adress of the *pos* element

    mov edi, eax ;destination
    add eax, 4
    mov esi, eax ;source

    mov eax, [ebx + Array.count]
    sub eax, [ebp + 12]
    dec eax
    mov ecx, eax ;number of time to iterate

    cld
    rep movsd

    mov ebx, [ebp + 8]
    mov eax, [ebx + Array.count]
    dec eax

    push eax
    push dword [ebp + 8]
    call Array_resize
    add  esp, 8

Array_remove_end:
    mov esp, ebp
    pop ebp
    ret


;return the index(starting at zero) of the find element, -1 if not found
;int Array_find(Array*, int toFind)
Array_find:
    push ebp
    mov  ebp, esp

    mov ebx, [ebp + 8]
    mov edx, [ebx + Array.count]
    mov eax, [ebx + Array.start]
    mov esi, [ebx + Array.dataSize]
    mov ebx, [ebp + 12]

    xor ecx, ecx
    .loop:
        cmp ecx, edx
        jz .loop_end

        cmp [eax], ebx
        jz  Array_find_end

        add eax, esi

        inc ecx
        jmp .loop
    .loop_end:

    mov ecx, -1

Array_find_end:
    mov eax, ecx

    mov esp, ebp
    pop ebp
    ret
