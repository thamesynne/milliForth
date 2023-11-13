	bits 16
	cpu 8086		; tamsyn's house, tamsyn's rules
	jmp 0x0050:main
	org 0x7700

RSTACK_BASE equ 0x76fe
STACK_BASE equ 0xfffe
TIB equ 0x0000
TIBP1 equ TIB+1
STATE equ 0x1000 
CIN equ 0x1002
LATEST equ 0x1004
HERE equ 0x1006
FLAG_IMM equ 1<<7
LEN_MASK equ (1<<5)-1 ; have some extra flags, why not

%define link 0
%macro defword 2-3 0
word_%2:
	dw link
%define link word_%2
%strlen %%len %1
	db %3+%%len
	db %1
%2:
%endmacro

defword "@",FETCH
	pop bx
	push word [bx]
	jmp NEXT

defword "!",STORE
	pop bx
	pop word [bx]
	jmp NEXT

defword "sp@",SPFETCH
	push sp
	jmp NEXT

defword "rp@",RPFETCH
	push bp
	jmp NEXT

defword "0#",ZEROEQ
	pop ax
	neg ax
	sbb ax,ax
	push ax
	jmp NEXT

defword "+",PLUS
	pop bx
	pop ax
	add ax,bx
	push ax
	jmp NEXT

defword "nand",NAND
	pop bx
	pop ax
	and ax,bx
	not ax
 	push ax
	jmp NEXT

defword "exit",EXIT
	xchg sp,bp
	pop si
	xchg sp,bp
	jmp NEXT

defword "s@",STATEVAR
	mov ax,STATE
	push ax
NEXT:
	lodsw
	jmp ax

defword ":",COLON
	mov di,[HERE]
	mov ax,[LATEST]
	mov [LATEST],di
	stosw			; link
	inc di			; save byte for length
	mov cx,di		; tok takes cx=buffer
	call tok		; get token inline
	mov [di-1],cl		; store length
	add di,cx
	mov ax,0xD2FF		; call dx 
	stosw
	mov [HERE],di
 	mov byte [STATE],0
	jmp NEXT

DOCOL:
	xchg sp,bp
	push si
	xchg sp,bp
	pop si
	jmp NEXT

defword "key",KEY
	xor ax,ax		; might want to omit this 
	int 0x16
	push ax
	jmp NEXT

defword "emit",EMIT
	lodsw			; next in thread 
	pop bx			; char to emit
	push ax			; next word to execute => ret addr 
	xchg ax,bx
put	mov ah,14		; tty output
	int 0x10
	cmp al,13		; did we write CR? 
	jne .r
	mov al,10		; if so, write LF too, 
	int 0x10
	mov al,bl		; & say we wrote what's in BL 
.r	ret

defword ",",COMMA
	pop ax
compile:
	mov di,[HERE]
	stosw
	mov [HERE],di
	jmp NEXT

defword ";",SEMICOLON,FLAG_IMM
	mov byte [STATE],1
	mov ax, EXIT
	jmp compile

main:
	push cs
	push cs
	push cs
	pop ds
	pop es
	pop ss
	mov word [LATEST],word_SEMICOLON
	mov word [HERE],here
error:
	mov al,19		; double-exclamation 
	call put
exec:
	mov sp,STACK_BASE
	mov bp,RSTACK_BASE
	mov byte [STATE],1
	mov dx,DOCOL

repl:
	xor cx,cx		; get token to buffer at 0x0 
	call tok

	mov bx,[LATEST]
.1:	test bx,bx
	jz error

	mov si,bx
	lodsw
	xchg ax,bx
	lodsb
	mov dl,al
	and al,LEN_MASK
	cmp al,cl
	jne .1

	push cx
	push di
	repe cmpsb
	pop di
	pop cx
	jne .1

	xchg ax,si
	and dl,FLAG_IMM
	or dl,[STATE]
	jnz .2
	  push ax
	  mov ax,COMMA
.2:	mov dl,DOCOL & 255	; must restore dx to DOCOL!
	call _go
	dw repl
_go:
	pop si
	jmp ax

tok:	mov bl,32		; stop at space
wrd:	mov di,cx		; reset position to buf start
_ch:	mov ah,0
	int 0x16		; get a key
	cmp al,8		; is it a backspace?
	jne _wr-1		; if so
	dec di			; remove last character stored 
	cmp di,cx		; did that take us before start?
	jl wrd			; if so, reset everything
	test al,0xAA		; otherwise skip stosb and...
_wr:	call put		; print keypress 
	cmp al,bl		; is it the terminator?
	jne _ch			; if not, go again, otherwise...
	dec di			; we stored terminator, undo that 
	sub di,cx		; calculate length
	jle wrd			; don't go home empty handed 
	xchg cx,di		; return length in cx, origin in di
	ret


%ifndef CHECKSIZE
times 510-($-$$) db 0
db 0x55, 0xaa
%endif

here:

; use -DFLOPPY to make something Bochs can boot
%ifdef FLOPPY
times 719*512 db 0
%endif
