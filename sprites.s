
sprites7 macro
_\0_sprites:  incbin "gfx/sprites/line7/\0.spr"
_\0_sprites_size: equ *-_\0_sprites
        endm
palettes7 macro
_\0_pal:  incbin  "gfx/sprites/line7/\0.nxp"
_\0_pal_size: equ *-_\0_pal
        endm

sprites macro
_\0_sprites:  incbin "gfx/sprites/\0.spr"
_\0_sprites_size: equ *-_\0_sprites
        endm
palettes macro
_\0_pal:  incbin  "gfx/sprites/\0.nxp"
_\0_pal_size: equ *-_\0_pal
        endm

all_sprites:
sprites line7
sprites line1
sprites line2
sprites line3
sprites line4
sprites line5_2
sprites line6_1
sprites line6a

all_sprites_size: equ *-all_sprites


all0_palettes:
palettes line7
all0_palettes_size: equ *-all0_palettes

all1_palettes:
palettes line1
palettes line2
palettes line3
palettes line4
palettes line5_2
palettes line6_1
palettes line6a
all1_palettes_size: equ *-all1_palettes




sprites_init
    ld a,0
    ld hl, all_sprites
    ld b,   HI(all_sprites_size+255)
    call upload_sprites


    nextreg PAL_CTRL,%00100001
    nextreg PAL_INDEX,0

    ld b, +($e0/2)
    ld hl, all0_palettes
.pal_lp0:
    ld a,(hl)
    nextreg PAL_VALUE_9BIT,a
    inc hl

    ld a,(hl)
    nextreg PAL_VALUE_9BIT,a
    inc hl

    djnz .pal_lp0

    ld bc, all1_palettes_size/2

    ld hl, all1_palettes
.pal_lp1:
    ld a,(hl)
    nextreg PAL_VALUE_9BIT,a
    inc hl

    ld a,(hl)
    nextreg PAL_VALUE_9BIT,a
    inc hl

    dec bc

    ld a,b
    or c
    jr nz,.pal_lp1


    call create_sprites  

;    nextreg CLIP_WINDOW_CTRL,%00000010
;    nextreg SPRITE_CLIP_WINDOW,20


    ret


upload_sprites:
   ; now copy sprites up
    nextreg SPRITE_NUMBER, a
upload_next_sprites:

    ld a,b
    ld bc,$005b + (16*16)*256
.sprite_loop
    otir ;; send 256 bytes to port 0x5b
    dec a
    jr nz, .sprite_loop;

    ret

create_sprites:

        exx
        ld de,NUM_SPRITE_ATTRIBUTES
        exx

        nextreg CLIP_WINDOW_CTRL,%00000010

        nextreg SPRITE_CLIP_WINDOW,0
        nextreg SPRITE_CLIP_WINDOW,255
        nextreg SPRITE_CLIP_WINDOW,0
        nextreg SPRITE_CLIP_WINDOW,255

        call LINE_OF_SPRITES

        ret

        
sprites_update:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ld de,NUM_SPRITE_ATTRIBUTES

;        call sprites_scroll

        ld bc, SPRITE_INDEX_OUT
        ld a,0
        out (c),a ; start at pattern 0
        call update_toplines     
        ret
upload:    
        ld bc, +(21*5*256)+SPRITE_ATTRIBUTE_OUT
.spr_lp
        ld a,(hl)
        inc hl
        out (c),a  ; x:lo
        djnz .spr_lp
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;21 sprites in a line
;1 normal sprite and then 20 continue ones each +16 x 
;
;spr0
;        .A0 = x ls8 bits
;        .A1 = y ls8 bits
;        .A2 = PPPP XM(0) YM (0) 0 X8
;        .A3 =  V(1) E(1)  N5->0
;        .A4 = H(1) N6 T XX(00) YY(00) Y8
;
;rel1 _ 0
;        .A0 = delta x ( 16 )
;        .A1 = delta y ( 0 )
;        .A2 = PPPP XM(0) YM R(0) 0 X8(0)
;        .A3 =  V(1) E(1)  N5->0
;        .A4 = H(1) N6 T XX(00) YY(00) Y8
; 

