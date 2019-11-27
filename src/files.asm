
right_click:
	jp main_loop

left_click:
	call getCursorSelection
	jp nz,main_draw
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



