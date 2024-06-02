[org 0x7c00]

start:
    mov ax, 0
    int 0x10                    ; clear screen and set video mode to 40x25
    mov word [snake], 0x0c14    ; middle, 14 = 20x, 0c = 12y
    mov word [len], 2           ; len is twice the amount of snake members; because len is actualy the amount of bytes and each member uses 2
    mov word [apple], 0x050f
    mov byte [lost], 0
input:
    mov ah, 0x11
    int 0x16        ; check input
    jz .wait        ; continue if no input

    mov ah, 0x10
    int 0x16        ; get input


    cmp al, 'r'     ; check if restart
    je start

    .notC:
    cmp al, 's'
    jne .notS
    mov word [dir], 0x0100
    .notS:
    cmp al, 'w'
    jne .notW
    mov word [dir], 0xff00  ; two's complement of 0x0100
    .notW:
    cmp al, 'd'
    jne .notD
    mov word [dir], 0x0001
    .notD:
    cmp al, 'a'
    jne .notA
    mov word [dir], 0xffff
    .notA:
    .wait:
        mov ah, 0x86    ; wait
        mov cx, 0x01    ; time to wait
        mov dx, 0x7100  ; time to wait
        int 0x15        ; call wait
        jc input        ; get input again if not finished waiting

    cmp byte [lost], 1  ; check if lost
    jne copy            ; continue if not
    jmp input           ; wait longer if lost
copy:
    mov bx, word [len]                  ; set index

    .loop:
        sub bx, 2                       ; decrease index
        cmp bx, 0                       ; check if finished
        je move                         ; if so jmp eat
        mov ax, word [snake + bx - 2]   ; copy down
        mov word [snake + bx], ax       ; copy down
        jmp .loop                       ; repeat
move:
    mov ax, [dir]
    add word [snake], ax    ; move head

    cmp byte [snake], 255   ; check if out of bounds
    jne .inHN
    add word [snake], 40    ; add 40 to also increase y by one as it decrease because of the addition

    .inHN:                  ; in horizontal negative direction
    cmp byte [snake], 40
    jne .inHP
    mov byte [snake], 0

    .inHP:
    cmp byte [snake + 1], 255
    jne .inVN
    mov byte [snake + 1], 24

    .inVN:
    cmp byte [snake + 1], 25
    jne collision
    mov byte [snake + 1], 0

collision:
    mov bx, 0
    mov ax, word [snake]
    .loop:
        add bx, 2           ; index
        cmp bx, word [len]
        je .checkapple
        cmp ax, [snake + bx]; check if self collision
        jne .notlost        ; skip if not lost
        mov byte [lost], 1  ; set to lost
        jmp clear
        .notlost:
        jmp .loop           ; again if not finished
    .checkapple:
    cmp ax, word [apple]    ; check apple
    jne clear
    add word [len], 2       ; increase length
rand:
    mov ah, 0               ; set mode
    int 0x1a                ; clock interrupt
    mov bl, dl              ; mov dl to bl to keep after clearing

    mov al, bl              ; move to ax to divide
    xor dx, dx              ; clear dx for divide
    xor ah, ah              ; clear ah for divide
    mov cl, 40              ; move 40 to cl for division

    div cl                  ; divide ax by 40 to get x
    mov [apple], ah         ; move remainder to apple x


    mov al, bl              ; move to ax to divide
    mov cl, 25              ; move 25 to cl for division
    xor dx, dx              ; clear dx for divide
    xor ah, ah              ; clear ah for divide

    div cl                  ; divide ax by 25 to get y
    mov [apple + 1], ah     ; move remainder to y
clear:
    mov ax, 0x0000          ; set video mode
    int 0x10                ; clear screen
checklost:
    cmp byte [lost], 1      ; check if lost
    jne print               ; continue if not
    mov ax, 0x1300          ; set mode
    xor bh, bh              ; set page
    mov bl, 0x07            ; set attribute
    mov cx, strLen          ; set len
    xor dx, dx              ; set position
    mov es, dx              ; set es to zero
    mov bp, gameOverString  ; set bp to str pointer
    int 0x10                ; call print string
    jmp input

print:
    mov bh, 0                       ; set page number
    mov bp, 0                       ; set index
    mov cx, 1                       ; set amount of chars to write
    mov bl, 0x02                    ; set color green
    .loop:
        mov ah, 0x2                 ; set interrupt mode to set cursor
        mov dx, word [snake + bp]   ; get position
        int 0x10                    ; set cursor

        mov ax, 0x09db              ; set interrupt mode to write cursor and set ascii char (09 for mode and db for char)
        int 0x10                    ; write char
        
        add bp, 2                   ; increase index
        cmp bp, word [len]          ; check how far
        jl .loop                    ; again if not finished
    
    mov ah, 0x2                     ; set mode to set cursor
    mov dx, word [apple]            ; set position to apple
    int 0x10                        ; set cursor

    mov ax, 0x0940                  ; set char to @ and set mode to write cursor
    mov bl, 0x04                    ; set color to red
    int 0x10                        ; write

    jmp input

gameOverString:
    db `You lost\r\nr to try again`
    strLen equ $ - gameOverString

times 510-($-$$) db 0   ; boot sector stuff
dw 0xaa55

                        ; not loaded, just for memory adresses
dir:
dw 0
len:
dw 0
apple:
dw 0
lost:
db 0
snake:
