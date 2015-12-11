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
stack_size	word	256
sp_array	word	32*2 dup (0)	;space for the SP stack
sp_index	word	0
old_sp		word	?
counter		word	0
counter2	word	320
task3Char	byte	'.'
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

task2 proc
task2_start:
	push	ax
	push	si
	push	bx
	mov	al, '>'
	mov	si, [counter]
	mov	es:[si], al
	mov	bx, [color]
	mov	es:[si+1], bx
	add [counter], 2
	dec [color]
	cmp [color], 0
	jne noColorReset
	mov color, 15
noColorReset:
	cmp	[counter], 160
	je	reset_counter
	jmp	after_reset_counter
reset_counter:
	mov counter, 0
after_reset_counter:
	pop bx
	pop si
	pop ax
	call yield
	jmp task2_start
task2 endp

task3 proc
	push ax
	push si
task3_top:
	mov al, [task3Char]
	mov si, [counter2]
	mov es:[si], al ; write chareacter to screen
	mov bx, [color]
	mov es:[si+1], bx
	add [counter2], 2 ; add 2 to the counter to get to the next screen location.
	dec [color]
	cmp [color], 0
	jne task3noColorReset
	mov color, 15
task3noColorReset:
	cmp [counter2], 480 ; cheick if the counter is at the end of the row and if so reset it
	je reset
	jne noReset
reset:
	mov [counter2], 320 ; reset counter to begining of row
	cmp al, '.'
	je period ; if current char == '.' set it to ' '
	mov [task3Char], '.'
	jmp task3_top
period:
	mov [task3Char], ' '
	
noReset:
	pop si
	pop ax
	jmp task3_top
task3 endp

task4 proc

task4 endp



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
	cmp	[sp_index], 64
	jae	after_reset_sp_index
reset_sp_index:
	mov	[sp_index], 0
after_reset_sp_index:	
	mov	si, [sp_index]
	mov	[sp_array + si], sp		;store old sp on stack
	inc	[sp_index]
	inc	[sp_index]			;move to next word on sp stack
	mov	si, [sp_index]
	mov	sp, [sp_array + si]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
yield_mid:
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
	ret
yield endp

init_sp_array proc
	push ax
	push cx
	push bx
	
	mov ax, offset task_stacks ; get the initial addres of task_stacks
	add ax, 256 ; move to the first location 256 words in.
	mov cx, 32 ; loop 32 times
	mov bx, 0 ; index for sp_array
	
loopTop:
	mov sp_array[bx], ax ; move the current location into the sp array
	add ax, 256 ; add 256 to move the next task task
	inc bx
	loop loopTop
	
	pop bx
	pop cx
	pop ax
init_sp_array endp

main proc
	mov	ax, cs
	mov	ds, ax			; Flat memory model
	
	; Frame buffer
	mov	ax, 0B800h
	mov	es, ax
	
	mov ax, 0003h ; set graphics mode to text
	int 10h
	
	;call task1
	;call task2
	;call task3
	
	; yield kick-start logic
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; move a saved SP into SP
	mov	sp, offset task_stacks
	; push task1 address for yield's return
	push	offset task1
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushw	0
	pushf
	push	0800h
	
	push	offset yield
	retf
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;exit
	jmp	$
main endp

end main
