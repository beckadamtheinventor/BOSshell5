; unrelocated data

; safely unarchive a varible and restore screen mode
; in the case of a garbage collect
; returns nz if okay, z if garbage collect
; derived from https://github.com/calc84maniac/tiboyce/blob/350e414dfc345d5e754eb87c1b87bc4e06131e71/tiboyce.asm#L468
cesium.Arc_Unarc:
	call	ti.ChkFindSym
	ret	c
	ex	de,hl
	push	hl
	add	hl,hl
	pop	hl
	jr	nc,.no_garbage_collect
	ld	hl,(hl)
	ld	a,c
	add	a,12
	ld	c,a
	ld	b,0
	add.s	hl,bc
	jr	c,.garbage_collect
	push	hl
	pop	bc
	call	ti.FindFreeArcSpot
	jr	nz,.no_garbage_collect
.garbage_collect:
	xor	a,a
	push	af
	call	ti.boot.ClearVRAM
	ld	a,$2d
	ld	(ti.mpLcdCtrl),a
	call	ti.DrawStatusBar
	jr	.archive_or_unarchive
.no_garbage_collect:
	xor	a,a
	inc	a
	push	af
.archive_or_unarchive:
	ld	hl,data_lcd_init
	call	ti.PushErrorHandler
	call	ti.Arc_Unarc
	call	ti.PopErrorHandler
data_lcd_init:
	call	ti.boot.ClearVRAM
	ld	a,ti.lcdBpp8
	ld	(ti.mpLcdCtrl),a		; operate in 8bpp
	ld	hl,ti.mpLcdPalette
	ld	b,0
.loop:
	ld	d,b
	ld	a,b
	and	a,192
	srl	d
	rra
	ld	e,a
	ld	a,31
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,.loop
	pop	af
	ret

data_string_quit1:
	db	'1:',0,'Quit',0
data_string_quit2:
	db	'2:',0,'Goto',0

data_string_bos_name:
	db 'BOSshell'
	db ti.AppVarObj
data_config_appvar:
	db 'BOSconfg'
	db ti.AppVarObj
data_packet_appvar:
	db '__B',0
	db ti.AppVarObj
data_folds_appvar:
	db 'BOSfolds'
	db ti.AppVarObj
data_dirs_appvar:
	db 'BOSdirs',0
	db ti.AppVarObj
data_temp_appvar:
	db '__tmp',0
data_open_w:
	db 'w',0
data_open_wplus:
	db 'w+',0
data_open_r:
	db 'r',0
data_open_rplus:
	db 'r+',0
data_open_a:
	db 'a',0
data_open_aplus:
	db 'a+',0

internal_editor:=$FF

data_default_colors:
	db $BF,$00,$C0,$07
data_default_assoc:
	db 'ximg', 7 dup 0, internal_editor, 'BOSximgE'
	db 'xgif', 7 dup 0, internal_editor, 'BOSxgifV'
	db 'prgm', 7 dup 0, internal_editor, 'BOSptoav'
	db 'DCS',$3E,$3F, 6 dup 0, internal_editor, 'BOSDCSit'
	db 'BBAS',$3E,$3F, 5 dup 0, 6, 'BOSBASIC'
	db 'bbas', 7 dup 0, 6, 'BOSBASIC'
data_default_dirs:
.bin:
	db 'root',0
.len:=$-.bin
data_folds_version:=5
data_dirs_version:=5

data_cursor_sprite:
	db 7,7
	db 6,6,6,6,6,0,0
	db 6,0,0,0,4,6,0
	db 6,0,5,5,6,0,0
	db 6,0,5,0,0,0,0
	db 6,4,6,0,0,5,0
	db 0,6,0,0,0,0,0
	db 0,0,0,5,0,0,0
data_cursor_2_sprite:
	db 7,7
	db 0,0,0,0,0,0,0
	db 0,0,4,4,4,0,0
	db 0,4,3,0,3,4,0
	db 0,4,0,0,0,4,0
	db 0,4,3,0,3,4,0
	db 0,0,4,4,4,0,0
	db 0,0,0,0,0,0,0
