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
	db $BF,$20,$C0,$07
data_default_assoc:
.bin:
	db 'ximg', 7 dup 0, internal_editor, 'BOSximgE'
	db 'xgif', 7 dup 0, internal_editor, 'BOSxgifV'
	db 'prgm', 7 dup 0, internal_editor, 'BOSptoav'
	db 'DCS',$3E,$3F, 6 dup 0, internal_editor, 'BOSDCSit'
	db 'BBAS',$3E,$3F, 5 dup 0, 6, 'BOSBASIC'
	db 'bbas', 7 dup 0, 6, 'BOSBASIC'
.len:=$-.bin
data_default_dirs:
.bin:
	db 'root',0
.len:=$-.bin
data_folds_version:=5
data_dirs_version:=5

data_cursor_0_sprite: ; when the cursor is hidden
	db 1,1,0
data_cursor_sprite:   ; regular cursor
	db 7,7
	db 6,6,6,6,6,0,0
	db 6,0,0,0,4,6,0
	db 6,0,5,5,6,0,0
	db 6,0,5,0,0,0,0
	db 6,4,6,0,0,5,0
	db 0,6,0,0,0,0,0
	db 0,0,0,5,0,0,0
data_cursor_2_sprite: ; hovering over a clickable item
	db 7,7
	db 0,0,0,0,0,0,0
	db 0,0,4,4,4,0,0
	db 0,4,3,0,3,4,0
	db 0,4,0,0,0,4,0
	db 0,4,3,0,3,4,0
	db 0,0,4,4,4,0,0
	db 0,0,0,0,0,0,0
data_cursor_3_sprite: ; hovering over a draggable item
	db 7,7
	db 0,0,0,0,0,0,0
	db 0,0,3,3,3,2,0
	db 0,3,1,1,1,5,0
	db 0,0,0,0,1,5,0
	db 0,3,3,3,5,2,0
	db 0,0,0,1,2,2,1
	db 0,0,0,0,0,1,1
data_bos_icon:        ; menu icon
	db 6,8
	db 0,0,4,4,0,0
	db 0,4,2,2,4,0
	db 4,2,1,1,2,4
	db 4,2,1,1,2,4
	db 4,2,1,1,2,4
	db 4,2,1,1,2,4
	db 0,4,2,2,4,0
	db 0,0,4,4,0,0
backgroundObject:
	db 0,0,160,240 ; min x, min y, size x, size y
	db 0,0,0       ; Null type
	dl BOS_Nop
	dl BOS_Nop
	dl BOS_Nop
BOSIconObject:
	db 0,216,18,24
	db 1,0,0       ; clickable item
	dl drawBOSIcon
	dl openCredits
	dl BOS_Nop
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


OpenWindow:
	jp .open     ; jump here to open a window using (sp + 3)
.OptionsWindow:
	ld hl,.draw2 ; jump here for an options window
.HLWindow:
	push hl      ; jump here for a window pointed to by HL
	call .open
	pop hl
	ret
; Return z if success, c if fail.
.open:
	ld a,(currentScreenObjects)
	push af
	ld b,a
	ld ix,currentScreenObjects+1
.checkloop:
	ld hl,(ix+4)
	sbc hl,de
	jr z,.nonono
	lea ix,ix+16
	djnz .checkloop
	jr .ok
.nonono:
	pop af
	scf
	ret
.ok:
	ex hl,de
	pop af
	ld b,a
	inc a
	cp a,maxScreenObjects/16 - 1
	ccf
	ret c
	ld (currentScreenObjects),a
	ld c,16
	mlt bc
	ld hl,currentScreenObjects+1
	add hl,bc
	push hl
	ex hl,de
	ld hl,(curHoverObject)
	ld bc,16
	ldir
	pop ix
	pop bc
	pop de
	push de
	push bc
	lea hl,ix+7
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld de,.OptionsWindow
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld de,.close
	ld (hl),de
	xor a,a
	ret
.close:
	ld hl,currentScreenObjects
	dec (hl)
	ld a,(hl)
	inc hl
	ld d,8
	ld e,a
	mlt de
	add hl,de
	ld de,(curHoverObject)
	xor a,a
	sbc hl,de
	jr z,.last
	push hl
	ld hl,16
	add hl,de
	pop bc
	ldir
	ret
.last:
	ld (de),a
	push de
	pop hl
	inc de
	ld bc,8
	ldir
	ret
.draw:
	xor a,a
	sbc hl,hl
	ld l,(ix+3)
	push hl
	ld l,(ix+2)
	add hl,hl
	push hl
	ld h,a
	ld l,(ix+1)
	push hl
	ld l,(ix)
	add hl,hl
	push hl
	ld h,a
	ld a,(config_colors+3)
	ld l,a
	push hl
	call gfx_SetColor
	pop hl
	call gfx_FillRectangle
	ld a,(config_colors+1)
	ld l,a
	push hl
	call gfx_SetColor
	pop hl
	call gfx_Rectangle
	pop hl
	pop hl
	pop hl
	pop hl
	ret
.draw2:
	ret

BOS_Nop:
	ret

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
openCredits:
	ld hl,drawCredits
	jp OpenWindow.HLWindow
drawCredits:
	ld a,(config_colors+3)
	ld l,a
	push hl
	call gfx_SetTextBGColor
	ld a,(config_colors+1)
	ld l,a
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

maxScreenObjects:=1024  ;64 objects should be enough

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
tempBuffer:=currentScreenObjects+maxScreenObjects+1
curHoverObject:=tempBuffer+64

config_password:=curHoverObject+3
config_password_len:=64
;next:=config_password+config_password_len

; data in this location is allowed to be modified at runtime
	app_data


