
right_click:
	call .entry
	jr clickWaitLoop
.entry:
	ld ix,(curHoverObject)
	ld de,6
	jr callIX_plus7plusDE

left_click:
	call .entry
	jr clickWaitLoop
.entry:
	ld ix,(curHoverObject)
	ld de,3

callIX_plus7plusDE:
	lea hl,ix+7
	add hl,de
	jp (hl)

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



