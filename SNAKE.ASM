model	tiny
.code
org	100h

; Constants
args_pos = 80h

; Field cells
snake_cell = 2000h
apple_cell = 0a6fh
burger_cell = 0c0fh
poison_cell = 8e0bh
empty_cell = 0h

left_cell = 71b3h
right_cell = 4dbh
up_cell = 0e0cdh
down_cell = 3fb0h

_start:
	call	begin
	ret
; Variables

old_int09	dw	0, 0	; old keyboard control address

; Music params
valoct	dd	1191109120	; octave value
valnot	dd	1149526016	; note value
deg	dd	1073741824	; octave degree
decr	dd	1148846080	; divide value
result	dd	0		; writable value

; Game load params
snake_length	dw	2
speed_mode	dw	3	; [1;5]
apples_cnt	dw	3
burgers_cnt	dw	1
poison_cnt	dw	1
uwall_mode	dw	1	; [0;3]
cut_mode	dw	1	; [0;2]

; Game extras
help_mode	dw	0	; freeze update + print controls
pause_mode	dw	0	; freeze update
exit_mode	dw	0	; print stats + restart
cspeed_mode	dw	3	; current speed

; Snake
snake_dx	db	0
snake_dy	db	1
snake_xbuffer	db	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
snake_ybuffer	db	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

; The Buffer!
buf_x		db	1,7,17,5,9,11,14,5,4,10,8,9,3,2,7,9,16,3,17,14
buf_y		db	14,17,3,16,9,7,2,3,9,8,10,4,5,14,11,9,5,17,7,1
buf_pos		db	0	; Max = 19

; Counters - check'em before take from buffer (if = 0 push to max)
apple		dw	0
burger		dw	0
poison		dw	0

; Field variables
; Left-reflect	71B3
; Right-death	4DB
; Down-teleport	3FB0
; Up-any	E0CD
; Snake		2000
; Apple		A6F
; Burger	C0F
; Poison	8E0B
; size 19x32 (OX x OY)
field	dw	0,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,57549,0
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	29107,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1243
	dw	0,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,16304,0

; Stats-field
statfield	db	"================================"
		db	"|        GAME STATISTICS       |"
		db	"================================"
flen_print	db	"| FINAL LENGTH  |00000000000000|"
		db	"================================"
mxlen_print	db	"| MAX LENGTH    |00000000000000|"
minlen_print	db	"| MIN LENGTH    |00000000000000|"
		db	"================================"
apeat_print	db	"| APPLES EATEN  |00000000000000|"
breat_print	db	"| BURGERS EATEN |00000000000000|"
		db	"================================"
rflt_print	db	"| REFLECTED     |00000000000000|"
		db	"================================"
tlpt_print	db	"| TELEPORTED    |00000000000000|"
		db	"================================"
cut_print	db	"| CUT           |00000000000000|"
		db	"================================"
		db	"|  PRESS ANY KEY TO CONTINUE   |" ; wanna flash
		db	"================================"

; Help-field
helpfield	db	"================================"
		db	"| ", 0h," - SNAKE     | ", 0b3h ," - REFLECT  |"
		db	"| o - APPLE     | ", 0dbh ," - DEATH    |"
		db	"| ", 0fh, " - BURGER    | ", 0b0h," - TELEPORT |"
		db	"| ", 0bh, " - POISON    | ", 0cdh ," - EXTRA    |"
		db	"================================"
		db	"|            CONTROLS          |"
		db	"| F1            |WRITES HELP   |"
		db	"| + BUTTON      |INCREASE SPEED|"
		db	"| - BUTTON      |DECREASE SPEED|"
		db	"| LEFT ARROW    |MOVE LEFT     |"
		db	"| UP ARROW      |MOVE UP       |"
		db	"| RIGHT ARROW   |MOVE RIGHT    |"
		db	"| DOWN ARROW    |MOVE DOWN     |"
		db	"| SPACE         |PAUSE GAME    |"
		db	"| ESC           |EXIT          |"
		db	"================================"
		db	"|   PRESS F1 TO CONTINUE PLAY  |" ; wanna flash
		db	"================================"


; Stats variables
final_length	dw	0	; load when end
max_length	dw	0	; max{mx, cur}
min_length	dw	0	; min{mn, cur}
apples_eaten	dw	0	; if apple ++
burgers_eaten	dw	0	; if burger ++
reflected	dw	0	; when reflect ++
teleported	dw	0	; when teleport ++
cut		dw	0	; when cut ++
; Functions

; Main function
begin:
	; Parse args
	mov	si,	args_pos
	lodsb
	mov	cl,	al
	test	cl,	cl
	jz	endparse_D
	add	cl,	081h
	mov	ch,	0	; 0 - read key, other (letter) - read int
