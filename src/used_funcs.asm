
;graphx header
db $C0,"GRAPHX",0,10

gfx_Begin:
	jp 0
gfx_End:
	jp 3
gfx_SetColor:
	jp 6
gfx_FillScreen:
	jp 15
gfx_SetDraw:
	jp 27
gfx_SwapDraw:
	jp 30
gfx_Blit:
	jp 33
gfx_BlitArea:
	jp 39
gfx_PrintInt:
	jp 45
gfx_PrintUInt:
	jp 48
gfx_PrintString:
	jp 51
gfx_PrintStringXY:
	jp 54
gfx_SetTextXY:
	jp 57
gfx_SetTextBGColor:
	jp 60
gfx_SetTextFGColor:
	jp 63
gfx_SetTextTransparentColor:
	jp 66
gfx_GetStringWidth:
	jp 78
gfx_GetCharWidth:
	jp 81
gfx_GetTextX:
	jp 84
gfx_GetTextY:
	jp 87
gfx_Rectangle:
	jp 105
gfx_FillRectangle:
	jp 108
gfx_Sprite:
	jp 171
gfx_TransparentSprite:
	jp 180
gfx_ScaledTransparentSprite:
	jp 189
gfx_SetTransparentColor:
	jp 225

;gfx_ZeroScreen:
;	jp 228

;KeypadC header
db $C0,"KEYPADC",0,1

kb_Scan:
	jp 0
kb_AnyKey:
	jp 6

;FileIOC header
db $C0,'FILEIOC',0,5
ti_CloseAll:
	jp 0
ti_Open:
	jp 3
ti_OpenVar:
	jp 6
ti_Close:
	jp 9
ti_Write:
	jp 12
ti_Read:
	jp 15
ti_GetC:
	jp 18
ti_PutC:
	jp 21
ti_Delete:
	jp 24
ti_DeleteVar:
	jp 27
ti_Seek:
	jp 30
ti_Resize:
	jp 33
ti_IsArchived:
	jp 36
ti_SetArchiveStatus:
	jp 39
ti_Tell:
	jp 42
ti_Rewind:
	jp 45
ti_GetSize:
	jp 48
ti_GetDataPtr:
	jp 54
ti_Detect:
	jp 57
ti_DetectVar:
	jp 60
ti_DetectAny:
	jp 87
ti_Rename:
	jp 96
ti_RenameVar:
	jp 99
ti_ArchiveHasRoom:
	jp 102
