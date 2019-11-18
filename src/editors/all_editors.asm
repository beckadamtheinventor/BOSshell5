

	dl __filetags_title
	dl __filetags
	dl __zipper_title
	dl __zipper
	dl __txt_title
	dl __txt
	dl 0

__filetags_title:
	db 0
__filetags:
	include 'filetags.asm'
__zipper_title:
	db "ZIPPER",0
__zipper:
	include 'zipper.asm'
__txt_title:
	db "TXT",0
__txt:
	include 'txt.asm'