args_lp:
	test	ch,	ch
	jnz	rint
rkey:
	call	read_key
	cmp	ax,	02f68h	; is /h
	jne	keycheck	
	mov	ch,	'h'
	jmp	endparse
keycheck:
	cmp	ax,	02f6ch	; /l
	je	ekey
	cmp	ax,	02f61h	; /a
	je	ekey
	cmp	ax,	02f72h	; /r
	je	ekey
	cmp	ax,	02f64h	; /d
	je	ekey
	cmp	ax,	02f63h	; /c
	je	ekey
	cmp	ax,	02f77h	; /w
	je	ekey
	mov	ch,	0FFh	; No correct mode error
	jmp	endparse
ekey:
	cmp	dx,	'='
	je	noerkey
	mov	ch,	0fdh	; No = error
	jmp	endparse
endparse_D:
	jmp	endparse
args_lp_U:
	jmp	args_lp
noerkey:
	mov	ch,	al	; Set key_no
	jmp	endcheck
rint:
	call	read_int
	cmp	ax,	0FFFFh
	je	endparse	; No int error
	cmp	ch,	06ch	; /l
	je	setlkey
	cmp	ch,	061h	; /a
	je	setakey
	cmp	ch,	072h	; /r
	je	setrkey
	cmp	ch,	064h	; /d
	je	setdkey
	cmp	ch,	063h	; /c
	je	setckey
	cmp	ch,	077h	; /w
	je	setwkey
setlkey:
	test	ax,	ax
	jnz	lok
	mov	ch,	0feh
	jmp	endparse
lok:
	mov	di,	offset	snake_length
	jmp	eint
setakey:
	mov	di,	offset	apples_cnt
	jmp	eint
setrkey:
	mov	di,	offset	burgers_cnt
	jmp	eint
setdkey:
	mov	di,	offset	poison_cnt
	jmp	eint
setckey:
	cmp	ax,	2
	jle	ckeyok
	mov	ch,	0feh
	jmp	endparse
ckeyok:
	mov	di,	offset	cut_mode
	jmp	eint
setwkey:
	cmp	ax,	3
	jle	wkeyok
	mov	ch,	0feh
	jmp	endparse
wkeyok:
	mov	di,	offset	uwall_mode
	jmp	eint
eint:
	mov	[di],	ax
	xor	ch,	ch
	jmp	endcheck
endcheck:
	push	cx
	xor	ch,	ch
	cmp	cx,	si	; Check [si in end position]
	pop	cx
	jg	args_lp_U
	; Parse ends
endparse:
; Printer codes: 'h' - help, "FF" - incorrect mode, "FE" - incorrect args
; "FD" - missing =
; Message checker
	cmp	ch,	'h'
	je	phelp
	cmp	ch,	0FFh
	je	pimode
	cmp	ch,	0FEh
	je	piargs
	cmp	ch,	0FDh
	je	pmeq
	test	ch,	ch
	jnz	pmnum		; If some args not filled
game:
	call	init		; Set settings into game state
gm_lp:
	call	iteration
	call	print_game
	mov	di,	offset exit_mode
	mov	di,	[di]
	test	di,	di
	jnz	game_exit
	call	calc_game
pause_loop:
	mov	di,	offset pause_mode
	mov	di,	[di]
	test	di,	di
	jnz	pause_loop
help_loop:
	mov	di,	offset help_mode
	mov	di,	[di]
	test	di,	di
	jz	skp_hprint
	call	print_help
	jmp	help_loop
skp_hprint:
	jmp	gm_lp
game_exit:
	call	restore		; Restore to basic state
	push	cs
	pop	es		; Restore es-register
	
	call	init_stat
	call	print_stat	; Print end-game stat
	xor	ax, ax
	int	16h

	jmp	ext
phelp:
	mov	dx,	offset msghelpkey
	jmp	showmsg
pimode:
	mov	dx, 	offset msgerrormode
	jmp	showmsg
piargs:
	mov	dx,	offset msgerrorargs
	jmp	showmsg
pmeq:
	mov	dx,	offset msgmissingeq
	jmp	showmsg
pmnum:
	mov	dx,	offset msgmissingnum
	jmp	showmsg
showmsg:
	mov	ah,	09h
	int	21h
	jmp	ext
ext:
	ret

; Just nop-function, correction game speed
iteration:
	push	di
	push	cx

	mov	di,	offset cspeed_mode
	mov	di,	[di]
	mov	cx,	6
	sub	cx,	di
	shl	cx,	2
