
right_click:
	call right_click_menu
	jp main_draw

right_click_menu:
	ld hl,(config_colors)
	push hl
	call gfx_SetColor
	pop hl
	ld hl,320
	push hl
	ld hl,19
	push hl
	or a,a
	sbc hl,hl
	push hl
	push hl
	call gfx_FillRectangle
	ld hl,data_string_right_click
	call gfx_PrintStringXY
	pop hl
	pop hl
	pop hl
	pop hl
	pop hl
	jp main_loop

left_click:
	call getCursorSelection
	jp nz,main_draw
	ld a,(hl)
	or a,a
	jp z,main_draw
	ld (currentOpeningFile),hl
	call openfile
	jp c,main_draw
	ld hl,0
currentOpeningFile:=$-3
	jp execute_item_hl


WaitKeyUnpress:
	call kb_AnyKey
	or a,a
	jr nz,WaitKeyUnpress
	ret
WaitKeyPress:
	call kb_AnyKey
	or a,a
	jr z,WaitKeyPress
	ret

delete_file:
	jp main_loop

settings_menu:
	jp main_loop



