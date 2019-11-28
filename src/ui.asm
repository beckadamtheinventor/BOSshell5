
input_number_routine:
	call gfx_GetTextX
	push hl
	call gfx_GetTextY
	ld l,a
	push hl
.loop:
	call gfx_SetTextXY
	ld hl,3
	push hl
	ld hl,(ix+3)
	push hl
	call gfx_PrintUInt
	pop hl
	pop hl
	call kb_Scan
	ld hl,kb_Data+2
; Group 1
	ld a,(hl)
	inc hl
	inc hl
; Group 2
	ld a,(hl)
	inc hl
	inc hl
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
; Group 7
	ld a,(hl)
	inc hl
	inc hl

	pop hl
	pop hl
	ret

ui_credits_area_x:=0
ui_credits_area_y:=221
ui_credits_area_w:=20
ui_credits_area_h:=19

ui_folder_area_x:=0
ui_folder_area_y:=10
ui_folder_area_w:=80
ui_folder_area_h:=9


