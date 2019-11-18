; routines for loading libload libraries

; returns z if loaded, nz if not loaded
libload_load:
	call	libload_unload
	jr	.try
.inram:
	call	cesium.Arc_Unarc
.try:
	ld	hl,libload_name
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	jr	c,.notfound
	call	ti.ChkInRam
	jr	z,.inram		; if in ram, archive LibLoad and search again
	ld	hl,9 + 3 + libload_name.len
	add	hl,de			; start of loader (required to be in hl)
	ld	a,(hl)
	cp	a,$1F			; ensure a valid libload version
	jr	c,.notfound
	dec	hl			; move to start of libload
	dec	hl
	ld	de,.relocations 	; start of relocation data
	ld	bc,.notfound
	push	bc
	ld	bc,$aa55aa		; tell libload to not show an error screen
	jp	(hl)			; jump to the loader -- it should take care of everything else
.notfound:
	xor	a,a
	inc	a
	ret

.relocations:

; default libload library
libload_libload:
	db	$c0, "LibLoad", $00, $1F

include 'used_funcs.asm'

	xor	a,a		; return z (loaded)
	pop	hl		; pop error return
	ret


libload_name:
	db	ti.AppVarObj, "LibLoad", 0
.len := $ - .

; remove loaded libraries from usermem
libload_unload:
	jp	util_delete_prgm_from_usermem

