;       Program: TPK - Timer Pre-emptive Kernel, otherwise known as Kernel Sanders
;   Description: Demonstrates a TPK that switches between 32 different tasks
;        Author: Jared Messer and Mark Bixler
;          Date: 
;         Notes: 
; Help Received: 

; Mr. J, does this need to be stated twice?
; .model tiny
; .386
; .stack 100h

.data
TASK_STACKS	equ	SOME ADDRESS
SP_ARRAY	equ	SOME ADDRESS
counter		byte	0
.code

task1 proc
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
task1 endp

task2 proc
	push	ax
	mov	al, '>'
	mov	es:[counter], al
	inc	[counter]
	cmp	[counter], 80
	je	reset_counter
	jmp	after_reset_counter
reset_counter:
	xor	[counter], [counter]
after_reset_counter:
	pop	ax
task2 endp

task3 proc
task4 endp

task4 proc
task5 endp

task5 proc
task5 endp

task6 proc
task6 endp


main proc
	mov  ax, @data			; @data is the data segment that DOS sets up.
	mov  ds, ax			; These two lines are required for all programs
	
	; Frame buffer
	mov	ax, 0B800h
	mov	es, ax
	
	; Mr. J: is each task a proc
	; Mr. J: what is wrong with task2? (look at P8)
	
	; Task Stacks will start at address something
	
	
	;exit
main endp

end main
