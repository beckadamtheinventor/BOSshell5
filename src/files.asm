
right_click:
	jp main_loop

left_click:
	call getCursorSelection
	cp a,$FF
	jp z,main_loop
	call opening_file_hl
	jp c,main_loop
	call openfile
	jp main_loop

clickWaitLoop:
	call gfx_SwapDraw
	call .loop
	call .loop2
	jp main_loop
.loop:
	call kb_AnyKey
	or a,a
	jr nz,.loop
	ret
.loop2:
	call kb_AnyKey
	or a,a
	jr z,.loop2
	ret

delete_file:
	jp main_loop

settings_menu:
	jp main_loop



