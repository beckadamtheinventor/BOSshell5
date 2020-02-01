
right_click:
	call getCursorSelection
	jp nz,main_draw
	ld a,(hl)
	or a,a
	jp z,main_draw
	call ti.Mov9ToOP1
	call	ti.ChkFindSym
	jp c,main_draw
	ld a,(ti.OP1)
	cp a,21
	jp z,right_click_menu_21
	cp a,5
	jp z,right_click_menu_5
	cp a,6
	jp z,right_click_menu_6
	jp main_draw
.ui:
	push hl
	ret

right_click_menu_21:
	ld hl,text_right_click_menu_21
	call right_click_menu_loop
	jp nz,main_draw
	ld de,action_right_click_menu_21
	add hl,de
	ld hl,(hl)
	push hl
	ret

right_click_menu_6:
	ld hl,text_right_click_menu_6
	call right_click_menu_loop
	jp nz,main_draw
	ld de,action_right_click_menu_6
	add hl,de
	ld hl,(hl)
	push hl
	ret

right_click_menu_5:
	ld hl,text_right_click_menu_5
	call right_click_menu_loop
	jp nz,main_draw
	ld de,action_right_click_menu_5
	add hl,de
	ld hl,(hl)
	push hl
	ret

right_click_menu_loop:
	ld (.menu),hl
	dec hl
	ld a,(hl)
	ld (.maxoffset),a
.zero:
	xor a,a
	ld (.offset),a
.loop:
	ld hl,0
.menu:=$-3
	ld de,0
.offset:=$-3
	add hl,de
	ld hl,(hl)
	call right_click_menu_draw
	call util_get_csc
	cp a,2
	jr z,.back
	cp a,3
	jr z,.forward
	cp a,54
	jr z,.return
	cp a,9
	jr z,.return
	cp a,15
	jr nz,.loop
	xor a,a
	inc a
	ret
.return:
	ld hl,(.offset)
	call util_WhileKeyPressed
	xor a,a
	ret
.back:
	ld a,(.offset)
	or a,a
	jr z,.end
	sub a,3
	ld (.offset),a
	jr .loop
.forward:
	ld a,(.offset)
	cp a,0
.maxoffset:=$-1
	jr nc,.zero
	add a,3
	ld (.offset),a
	jr .loop
.end:
	ld hl,(.menu)
	dec hl
	ld a,(hl)
	ld (.offset),a
	jr .loop


right_click_menu_draw:
	ld (.text),hl
	ld hl,(config_colors)
	push hl
	call gfx_SetColor
	ld hl,19
	ex (sp),hl
	ld hl,320
	push hl
	or a,a
	sbc hl,hl
	push hl
	push hl
	call gfx_FillRectangle
	call gfx_SetTextXY
	ld l,'<'
	push hl
	call gfx_PrintChar
	ld hl,0
.text:=$-3
	ex (sp),hl
	call gfx_PrintString
	ld hl,'>'
	ex (sp),hl
	call gfx_PrintChar
	pop hl
	pop hl
	pop hl
	pop hl
	pop hl
	ret

left_click:
	call getCursorSelection
	jp nz,main_draw
	ld a,(hl)
	or a,a
	jp z,main_draw
.open:
	call openfile
.exec:
	jp c,main_draw
	ld hl,0
currentOpeningFile:=$-3
	call ti.Mov9ToOP1
	jp execute_program.entry
.edit:
	call editfile
	jr .exec
.ui:
	xor a,a
	push hl
	ret



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
	ld hl,(config_colors)
	push hl
	call gfx_SetColor
	pop hl
	ld hl,320
	push hl
	ld l,9
	push hl
	xor a,a
	sbc hl,hl
	push hl
	push hl
	call gfx_FillRectangle
	ld hl,data_string_enter_delete
	push hl
	call gfx_PrintStringXY
	pop hl
	pop hl
	pop hl
	pop hl
	pop hl
.loop:
	call util_get_csc
	cp a,9
	jp nz,main_draw
	ld hl,(currentOpeningFile)
	ld e,(hl)
	push de
	inc hl
	push hl
	call ti_DeleteVar
	pop hl
	pop hl
	jp main_draw

settings_menu:
	jp main_draw

credits_menu:
	call drawHomeScreenLines
	ld hl,data_credits
	push hl
	call gfx_PrintStringLines
	pop hl
	call util_get_csc
	jp main_draw


new_folder:
	jp main_draw



