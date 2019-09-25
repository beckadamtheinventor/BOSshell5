
kb_Data:=$F50010

init:
	call libload_load
	jr z,main_init
	call ti.HomeUp
	call ti.RunIndicOff
	ld hl,.needlibload
	call ti.PutS
	xor a,a
	ld (ti.curCol),a
	inc a
	ld (ti.curRow),a
	call ti.PutS
	call GetCSC
	jp ti.JForceCmdNoChar
.needlibload:
	db "Need libLoad",0
	db "tiny.cc/clibs",0
GetCSC:
	call ti.GetCSC
	or a,a
	jr z,GetCSC
	ret
main_init:
	call ti.HomeUp
	call ti.RunIndicOff
	call gfx_Begin
	call ti_CloseAll
	call gfx_SetDrawBuffer
	ld l,0
	push hl
	call gfx_SetTransparentColor
	call gfx_SetTextTransparentColor
	ld a,(config_colors)
	ld l,a
	ex (sp),hl
	call gfx_SetTextBGColor
	ld a,(config_colors+1)
	ld l,a
	ex (sp),hl
	call gfx_SetTextFGColor
	pop hl
	xor a,a
	sbc hl,hl
	ex hl,de
	ld hl,cursor
	ld (hl),a
	inc hl
	ld (hl),de
	ld hl,currentScreenObjects
	ld (hl),a
	push hl
	push hl
	pop de
	inc de
	ld bc,maxCurrentScreenObjects-1
	ldir
	pop de
	ld hl,defaultScreenObjects
	ld bc,numDefaultScreenObjects
	ldir
	ld hl,cursor
	ld de,2
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld a,2
	ld (hl),a
	inc hl
	ld de,data_cursor_sprite
	ld (hl),de
	call config_load
	jr nc,main_loop
	ld hl,data_default_colors
	ld de,config_colors
	ldi
	ldi
	ldi
	ldi
main_loop:
	ld a,(config_colors)
	ld l,a
	push hl
	call gfx_FillScreen
	pop hl

	ld a,(currentScreenObjects)
	ld ix,currentScreenObjects+1
	ld b,a
	or a,a
	call nz,draw_objects

	call get_cursor_sprite

	call draw_cursor
	call gfx_SwapDraw
; Scan the keypad
.keywait:
	call kb_Scan
	ld hl,kb_Data+2
; Group 1
	ld a,(hl)
	inc hl
	inc hl
	bit 0,a
	jp nz,right_click
	bit 1,a
	jp nz,left_click
	bit 5,a
	jp nz,left_click
	bit 6,a
	jp nz,settings_menu
	bit 7,a
	jp nz,delete_file
; Group 2
	ld a,(hl)
	inc hl
	inc hl
	bit 7,a
	jp nz,right_click
; Group 3
	ld a,(hl)
	inc hl
	inc hl
; Group 4
	ld a,(hl)
	inc hl
	inc hl
; Group 5
	ld a,(hl)
	inc hl
	inc hl
; Group 6
	ld a,(hl)
	inc hl
	inc hl
; Is the clear key pressed?
	bit 6,a
	jr nz,.exit
; Group 7
	ld a,(hl)
	bit 0,a
	call nz,cursorDown ;down arrow
	bit 1,a
	call nz,cursorLeft ;left arrow
	bit 2,a
	call nz,cursorRight;right arrow
	bit 3,a
	call nz,cursorUp   ;up arrow
	and a,$F
	jp nz,main_loop
	jr .keywait
.exit:
	call config_save
	call ti_CloseAll
	jp exit_full

