;       Program: Boot-loader and TPK - Timer Pre-emptive Kernel
;   Description: Bootstraps the computer to a small OS
;        Author: Jared Messer and Mark Bixler
;          Date: 
;         Notes: 
; Help Received: 

; Is all this right?
.model small
.386
.stack 100h

.data

.code
main proc
    mov  ax, @data          ; @data is the data segment that DOS sets up.
    mov  ds, ax             ; These two lines are required for all programs

main endp

end main