SPR_ATTRIB_4_COMPOSITE equ %00100000

set_sprite_first16: macro

        ld (ix+0),c
        ld (ix+1),e

        ld a,1                  ; 9 bit check x
        and b
        or h
        ld (ix+2),a

        ld a,0
        or %11000000
        ld (ix+3),a

        ld a,1                  ; 9 bit check y
        and d
        ;jr z,.no9bity
;.no9bity
        or %10100000            ; T= 1(unified), H = 1
 
        ld (ix+4),a

        ld bc,16                ; x offset
        ld de,0                 ; y offset

        exx
        add ix,de
        exx
        endm


set_sprite_next: macro

        ld (ix+0),c
        ld (ix+1),e

        ld (ix+2),1
 
        ld a,1                  ; 9 bit check y
        and b
        or %11000000
        ld (ix+3),a

        ld (ix+4),%01000001

        add bc,16               ; x offset
        
        exx
        add ix,de
        exx
        endm

set_sprite_first256: macro

        ld (ix+0),c
        ld (ix+1),e

        ld a,1                  ; 9 bit check x
        and b
        or h
        ld (ix+2),a

        ld a,0
        or %11000000
        ld (ix+3),a

        ld a,1                  ; 9 bit check y
        and d
        ;jr z,.no9bity
;.no9bity
        or %00100000            ; T= 1(unified), H = 0
 
        ld (ix+4),a

        ld bc,16                ; x offset
        ld de,0                 ; y offset

        exx
        add ix,de
        exx
        endm




settiles16:
        ld b, a ; volume in bytes
        ld c,d
        ld a,d
        ld (.anchor_tile),a
.lp:
        ld a,%11000000
        and (ix+4)
        cp %01000000
        jr nz ,.not_relative_pattern
.relative_sprite:
        bit 0,(ix+4)
        ld a,c
        jr z,.not_relative_pattern
 .anchor_tile: def *+1
        sub 00
        and 127
        srl a
        jr nc, .rel_bit7_notset
        set 5,(ix+4)
.rel_bit7_notset:
        jr .cont

.not_relative_pattern:
        ld a,c
        ld (.anchor_tile),a
.all_fine:
        srl a
        jr nc, .cont
        set 6,(ix+4)
 .cont:
        or %11000000
        ld (ix+3),a

        inc c
        ld a,c
        cp e
        jr nz,.ok
        ld c,d
.ok:
        exx
        add ix,de       ; add 5 to ix
        exx

        inc iyl
        add bc,-4*256
        djnz .lp
        ret


settiles256:
        ld b, a ; volume in bytes
        ld c,d
        ld a,d
        ld (.anchor_tile),a
.lp:
        ld a,%11000000
        and (ix+4)
        cp %01000000
        jr nz ,.not_relative_pattern
.relative_sprite:
        bit 0,(ix+4)
        ld a,c
        jr z,.not_relative_pattern
 .anchor_tile: def *+1
        sub 00
        and 63
;        srl a
;        jr nc, .rel_bit7_notset
;        set 5,(ix+4)
.rel_bit7_notset:
        jr .cont

.not_relative_pattern:
        ld a,c
        ld (.anchor_tile),a
.all_fine:
;        srl a
 ;       jr nc, .cont
 ;       set 6,(ix+4)
 .cont:
        or %11000000
        ld (ix+3),a

        inc c
        ld a,c
        cp e
        jr nz,.ok
        ld c,d
.ok:
        exx
        add ix,de       ; add 5 to ix
        exx

        inc iyl
        add bc,-4*256
        djnz .lp
        ret















volume: macro
        push hl
        ld de ,\0
        ld a,ixh
        ld h,a
        ld a,ixl
        ld l,a
        xor a
        sbc hl,de
        ld a,l
        ld (\0_vol),a
        pop hl
        endm



MIN_MAX macro  
        ; \2
        ld de,+(\0+\2) * 256 +(\1+\2)
        endm

