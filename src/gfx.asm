gfx_SetDrawBuffer:
	ld l,1
	push hl
	call gfx_SetDraw
	pop hl
	ret

gfx_SetDrawScreen:
	ld l,0
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

home_item_width:=70
home_item_height:=50
home_item_top:=20
home_item_bottom:=220
home_item_left:=20
home_item_right:=300
home_item_text_offset_y:=home_item_height-9

drawCursor:
	ld hl,(cursor+3)
	push hl
	ld hl,(cursor)
	push hl
	ld hl,(cursor+4)
	push hl
	call gfx_TransparentSprite
	pop hl
	pop hl
	ld hl,(config_colors+1)
	ex (sp),hl
	call gfx_SetColor
	pop hl

drawCursorSelectionBox:
	ld bc,home_item_height+2
	push bc
	ld c,home_item_width+2
	push bc
	ld c,home_item_height
	or a,a
	sbc hl,hl
	ld a,(cursor+3)
	or a,a
	sbc a,home_item_top
	jr c,.exity
	cp a,home_item_bottom - home_item_top
	jr nc,.exity
.loopy:
	add hl,bc
	or a,a
	sbc a,c
	jr nc,.loopy
	or a,a
	sbc hl,bc
	ld c,home_item_top
	add hl,bc
	push hl
	ld hl,(cursor)
	ld de,home_item_left
	ld e,0
	ld c,home_item_width
.loopx:
	ex hl,de
	add hl,bc
	ex hl,de
	or a,a
	sbc hl,bc
	jr nc,.loopx
	ex hl,de
	or a,a
	sbc hl,bc
	ld bc,home_item_left
	add hl,bc
	push hl
	call gfx_Rectangle
	pop bc
	pop bc
.exity:
	pop bc
	pop bc
	ret

eraseCursor:
	push af
	ld hl,16 ;cursor width/height
	push hl
	push hl
	ld hl,(cursor+3)
	push hl
	ld hl,(cursor)
	push hl
	ld hl,1
	push hl
	call gfx_BlitArea
	pop hl
	pop hl
	pop hl
	pop hl
	ld a,(config_colors)
	ld l,a
	ex (sp),hl
	call gfx_SetColor
	pop hl
	call drawCursorSelectionBox
	pop af
	ret

getCursorSelection:
	ld a,(cursor+3)
	or a,a
	sbc a,home_item_top
	jr c,.failed
	cp a,home_item_bottom - home_item_top
	jr nc,.failed
	ld bc,home_item_height
	ld de,$FFFF
.loopy:
	inc d
	or a,a
	sbc a,c
	jr nc,.loopy

	ld hl,(cursor)
	ld c,home_item_width
.loopx:
	inc e
	or a,a
	sbc hl,bc
	jr nc,.loopx

	ld a,d
	add a,a
	add a,a
	add a,e
	ld e,a
	add a,a
	add a,a
	add a,a
	add a,e
	or a,a
	sbc hl,hl
	ld l,a
	ld de,homeNameTemp
	add hl,de
	xor a,a
	ret
.failed:
	or a,a
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
	inc a
	ld (cursor+3),a
.done:
	pop af
	ret

cursorUp:
	push af
	ld a,(cursor+3)
	or a,a
	jr z,.done
	dec a
	ld (cursor+3),a
.done:
	pop af
	ret

cursorLeft:
	push hl
	ld hl,(cursor)
	ld de,1
	or a,a
	sbc hl,de
	jr c,.done
	ld (cursor),hl
.done:
	pop hl
	ret

cursorRight:
	push hl
	ld hl,(cursor)
	ld de,320 - cursor_width
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.done
	inc hl
	ld (cursor),hl
.done:
	pop hl
	ret

; input HL pointer to start of file
; output HL pointer to sprite
getFileSpriteFromPtr:
	ld a,(hl)
	inc hl
	cp a,$EF
	jr z,.maybeasm
	cp a,$3E
	jr z,.maybebas
; use the var type
.usevartype:
	ld a,0
.vartype:=$-1
	ld hl,_ico_data
	cp a,type_folder
	jr nz,.next1
	ld hl,_ico_folder
.next1:
	cp a,type_link
	jr nz,.next2
	ld hl,_ico_link
.next2:
	cp a,21
	jr nz,.next3
	ld hl,_ico_appvar
