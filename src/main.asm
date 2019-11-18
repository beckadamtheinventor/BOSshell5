
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
.GetCSC:
	call ti.GetCSC
	or a,a
	jr z,.GetCSC
	jp exit_full
.needlibload:
	db "Need libLoad",0
	db "tiny.cc/clibs",0
main_init:
	call ti.HomeUp
	call ti.RunIndicOff
	call gfx_Begin
	call ti_CloseAll
	call config_load
	jr nz,.loaded
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
.loaded:
	ld hl,_ico_cursor
	ld (cursor+4),hl
	call gfx_SetDrawBuffer
	ld l,255
	push hl
	call gfx_SetTransparentColor
	ld l,0
	ex (sp),hl
	call gfx_SetTextTransparentColor
	ld hl,(config_colors)
	ex (sp),hl
	call gfx_SetTextBGColor
	ld hl,(config_colors+1)
	ex (sp),hl
	call gfx_SetTextFGColor
	pop hl
main_loop:
	ld hl,(config_colors)
	push hl
	call gfx_FillScreen

;draw the cursor
	ld hl,(cursor+3)
	ex (sp),hl
	ld hl,(cursor)
	push hl
	ld hl,(cursor+4)
	push hl
	call gfx_TransparentSprite
	pop hl
	pop hl
	pop hl

	call drawHomeScreen

	call gfx_SwapDraw

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
	jq main_loop
.exit:
	call config_save
	call ti_CloseAll
	jp exit_full



