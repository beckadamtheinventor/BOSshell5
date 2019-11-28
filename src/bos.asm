

include 'include/ez80.inc'
include 'include/tiformat.inc'
include 'include/ti84pceg.inc'
format ti executable "BOSSHELL"
include 'include/app.inc'
include 'include/macros.inc'


; Install me
app_create
	
	ret	nz
	call	ti.ChkFindSym
	jp	ti.DelVarArc		; delete installer code
shell_name:
db "BOSshell",0

app_start 'BOSshell', '2019 beckadamtheinventor'

bos_start:
	bos_code.run

relocate bos_code, bos_execution_base
	include 'main.asm'
	include 'load_libs.asm'
	include 'files.asm'
	include 'exit.asm'
	include 'edit.asm'
	include 'execute.asm'
	include 'squish.asm'
	include 'util.asm'
	include 'sort.asm'
	include 'gfx.asm'
	include 'config.asm'
	include 'ui.asm'
end relocate

; we want to keep these things in flash
include 'flash.asm'
include 'return.asm'
include 'hooks.asm'

include 'data.asm'

