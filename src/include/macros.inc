macro relocate? name, address*
	name.source? := $
	name.destination? := address
	org name.destination?
	macro name.copy?
		ld	hl, name.source?
		ld	de, name.destination?
		ld	bc, name.length?
		ldir
	end macro
	macro name.run
		name.copy
		jp	name.destination?
	end macro
	macro name.call
		name.copy
		call	name.destination?
	end macro
	macro end?.relocate?
		name.length? := $ - name.destination?
		org name.source? + name.length?
		purge end?.relocate?
	end macro
end macro

macro compare_hl_zero
	sbc hl,de
	add hl,de
end macro

macro compare_hl_de
	sbc hl,de
	add hl,de
end macro


bos_execution_base:=$D09466

return_goto := $aa
return_prgm := $bb
return_settings := $cc
return_edit := $ee
edit_archived := $ff				; edit_status
edit_goto := return_edit			; edit_mode


; these should go in ti84pce.inc

sysHookFlg := 52
appInpPrmptInit := 0
appInpPrmptDone := 1
appWantHome := 4
