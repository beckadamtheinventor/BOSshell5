gfx_SetDrawBuffer:
	ld hl,1
	push hl
	call gfx_SetDraw
	pop hl
	ret

gfx_BlitBuffer:
	ld hl,1
	push hl
	call gfx_Blit
	pop hl
	ret

gfx_PrintStringLine:
	pop de
	pop hl
	push hl
	push de
	ld (.str),hl
	call gfx_GetTextX
	ld (.smc),hl
.str:=$+1
	ld hl,0
	push hl
	call gfx_PrintString
	pop hl
	call gfx_GetTextY
.spacing:=$+1
	ld a,10
	add a,l
	ld l,a
	push hl
.smc:=$+1
	ld hl,0
	push hl
	call gfx_SetTextXY
	pop hl
	pop hl
	ret

cursor_height:=16
cursor_width:=16

cursorDown:
	push af
	ld a,(cursor+3)
	cp a, 240 - cursor_height
	jr nc,.done
	add a,4
	ld (cursor+3),a
.done:
	pop af
	ret

cursorUp:
	push af
	ld a,(cursor+3)
	sub a,4
	jr c,.done
	ld (cursor+3),a
.done:
	pop af
	ret

cursorLeft:
	push hl
	push de
	ld hl,(cursor)
	ld de,2
	or a,a
	sbc hl,de
	jr c,.done
	ld (cursor),hl
.done:
	pop de
	pop hl
	ret

cursorRight:
	push hl
	push de
	ld hl,(cursor)
	ld de,320 - cursor_width
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.done
	inc hl
	inc hl
	ld (cursor),hl
.done:
	pop de
	pop hl
	ret

drawHomeScreen:
	ld de,0
	push de
	ld hl,5
	push hl
	ld hl,temp_ptr
	ld (hl),de
	push hl
.loop:
	call ti_DetectVar
	
	pop hl
	pop hl
	pop hl
	ret



