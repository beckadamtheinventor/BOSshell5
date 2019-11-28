
editfile:
	ld a,1
	jr openfile.entry
openfile:
	xor a,a
.entry:
	ld (.mode),a
	ld hl,openingVarName
	call util_openVarHL
	ret c
	ld (prgm_data_ptr),hl
	ld a,(hl)
	inc hl
	cp a,$EF
	jr nz,.useassoc
	ld a,(hl)
	cp a,$7B
	jr z,.exec
.useassoc:
	push hl
	ld hl,(currentOpeningFile)
	ld a,0
.mode:=$-1
	pop de
	dec de
	ld a,(de)
	or a,a
	jr nz,.tryassoc
	inc de
.tryassoc:
	call getFileAssociation
	jr z,.success
	scf
	ret
.success:
	ld de,(currentOpeningFile)
	ld (currentOpeningFile),hl
	ex hl,de
	ld a,(hl)
	inc hl
	call util_setup_packet
.exec:
	call config_save
	xor a,a
	ret

openingVarName:
	db 10 dup 0

openprgm:
	ld hl,(currentOpeningFile)
	call util_openVarHL
	jp c,main_draw
	jp execute_program.entry

editprgm:
	ld hl,(currentOpeningFile)
	call util_openVarHL
	jp c,main_draw
	jp edit_basic_program
	push de
	push hl
	ld l,5
	push hl
	ld hl,data_open_w
	push hl
	ld hl,data_temp_prgm+1
	push hl
	call ti_OpenVar
	pop bc
	pop bc
	pop bc
	pop de
	pop bc
	ld l,a
	push hl
	ld hl,1
	push hl
	push bc
	push de
	call ti_Write
	pop hl
	pop hl
	pop hl
	call ti_Close
	pop hl
edit_temp_prgm:
	ld hl,data_temp_prgm
	call ti.Mov9ToOP1
	jp edit_basic_program


; input de = file extension
; return nz when no association found
; return hl = associated program
getFileAssociation:
	ld hl,0
fileAssociationTable:=$-3
.loop:
	ld a,(hl)
	or a,a
	jr z,.noassoc
	push de
	call strcompare
	pop de
	ret z
	ld bc,9
	add hl,bc
	jr .loop
.noassoc:
	xor a,a
	dec a
	ret

execute_item_hl:
	call ti.Mov9ToOP1
execute_item_op1:
	call	flash_code_copy
	ld a,(ti.OP1)
	cp a,21
	jr z,execute_program.entry
	cp a,6
	jr z,execute_program.entry
	cp a,5
	jr z,execute_program.entry
	xor a,a
	dec a
	jp main_draw

execute_program:
	call	util_backup_prgm_name
.entry:							; entry point, OP1 = name
	ld iy,ti.flags
	call ti.ChkFindSym
	jp c,main_draw
	ld a,b
	ld (prgm_ram_status),a
	ld iy,ti.flags
	call	ti_CloseAll
	call	libload_unload
	ld de,(prgm_data_ptr)
	ld a,(de)
	cp a,$EF
	jr	nz,execute_ti.basic_program		; execute basic program
	inc de
	ld a,(de)
	cp a,$7B
	jr	nz,execute_ti.basic_program		; execute basic program
	ld hl,openingVarName
	call	util_move_prgm_to_usermem		; execute assembly program
	jp nz,main_init		; return on error
	call lcd_normal
	or a,a
	sbc hl,hl
	add hl,sp
	push hl
	ld	hl,return_asm_error
	call	ti.PushErrorHandler
	or a,a
	sbc hl,hl
	add hl,sp
	push hl
execute_assembly_program:
	ld	hl,return_asm
	push	hl
	call	ti.DisableAPD
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	jp	ti.userMem

execute_ti.basic_program:
	call	ti_CloseAll
	call	libload_unload
	call lcd_normal
	ld iy,ti.flags
	ld	hl,(prgm_data_ptr)
	ld	a,(hl)
	cp	a,ti.tExtTok
	jr	nz,.not_unsquished			; check if actually an unsquished assembly program
	inc	hl
	ld	a,(hl)
	cp	a,ti.tAsm84CePrgm
	jp	z,squish_program			; we've already installed an error handler
.not_unsquished:
	call	ti.ClrTxtShd
	call	ti.HomeUp
	call	ti.RunIndicOn
	call	ti.DisableAPD
	call	hook_home.save
	ld	hl,hook_home
	call	ti.SetHomescreenHook
prgm_ram_status:=$+1
	ld a,0
	or a,a
	jr	z,.in_ram
	call	util_delete_temp_program_get_name
	ld	hl,(prgm_real_size)
	push	hl
	ld	a,ti.TempProgObj
	call	ti.CreateVar				; create a temp program so we can execute
	inc	de
	inc	de
	pop	bc
	call	ti.ChkBCIs0
	jr	z,.in_rom				; there's nothing to copy
	ld	hl,(prgm_data_ptr)
	ldi
	jp	po,.in_rom
	ldir
.in_rom:
	call	ti.OP4ToOP1
.in_ram:
	call	ti.ClrTxtShd
	xor	a,a
	ld	(ti.curRow),a
	ld	(ti.curCol),a
	ld	(ti.appErr1),a
	set	ti.graphDraw,(iy + ti.graphFlags)
	ld	hl,return_basic_error
	ld	(persistent_sp_error),sp
	call	ti.PushErrorHandler
	ld	(persistent_sp),sp
	set	ti.appTextSave,(iy + ti.appFlags)	; text goes to textshadow
	set	ti.progExecuting,(iy + ti.newDispF)
	res	7,(iy + $45)
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	set	ti.cmdExec,(iy + ti.cmdFlags) 		; set these flags to execute basic program
	res	ti.onInterrupt,(iy + ti.onFlags)
	res	appInpPrmptDone,(iy + ti.apiFlg2)
	ld	a,ti.cxCmd
	ld	(ti.cxCurApp),a
	call	ti.SaveCmdShadow
	call	ti.SaveShadow
	ld	hl,return_basic
	push	hl
	sub	a,a
	ld	(ti.kbdGetKy),a
	call	ti.EnableAPD
	ld	hl,hook_parser
	call	ti.SetParserHook
	ei
	call	ti.ParseInp				; run program
	xor a,a
	ret