.next3:
	cp a,6
	jr nz,.next4
	ld hl,_ico_locked_prgm
.next4:
	cp a,5
	ret nz
	ld hl,_ico_prgm
	ret
.maybeasm:
	ld a,(hl)
	cp a,$7B
	jr nz,.usevartype
	inc hl
.isasm:	
	ld a,(hl)
	ex hl,de
	ld hl,_ico_asm
	cp a,$7F
	jr nz,.next5
	ld hl,_ico_ice
	inc de
.next5:
	or a,a
	jr nz,.next6
	ld hl,_ico_c
	inc de
.next6:
	cp a,$2C
	jr nz,.next7
	ld hl,_ico_ice_src
.next7:
	ld a,(de)
	inc de
	cp a,$C3
	jp z,.maybeicon
	ret
.maybebas:
	ld de,data_dcs_header
.checkdcs:
	ld a,(de)
	inc de
	or a,a
	jr z,.isdcs
	cpi
	jr z,.checkdcs
.isbasic:
	ld hl,_ico_basic
	ret
.isdcs:
	push hl
	ld hl,0
NextHomeSprite:=$-3
	ld (.returnsprite),hl
	ld a,16
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	ld bc,256
	add hl,bc
	ld (NextHomeSprite),hl
	or a,a
	sbc hl,bc
	ld b,0
	pop de
.dcsiconloop:
	ex hl,de
	ld a,(hl)
	cp a,$30
	jr c,.isbasic
	sbc a,$39
	jr c,.putcolor
.alpha:
	or a,a
	sbc a,$41
	jr c,.isbasic
	cp a,6
	jr nc,.isbasic
	add a,10
.putcolor:
	push hl
	push de
	ex hl,de
	ld de,0
	ld e,a
	ld hl,data_color_table
	add hl,de
	ld a,(hl)
	pop de
	pop hl
	djnz .dcsiconloop
	ld hl,0
.returnsprite:=$-3
	ret
.maybeicon:
	inc de
	inc de
	inc de
	ld a,(de)
	cp a,$01 ;has an icon
	ret nz
	inc de
	ex hl,de ;probably an icon in hl now
	ret

drawHomeScreen:
	ld hl,homeNameTemp
	ld (.currentHomeNamePtr),hl
	ld hl,0
homeSkip:=$-3
	ld (.skip),hl
	ld hl,home_item_left
	ld (.xpos),hl
	ld l,home_item_top
	ld (.ypos),hl
	xor a,a
	ld (string_temp+8),a
	ld hl,homeNameTemp
	ld (hl),a
	push hl
	pop de
	inc de
	ld bc,143
	ldir
	ld hl,data_open_r
	push hl
	ld hl,data_folds_appvar
	push hl
	call ti_Open
	or a,a
	jr nz,.exists
	call findPrograms
	call ti_Open
.exists:
	pop hl
	pop hl
	ld l,a
	push hl
	call ti_GetDataPtr
	ld (HomeDataVarPtr),hl
	call ti_GetSize
	ld de,(HomeDataVarPtr)
	add hl,de
	ld (HomeDataVarEndPtr),hl
	call ti_Close
	pop bc
	ld hl,(HomeDataVarPtr)
	ld bc,16
	add hl,bc
	ld (HomeDataVarPtr),hl
	ld (.currentdataptr),hl
.loop:
	ld hl,(.currentdataptr)
	ld bc,9
	add hl,bc
	ld hl,(hl)
	ex.s hl,de
	ld hl,(CurrentHomePage)
	or a,a
	sbc hl,de
	jp nz,.next
	ld hl,0
.skip:=$-3
	ld de,1
	or a,a
	sbc hl,de
	jr c,.drawitem
	ld (.skip),hl
	jp .next
.drawitem:
	ld hl,(.currentdataptr)
	ld a,(hl)
	ld e,a
	and a,$1F
	ld (getFileSpriteFromPtr.vartype),a
	push de
	ld de,data_open_r
	push de
	inc hl
	push hl
	ld de,string_temp
	ld bc,8
	ldir
	call ti_OpenVar
	pop bc
	pop bc
	pop bc
	or a,a
	jr z,.drawtitle
	ld l,a
	push hl
	call ti_GetDataPtr
	pop bc
	push hl
	push bc
	call ti_Close
	pop bc
	pop hl
	call getFileSpriteFromPtr
	ld de,3
	push de
	push de
	ld de,0