nop_lp:
	push	cx
	mov	cx,	0fffh
nop_ilp:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	loop	nop_ilp
	pop	cx
	loop	nop_lp
	pop	cx
	pop	di
	ret

; Read from args as int into ax
; If no int -> ax = 0FFFFh
read_int:
	push	dx
	push	cx
	xor	ax,	ax
	xor	cx,	cx
@@rep:
	mov	dx, 	0ah
	mul	dx
	push	ax
	xor	ax,	ax
	lodsb
	cmp	al,	'0'
	jl	exrint
	cmp	al,	'9'
	jg	exrint
	sub	al,	'0'
	mov	dx,	ax
	pop	ax
	add	ax,	dx
	inc	cx
	jmp	@@rep
exrint:
	pop	ax
	push	bx
	mov	bx,	0ah
	div	bx
	pop	bx
	test	cx,	cx
	jnz	ndrint
	mov	ax,	0ffffh	; if no digit
ndrint:
	pop	cx
	pop	dx
	ret

; Read from args as key (pair slash-latin)
; Save them in ax
; Last symbol saved in dx -> to = check
read_key:
	xor	ax,	ax
	xor	dx,	dx
@@rep2:
	shl	ax,	8
	add	ax,	dx
	xor	dx,	dx
	xchg	ax,	dx
	lodsb
	xchg	ax,	dx
	cmp	dx,	'='
	je	exrkey
	test	dx,	dx
	jz	exrkey
	cmp	dx,	0dh
	je	exrkey
	cmp	ah,	02fh	; slash-check
	jne	@@rep2
	test	al,	al
	jnz	exrkey
	jmp	@@rep2
exrkey:
	ret

; Complete init (set a new keyboard-controller, push stat, init field)
init:
	mov	ax,	03509h
	int	21h
	mov	di,	offset	old_int09

	mov	[di],	bx
	mov	[di+2],	es

	mov	dx,	offset	keyboard
	mov	ax,	02509h
	int	21h

	mov	di,	offset snake_length
	mov	ax,	[di]
	mov	di,	offset max_length
	mov	[di],	ax	
	mov	di,	offset min_length
	mov	[di],	ax
	
	mov	di,	offset uwall_mode
	mov	ax,	[di]
	cmp	ax,	3
	jne	nonrand
; Generate "rand" mode for upper
	mov	di,	offset snake_length
	add	ax,	[di]
	mov	di,	offset apples_cnt
	add	ax,	[di]
	mov	di,	offset burgers_cnt
	add	ax,	[di]
	mov	di,	offset poison_cnt
	add	ax,	[di]

	and	ax,	3
	cmp	ax,	3
	jne	uwall_skip
	mov	ax,	1
uwall_skip:
	mov	di,	offset uwall_mode
	mov	[di],	ax
nonrand:	
	call	print_snake
	call	refresh_cells
	call	print_game
	ret

; Function to write into stat field
init_stat:
	push	ax
	mov	di,	offset snake_length
	mov	ax,	[di]
	mov	di,	offset final_length	; Save last length
	mov	[di],	ax
	pop	ax

	mov	si,	offset final_length
	mov	di,	offset flen_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset max_length
	mov	di,	offset mxlen_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset min_length
	mov	di,	offset minlen_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset apples_eaten
	mov	di,	offset apeat_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset burgers_eaten
	mov	di,	offset breat_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset reflected
	mov	di,	offset rflt_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset teleported
	mov	di,	offset tlpt_print
	add	di,	01eh
	call	iwrite_rev
	mov	si,	offset cut
	mov	di,	offset cut_print
	add	di,	01eh
	call	iwrite_rev
	ret

; Move the snake, calc intersection, walls
calc_game:
	call	move		; move a snake
wall_upd:
	call	next_move	; check new cell
	test	ax,	ax
	jz	calc_end

	cmp	ax,	apple_cell
	je	calc_ap
	cmp	ax,	burger_cell
	je	calc_bu
	cmp	ax,	poison_cell
	je	calc_po
	cmp	ax,	snake_cell
	je	calc_sn
	cmp	ax,	left_cell
	je	calc_le
	cmp	ax,	right_cell
	je	calc_ri
	cmp	ax,	up_cell
	je	calc_up
	cmp	ax,	down_cell
	je	calc_do
	jmp	calc_end
calc_ap:
	call	snake_apple
	jmp	calc_end
calc_bu:
	call	snake_burger
	jmp	calc_end
calc_po:
	call	snake_poison
	jmp	calc_end
calc_sn:
	call	snake_snake
	jmp	calc_end
calc_le:
	call	snake_left
	jmp	wall_upd
