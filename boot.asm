[org 0x7c00]

start:
    mov ax, 0
    int 0x10                    ; clear screen and set video mode to 40x25
    mov word [snake], 0x0c14    ; middle, 14 = 20y, 0c = 12x
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
    mov [dir], al   ; move char to dir
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
move:                       ; check key and move head
    cmp byte [dir], 'w'
    jne notW
    dec byte [snake+1]

    cmp byte [snake+1], 255 ; check if out of bounds
    jne notW
    mov byte [snake+1], 24
    notW:
    cmp byte [dir], 'a'
    jne notA
    dec byte [snake]

    cmp byte [snake], 255
    jne notA
    mov byte [snake], 39
    notA:
    cmp byte [dir], 's'
    jne notS
    inc byte [snake+1]
    
    cmp byte [snake+1], 25
    jne notS
    mov byte [snake+1], 0
    notS:
    cmp byte [dir], 'd'
    jne notD
    inc byte [snake]
    
    cmp byte [snake], 40
    jne notD
    mov byte [snake], 0
    notD:
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
    mov ax, 0
    int 0x10    ; clear screen
checklost:
    cmp byte [lost], 1  ; check if lost
    jne print           ; continue if not
    mov ax, 0x1300      ; set mode
    xor bh, bh          ; set page
    mov bl, 0x07        ; set attribute
    mov cx, strLen      ; set len
    xor dx, dx          ; set position
    mov es, dx          ; set es to zero
    mov bp, gameOverString  ; set bp to str pointer
    int 0x10            ; call print string
    jmp input

print:
    mov bh, 0                       ; set page number
    mov bp, 0                       ; set index
    mov cx, 1                       ; set amount of chars to write
    .loop:
        mov ah, 0x2                 ; set interrupt mode to set cursor
        mov dx, word [snake + bp]   ; get position
        int 0x10                    ; set cursor

        mov ax, 0x0adb              ; set interrupt mode to write cursor and set ascii char (0a for mode and db for char)
        int 0x10                    ; write char
        
        add bp, 2                   ; increase index
        cmp bp, word [len]          ; check how far
        jl .loop                    ; again if not finished
    
    mov ah, 0x2                     ; set mode to set cursor
    mov dx, word [apple]            ; set position to apple
    int 0x10                        ; set cursor

    mov ax, 0x0a40                  ; set char to @ and set mode to write cursor
    int 0x10                        ; write

    jmp input

gameOverString:
    db `You lost\r\nr to try again`
    strLen equ $ - gameOverString

times 510-($-$$) db 0   ; boot sector stuff
dw 0xaa55

                        ; not loaded, just for memory adresses
dir:
db 0
len:
dw 0
apple:
dw 0
lost:
db 0
snake:
