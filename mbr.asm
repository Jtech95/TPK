; CpS 230: Bootloader
;-----------------------------
; originally by Mr. J
; modified by Messer and Bixler
.model tiny


.code

; Set offset of the following code
org	7C00h
start:	jmp	main			; Boot loader starts with a jump instruction to our entry code

; Data sitting between the initial jmp and the actual code

disknum	byte	?

msg	byte	"CpS 230 Bootloader and TPK by Bixler and Messer", 13, 10
	byte	"-----------------------------------------------", 13, 10
	byte	13, 10
	byte	"Hello. This is the Ghost of Kernel Sanders.", 13, 10
	byte	"Press any key to execute the Kernel....", 13, 10, 13, 10
	byte	"Change the timeslice on line 275 in TPK.asm for fun!", 0
	
; Main is our "real" entry point
main proc
	; Set up data segment
	mov	ax, cs			; Discover our code segment (better be 0000h)
	mov	ds, ax			; Tiny model (data segment == code segment)
	
	; Set up stack
	mov	ax, 0800h		; This will be Kernel Sander's [one] segment, so use it now
	mov	ss, ax
	xor	sp, sp			; Stack pointer starts at the TOP of Sander's segment
					; (first PUSH will decrement by 2, to 0FFFEh)
	
	mov	[disknum], dl		; The BIOS should have told us what disk we booted from here...
	
	; Print message
	mov	dx, offset msg
	call	print_string
	
	; Wait for the stroke of a key
	mov	ah, 10h
	int	16h
	
	; Load Sanders to 0800h
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reads sectors from disk into memory using BIOS services
	mov	dl, [disknum]		; boot drive
	mov	cx, 0002h		; cylinder 0 sector 2
	xor	dh, dh			; head 0
	mov	al, 004fh			; read 12 sectors (2 - 14)	
	mov	bx, 0800h		; destination
	mov	es, bx
	xor	bx, bx
	
	mov	ah, 02h    ; read designated sectors into memory
	int	13h
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Execute Sanders
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push	0800h
	push	0000h
	retf
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
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