.ypos:=$-3
	push de
	ld de,0
.xpos:=$-3
	push de
	push hl
	call gfx_ScaledTransparentSprite
	pop bc
	pop hl
	pop de
	pop bc
	pop bc
.drawtitle:
	ld hl,(.ypos)
	ld de,home_item_text_offset_y
	add hl,de
	push hl
	ld hl,(.xpos)
	inc hl
	push hl
	ld hl,string_temp
	push hl
	call gfx_PrintStringXY
	pop bc
	pop bc
	pop bc

	ld de,0
.currentHomeNamePtr:=$-3
	ld hl,(.currentdataptr)
	ld bc,9
	ldir
	ld (.currentHomeNamePtr),de

	ld hl,(.xpos)
	ld de,home_item_width
	add hl,de
	ld (.xpos),hl
	ld de,home_item_right
	or a,a
	sbc hl,de
	jr c,.next

	ld hl,home_item_left
	ld (.xpos),hl
	ld hl,(.ypos)
	ld de,home_item_height
	add hl,de
	ld (.ypos),hl
	ld de,home_item_bottom
	or a,a
	sbc hl,de
	ret nc
.next:
	ld hl,0
.currentdataptr:=$-3
	ld de,11
	add hl,de
	ld (.currentdataptr),hl
	ld de,0
HomeDataVarEndPtr:=$-3
	or a,a
	sbc hl,de
	jp c,.loop
	ret

countHomeItems:
	ld de,0
	ld hl,(HomeDataVarPtr)
.loop:
	ld bc,9
	add hl,bc
	push hl
	push de
	ld hl,(hl)
	ex.s hl,de
	ld hl,(CurrentHomePage)
	or a,a
	sbc hl,de  ;check current page equal to item page
	pop de
	pop hl
	inc hl
	inc hl
	jr nz,$+1  ;don't count an item that isn't on the current page
	inc de
	ld bc,(HomeDataVarEndPtr)
	or a,a
	sbc hl,bc
	add hl,bc
	jr c,.loop
	ld a,e
	and a,$FC ;floor to the nearest 4
	ld e,a
	ld (maxHomeSkip),de
	ret


findPrograms:
	ld hl,data_open_w
	push hl
	ld hl,data_folds_appvar
	push hl
	call ti_Open
	ld (.fileslot),a
	ld l,a
	pop de
	pop de
	push hl
	ld hl,1
	push hl
	ld hl,data_bos_folds_header.len
	push hl
	ld hl,data_bos_folds_header
	push hl
	call ti_Write
	pop hl
	pop hl
	pop hl
	pop hl
	ld hl,.vartype
	push hl
	ld de,0
	push de
	ld hl,.temp_ptr
	ld (hl),de
	push hl
	ld hl,0
.temp_ptr:=$-3
.loop:
	call ti_DetectAny
	ld de,0
.fileslot:=$-3
	or a,a
	sbc hl,de
	add hl,de
	jr c,.exit
	call checkOSReservedVar  ;preserves de
	jr z,.loop
	push de ;file slot
	ld de,string_temp
	ld bc,8
	ldir
	ld hl,0
.vartype:=$-3
	push hl
	call ti_PutC
	pop hl
	ld de,1
	push de
	ld e,8
	push de
	ld hl,string_temp
	push hl ;data to write
	call ti_Write
	pop hl
	pop hl
	pop hl ;leave the file slot on the stack
	or a,a
	sbc hl,hl
	push hl
	call ti_PutC
	call ti_PutC
	pop hl
	pop hl ;pop the file slot
	jr .loop
.exit:
	pop hl
	pop hl
	ex hl,de
	ex (sp),hl
	call ti_Close
	pop de
	ld hl,data_folds_appvar-1
	call ti.Mov9ToOP1
	jp cesium.Arc_Unarc


checkOSReservedVar:
	ld a,(hl)
	cp a,$5D
	ret z
	cp a,'!'
	jr nz,.checknext
.checknull:
	inc hl
	ld a,(hl)
	or a,a
	ret
.checknext:
	cp a,'#'
	jr z,.checknull
	ret




