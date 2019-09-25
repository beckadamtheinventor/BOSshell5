
right_click:
	ld ix,(curHoverObject)
	ld de,8
	call callIndIXplus5_plusDE

clickWaitLoop:
	call gfx_SwapDraw
.loop:
	call kb_AnyKey
	or a,a
	jr nz,.loop
.loop2:
	call kb_AnyKey
	or a,a
	jr z,.loop2
	jp main_loop


left_click:
	ld ix,(curHoverObject)
	ld de,4
	call callIndIXplus5_plusDE
	jr clickWaitLoop

callIndIXplus5_plusDE:
	ld hl,(ix+5)
	add hl,de
	push hl
	ret


delete_file:
	jp main_loop

settings_menu:
	jp main_loop



