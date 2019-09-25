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

draw_objects:
	ld ix,currentScreenObjects+1
	ld a,(ix-1)
	or a,a
	ret z
.loop:
	push bc
	call callIndIXplus5
	lea ix,ix+8
	pop bc
	djnz .loop
	ret

callIndIXplus5:
	ld bc,(ix+5)
	push bc
	ret



get_cursor_sprite:
	call check_cursor_region
	ld a,(hl)
	or a,a
	jr z,.normsprite
	bit clickableItem,a
	jr nz,.hoversprite
	bit draggableItem,a
	jr z,.normsprite
.dragsprite:
	ld hl,data_cursor_3_sprite
	jr .done
.hoversprite:
	ld hl,data_cursor_2_sprite
	jr .done
.normsprite:
	ld hl,data_cursor_sprite
.done:
	ld (cursor+4),hl
	ret


; output IX pointer to currently hovered object struct
; output HL pointer to currently hovered object type and data pointer (equal to IX+4)
; Always returns something. Default is the background layer
check_cursor_region:
	ld ix,currentScreenObjects+1
	ld a,(ix-1)
	or a,a
	jr nz,.check
.background:
	ld ix,backgroundObject
	lea hl,ix+4
.done:
	ld (curHoverObject),ix
	ret
.check:
	ld b,a
	ld a,(cursor)
	ld (.smcx),a
	ld a,(cursor+3)
	ld (.smcy),a
.loop:
	xor a,a
	ld c,(ix)
.smcx:=$+1
	ld a,0
	sbc a,c
	jr c,.nope
	ld c,(ix+2)
	cp a,c
	jr nc,.nope
	ccf
	ld c,(ix+1)
.smcy:=$+1
	ld a,0
	sbc a,c
	jr c,.nope
	ld c,(ix+3)
	cp a,c
	jr nc,.nope
	lea hl,ix+4
	jr .done
.nope:
	lea ix,ix+8
	djnz .loop
	jr .background

draw_cursor:
	xor a,a
	sbc hl,hl
	ld a,(cursor+3)
	ld l,a
	push hl
	ld a,(cursor)
	ld l,a
	add hl,hl
	push hl
	ld hl,(cursor+4)
	push hl
	call gfx_TransparentSprite
	pop hl
	pop hl
	pop hl
	ret

cursor_height:=7
cursor_width:=7

cursorDown:
	push af
	ld a,(cursor+3)
	cp a, 237 - cursor_height
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
	push af
	ld a,(cursor)
	sub a,2
	jr c,.done
	ld (cursor),a
.done:
	pop af
	ret

cursorRight:
	push af
	ld a,(cursor)
	cp a,(318 - cursor_width)/2
	jr nc,.done
	add a,2
	ld (cursor),a
.done:
	pop af
	ret


