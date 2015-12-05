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

.code
main proc
	mov  ax, @data			; @data is the data segment that DOS sets up.
	mov  ds, ax			; These two lines are required for all programs
	
	; Mr. J: is each task a proc
	
	;exit
main endp

end main