;####################################################################
;;;;;; bc = x
; de = y
; ix = write
; h = pal + mirroring etv;
; l = number of extra sprites for ease of shifting
LINE_OF_SPRITES:
        exx 
        ld de,5 ; size of sprite attributes
        exx

        ld de,0
        ld h, SPA_2_PAL_7
        ld l,0
        ld ix ,my_buffert1
 
        call create_line16

        volume my_buffert1
 
        ld c,0
        MIN_MAX 0,1,32
        ld ix ,my_buffert1
        call settiles16
        ;;;;;;;;;;;;;;;;;;;;;

        ld de,8
        ld h, SPA_2_PAL_8
        ld l,0
        ld ix ,my_buffert2

        call create_line16
        volume my_buffert2

        ld c,0
        MIN_MAX 1,2,32 
        ld ix ,my_buffert2
        call settiles16

        ;;;;;;;;;;;;;;;;;;;;;

        ld de,16
        ld h, SPA_2_PAL_9
        ld l,0
        ld ix ,my_buffert3
        call create_line16
        volume my_buffert3

        ld c,0
        MIN_MAX 2,4,32
        ld ix ,my_buffert3
        call settiles16

        ;;;;;;;;;;;;;;;;;;;;;
        
        ld de,24
        ld h, SPA_2_PAL_10
        ld l,0
        ld ix ,my_buffert4
        call create_line16
        volume my_buffert4


        ld c,0
        MIN_MAX 4,6,32
        ld ix ,my_buffert4
        call settiles16

        ;;;;;;;;;;;;;;;;;;;;;
        
        ld de,32
        ld h, SPA_2_PAL_11
        ld l,0
        ld ix ,my_buffert5_1
        call create_line16
        volume my_buffert5_1

        ld c,0
        MIN_MAX 6,9,32
        ld ix ,my_buffert5_1
        call settiles16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ld de,40
        ld h, SPA_2_PAL_11
        ld l,0
        ld ix ,my_buffert5_2
        call create_line16
        volume my_buffert5_2

        ld c,0
        MIN_MAX 9,12,32
        ld ix ,my_buffert5_2
        call settiles16

        ld de,40
        ld h, SPA_2_PAL_12
        ld l,0
        ld ix ,my_buffert6_1
        call create_line16
        volume my_buffert6_1

        ld c,0
        MIN_MAX 12,15,32
        ld ix ,my_buffert6_1
        call settiles16
;;

        ld de,48+8
        ld h, SPA_2_PAL_13
        ld l,0
        ld ix ,my_buffert6_2
        call create_line16
        volume my_buffert6_2

        ld c,0
        MIN_MAX 15,18,32
        ld ix ,my_buffert6_2
        call settiles16

        ld de,48+16*1-8
        ld h, SPA_2_PAL_0
        ld l,0
        ld ix ,my_buffert7_1
        call create_line256
        volume my_buffert7_1

        ld c,0
        MIN_MAX 0,4,0
        ld ix ,my_buffert7_1
        call settiles256
;;

        ld de,48+16*2-8
        ld h, SPA_2_PAL_0
        ld l,0
        ld ix ,my_buffert7_2
        call create_line256
        volume my_buffert7_2

        ld c,0
        MIN_MAX 4,8,0
        ld ix ,my_buffert7_2
        call settiles256

;;
        ld de,48+16*3-8
        ld h, SPA_2_PAL_0
        ld l,0
        ld ix ,my_buffert7_3
        call create_line256
        volume my_buffert7_3

        ld c,0
        MIN_MAX 8,12,0
        ld ix ,my_buffert7_3
        call settiles256