calc_ri:
	call	snake_right
	jmp	calc_end
calc_up:
	call	snake_up
	cmp	cx,	1
	je	wall_upd
	jmp	calc_end
calc_do:
	call	snake_down
	jmp	wall_upd
calc_end:
	mov	di,	offset exit_mode
	mov	di,	[di]
	test	di,	di
	jnz	calc_ext
	call	print_snake
	call	refresh_cells
calc_ext:
	ret

; Cell-controller functions
snake_apple:
	push	ax

	mov	di,	offset apple
	mov	ax,	[di]
	dec	ax
	mov	[di],	ax

	mov	di,	offset apples_eaten
	mov	ax,	[di]
	inc	ax
	mov	[di],	ax

	mov	di,	offset snake_length
	mov	ax,	[di]
	inc	ax
	mov	[di],	ax

	mov	di,	offset max_length
	cmp	ax,	[di]
	jle	no_max
	mov	[di],	ax
no_max:
	pop	ax
	push	cx
	mov	di,	offset apple_soundn
	mov	si,	offset apple_soundo
	mov	cx,	0ch
	call	sound_tone
	pop	cx
	ret

snake_burger:
	push	ax


	mov	di,	offset burger
	mov	ax,	[di]
	dec	ax
	mov	[di],	ax

	mov	di,	offset burgers_eaten
	mov	ax,	[di]
	inc	ax
	mov	[di],	ax

	mov	di,	offset snake_length
	mov	ax,	[di]
	dec	ax
	mov	[di],	ax
; remove last
	push	ax
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	ax
	add	si,	ax

	xor	ax,	ax
	mov	al,	byte ptr [di]
	shl	ax,	6
	add	al,	byte ptr [si]
	add	al,	byte ptr [si]
	mov	di,	offset field
	add	di,	ax
	xor	ax,	ax
	mov	[di],	ax
	pop	ax

	mov	di,	offset min_length
	cmp	ax,	[di]
	jge	no_min
	mov	[di],	ax
no_min:
	test	ax,	ax
	jnz	sna_ext
; Snake zero-length
	mov	di,	offset exit_mode
	inc	ax
	mov	[di],	ax
sna_ext:
	pop	ax
	push	cx
	mov	di,	offset burger_soundn
	mov	si,	offset burger_soundo
	mov	cx,	0ch
	call	sound_tone
	pop	cx
	ret

snake_poison:
	push	ax
	xor	ax,	ax
	mov	di,	offset exit_mode
	inc	ax
	mov	[di],	ax
	pop	ax
	push	cx
	mov	di,	offset poison_soundn
	mov	si,	offset poison_soundo
	mov	cx,	0ch
	call	sound_tone
	pop	cx
	ret

snake_snake:
	push	ax
	mov	di,	offset cut_mode
	mov	ax,	[di]
	test	ax,	ax
	jz	snsn_ext	; ignore-mode
	cmp	ax,	1
	je	snsn_dead	; dead-mode

; take next position
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer

	push	cx
	mov	al,	byte ptr [di]
	mov	ah,	byte ptr [si]
	xor	cx,	cx
snsn_search:
	inc	cx
	inc	di
	inc	si

	push	bx
	mov	bl,	byte ptr [di]
	mov	bh,	byte ptr [si]
	cmp	ax,	bx
	je	snsn_refresh
	pop	bx
	jmp	snsn_search
snsn_refresh:
	push	di
	mov	di,	offset snake_length
	mov	bx,	[di]
	mov	[di],	cx
	mov	di,	offset min_length
	cmp	cx,	[di]
	jge	cut_ignore
	mov	[di],	cx
cut_ignore:
	pop	di
snsnr_lp:
	xor	ax,	ax
	mov	al,	byte ptr [di]
	shl	ax,	6
	add	al,	byte ptr [si]
	add	al,	byte ptr [si]
	push	di
	mov	di,	offset field
	add	di,	ax
	mov	ax,	empty_cell
	mov	[di],	ax
	pop	di

	inc	di
	inc	si
	inc	cx
	cmp	bx,	cx
	jne	snsnr_lp
	pop	bx
	mov	di,	offset cut
	mov	cx,	[di]
	inc	cx
	mov	[di],	cx
	pop	cx
	jmp	snsn_ext
snsn_dead:
	mov	di,	offset exit_mode
	mov	[di],	ax
snsn_ext:
	pop	ax
	ret

snake_left:
	push	ax
	push	bx
; set new vector
	mov	di,	offset snake_dx
	mov	ax,	0100h
	mov	[di],	ax
; reverse
	mov	di,	offset snake_length
	mov	ax,	[di]
	inc	ax
