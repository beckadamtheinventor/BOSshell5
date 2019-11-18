
macro uppercase? string
	ld hl,string
	call str_upper
end macro

macro lowercase? string
	ld hl,string
	call str_lower
end macro

macro strcpy? string, strout
	ld hl,string
	ld de,strout
	call str_copy
end macro

macro strlen? string
	ld hl,string
	call str_len
end macro

macro strset? string, char
	ld hl,string
	ld c,char
	call str_set
end macro

macro strcmp? string, strout
	ld hl,string
	ld de,strout
	call str_cmp
end macro

macro memset? ptr, amt, data
	ld c,data
	ld hl,ptr
	ld bc,amt
	call sys_setMem
end macro



; set BC bytes of HL to the value C
sys_setMem:
	xor a,a
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ret

; get length of null-terminated string at HL
; return length in BC
str_len:
	ld bc,0
	xor a,a
.loop:
	cpir
	sbc hl,hl
	sbc hl,bc
	ret

; set null-terminated string at HL to byte C
; input HL -- string
; input C -- byte
str_set:
	xor a,a
.loop:
	cp a,(hl)
	ret z
	ld (hl),c
	inc hl
	jr .loop


; copy null-terminated string at HL to DE
; return HL -- null-terminated string
str_copy:
	xor a,a
	ld bc,0
.loop:
	cp a,(hl)
	ldi
	jr nz,.loop
	ex hl,de
	add hl,bc
	ret


; uppercase version of string at HL
_str_upper:
.loop:
	ld (hl),a
.next:
	inc hl
str_upper:
	ld a,(hl)
	or a,a
	ret z
	sub a,'a'
	cp a,26
	jr nc,_str_upper.next
	add a,'A'
	jr _str_upper.loop

; lowercase version of string at HL
_str_lower:
.loop:
	ld (hl),a
.next:
	inc hl
str_lower:
	ld a,(hl)
	or a,a
	ret z
	sub a,'A'
	cp a,26
	jr nc,_str_lower.next
	add a,'a'
	jr _str_lower.loop

; compare strings HL and DE.
; return z if true, otherwise nz
; will subtract the minimum of the lengths of HL and DE, from BC.
str_cmp:
	ld a,(de)
	inc de
	cpi
	jr z,str_cmp
	ret


