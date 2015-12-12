;       Program: TPK - Timer Pre-emptive Kernel, otherwise known as Kernel Sanders
;   Description: Demonstrates a TPK that switches between 32 different tasks
;        Author: Jared Messer and Mark Bixler
;          Date: 
;         Notes: 
; Help Received: 

.model tiny
.386
.stack 100h

.data
task_stacks	word	256*32 dup (0)	;space for task stacks
sp_array	word	32 dup (0)	;space for the SP stack
sp_index	word	0
counter2	word	320
old_segment	word	?
old_offset	word	?
task2Char	byte	'.'
init_stacks_counter	word	0
color		word	15

.code
jmp	main
task1 proc
	mov bx, 0
task1_start:
	push	ax
	mov	al, '|'
	mov	es:[si], al
	mov	al, '/'
	mov	es:[si], al
	mov	al, '-'
	mov	es:[si], al
	mov	al, '\'
	mov	es:[si], al
	mov es:[si+1], bx
	inc bx
	cmp bx, 100
	jb DontReset
	mov bx, 0
DontReset:
	pop	ax
	jmp	task1_start
task1 endp

task2 proc
	mov al, '.'
	mov bx, 15
	mov dx, si
	mov di, si
	add dx, 160
task2_top:
	;mov al, [task2Char]
	;mov si, [counter2]
	mov es:[si], al ; write chareacter to screen
	;mov bx, [color]
	mov es:[si+1], bx
	add si, 2 ; add 2 to the counter to get to the next screen location.
	dec bx
	cmp bx, 0
	jne task2noColorReset
	mov bx, 15
task2noColorReset:
	cmp si, dx ; cheick if the counter is at the end of the row and if so reset it
	je reset
	jne noReset
reset:
	mov si, di ; reset counter to begining of row
	cmp al, '.'
	je period ; if current char == '.' set it to ' '
	mov al, '.'
	jmp task2_top
period:
	mov al, ' '
	
noReset:
	jmp task2_top
task2 endp


init_stack1 proc
	push	si
	push	bp
	mov	bp, sp
	mov	si, [init_stacks_counter]
	mov	sp, [sp_array + si]
	; push task1 address for yield's return
	pushf
	push	cs
	push	offset task1
	; push regs
	push	es
	push	ds
	pushw	0		; use these for param passing
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	push	bx
	pushw	0
	mov	[sp_array + si], sp
	push	bp
	pop	sp
	pop	bp
	pop	si
	ret
init_stack1 endp
init_stack2 proc
	push	si
	push	bp
	mov	bp, sp				; store old sp
	mov	si, [init_stacks_counter]	
	mov	sp, [sp_array + si]
	; push task1 address for yield's return
	pushf
	push	cs
	push	offset task2
	; push regs
	push	es
	push	ds
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	push	bx
	pushw	0
	mov	[sp_array + si], sp
	push	bp
	pop	sp
	pop	bp
	pop	si
	ret
init_stack2 endp

init_sp_array proc
	push ax
	push cx
	push bx
	
	mov ax, offset task_stacks ; get the initial addres of task_stacks
	add ax, 256 ; move to the first location 256 words in.
	mov cx, 32 ; loop 32 times
	mov bx, 0 ; index for sp_array
	
loopTop:
	mov [sp_array + bx], ax ; move the current location into the sp array
	add ax, 256 ; add 256 to move the next task task
	inc bx
	inc bx
	loop loopTop
	
	pop bx
	pop cx
	pop ax
	ret
init_sp_array endp

ISR_counter proc
	; push all regs minus SP
	push	es
	push	ds
	push	ax
	push	cx
	push	dx
	push	bx
	push	bp
	push	si
	push	di
	
	;swap sp's with target task
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
after_reset_sp_index:	
	mov	si, [sp_index]
	mov	[sp_array + si], sp		;store old sp on stack
	inc	[sp_index]
	inc	[sp_index]			;move to next word on sp stack
	cmp	[sp_index], 64
	jb	yield_mid
reset_sp_index:
	mov	[sp_index], 0
yield_mid::
	mov	si, [sp_index]
	mov	sp, [sp_array + si]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; pop all regs
	pop	di
	pop	si
	pop	bp
	pop	bx
	pop	dx
	pop	cx
	pop	ax
	pop	ds
	pop	es
	; Push segment and offset of old Int Vector for retf later
	push	[old_segment]
	push	[old_offset]
	retf
ISR_counter endp


main proc
	mov	ax, cs
	mov	ds, ax			; Flat memory model
	
	; Frame buffer
	mov	ax, 0B800h
	mov	es, ax
	
	mov ax, 0003h ; set graphics mode to text
	int 10h
	
	call init_sp_array
	
	mov	cx, 16
	mov bx, 0
main_loopy1:
	call	init_stack1
	inc	init_stacks_counter		; initially 0
	inc	init_stacks_counter
	add bx, 10
	loop	main_loopy1
	
	mov	cx, 16
	mov bx, 320
main_loopy2:
	call	init_stack2
	inc	init_stacks_counter
	inc	init_stacks_counter
	add bx, 160
	loop	main_loopy2
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; CHANGE TO GRAPHICS MODE
	
	; DISPLAY PICTURE
	
	; WAIT FOR KEYSTROKE
	
	; CHANGE TO TEXT MODE
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; PIT INIT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; COUNT = input hz / frequency 
	mov	dx, 1193180 / 500	; 100hz, or 10 milliseconds
 
	; FIRST send the command word to the PIT. Sets binary counting,
	; Mode 3, Read or Load LSB first then MSB, Channel 0
	mov	al, 110110b
	out	43h, al
 
	; Now we can write to channel 0. Because we set the "Load LSB first then MSB" bit, that is
	; the way we send it 
	mov	ax, dx
	out	40h, al		;LSB
	xchg	ah, al
	out	40h, al		;MSB
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; Install Interupt handler
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cli
	xor	ax, ax
	mov	es, ax				; es is 0000, for IVT
	
	mov	bx, es:[32]
	mov	[old_offset], bx		; Save old int offset
	mov	bx, es:[34]
	mov	[old_segment],  bx		; Save old int segment
	
	mov	es:[32], offset ISR_counter	; Install the addresses of ISR_counter
	mov	es:[34], cs
	;do not sti
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	jmp	yield_mid
	
	;exit
	jmp	$
main endp
end main
