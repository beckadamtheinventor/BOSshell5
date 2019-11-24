execute_item_hl:
	call ti.Mov9ToOP1
execute_item_op1:
	call	flash_code_copy
	ld a,(ti.OP1)
	cp a,21
	jr z,.exec
	cp a,6
	jr z,.exec
	cp a,6
	jr z,.exec
	xor a,a
	dec a
	ret
.exec:
	jr	execute_program.entry

opening_file_hl:
	ld (currentOpeningFile),hl
	call ti.Mov9ToOP1
	jp ti.ChkFindSym

editfile:
	ld a,1
	jr openfile.entry
openfile:
	xor a,a
.entry:
	ld (openfile.openmode),a
	call getFileAssociation
	ret nz
	ld a,(hl)
	cp a,internal_editor
	jr z,.internal
	ld hl,0
currentOpeningFile:=$-3
	ld a,0
.openmode:=$-1
	call util_setup_packet
	jr .execute
.internal:
	inc hl
	ld a,(hl)
	or a,a
	ret nz
.execute:
	ld hl,(currentOpeningFile)
	jp execute_item_hl

; input de = file extension
; return nz when no association found
; return hl = associated program
getFileAssociation:
	ld hl,0
fileAssociationTable:=$-3
	jr .entry
.loop:
	ld bc,9
	add hl,bc
.entry:
	ld a,(hl)
	or a,a
	jr z,.noassoc
	push de
	call strcompare
	pop de
	jr nz,.loop
	ret
.noassoc:
	inc a
	ret

execute_program:
	call	util_move_prgm_name_to_op1
	call	util_backup_prgm_name
.entry:							; entry point, OP1 = name
	call ti.ChkFindSym
	ld a,b
	ld (prgm_ram_status),a
	ld a,(de)
	cp a,$EF
	jr	nz,execute_ti.basic_program		; execute basic program	
	ld a,(de)
	cp a,$7B
	jr	nz,execute_ti.basic_program		; execute basic program
	call	util_move_prgm_to_usermem		; execute assembly program
	jp	nz,main_loop				; return on error
	call	gfx_End
	ld	hl,return_asm_error
	ld	(persistent_sp_error),sp
	call	ti.PushErrorHandler
	ld	(persistent_sp),sp
execute_assembly_program:
	ld	hl,return_asm
	push	hl
	call	ti.DisableAPD
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	jp	ti.userMem

execute_ti.basic_program:
	call	gfx_End
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
	jp	ti.ParseInp				; run program
