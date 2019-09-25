
config_save:
	ld hl,data_config_appvar
	call ti.Mov9ToOP1
	call ti.ChkFindSym
	jr nc,.okay
	ld hl,data_open_w
	push hl
	ld hl,data_config_appvar
	push hl
	call ti_Open
	pop hl
	pop hl
	ld l,a
	push hl
	ld hl,config_password_len+6
	push hl
	call ti_Resize
	pop hl
	call ti_Close
	pop hl
.okay:
	ld hl,data_open_rplus
	push hl
	ld hl,data_config_appvar
	push hl
	call ti_Open
	pop de
	pop de
	ld l,a
	push hl
	ld hl,1
	push hl
	ld hl,4
	push hl
	ld hl,config_colors
	push hl
	call ti_Write
	pop hl
	pop hl
	pop hl
	ld hl,(cursor)
	push hl
	call ti_PutC
	pop hl
	ld hl,(cursor+3)
	push hl
	call ti_PutC
	pop hl
	call ti_Close
	pop hl
	ld hl,data_config_appvar-1
	call ti.Mov9ToOP1
	jp cesium.Arc_Unarc

config_load:
	ld hl,data_config_appvar-1
	call ti.Mov9ToOP1
	call ti.ChkFindSym
	ret c
	ex hl,de
	ld de,config_colors
	ldi
	ldi
	ldi
	ldi
	ld de,cursor
	ldi
	inc de
	inc de
	ldi
	ld de,config_password
	ld bc,config_password_len
	ldir
	or a,a
	ret

