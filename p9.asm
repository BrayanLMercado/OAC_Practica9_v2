%include "pc_io.inc"
section .data
    NL: db  13,10
    NL_L:    equ $-NL
    sizeTag: db "Ingresa Tamaño Del Arreglo: ",0
    captureTag: db "Ingresa Valor Decimal De 3 Dígitos: ",0
    orderedTag: db "El Arreglo Ordenado Es: ",10,0

section .bss
    size resb 4
    num resb 3
    array resw 256
    i resb 4
    j resb 4
    tmp resb 3
    cad resb 256
    cadDec resb 256

section .text
global _start:
    _start:mov esi,cad
    call capturarArreglo
    call ordenarArreglo
    ;Exit Call
    mov eax,1
    mov ebx,0
    int 0x80

capturarDecimal:
    pushad
    mov eax,3
    mov ebx,0
    mov ecx,tmp
    mov edx,4
    int 0x80
    mov ecx,3
    call st2num
    popad
    ret

st2num:
    pushad
    xor ebx,ebx
    lea edi,tmp
    .next:
        movzx eax,byte[edi]
        inc edi
        sub al,'0'
        imul ebx,10
        add ebx,eax
        loop .next
    mov eax,ebx
    mov [tmp],eax
    popad
    ret

limpiarCadena:
    push esi
    mov esi,[cadDec]
    xor esi,esi
    mov [cadDec],esi
    pop esi
    ret

capturarArreglo:
    pushad
    mov edx,sizeTag
    call puts
    call capturarDecimal
    mov eax,[tmp]
    mov [size],eax
    mov ecx,[size]
    mov edi,0x0
    lea ebx,array
    .capture:
        mov edx,captureTag
        call puts
        call capturarDecimal
        mov eax,[tmp]
        mov [ebx+4*edi],eax
        inc edi
        loop .capture
    popad
    ret

imprimirArreglo:
    pushad
    mov ebx,array
    mov ecx,[size]
    mov edi,0x0
    .print:
        mov eax,[ebx+edi*4]
        call printDec
        call new_line
        inc edi
        loop .print
    popad
    ret

printDec:
    pushad
    mov bx,0xA
    xor edx,edx
    mov ecx,8
    mov esi,cadDec
    call limpiarCadena
    .convert:
        xor dx,dx
        div bx
        add dl,'0'
        mov [esi+ecx],dl
        loop .convert
    mov eax,4
    mov ebx,1
    mov ecx,cadDec
    mov edx,12
    int 0x80
    popad
    ret

ordenarArreglo:
    pushad
    mov dword[i],1
    .outLoop:
        lea esi,array
        mov edx,[size]
        .check:
            mov eax,[esi]
            add esi,0x4
            mov ebx,[esi]
            cmp eax,ebx
            jb .next
        .exchange:
            mov [tmp],eax
            mov eax,ebx
            mov ebx,[tmp]
            mov [esi],ebx
            sub esi,0x4
            mov [esi],eax
            add esi,0x4
        .next:
            dec edx
            cmp edx,[i]
            jne .check
    inc dword[i]
    mov ecx,[i]
    cmp ecx,[size]
    jne .outLoop
    mov edx,orderedTag
    call puts
    call imprimirArreglo
    popad
    ret

;Subrutinas Auxiliares
printBin:
    pushad
    mov edi,eax
    mov ecx,32
    .cycle:
        xor al,al
        shl edi,1
        adc al,'0'
        call putchar
        loop .cycle
    popad
    ret

new_line:
    pushad
    mov eax, 4
    mov ebx, 1
    mov ecx, NL
    mov edx, NL_L
    int 0x80
    popad
    ret

printHex:
    pushad
    mov edx, eax
    mov ebx, 0fh
    mov cl, 28
    .nxt: shr eax,cl
    .msk: and eax,ebx
    cmp al, 9
    jbe .menor
    add al,7
    .menor:add al,'0'
    mov byte [esi],al
    inc esi
    mov eax, edx
    cmp cl, 0
    je .print
    sub cl, 4
    cmp cl, 0
    ja .nxt
    je .msk
    .print: mov eax, 4
    mov ebx, 1
    sub esi, 8
    mov ecx, esi
    mov edx, 8
    int 80h
    popad
    ret

clearReg:
    xor eax,eax ; Limpieza De Registros
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    ret