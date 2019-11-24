

config_save:
	ld hl,data_config_appvar-1
	call ti.Mov9ToOP1
	call ti.ChkFindSym
	jr nc,.okay
	ld hl,data_open_a
	push hl
	ld hl,data_config_appvar
	push hl
	call ti_Open
	pop hl
	pop hl
	ld l,a
	push hl
	ld hl,config_password_len+11
	push hl
	call ti_Resize
	ld hl,10
	ex (sp),hl
	or a,a
	sbc hl,hl
	push hl
	call ti_Seek
	pop hl
	ld hl,1
	ex (sp),hl
	ld hl,data_default_assoc.len
	push hl
	ld hl,data_default_assoc
	push hl
	call ti_Write
	pop hl
	pop hl
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
	ld hl,cursor
	ex (sp),hl
	call ti_Write
	pop hl
	ld hl,3
	ex (sp),hl
	ld hl,CurrentHomePage
	push hl
	call ti_Write
	pop hl
	pop hl
	pop hl
	call ti_Close
	pop hl
	ld hl,data_config_appvar-1
	call ti.Mov9ToOP1
	jp cesium.Arc_Unarc

config_load:
	ld hl,data_open_r
	push hl
	ld hl,data_config_appvar
	push hl
	call ti_Open
	pop hl
	pop hl
	or a,a
	jr z,.create
	ld l,a
	push hl
	ld hl,1
	push hl
	ld hl,4
	push hl
	ld hl,config_colors
	push hl
	call ti_Read
	ld hl,cursor
	ex (sp),hl
	call ti_Read
	pop hl
	ld hl,3
	ex (sp),hl
	ld hl,CurrentHomePage
	push hl
	call ti_Read
	pop hl
	pop hl
	pop hl
	call ti_GetDataPtr
	ld (fileAssociationTable),hl
	call ti_Close
	pop hl
	ret
.create:
	ld hl,data_default_colors
	ld de,config_colors
	ldi
	ldi
	ldi
	ldi
	xor a,a
	sbc hl,hl
	ex hl,de
	ld hl,cursor
	ld (hl),a
	inc hl
	ld (hl),de
	or a,a
	sbc hl,hl
	ld (CurrentHomePage),hl
	ld hl,data_default_assoc
	ld (fileAssociationTable),hl
	ret

