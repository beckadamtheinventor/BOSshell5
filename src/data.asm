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

lcd_init:
	call	ti.RunIndicOff
	di					; turn off indicator
	call	lcd_clear
.setup:
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
	ret

lcd_normal:
	call lcd_clear
	ld	a,$2d
	ld	(ti.mpLcdCtrl),a
	jp	ti.DrawStatusBar

lcd_clear:
	ld	hl,ti.vRam
	ld	bc,((ti.lcdWidth * ti.lcdHeight) * 2) - 1
	ld	a,255
	jp	ti.MemSet

data_string_quit1:
	db	'1:',0,'Quit',0
data_string_quit2:
	db	'2:',0,'Goto',0


text_right_click_menu_21:=$+1
	db 15
	dl data_open_string
	dl data_edit_string
	dl data_copy_string
	dl data_cut_string
	dl data_paste_string
	dl data_delete_string

action_right_click_menu_21:
	dl left_click.open
	dl left_click.edit
	dl main_draw
	dl main_draw
	dl main_draw
	dl delete_file

text_right_click_menu_6:=$+1
	db 12
	dl data_open_string
	dl data_copy_string
	dl data_cut_string
	dl data_paste_string
	dl data_delete_string

action_right_click_menu_6:
	dl left_click.open
	dl main_draw
	dl main_draw
	dl main_draw
	dl delete_file

text_right_click_menu_5:=$+1
	db 15
	dl data_open_string
	dl data_edit_string
	dl data_copy_string
	dl data_cut_string
	dl data_paste_string
	dl data_delete_string

action_right_click_menu_5:
	dl openprgm
	dl editprgm
	dl main_draw
	dl main_draw
	dl main_draw
	dl	delete_file

data_save_temp_prgm:
	dl .save_temp_prgm
	dl .discard
	dl .save
	dl .return_to_editing
	dl 0
.save_temp_prgm:
	db "Save program before exiting?",0
.discard:
	db "[1]: discard",0
.save:
	db "[2]: save",0
.return_to_editing:
	db "[3]: return to editing",0

data_open_string:
	db "open",0
data_edit_string:
	db "edit",0
data_copy_string:
	db "copy",0
data_cut_string:
	db "cut",0
data_paste_string:
	db "paste",0
data_delete_string:
	db "delete",0
data_string_enter_delete:
	db "Press enter to delete",0

data_temp_prgm:
	db 5,"tempprgm",0

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
data_no_sprite:
	db 1,1,$FF
data_dcs_header:
	db $3E,'DCS',$3F,$2A,0
data_color_table:
	db	$ff,$18,$e0,$00,$f8,$24,$e3,$61,$09,$13,$e6,$ff,$b5,$6b,$6a,$4a

internal_editor:=$FF
type_folder:=$FE
type_link:=$FD

data_default_colors:
	db $BF,$08,$07,$C0
data_default_assoc:
.bin:
	db 'ximg', 0, 21, 'BOSximgE'
	db 'xgif', 0, 21, 'BOSxgifV'
	db 'prgm', 0, 21, 'BOSptoav'
	db 'bbas', 0, 6, 'BOSBASIC'
	db 'ZIPPER',0, 6, 'ZIPPER', 0, 0
	dl 0
.len:=$-.bin
data_default_dirs:
.bin:
	db 'root',0
.len:=$-.bin
data_folds_version:=5
data_dirs_version:=5
data_bos_folds_header:
	db "BOSfolds v500",0,0,0
.len:=16


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

include 'gfx/bos_gfx.inc'

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

config_colors:=backup_home_hook_location+3
setting_editor_name:=config_colors+4
cursor:=setting_editor_name+11
tempBuffer:=cursor+6

config_password:=tempBuffer+64
config_password_len:=64
temp_ptr:=config_password+config_password_len
HomeDataVarPtr:=temp_ptr+3
CurrentHomePage:=HomeDataVarPtr+3
homeNameTemp:=CurrentHomePage+3
;next:=homeNameTemp+144

; data in this location is allowed to be modified at runtime
	app_data


