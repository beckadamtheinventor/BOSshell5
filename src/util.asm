util_find_var:
	call	ti.Mov9ToOP1
	jp	ti.ChkFindSym

util_install_error_handler:
	ret

; return z if strings are equal
strcompare:
	ld a,(de)
	inc de
	cpi
	ret nz
	or a,a
	jr nz,strcompare
	ret

delete_packet_file:
	ld hl,data_packet_appvar
	push hl
	call ti_Delete
	pop hl
	ret

; HL points to file entry
; A is open/edit mode
util_setup_packet:
	push hl
	push af
	ld hl,data_open_w
	push hl
	ld hl,data_packet_appvar
	push hl
	call ti_Open
	pop hl
	pop hl
	ld l,a
	push hl
	ld hl,12
	push hl
	call ti_Resize
	pop hl
	call ti_GetDataPtr
	ex hl,de
	pop bc
	pop af
	push de
	push bc
	ld l,a
	push hl
	call ti_PutC
	pop hl
	pop bc
	pop hl
	pop de
	push bc
	ld de,11
	push de
	ld de,0
	push de
	push hl
	call ti_Write
	pop hl
	pop hl
	pop hl
	call ti_Close
	pop hl
	ret


util_delete_prgm_from_usermem:
	or	a,a
	sbc	hl,hl
	ld	de,(ti.asm_prgm_size)		; get program size
	ld	(ti.asm_prgm_size),hl		; delete whatever was there
	ld	hl,ti.userMem
	jp	ti.DelMem

util_move_prgm_to_usermem:
	call util_openVarHL
	jr c,.error_not_found
	inc	hl
	inc	hl				; bypass tExtTok, tAsm84CECmp
	push	hl
	push	de
	ex	de,hl
	call	util_check_free_ram		; check and see if we have enough memory
	pop	hl
	jr	c,.error_ram
	ld	(ti.asm_prgm_size),hl		; store the size of the program
	ld	de,ti.userMem
	call	ti.InsertMem			; insert memory into usermem
	pop	hl				; hl -> start of program
	ld	bc,(ti.asm_prgm_size)		; load size of current program
	ldir					; copy the program to userMem
	xor	a,a
	ret					; return
.error_ram:
	pop	hl				; pop start of program
.error_not_found:
	xor	a,a
	inc	a
	ret


; HL->OP1, returns HL pointer to file, DE length of file.
util_openVarHL:
	ld iy,ti.flags
	call ti.Mov9ToOP1
	call	ti.ChkFindSym
	ret c
	call	ti.ChkInRam
	ex	de,hl
	jr	z,.in_ram
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
.in_ram:					; hl -> size bytes
	call	ti.LoadDEInd_s
	xor a,a
	ret


util_check_free_ram:
	push	hl
	ld	de,128
	add	hl,de				; for safety
	call	ti.EnoughMem
	pop	hl
	ret
	;call	gui_ram_error
	;jr	util_delay_one_second

util_delay_one_second:
	ld	bc,100
.delay:
	push	bc
	call	ti.Delay10ms
	pop	bc
	dec	bc
	ld	a,c
	or	a,b
	jr	nz,.delay
	ret

util_get_csc:
	call ti.GetCSC
	or a,a
	jr z,util_get_csc
	ret

util_get_key:
	di
.run:
	call	util_handle_apd
	ld	iy,ti.flags
	call	ti.DisableAPD			; disable os apd and use our own
;	call	util_show_time
	call	gfx_BlitBuffer
	call	ti.GetCSC			; avoid using getcsc for usb
	or	a,a
	jr	z,.run
	ret

util_setup_apd:
	ld	hl,$b0ff
	ld	(apd_timer),hl
	ret

util_handle_apd:
	ld	hl,0
apd_timer := $-3
	dec	hl
	ld	(apd_timer),hl
	add	hl,de
	or	a,a
	sbc	hl,de
	ret	nz
	jp	exit_full

util_to_one_hot:
	ld	b,a
	xor	a,a
	scf
.loop:
	rla
	djnz	.loop
	ret

util_move_prgm_name_to_op1:
	ld	hl,(prgm_ptr)
util_prgm_ptr_to_op1:
	ld	hl,(hl)
	push	hl				; vat pointer
	ld	de,6
	add	hl,de
	ld	a,(hl)				; get the type byte
	pop	hl
	ld	de,ti.OP1			; store to op1
	ld	(de),a
	inc	de
	ld	b,(hl)
	dec	hl
.copy:
	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	djnz	.copy
	xor	a,a
	ld	(de),a				; terminate the string
	ret

util_backup_prgm_name:
	ld	hl,ti.OP1
.entry:
	ld	de,backup_prgm_name
	jp	ti.Mov9b

util_delete_temp_program_get_name:
	ld	hl,util_temp_program_object
	call	ti.Mov9ToOP1
	call	ti.PushOP1
	call	ti.ChkFindSym
	call	nc,ti.DelVarArc			; delete the temp prgm if it exists
	jp	ti.PopOP1

util_get_archived_name:
	ld	de,util_temp_program_object + 1
	ld	b,8
.compare:
	ld	a,(de)
	cp	a,(hl)
	jr	nz,.no_match
	inc	hl
	inc	de
	djnz	.compare
	ld	hl,backup_prgm_name
	ret
.no_match:
	ld	hl,ti.basic_prog
	ret

util_op1_to_temp:
	ld	de,string_temp
	push	de
	call	ti.ZeroOP
	ld	hl,ti.OP1 + 1
	pop	de
.handle:
	push	de
	call	ti.Mov8b
	pop	hl
	ret

util_temp_to_op1:
	ld	hl,string_temp
	ld	de,ti.OP1
	jr	util_op1_to_temp.handle

util_num_convert:
	ld	de,string_other_temp
	push	de
	call	.entry
	xor	a,a
	ld	(de),a
	pop	de
	ret
.entry:
	ld	bc,-1000000
	call	.aqu
	ld	bc,-100000
	call	.aqu
	ld	bc,-10000
	call	.aqu
	ld	bc,-1000
	call	.aqu
	ld	bc,-100
	call	.aqu
	ld	c,-10
	call	.aqu
	ld	c,b
.aqu:
	ld	a,'0' - 1
.under:
	inc	a
	add	hl,bc
	jr	c,.under
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret

util_temp_program_object:
	db	ti.TempProgObj, $5F,$5F,'tmp', 0, 0, 0, 0

