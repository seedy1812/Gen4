prepare_bg2_layer2:

	nextreg LAYER_2_ACTIVE_BANK,BANK(BG2_NXI)/2

	nextreg MMU_Slot7,BANK(BG2_NXI)

    ld bc, LAYER2_OUT
	ld a,    %0010
	out (c),a

	nextreg PAL_CTRL,%10010001

	nextreg PAL_INDEX,0
	nextreg PAL_VALUE_9BIT,%01010100
	nextreg PAL_VALUE_9BIT,1
	nextreg PAL_INDEX,1
	nextreg PAL_VALUE_8BIT,$e3
	ret

_bgcount: dw 0
_howmuchY: dw 0
_moveY: dw  -1
_moveX: dw  0
_howmuchX: dw  2

update_bg2:
;	my_break
;w1.c:98: bgcount+=1;
	ld	hl, (_bgcount)
	inc	hl
	ld	(_bgcount), hl
;w1.c:100: if(moveY < 0)
	ld	a,(_moveY + 1)
	bit	7, a
	jr	Z,l_bg2_00102
;w1.c:102: howmuchY=1;
	ld	hl,_howmuchY
	ld	(hl),$01
	xor	a
	inc	hl
	ld	(hl), a
l_bg2_00102:
;w1.c:104: if(moveY>192)
	ld	a,$c0
	ld	hl,_moveY
	cp	(hl)
	ld	a,$00
	inc	hl
	sbc	a, (hl)
	jp	PO, l_bg2_00145
	xor	$80
l_bg2_00145:
	jp	P, l_bg2_00104
;w1.c:106: howmuchY=-1;
	ld	hl,$ffff
	ld	(_howmuchY),hl
l_bg2_00104:
;w1.c:109: moveY+=howmuchY;
	ld	hl,(_moveY)
	ld	de,(_howmuchY)
	add	hl,de
	ld	(_moveY),hl
;w1.c:111: if (bgcount>192/4)
	ld	a,$30
	ld	hl,_bgcount
	cp	(hl)
	ld	a,$00
	inc	hl
	sbc	a, (hl)
	jp	PO, l_bg2_00146
	xor	$80
l_bg2_00146:
	jp	P, l_bg2_00110
;w1.c:113: if(moveX>256*2)
	xor	a
	ld	hl,_moveX
	cp	(hl)
	ld	a,$02
	inc	hl
	sbc	a, (hl)
	jp	PO, l_bg2_00147
	xor	$80
l_bg2_00147:
	jp	P, l_bg2_00106
;w1.c:114: howmuchX=-8;
	ld	hl,$fff8
	ld	(_howmuchX),hl
l_bg2_00106:
;w1.c:115: if(moveX<0)
	ld	a,(_moveX + 1)
	bit	7, a
	jr	Z,l_bg2_00108
;w1.c:116: howmuchX=8;
	ld	hl,_howmuchX
	ld	(hl),$08
	xor	a
	inc	hl
	ld	(hl), a
l_bg2_00108:
;w1.c:117: moveX+=howmuchX;
	ld	hl,(_moveX)
	ld	de,(_howmuchX)
	add	hl,de
	ld	(_moveX),hl
l_bg2_00110:
;w1.c:120: if (bgcount>192/2)
	ld	a,$60
	ld	hl,_bgcount
	cp	(hl)
	ld	a,$00
	inc	hl
	sbc	a, (hl)
	jp	PO, l_bg2_00148
	xor	$80
l_bg2_00148:
	jp	P, l_bg2_00112
;w1.c:121: bgcount=0;
	xor	a
	ld	l,a
	ld	h,a
	ld	(_bgcount),hl
l_bg2_00112:

	ld a,(_moveX)
	nextreg LAYER2_SCROLL_X_LSB,a

	ld a,(_moveY)
	nextreg LAYER2_SCROLL_Y,a
	ret

