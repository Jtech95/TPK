; CpS 230: Bootloader Template
;-----------------------------
; originally by Mr. J
; modified by __________
.model tiny


.code

; Set offset of the following code
org	7C00h
start:	jmp	main			; Boot loader starts with a jump instruction to our entry code

; Data sitting between the initial jmp and the actual code

disknum	byte	?

msg	byte	"CpS 230 Bootloader Example", 13, 10
	byte	"--------------------------", 13, 10
	byte	13, 10
	byte	"Hello, world!  Press any key to reboot...", 0
	
; Main is our "real" entry point
main proc
	; Set up data segment
	mov	ax, cs			; Discover our code segment (better be 0000h)
	mov	ds, ax			; Tiny model (data segment == code segment)
	
	; Set up stack
	mov	ax, 0800h		; This will be our kernel's [one] segment, so use it now
	mov	ss, ax
	xor	sp, sp			; Stack pointer starts at the TOP of kernel segment
					; (first PUSH will decrement by 2, to 0FFFEh)
	
	mov	[disknum], dl		; The BIOS should have told us what disk we booted from here...
	
	; Print message
	mov	dx, offset msg
	call	print_string
	
	; Wait for a keystroke
	mov	ah, 10h
	int	16h
	
	; Invoke the BIOS "warm boot" command
	; (reboot using same "disk" number)
	; (this will actually kill DOSBox!)
	mov	dl, [disknum]
	int	19h
main endp

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


; Include magic MBR marker WORD at end of 512-byte sector
org	start+510
magic	word	0AA55h

end
