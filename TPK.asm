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
	;call yield
	jmp	task1_start
task1 endp

task2 proc
task2_start:
	push	ax
	push	si
	mov	al, '>'
	mov	si, [counter]
	mov	es:[si], al
	inc	[counter]
	cmp	[counter], 80
	je	reset_counter
	jmp	after_reset_counter
reset_counter:
	mov counter, 0
after_reset_counter:
	pop si
	pop	ax
	jmp task2_start
task2 endp

task3 proc
	
task3 endp

; task4 proc
; task4 endp

; task5 proc
; task5 endp

; task6 proc
; task6 endp

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

; yield proc
	; ; push all regs
	; ; push all flags minus SP
	; ; swap sp's with target task
; yield_mid:
	; ; pop all flags
	; ; pop all regs
	; ret
; yield endp


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
	
	call task1
	
	;exit
	jmp	$
main endp

end main
