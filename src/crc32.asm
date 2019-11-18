crc_hl_bc:
	ex hl,de
	jr crc_de_bc
crc_file_hl:
	call ti.Mov9ToOP1
crc_file_OP1:
	call ti.ChkFindSym
crc_de_bc:
	ld ix,crc_sum
	xor a,a
	sbc hl,hl
.loop:
	ld a,(de)
	inc de
	xor a,(ix+3)
	ld hl,(ix+1)
	ld (ix),hl
	push de
	ld hl,0
	ld l,a
	ld de,crc32_table
	add hl,de
	pop de
	ld a,(hl)
	ld (ix+3),a
	dec bc
	ld a,b
	or a,c
	jr nz,.loop
	lea hl,ix
	ret


