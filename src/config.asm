
config_change_colors:
	ret
.text:
	db 'main background color?',0
	dl input_number_routine, config_colors
	db 'main text color?',0
	dl input_number_routine, config_colors+1
	db 'secondary text color?',0
	dl input_number_routine, config_colors+2
	db 'window background color?',0
	dl input_number_routine, config_colors+3
	db 0


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
	ld hl,config_password_len+6
	push hl
	call ti_Resize
	pop hl
	ld hl,1
	push hl
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
	pop hl
	ld hl,cursor
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
	ret z
	ld l,a
	push hl
	ld hl,1
	push hl
	ld hl,4
	push hl
	ld hl,config_colors
	push hl
	call ti_Read
	pop hl
	ld hl,cursor
	push hl
	call ti_Read
	pop hl
	pop hl
	pop hl
	call ti_Close
	pop hl
	xor a,a
	inc a
	ret