;;
        ld de,48+16*4-8
        ld h, SPA_2_PAL_0
        ld l,0
        ld ix ,my_buffert7_4
        call create_line256
        volume my_buffert7_4

        ld c,0
        MIN_MAX 12,16,0
        ld ix ,my_buffert7_4
        call settiles256

      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ld de,256-16
        ld h, SPA_2_PAL_7 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb1
        call create_line16

        volume my_bufferb1
 
        ld c,0
        MIN_MAX 0,1,32
        ld ix ,my_bufferb1
        call settiles16
        ;;;;;;;;;;;;;;;;;;;;;

        ld de,256-24
        ld h, SPA_2_PAL_8 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb2

        call create_line16
        volume my_bufferb2

        ld c,0
        MIN_MAX 1,2,32
        ld ix ,my_bufferb2
        call settiles16

        ;;;;;;;;;;;;;;;;;;;;;

        ld de,256-32
        ld h, SPA_2_PAL_9 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb3
        call create_line16
        volume my_bufferb3

        ld c,0
        MIN_MAX 2,4,32
        ld ix ,my_bufferb3
        call settiles16

        ;;;;;;;;;;;;;;;;;;;;;
        
        ld de,256-40
        ld h, SPA_2_PAL_10 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb4
        call create_line16
        volume my_bufferb4


        ld c,0
        MIN_MAX 4,6,32
        ld ix ,my_bufferb4
        call settiles16

        ;;;;;;;;;;;;;;;;;;;;;
        
        ld de,256-48
        ld h, SPA_2_PAL_11 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb5_1
        call create_line16
        volume my_bufferb5_1


        ld c,0
        MIN_MAX 6,9,32
        ld ix ,my_bufferb5_1
        call settiles16

;;;;;;;;;;;;;;;;;;;;;;;;;;


        ld de,256-48-16+8
        ld h, SPA_2_PAL_11 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb5_2
        call create_line16
        volume my_bufferb5_2

        ld c,0
        MIN_MAX 9,12,32
        ld ix ,my_bufferb5_2
        call settiles16

        ld de,256-48-16+8
        ld h, SPA_2_PAL_12 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb6_1
        call create_line16
        volume my_bufferb6_1

        ld c,0
        MIN_MAX 12,15,32
        ld ix ,my_bufferb6_1
        call settiles16
;;

        ld de,256-56-16
        ld h, SPA_2_PAL_13 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb6_2
        call create_line16
        volume my_bufferb6_2

        ld c,0
        MIN_MAX 15,18,32
        ld ix ,my_bufferb6_2
        call settiles16

        ld de,256-56-16
        ld h, SPA_2_PAL_0 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb7_1
        call create_line256
        volume my_bufferb7_1

        ld c,0
        MIN_MAX 0,4,0
        ld ix ,my_bufferb7_1
        call settiles256

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ld de,256-(276/2)+40+8+2
        ld h, SPA_2_PAL_0 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb7_2
        call create_line256
        volume my_bufferb7_2

        ld c,0
        MIN_MAX 4,8,0
        ld ix ,my_bufferb7_2
        call settiles256

;;
        ld de,256-(276/2)+40-16+8+2
        ld h, SPA_2_PAL_0 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb7_3
        call create_line256
        volume my_bufferb7_3

        ld c,0
        MIN_MAX 8,12,0
        ld ix ,my_bufferb7_3
        call settiles256
;;
        ld de,256-(276/2)+40-16*2+8+2
        ld h, SPA_2_PAL_0 + SPA_2_YM
        ld l,0
        ld ix ,my_bufferb7_4
        call create_line256
        volume my_bufferb7_4

        ld c,0
        MIN_MAX 12,16,0
        ld ix ,my_bufferb7_4
        call settiles256

        ret

    
y__: dw 0

create_line16:
        push hl                 ; save l for last batch

        ld bc,0
        ld (y__),de
        set_sprite_first16

        ld a,7
.lp0:   ex af,af'
        set_sprite_next
        ex af,af'
        dec a
        jr nz ,.lp0

        ld bc,128
        ld de,(y__)
        set_sprite_first16

        ld a,7
.lp1:    ex af,af'
        set_sprite_next
        ex af,af'
        dec a
        jr nz ,.lp1

        ld bc,256
        ld de,(y__)
        set_sprite_first16

        pop hl
        ld a,7
        add a,l
.lp2:   ex af,af'
        set_sprite_next
        ex af,af'
        dec a
        jr nz ,.lp2
        ret

create_line256:
        push hl                 ; save l for last batch

        ld bc,0
        ld (y__),de
        set_sprite_first256

        ld a,7
.lp0:   ex af,af'
        set_sprite_next
        ex af,af'
        dec a
        jr nz ,.lp0

        ld bc,128
        ld de,(y__)
        set_sprite_first256

        ld a,7