revpush_lp:
	dec	ax
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	ax
	add	si,	ax
	mov	bl,	[di]
	mov	bh,	[si]
	push	bx
	test	ax,	ax
	jnz	revpush_lp
; end push
	mov	di,	offset snake_length
	mov	ax,	[di]
	inc	ax
revsav_lp:
	dec	ax
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	ax
	add	si,	ax
	pop	bx
	mov	byte ptr [di], bl
	mov	byte ptr [si], bh
	test	ax,	ax
	jnz	revsav_lp
	pop	bx
	mov	di,	offset reflected
	mov	ax,	[di]
	inc	ax
	mov	[di],	ax
	pop	ax
	ret

snake_right:
	push	ax
	xor	ax,	ax
	mov	di,	offset exit_mode
	inc	ax
	mov	[di],	ax
	pop	ax
	ret

snake_up:
	push	ax
	mov	di,	offset uwall_mode
	mov	ax,	[di]
	test	ax,	ax
	je	ureflect
	cmp	ax,	1
	je	udeath
	jmp	uteleport
ureflect:
	push	bx
; set new vector
	mov	di,	offset snake_dx
	mov	ax,	1
	mov	[di],	ax
; reverse
	mov	di,	offset snake_length
	mov	ax,	[di]
	inc	ax
urevpush_lp:
	dec	ax
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	ax
	add	si,	ax
	mov	bl,	byte ptr [di]
	mov	bh,	byte ptr [si]
	push	bx
	test	ax,	ax
	jnz	urevpush_lp
; end push
	mov	di,	offset snake_length
	mov	ax,	[di]
	inc	ax
urevsav_lp:
	dec	ax
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	ax
	add	si,	ax
	pop	bx
	mov	byte ptr [di], bl
	mov	byte ptr [si], bh
	test	ax,	ax
	jnz	urevsav_lp
	pop	bx
	mov	cx,	1
	mov	di,	offset reflected
	mov	ax, 	[di]
	inc	ax
	mov	[di],	ax
	jmp	snup_ext
udeath:
	mov	di,	offset exit_mode
	inc	ax
	mov	[di],	ax
	jmp	snup_ext
uteleport:
	mov	di,	offset snake_xbuffer
	mov	al,	17
	mov	byte ptr [di],	al
	mov	cx,	1
	mov	di,	offset teleported
	mov	ax,	[di]
	inc	ax
	mov	[di],	ax
	jmp	snup_ext
snup_ext:
	pop	ax
	ret

snake_down:
	push	ax
	mov	di,	offset snake_xbuffer
	mov	al,	1
	mov	byte ptr [di],	al
	mov	di,	offset teleported
	mov	ax,	[di]
	inc	ax
	mov	[di],	ax
	pop	ax	
	ret

; Function to move a snake without any check
move:
	push	cx
	mov	di,	offset snake_length
	mov	cx, 	[di]
; kill last cell
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	cx
	add	si,	cx
	dec	di
	dec	si
	push	ax
	push	cx
	mov	al,	byte ptr [di]
	mov	ah,	byte ptr [si]
	xor	cx,	cx
	mov	cl,	al
	shl	cx,	6
	add	cl,	ah
	add	cl,	ah
	mov	di,	offset field
	add	di,	cx
	mov	cx,	empty_cell
	mov	[di],	cx
	pop	cx
	pop	ax
move_lp:
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	cx
	add	si,	cx

	push	ax
	push	di
	push	si

	dec	di
	dec	si
	mov	al,	byte ptr [di]
	mov	ah,	byte ptr [si]

	pop	si
	pop	di
	mov	byte ptr [di], al
	mov	byte ptr [si], ah

	pop	ax

	dec	cx
	jnz	move_lp
; get new cell
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer

	mov	cl,	byte ptr [di]
	mov	ch,	byte ptr [si]
	mov	di,	offset snake_dx
	mov	si,	offset snake_dy

	add	cl,	byte ptr [di]
	add	ch,	byte ptr [si]

	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer

	mov	byte ptr [di], cl
	mov	byte ptr [si], ch

	pop	cx
	ret

; Function returns cell, which is new to the snake
; return into ax as cell-code 
next_move:
	push	di
	push	si

	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer

	xor	ax,	ax
	mov	al,	byte ptr [di]
	shl	ax,	6
	add	al,	byte ptr [si]
	add	al,	byte ptr [si]

	mov	di,	offset field
	add	di,	ax
	mov	ax,	[di]
	
	pop	si
	pop	di
	ret