data_cursor_3_sprite:
	db 7,7
	db 0,0,0,0,0,0,0
	db 0,0,3,3,3,2,0
	db 0,3,1,1,1,5,0
	db 0,0,0,0,1,5,0
	db 0,3,3,3,5,2,0
	db 0,0,0,1,2,2,1
	db 0,0,0,0,0,1,1
data_bos_icon:
	db 8,8
	db 0,0,0,4,4,0,0,0
	db 0,0,4,2,2,4,0,0
	db 0,4,2,1,1,2,4,0
	db 0,4,2,1,1,2,4,0
	db 0,4,2,1,1,2,4,0
	db 0,4,2,1,1,2,4,0
	db 0,0,4,2,2,4,0,0
	db 0,0,0,4,4,0,0,0
backgroundObject:
	db 0,0,160,240 ; min x, min y, size x, size y
	db 0           ; Null type
	dl BOS_No_Properties ; pointer to properties
defaultScreenObjects:
	db 1           ; 1 object to draw
	db 0,216,24,24
	db 1           ; clickableItem
	dl BOSIconPopup
numDefaultScreenObjects:=$-defaultScreenObjects
data_credits:
	db 7      ;number of lines
	dl .line_1
	dl .line_2
	dl .line_3
	dl .line_4
	dl .line_5
	dl .line_6
	dl .line_7
.line_1:
	db 'BOSshell v500b2-A',0
.line_2:
	db 'The dev: beckadamtheinventor',0
.line_3:
	db 'Cesium code: MateoC',0
.line_4:
	db 'Thanks to: jcgter777, LAX18, SM84CE',0
.line_5:
	db 'and many others',0
.line_6:
	db 'special thanks to KermPhD',0
.line_7:
	db 'Everyone at Cemetech: You\'re awesome! :D',0

BOS_No_Properties:
	db 32 dup $C9

BOSIconPopup:
	jp drawBOSIcon
	jp drawCredits
	db 24 dup $C9
drawBOSIcon:
	ld hl,3
	push hl
	push hl
	ld l,(ix+1)
	push hl
	ld l,(ix)
	add hl,hl
	push hl
	ld hl,data_bos_icon
	push hl
	call gfx_ScaledTransparentSprite
	pop hl
	pop hl
	pop hl
	pop hl
	pop hl
	ret
drawCredits:
	ld l,$01
	push hl
	call gfx_SetTextBGColor
	ld l,$FF
	ex (sp),hl
	call gfx_SetTextFGColor
	pop hl
	ld hl,20
	push hl
	push hl
	call gfx_SetTextXY
	pop hl
	pop hl
	ld hl,data_credits
	ld b,(hl)
	inc hl
.loop:
	push bc
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	push hl
	push de
	call gfx_PrintStringLine
	pop hl
	pop hl
	pop bc
	djnz .loop
	ret

maxCurrentScreenObjects:=512  ;64 objects should be enough

string_temp:=ti.pixelShadow
string_other_temp:=string_temp+64
prgm_data_ptr:=string_other_temp+64
prgm_real_size:=prgm_data_ptr+3
prgm_ptr:=prgm_real_size+3
persistent_sp_error:=prgm_ptr+3
persistent_sp:=persistent_sp_error+3
edit_status:=persistent_sp+3
edit_mode:=edit_status+1
return_info:=edit_mode			; yes this is right
backup_prgm_name:=return_info+1
backup_home_hook_location:=backup_prgm_name+11

crc_sum:=backup_home_hook_location+3
config_colors:=crc_sum+4
AppLen:=config_colors+4
AppCRC32:=AppLen+3
setting_editor_name:=AppCRC32+4
cursor:=setting_editor_name+11
currentScreenObjects:=cursor+8
tempBuffer:=currentScreenObjects+maxCurrentScreenObjects+1
curHoverObject:=tempBuffer+64

config_password:=curHoverObject+3
config_password_len:=64
;next:=config_password+config_password_len

; data in this location is allowed to be modified at runtime
	app_data

