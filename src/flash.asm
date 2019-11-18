; the os can't do 16 bit relocations... which means we need to copy flash code to ram before running :/
; call this before calling any flash_* functions as necessary

flash_code_copy:
	flash_code.copy
	ret

relocate flash_code, ti.mpLcdCrsrImage

write_port:
	ld	de,$C979ED
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)

read_port:
	ld	de,$C978ED
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)

flash_unlock:
	ld	bc,$24
	ld	a,$8c
	call	write_port
	ld	bc,$06
	call	read_port
	or	a,4
	call	write_port
	ld	bc,$28
	ld	a,$4
	jp	write_port

flash_lock:
	ld	bc,$28
	xor	a,a
	call	write_port
	ld	bc,$06
	call	read_port
	res	2,a
	call	write_port
	ld	bc,$24
	ld	a,$88
	jp	write_port

assume	adl = 1

flash_erase_sector:
	ld	bc,$f8				; lol, what a flaw
	push	bc
	jp	ti.EraseFlashSector

flash_clear_backup:
	ld	de,$3c0000			; backup address
	ld	hl,$d00001
	xor	a,a
	ld	b,a				; write 0
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	a,(de)
	or	a,a
	ret	z				; dont clear if done already
	call flash_unlock
	call	ti.WriteFlashByte		; clear old backup
	call flash_lock
	ret

end relocate