; Update cells if empty
refresh_cells:
	push	ax
	push	cx
	mov	di,	offset apples_cnt
	mov	cx,	[di]
	mov	di,	offset apple
	sub	cx,	[di]
	jz	appe_lp
app_lp:
	call	find_fcell
	test	ax,	ax
	jz	ref_ext
	mov	di,	offset field
	add	di,	ax
	mov	[di],	apple_cell
	dec	cx
	mov	di,	offset apple
	push	cx
	mov	cx,	[di]
	inc	cx
	mov	[di],	cx
	pop	cx
	test	cx,	cx
	jnz	app_lp
appe_lp:
	mov	di,	offset burgers_cnt
	mov	cx,	[di]
	mov	di,	offset burger
	sub	cx,	[di]
	jz	bure_lp
bur_lp:
	call	find_fcell
	test	ax,	ax
	jz	ref_ext
	mov	di,	offset field
	add	di,	ax
	mov	[di],	burger_cell
	dec	cx
	mov	di,	offset burger
	push	cx
	mov	cx,	[di]
	inc	cx
	mov	[di],	cx
	pop	cx
	test	cx,	cx
	jnz	bur_lp
bure_lp:
	mov	di,	offset poison_cnt
	mov	cx,	[di]
	mov	di,	offset poison
	sub	cx,	[di]
	jz	ref_ext
poi_lp:
	call	find_fcell
	test	ax,	ax
	jz	ref_ext
	mov	di,	offset field
	add	di,	ax
	mov	[di],	poison_cell
	dec	cx
	mov	di,	offset poison
	push	cx
	mov	cx,	[di]
	inc	cx
	mov	[di],	cx
	pop	cx
	test	cx,	cx
	jnz	poi_lp
ref_ext:
	pop	cx
	pop	ax
	ret

; Find first empty cell (as shift)
; If no empty - returns zero
find_fcell:
	push	di
	push	si
	push	bx
	xor	bx,	bx

	mov	si,	offset buf_pos
	mov	bl,	byte ptr [si]	; get pos - save it to check
	mov	ax,	bx

fcell_lp:
	mov	di,	offset buf_x
	mov	si,	offset buf_y
	add	di,	ax
	add	si,	ax

	push	cx
	xor	cx,	cx
	mov	cl,	byte ptr [di]
	shl	cx,	6
	add	cl,	byte ptr [si]
	add	cl,	byte ptr [si]

	push	di
	mov	di,	offset field
	add	di,	cx
	push	cx
	mov	cx,	[di]
	test	cx,	cx
	jnz	fcell_next
fcell_succ:
	mov	di,	offset buf_pos
	mov	byte ptr [di],	al
	pop	ax
	pop	di
	pop	cx
	jmp	fcell_ext
fcell_next:
	pop	di
	pop	cx
	pop	cx	
	inc	ax
	cmp	ax,	019h
	jne	fcell_cskp	; return to start buffer
	xor	ax,	ax
fcell_cskp:
	cmp	ax,	bx
	jne	fcell_lp
	xor	ax,	ax
fcell_ext:
	pop	bx
	pop	si
	pop	di
	ret

; just print snake
print_snake:
	push	cx
	mov	di,	offset snake_length
	mov	cx,	[di]
prsn_lp:
	test	cx,	cx
	jz	prsn_ext
	mov	di,	offset snake_xbuffer
	mov	si,	offset snake_ybuffer
	add	di,	cx
	add	si,	cx
	dec	di
	dec	si

	push	cx
	xor	cx,	cx
	mov	cl,	byte ptr [di]
	shl	cx,	6
	add	cl,	byte ptr [si]
	add	cl,	byte ptr [si]
	
	mov	di,	offset field
	add	di,	cx
	mov	[di],	snake_cell
	pop	cx

	dec	cx
	jmp	prsn_lp
prsn_ext:
	pop	cx
	ret

; Game controller
keyboard:
; Codes (just not to forget)
; +		4e
; -		4a
; esc		01
; LUDR-arrows	4b 48 50 4d
; f1		3b
; space		39
; Take scan-code
	push	di
	push	bx
	in	al,	60h
	push	ax
	mov	di,	offset help_mode
	mov	bx,	[di]
	test	bx,	bx
	jnz	hmode
	mov	di,	offset pause_mode
	mov	bx,	[di]
	test	bx,	bx
	jnz	spmode
	mov	di,	offset exit_mode
	mov	bx,	[di]
	test	bx,	bx
	jnz	exmode
	cmp	al,	4eh
	je	plcode
	cmp	al,	4ah
	je	mncode
	cmp	al,	01h
	je	esccode
	cmp	al,	04bh
	je	larcode
	cmp	al,	048h
	je	uarcode
	cmp	al,	050h
	je	darcode
	cmp	al,	04dh
	je	rarcode
	cmp	al,	03bh
	je	f1code
	cmp	al,	039h
	je	spcode
	jmp	kbext