.lp1:    ex af,af'
        set_sprite_next
        ex af,af'
        dec a
        jr nz ,.lp1

        ld bc,256
        ld de,(y__)
        set_sprite_first256

        pop hl
        ld a,7
        add a,l
.lp2:   ex af,af'
        set_sprite_next
        ex af,af'
        dec a
        jr nz ,.lp2
        ret



shift_line:
        ld a,(iy+2)
        sub (iy+3)
 
        ld b,3
        ld l,a
        add a,a
        sbc a,a
        ld h,a

        jr .go
.next_line:
        ld de,5*8
        add ix,de
        add hl,128
;        3 parts per line
.go:    ld (ix+0),l
        bit 0,h
        jr nz ,.set
        res 0,(ix+2)
        djnz .next_line
        ret
.set:   set 0,(ix+2)
        djnz .next_line
        ret



draw_top:
        DRAW_SECTION_PUSH
        ld bc, SPRITE_INDEX_OUT
        ld a,0
        out (c),a ; start at pattern 0

        ld a,(my_buffert1_vol)
        ld hl ,my_buffert1
        call sprite_copy

        ld a,(my_buffert2_vol)
        ld hl ,my_buffert2
        call sprite_copy

        ld a,(my_buffert3_vol)
        ld hl ,my_buffert3
        call sprite_copy

        ld a,(my_buffert4_vol)
        ld hl ,my_buffert4
        call sprite_copy

        ld a,(my_buffert5_1_vol)
        ld hl ,my_buffert5_1
        call sprite_copy
        
        DRAW_SECTION_POP
        ret

draw_top_2nd:
        DRAW_SECTION_PUSH

        ld bc, SPRITE_INDEX_OUT
        ld a,0
        out (c),a ; start at pattern 0

        ld a,(my_buffert5_2_vol)
        ld hl ,my_buffert5_2
        call sprite_copy

        ld a,(my_buffert6_1_vol)
        ld hl ,my_buffert6_1
        call sprite_copy


        ld a,(my_buffert6_2_vol)
        ld hl ,my_buffert6_2
        call sprite_copy

        ld a,(my_buffert7_1_vol)
        ld hl ,my_buffert7_1
        call sprite_copy

        DRAW_SECTION_POP
        ret

draw_top_3rd:
        DRAW_SECTION_PUSH
        ld bc, SPRITE_INDEX_OUT
        ld a,0
        out (c),a ; start at pattern 0

        ld a,(my_buffert7_4_vol)
        ld hl ,my_buffert7_4
        call sprite_copy

        ld a,(my_buffert7_3_vol)
        ld hl ,my_buffert7_3
        call sprite_copy


        ld a,(my_buffert7_2_vol)
        ld hl ,my_buffert7_2
        call sprite_copy

        DRAW_SECTION_POP
        ret




draw_bottom_3rd:
        DRAW_SECTION_PUSH

        ld bc, SPRITE_INDEX_OUT
        ld a,64
        out (c),a ; start at pattern 0

        ld a,(my_bufferb7_4_vol)
        ld hl ,my_bufferb7_4
        call sprite_copy

        ld a,(my_bufferb7_2_vol)
        ld hl ,my_bufferb7_2
        call sprite_copy

        ld a,(my_bufferb7_3_vol)
        ld hl ,my_bufferb7_3
        call sprite_copy

        DRAW_SECTION_POP

        ret

