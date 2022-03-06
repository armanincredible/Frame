.model tiny
.code
org 100h

locals

VIDEOSEG equ 0b800h
X_START	 equ 40d
Y_START	 equ 5d


PROFILE_MODE equ 0d
ONE_FRAME_MODE equ 1d
TWO_FRAME_MODE equ 2d

HIGH_FR equ 3d
LENGTH_FRAME equ 30d

.getch	macro
		xor ah, ah
		int 16h
		endm

Start:

	call Set_Regs
	call Draw_Frame

	mov ax, 4C00h
	int 21h


;---------------------------------------------------------- 
; Set regs
;  
; Entry: None
; Note:  ES = videoseg addr (0b800h) 
; Exit:  None 
; Destr: AX, BX, ES, SI
;---------------------------------------------------------- 

Set_Regs		proc
				mov ax, VIDEOSEG
				mov es, ax

				mov bx, 82h
				mov ax, [bx]
				sub ax, 30h

				inc bx
				mov ah, [bx]
			

				cmp al, PROFILE_MODE
				je ProfileModeSymbols

				mov si, offset Two_Frame_Symbols
				cmp al, TWO_FRAME_MODE
				je return_back
				add si, 9h

				jmp return_back

ProfileModeSymbols : 
				inc bx
				mov si, bx

return_back:	ret
				endp

;---------------------------------------------------------- 
; Draw a frame 
;  
; Entry: AH - color (attr) of line 
;        CX - lenght of string 
;        SI - addr of 3-byte array containing line elements 
;        DI - adress of start of line 
; Note:  ES = videoseg addr (0b800h) 
; Exit:  None 
; Destr: AL, CX, SI, BX, DX
;---------------------------------------------------------- 
Draw_Frame		proc

				mov di, (Y_START * 80d + X_START) * 2

				mov cx, LENGTH_FRAME
			
				mov bx, cx

				call DrawLine
				mov cx, bx

				mov dx, HIGH_FR
Draw_middle:
				call DrawLine
				mov cx, bx
				sub si, 3
				sub dx, 1
				cmp dx, 0
				jne Draw_middle

				add si, 3
				call DrawLine

				mov bx, 0083h
				
				mov di, ((Y_START + 2) * 80d + X_START + 1) * 2
				mov dx, LENGTH_FRAME
				sub dx, 2

			
Draw_letter:
				.getch
				mov ah, [bx]
				mov es:[di], ax
				add di, 2 
				sub dx, 1
				cmp dx, 0
				jne Draw_letter

				ret 
				endp

;---------------------------------------------------------- 
; Draw a line in a frame 
;  
; Entry: AH - color (attr) of line 
;        CX - lenght of string 
;        SI - addr of 3-byte array containing line elements 
;        DI - adress of start of line 
; Note:  ES = videoseg addr (0b800h) 
; Exit:  None 
; Destr: AL, CX, SI
;---------------------------------------------------------- 
DrawLine        proc             
 
                mov al, [si]
                inc si 
                mov es:[di], ax
                add di, 2 
 
                mov al, [si]
                inc si 
 
                sub cx, 2 
                jbe @@ret
 
@@nextSym:      mov es:[di], ax
                add di, 2 
                loop @@nextSym

                mov al, [si]
				inc si
                mov es:[di], ax
                add di, 2 

				add di, 160d
				sub di, bx
				sub di, bx

@@ret:          ret
				endp


Two_Frame_Symbols:			db 	0C9h, 0CDh, 0BBh, 0BAh, 020h, 0BAh, 0C8h, 0CDh, 0BCh

One_Frame_Symbols:			db 	0DAh, 0C4h, 0BFh, 0B3h, 020h, 0B3h, 0C0h, 0C4h, 0D9h

end Start