hmode:
	cmp	al,	03bh
	je	f1code
	jmp	kbext
spmode:
	cmp	al,	039h
	je	spcode
	jmp	kbext
exmode:
	; EXIT
	jmp	kbext
plcode:
	mov	di,	offset cspeed_mode
	mov	ax,	[di]
	cmp	ax,	5
	je	pign
	inc	ax
pign:
	jmp	setter
mncode:
	mov	di,	offset cspeed_mode
	mov	ax,	[di]
	cmp	ax,	1
	je	mign
	dec	ax
mign:
	jmp	setter
esccode:
	mov	di,	offset exit_mode
	mov	ax,	1
	jmp	setter
uarcode:
	mov	di,	offset snake_dx
	mov	ax,	0ffh
	jmp	setter
larcode:
	mov	di,	offset snake_dx
	mov	ax,	0ff00h
	jmp	setter
rarcode:
	mov	di,	offset snake_dx
	mov	ax,	0100h
	jmp	setter
darcode:
	mov	di,	offset snake_dx
	mov	ax,	1
	jmp	setter
f1code:
	mov	di,	offset help_mode
	mov	ax,	1
	sub	ax,	[di]
	jmp	setter
spcode:
	mov	di,	offset pause_mode
	mov	ax,	1
	sub	ax,	[di]
	jmp	setter
ycode:
	; Set to restart
	jmp	setter
ncode:
	; Set to exit
	jmp	setter
setter:	; set ax into [di]
	mov	[di],	ax
; Read end
kbext:
	pop	ax
	pop	bx
	pop	di
	in	al,	61h
	mov	ah,	al
	or	al,	80h
	out	61h,	al
	xchg	ah,	al
	out	61h,	al
	mov	al,	20h
	out	20h,	al
	iret

; Restore old controller
restore:
	push	ds
	push	dx
	push	ax
	lds	dx,	dword ptr cs:old_int09
	mov	ax,	02509h
	int	21h
	pop	ax
	pop	dx
	pop	ds
	ret

; Switch on sound in cx frequency
sound_on:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	bx,	cx
	mov	ax,	034ddh
	mov	dx,	012h
	div	bx
	mov	bx,	ax
	in	al,	61h
	or	al,	3
	out	61h,	al
	mov	al,	10110110b
	mov	dx,	043h
	out	dx,	al
	dec	dx
	mov	al,	bl
	out	dx,	al
	mov	al,	bh
	out	dx,	al
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

; Switch off sound
sound_off:
	push	ax
	in	al,	61h
	and	al,	not 3
	out	61h,	al
	pop	ax
	ret

; Form in cx as sound frequency from pair (ax, bx) - (note, octave)
converttofreq:
	finit
	mov	di,	offset decr
	fld	dword ptr [di]
	mov	di,	offset valoct
	fld	dword ptr [di]
	fdivr
lp:
	mov	di,	offset deg
	fld	dword ptr [di]
	fmul
	dec	bx
	jnz	lp
lp1:
	mov	di,	offset valnot
	fld	dword ptr [di]
	fmul
	mov	di,	offset decr
	fld	dword ptr [di]
	fxch	st(1)
	fdivr
	dec	ax
	jnz	lp1
	fistp	result
	mov	di,	offset result
	mov	cx,	[di]
	ret

; Writes into pointer (es:di) as int [si]
; Direction - reversed
iwrite_rev:
	push	ax
	push	dx
	push	bx
	pushf
	pushf
	pop	ax
	or	ax,	0400h
	push	ax
	popf
	mov	ax,	[si]
	mov	bx,	0ah
	xor	dx,	dx
wrlp:
	div	bx
	xchg	ax,	dx
	add	ax,	'0'
	stosb
	xchg	ax,	dx
	xor	dx,	dx
	test	ax,	ax
	jnz	wrlp
	popf
	pop	bx
	pop	dx
	pop	ax
	ret

print_help:
	push	cx
	push	ax
	push	bp
	push	di
	push	dx
	xor	dx,	dx		; set cursor
	mov	cx,	020h		; set length
	mov	di,	010h		; set height
	mov	ax,	01e01h		; set color
	mov	bp,	offset helpfield; set string
	call	draw_field
	mov	di,	03h
	mov	ax,	09e01h
	call	draw_field
	pop	dx
	pop	di
	pop	bp
	pop	ax
	pop	cx
	ret

