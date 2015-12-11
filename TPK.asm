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
old_sp		word	?
counter		word	0
counter2	word	320
old_segment	word	?
old_offset	word	?
task2Char	byte	'.'
init_stacks_counter	word	0
color		word	15
.code
jmp	main
task1 proc
task1_start:
	push	ax
	mov	al, '|'
	mov	es:[0], al
	mov	al, '/'
	mov	es:[0], al
	mov	al, '-'
	mov	es:[0], al
	mov	al, '\'
	mov	es:[0], al
	pop	ax
	call	yield
	jmp	task1_start
task1 endp

; task2 proc
; task2_start:
	; push	ax
	; push	si
	; push	bx
	; mov	al, '>'
	; mov	si, [counter]
	; mov	es:[si], al
	; mov	bx, [color]
	; mov	es:[si+1], bx
	; add [counter], 2
	; dec [color]
	; cmp [color], 0
	; jne noColorReset
	; mov color, 15
; noColorReset:
	; cmp	[counter], 160
	; je	reset_counter
	; jmp	after_reset_counter
; reset_counter:
	; mov counter, 0
; after_reset_counter:
	; pop bx
	; pop si
	; pop ax
	; call yield
	; jmp task2_start
; task2 endp

task2 proc
task2_top:
	mov al, [task2Char]
	mov si, [counter2]
	mov es:[si], al ; write chareacter to screen
	mov bx, [color]
	mov es:[si+1], bx
	add [counter2], 2 ; add 2 to the counter to get to the next screen location.
	dec [color]
	cmp [color], 0
	jne task2noColorReset
	mov color, 15
task2noColorReset:
	cmp [counter2], 480 ; cheick if the counter is at the end of the row and if so reset it
	je reset
	jne noReset
reset:
	mov [counter2], 320 ; reset counter to begining of row
	cmp al, '.'
	je period ; if current char == '.' set it to ' '
	mov [task2Char], '.'
	jmp task2_top
period:
	mov [task2Char], ' '
	
noReset:
	call yield
	jmp task2_top
task2 endp



; Function: prints a NUL-terminated string
; Receives: DX=offset of string (in DS)
; Returns: none
; Requires: NUL terminator at end of string
; Clobbers: none
print_string proc
	push	ax
	push	si
	
	mov	si, dx
ps_loop:
	lodsb
	cmp	al, 0
	je	ps_done
	mov	ah, 0eh
	int	10h
	jmp	ps_loop
ps_done:

	pop	si
	pop	ax
	ret
print_string endp


yield proc
	; push all regs minus SP
	push	ax
	push	cx
	push	dx
	push	bx
	push	bp
	push	si
	push	di
	; push all flags
	pushf
	
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
	
	; pop all flags
	popf
	; pop all regs
	pop	di
	pop	si
	pop	bp
	pop	bx
	pop	dx
	pop	cx
	pop	ax
	; push flags, cs, ip, also ds and es
	ret	; need a label in middle of isr that this will return to
yield endp


init_stack1 proc
	push	si
	push	bp
	mov	bp, sp
	mov	si, [init_stacks_counter]
	mov	sp, [sp_array + si]
	; push task1 address for yield's return
	; push iret frame (flags, cs, ip)
	push	offset task1
	;offset of timer isr
	; push regs
	pushw	0		; use these for param passing
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushf
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
	mov	sp, sp_array[si]		
	; push task1 address for yield's return
	push	offset task2
	; push regs
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushf
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
main_loopy1:
	call	init_stack1
	inc	init_stacks_counter		; initially 0
	inc	init_stacks_counter
	loop	main_loopy1
	
	mov	cx, 16
main_loopy2:
	call	init_stack2
	inc	init_stacks_counter
	inc	init_stacks_counter
	loop	main_loopy2

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
	
	;call task1
	;call task2
	
	;exit
	jmp	$
main endp


;Description:   Prints the integers 1-9 in the top left corner of the screen
;		everytime interrupt vector 8 is activated
;Receives:      n/a
;Returns:       n/a
;Requires:      byte variable called "isrcounter" set to '0'
;		word variable called "old_segment" set to old interrupt segment
;		word variable called "old_offset"  set to old interrupt offset
;Clobbers:      counter variable
ISR_counter proc
	call yields
	; Push segment and offset of old Int Vector for retf later
	push	[old_segment]
	push	[old_offset]
	retf
ISR_counter endp

end main