draw_bottom_2nd:
        DRAW_SECTION_PUSH

        ld bc, SPRITE_INDEX_OUT
        ld a,0
        out (c),a ; start at pattern 0


        ld a,(my_bufferb6_2_vol)
        ld hl ,my_bufferb6_2
        call sprite_copy

        ld a,(my_bufferb6_1_vol)
        ld hl ,my_bufferb6_1
        call sprite_copy


        ld a,(my_bufferb5_2_vol)
        ld hl ,my_bufferb5_2
        call sprite_copy


        ld a,(my_bufferb7_1_vol)
        ld hl ,my_bufferb7_1
        call sprite_copy
  

        DRAW_SECTION_POP

        ret

 draw_bottom:
        DRAW_SECTION_PUSH

        ld bc, SPRITE_INDEX_OUT
        ld a,0
        out (c),a ; start at pattern 0

        ld a,(my_bufferb5_1_vol)
        ld hl ,my_bufferb5_1
        call sprite_copy

        ld a,(my_bufferb4_vol)
        ld hl ,my_bufferb4
        call sprite_copy

        ld a,(my_bufferb3_vol)
        ld hl ,my_bufferb3
        call sprite_copy


        ld a,(my_bufferb2_vol)
        ld hl ,my_bufferb2
        call sprite_copy


        ld a,(my_bufferb1_vol)
        ld hl ,my_bufferb1
        call sprite_copy

        DRAW_SECTION_POP

        ret

sprite_copy
        ld b,0
        ld c,a
        jr TransferDMASprite

        or a
        ret z
        ld b,a
        ld c,SPRITE_ATTRIBUTE_OUT
        otir
        ret


TransferDMASprite
    di
    ld (DMASourceS),hl
    ld (DMALengthS),bc
    ld hl,DMACodeS
    ld b,DMACode_LenS
    ld c,NEXT_DMA_PORT
    otir
    ei
    ret

DMACodeS db DMA_DISABLE
        db %01111101                   ; R0-Transfer mode, A -> B, write adress 
                                       ; + block length
DMASourceS dw 0                        ; R0-Port A, Start address (source address)
DMALengthS dw 0                        ; R0-Block length (length in bytes)
        db %01010100                   ; R1-read A time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R1-Cycle length port A
        db %01101000                   ; R2-write B time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R2-Cycle length port B
        db %10101101                   ; R4-Continuous mode (use this for block
                                       ; transfer), write dest adress
        dw SPRITE_ATTRIBUTE_OUT           ; R4-Dest address (destination address)
        db %10000010                   ; R5-Restart on end of block, RDY active
                                       ; LOW
        db DMA_LOAD                    ; R6-Load
        db DMA_ENABLE                  ; R6-Enable DMA
DMACode_LenS                   equ *-DMACodeS


my_buffert1_vol:        ds 1
my_buffert2_vol:        ds 1
my_buffert3_vol:        ds 1
my_buffert4_vol:        ds 1
my_buffert5_1_vol:        ds 1
my_buffert5_2_vol:        ds 1
my_buffert6_1_vol:        ds 1
my_buffert6_2_vol:        ds 1
my_buffert7_1_vol:        ds 1
my_buffert7_2_vol:        ds 1
my_buffert7_3_vol:        ds 1
my_buffert7_4_vol:        ds 1


my_bufferb1_vol:        ds 1
my_bufferb2_vol:        ds 1
my_bufferb3_vol:        ds 1
my_bufferb4_vol:        ds 1
my_bufferb5_1_vol:        ds 1
my_bufferb5_2_vol:        ds 1
my_bufferb6_1_vol:        ds 1
my_bufferb6_2_vol:        ds 1
my_bufferb7_1_vol:        ds 1
my_bufferb7_2_vol:        ds 1
my_bufferb7_3_vol:        ds 1
my_bufferb7_4_vol:        ds 1


my_buffert1:            ds 200
my_buffert2:            ds 200
my_buffert3:            ds 200
my_buffert4:            ds 200
my_buffert5_1:            ds 200
my_buffert5_2:            ds 200
my_buffert6_1:            ds 200
my_buffert6_2:            ds 200
my_buffert7_1:        ds 200
my_buffert7_2:        ds 200
my_buffert7_3:        ds 200
my_buffert7_4:        ds 200



my_bufferb1:            ds 200
my_bufferb2:            ds 200
my_bufferb3:            ds 200
my_bufferb4:            ds 200
my_bufferb5_1:            ds 200
my_bufferb5_2:            ds 200
my_bufferb6_1:            ds 200
my_bufferb6_2:            ds 200
my_bufferb7_1:        ds 200
my_bufferb7_2:        ds 200
my_bufferb7_3:        ds 200
my_bufferb7_4:        ds 200