print_stat:
	push	cx
	push	ax
	push	bp
	push	di
	push	dx
	xor	dx,	dx		; set cursor
	mov	cx,	020h		; set length
	mov	di,	010h		; set height
	mov	ax,	01e01h		; set color
	mov	bp,	offset statfield; set string
	call	draw_field
	mov	di,	03h
	mov	ax,	09e01h
	call	draw_field
	pop	dx
	pop	di
	pop	bp
	pop	ax
	pop	cx
	ret


print_game:
	push	cx
	push	ax
	push	bp
	push	di
	push	dx
	xor	dx,	dx		; set cursor
	mov	cx,	020h		; set length
	mov	di,	013h		; set height
	mov	ax,	01e03h		; set color
	mov	bp,	offset field; set string
	call	draw_field
	pop	dx
	pop	di
	pop	bp
	pop	ax
	pop	cx
	ret


; Draw-function
; Gets cx as length
; (ah, al) - attr, subserv
; es:bp - string ptr
; di - height
; dx - cursor
draw_field:
	push	es
	push	cs
	pop	es

	push	ax
	push	di
	push	bp
	mov	ah,	0fh
	int	10h		; get into bh page
	pop	bp
	pop	di
	pop	ax
	mov	bl,	ah	; move attr
drawlp:
	push	ax
	push	bp
	push	di
	mov	ah,	013h
	int	10h
	pop	di
	pop	bp
	pop	ax
	dec	di
	inc	dh
	cmp	al,	02h
	jl	ljmp
bjmp:
	add	bp,	040h
	jmp	drext
ljmp:
	add	bp,	020h
	jmp	drext
drext:
	test	di,	di
	jne	drawlp
	pop	es
	ret

apple_soundn	dw	7,7,7,8,8,8,9,9,9,8,8,8
apple_soundo	dw	1,2,3,1,2,3,1,2,3,1,2,3

burger_soundn	dw	3,3,3,4,4,4,5,5,5,6,6,6
burger_soundo	dw	1,2,3,1,2,3,1,2,3,1,2,3

poison_soundn	dw	1,1,1,2,2,2,3,3,3,1,1,1
poison_soundo	dw	1,2,3,1,2,3,1,2,3,1,2,3

; Sounds a tone (di - notes, si - octaves, cx - length)
sound_tone:
	push	ax
	push	bx
s_lp:
	mov	ax,	[di]
	mov	bx,	[si]
	add	di,	2
	add	si,	2
	push	di
	push	si
	push	cx
	mov	cx,	060ffh
	call	sound_off
	push	cx
	call	converttofreq
	call	sound_on
	pop	cx
sl_lp:
	nop
	nop
	loop	sl_lp
	nop
	pop	cx
	pop	si
	pop	di
	loop	s_lp
	pop	bx
	pop	ax
	call	sound_off
	ret

; Messages
msghelpkey	db	"Usage: snake [/h] [/l=x] [/a=x] [/r=x] [/d=x] [/c=x] [/w=x]", 0dh, 0ah, "/h - prints help", 0dh, 0ah, "/l=x - sets snake's length as x, recommended 2-8", 0dh, 0ah, "/a=x - sets amount of apples, recommeneded 2-6", 0dh, 0ah, "/r=x - sets amount of burgers, recommended 1-4", 0dh, 0ah, "/d=x - sets amount of poison, recommended 0-3", 0dh, 0ah, "/c=x - sets intersection mode", 0dh, 0ah, " x=0 - no action", 0dh, 0ah, " x=1 - death", 0dh, 0ah, " x=2 - cuts a tail", 0dh, 0ah, "/w=x - sets upper wall mode", 0dh, 0ah, " x=0 - reflection mode", 0dh, 0ah, " x=1 - death wall mode", 0dh, 0ah, " x=2 - teleport mode", 0dh, 0ah, " x=3 - random mode", 0dh, 0ah, " Standart settings: l=2, a=3, r=1, d=1, c=1, x=1", 0dh, 0ah, " Controls:", 0dh, 0ah,	" + - incrase snake's speed (max - 5)", 0dh, 0ah, " - - decrase snake's speed (min - 1)", 0dh, 0ah, " Esc - quit", 0dh, 0ah, " Space - pause", 0dh, 0ah, " F1 - in-game help", 0dh, 0ah, " Arrows - movement controls", 0dh, 0ah, "$"
msgerrormode	db	"Incorrect mode", 0dh, 0ah, "$"
msgerrorargs	db	"Incorrect args", 0dh, 0ah, "$"
msgmissingeq	db	"Missing =", 0dh, 0ah, "$"
msgmissingnum	db	"Missing a number", 0dh, 0ah, "$"

end _start