;       Program: TPK - Timer Pre-emptive Kernel, otherwise known as Kernel Sanders
;   Description: Demonstrates a TPK that switches between 32 different tasks
;        Author: Jared Messer and Mark Bixler
;          Date: 
;         Notes: 
; Help Received: 

; Mr. J, does this need to be stated twice?
.model tiny
.386
.stack 100h

.data
TASK_STACKS	equ	SOME ADDRESS
SP_ARRAY	equ	SOME ADDRESS
counter		word	0
counter2	word	320
task3Char	byte	'.'
color		word	15
message 	byte	"Hello World!!", 0
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
	call yield
	loop	task1_start
task1 endp

task2 proc
task2_start:
	push	ax
	push	si
	push	bx
	mov	al, '>'
	mov si, [counter]
	mov	es:[si], al
	mov bx, [color]
	mov es:[si+1], bx
	;inc	[counter]
	add [counter], 2
	dec [color]
	cmp [color], 0
	jne noColorReset
	mov color, 15
noColorReset:
	cmp	[counter], 80
	je	reset_counter
	jmp	after_reset_counter
reset_counter:
	mov counter, 0
after_reset_counter:
	pop bx
	pop si
	pop	ax
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

; task4 proc
; task4 endp

yield proc
	; ; push all regs
	pusha
	; ; push all flags minus SP
	pushf
	; ; swap sp's with target task
yield_mid:
	; ; pop all flags
	popf
	; ; pop all regs
	popa
	 ret
yield endp

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




main proc
	mov	ax, cs
	mov	ds, ax			; Flat memory model
	
	; yield kick-start logic
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; move a saved SP into SP
	;jmp	yield_mid
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	; Frame buffer
	mov	ax, 0B800h
	mov	es, ax
	
	; Mr. J: is each task a proc
	; Mr. J: what is wrong with task2? (look at P8)
	
	; Task Stacks will start at address something
	
	;Hello world
	mov dx, OFFSET message 
	call print_string
	
	; code to set up for tasks
	mov ah, 0
	mov al, 03h ; set graphics mode to text
	int 10h
	
	;call task1
	;call task2
	;call task3
	
	;exit
	jmp	$
main endp

end main
