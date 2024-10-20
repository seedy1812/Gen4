DO_WOBBLE equ 1

tilemap_init:
        NEXTREG LAYER3_CTRL,%10000001 ; layer 3 enable 40 col, pal 0 ,256 tile , ontop of ula , full attribute

        nextreg LAYER3_TRANS_INDEX,15

        nextreg LAYER3_MAP_HI, $40
        ld de,$4000


        ld hl,tm_map1
        ld bc ,tm_map1_size
        call do_line

        ld hl,tm_map2
        ld bc ,tm_map2_size
        call do_line

        ld hl,tm_map3
        ld bc ,tm_map3_size
        call do_line

        ld hl,tm_map4
        ld bc ,tm_map4_size
        call do_line

        ld hl,tm_map5
        ld bc ,tm_map5_size
        call do_line

        ld hl,tm_map6
        ld bc ,tm_map6_size
        call do_line

        ld hl,tm_map61
        ld bc ,tm_map61_size
        call do_line

        ld hl,tm_map7
        ld bc,tm_map7_size
        ldir

        push de

        ld hl,tm_map61
        ld bc ,tm_map61_size
        call do_line

        ld hl,tm_map6
        ld bc ,tm_map6_size
        call do_line
        
        ld hl,tm_map5
        ld bc ,tm_map5_size
        call do_line

        ld hl,tm_map4
        ld bc ,tm_map4_size
        call do_line

        ld hl,tm_map3
        ld bc ,tm_map3_size
        call do_line

        ld hl,tm_map2
        ld bc ,tm_map2_size
        call do_line


        ld hl,tm_map1
        ld bc ,tm_map1_size
        call do_line

        pop hl

        push de
.cont:
        inc hl
        ld a,(hl)
        or $04
        ld (hl),a
        inc hl

;        add hl,2

        ld a,h
        cp d
        jr nz,.cont
        ld a,l
        cp l
        jr nz,.cont




        pop de




        add de,255
        ld e,0

        ld a,d
        nextreg LAYER3_TILE_HI,a 

        ld hl, tm_tiles
        ld bc, tm_tiles_size
        ldir 

        // set palette
        nextreg PAL_CTRL,%00110001
        nextreg PAL_INDEX,0

        // layer 3 Pal 0 , enabel enhanced ula

        ld hl, tm_palettes
        ld bc , tm_palettes_size/2
.pal:   ld a,(hl)
	nextreg PAL_VALUE_9BIT,a
        inc hl
        ld a,(hl)
	nextreg PAL_VALUE_9BIT,a
        inc hl        
        djnz .pal

        call patch_copper_y

        call make_gradient


;        nextreg CLIP_WINDOW_CTRL,%00001000
;        nextreg LAYER3_CLIP_WINDOW,80


        ret


do_line:
        push bc ; save length

        push de
        ldir    ; copy to front

        pop hl
        pop bc

        ld a,40*2
        sub c
        ld c,a

        ldir


        ret




        align 256
tm_palettes:
        incbin "gfx/tilemap/line1.nxp"
        align 32
        incbin "gfx/tilemap/line2.nxp"
        align 32
        incbin "gfx/tilemap/line3.nxp"
        align 32
        incbin "gfx/tilemap/line4.nxp"
        align 32
        incbin "gfx/tilemap/line5.nxp"
        align 32
        incbin "gfx/tilemap/line6.nxp"
        align 32
        incbin "gfx/tilemap/line61.nxp"
        align 32
 tm_pal_gen4:
        incbin "gfx/tilemap/gen4.nxp"
        align 32
tm_palettes_size: equ *-tm_palettes
tm_tiles:
        incbin "gfx/tilemap/line1.nxt"
        incbin "gfx/tilemap/line2.nxt"
        incbin "gfx/tilemap/line3.nxt"
        incbin "gfx/tilemap/line4.nxt"
        incbin "gfx/tilemap/line5.nxt"
        incbin "gfx/tilemap/line6.nxt"
        incbin "gfx/tilemap/line61.nxt"
 gen4_t:       incbin "gfx/tilemap/gen4.nxt"
tm_tiles_size: equ *-tm_tiles

tm_map:
tm_map1:        incbin "gfx/tilemap/line1.nxm"
tm_map1_size:   equ *-tm_map1
tm_map2:        incbin "gfx/tilemap/line2.nxm"
tm_map2_size:   equ *-tm_map2
tm_map3:        incbin "gfx/tilemap/line3.nxm"
tm_map3_size:   equ *-tm_map3
tm_map4:        incbin "gfx/tilemap/line4.nxm"
tm_map4_size:   equ *-tm_map4
tm_map5:        incbin "gfx/tilemap/line5.nxm"
tm_map5_size:   equ *-tm_map5
tm_map6:        incbin "gfx/tilemap/line6.nxm"
tm_map6_size:   equ *-tm_map6
tm_map61:       incbin "gfx/tilemap/line61.nxm"
tm_map61_size:   equ *-tm_map61
tm_map7:        incbin "gfx/tilemap/gen4.nxm"
tm_map7_size:   equ *-tm_map7

        incbin "gfx/tilemap/line1.nxm"
tm_map_size: equ *-tm_map

; top_speed , width , top_x , bottom_x
; top_x -= top_speed , botttom_x -= bottom_speed.
                align 16
tm_speeds:
                db +1 ,16 ,0,16 ; line1
tm_entry_size  equ *-tm_speeds
                db -1, -16 ,0,0 ; line2
                db +2, 32 ,0,32 ; line3
                db -2, -32 ,0,0 ; line4
tm_magic:
                db +3, 48 ,0,48 ; line5
                db -3, -48 ,0,0 ; line6

;                db +4, 64 ,0,64 ; line7
;                db -4, -64 ,0,0 ; line8

               
; vert flip
;                db +4, 64 ,0,16 ; line7
;                db -4, -64 ,0,0 ; line8
tm_speeds_bot:
                db +3, 48 ,0,48 ; line5
                db -3, -48 ,0,0 ; line6

                db +2, 32 ,0,32 ; line3
                db -2, -32 ,0,0 ; line4

                db +1 ,16 ,0,16 ; line1
                db -1, -16 ,0,0 ; line2


tm_speeds_size equ (*-tm_speeds)/tm_entry_size

tm_update:      ld ix , tm_speeds
                ld de,tm_entry_size
                ld b,tm_speeds_size
.loop:          ld a,(ix+0)
                or a     
                jp m,.minus
.plus:          add a,(ix+2)
                cp  (ix+1)
                jr c ,.line_done
                sub (ix+1)
                jr .line_done
.minus:         add a,(ix+2)
                cp (ix+1)
                jr nc, .line_done
                sub (ix+1)

.line_done:     ld (ix+2),a

                add ix,de

                djnz .loop
                ret

tm_copper:
        ld a,(tm_speeds+2+(tm_entry_size*5))
        ld (line_5_top),a
        ld a,(tm_speeds+2+(tm_entry_size*6))
        ld (line_6_top),a
if 0
 ;       ld a,(tm_speeds+2+(tm_entry_size*6))
 ;       ld (line_7_top),a
 ;       ld a,(tm_speeds+2+(tm_entry_size*7))
 ;       ld (line_8_top),a

 ;       ld a,(tm_speeds+2+(tm_entry_size*7))
 ;       ld (line_8_bot),a
 ;       ld a,(tm_speeds+2+(tm_entry_size*6))
 ;       ld (line_7_bot),a
endif
        ld a,(tm_speeds_bot+2+(tm_entry_size*0))
        ld (line_5_bot),a
        ld a,(tm_speeds_bot+2+(tm_entry_size*1))
        ld (line_6_bot),a


	ld      hl,tn_cooper
	ld      bc,tn_cooper_size
        call    do_copper

      	nextreg COPPER_CTRL,%01000000 ;// copper start | MSBs = 00

        ld a, (tm_sine_index)
        inc a
        and 15
        ld (tm_sine_index),a

        ld hl, tn_sine
        add hl,a

        ld de, gen4_sin+3
        ld a, 144
.lpa:   ldi
if DO_WOBBLE
        add de,3+4
else
        add de,3
endif
        dec a
        jr nz,.lpa

if DO_WOBBLE
        call copy_palette
endif

        ret


tm_sine_index: db 0

patch_copper_y:
        call GetMaxScanline
        ld (.selfmod+2),hl

	ld      hl,tn_cooper
.next
        bit 7,(hl)
        jr nz,.is_move

        inc hl
        inc hl
        jr .next
.is_move:
        ld a,(hl)
        inc hl
        ld c,(hl)       ; bc = original Y
        dec hl

        cp 255          ; 255,255, is end of list
        jr nz, .cont
        cp c
        ret z
.cont:
        and 1
        ld b,a

        add bc,-32           ; move up by border height
        bit 7,b              ; if negative the -1 = max_scanline-1
        jr z,.posi
.selfmod:
        add bc,$1234         ; self mod code - $1234 will be max_scanlines
.posi:

        ld a,(hl)
        res 0,a
        or b

        ld (hl),a
        inc hl
        ld (hl),c
        inc hl
        jr .next


GEN_4_2 macro
        COPPER_WAIT(\0+0,0)
        COPPER_MOVE LAYER3_SCROLL_X_LSB,0
if DO_WOBBLE
        COPPER_MOVE PAL_VALUE_9BIT,0
        COPPER_MOVE PAL_VALUE_9BIT,0
endif
        COPPER_WAIT(\0+1,0)
        COPPER_MOVE LAYER3_SCROLL_X_LSB,0
if DO_WOBBLE
        COPPER_MOVE PAL_VALUE_9BIT,0
        COPPER_MOVE PAL_VALUE_9BIT,0
endif
        endm

GEN_4_10 macro
        GEN_4_4 (\0+0)
        GEN_4_4 (\0+4)
        GEN_4_2 (\0+8)
        endm

GEN_4_4 macro
       GEN_4_2 (\0+0)
       GEN_4_2 (\0+2)
        endm

GEN_4_144 macro
        GEN_4_10 (\0+0)
        GEN_4_10 (\0+10)
        GEN_4_10 (\0+20)
        GEN_4_10 (\0+30)
        GEN_4_10 (\0+40)
        GEN_4_10 (\0+50)
        GEN_4_10 (\0+60)
        GEN_4_10 (\0+70)
        GEN_4_10 (\0+80)
        GEN_4_10 (\0+90)
        GEN_4_10 (\0+100)
        GEN_4_10 (\0+110)
        GEN_4_10 (\0+120)
        GEN_4_10 (\0+130)
        GEN_4_4 (\0+140)
        endm

tn_cooper:
                COPPER_WAIT 32,0
line_5_top:    equ *+1
                COPPER_MOVE LAYER3_SCROLL_X_LSB,5

                COPPER_WAIT 40,0
line_6_top:    equ *+1
                COPPER_MOVE LAYER3_SCROLL_X_LSB,6
                // 16 pixel high

if DO_WOBBLE
                COPPER_MOVE  PAL_CTRL,%10110001

        	COPPER_MOVE PAL_INDEX,$71
endif

gen4_sin:       GEN_4_144(56)

                COPPER_WAIT 56+144,0
line_6_bot:    equ *+1
                COPPER_MOVE LAYER3_SCROLL_X_LSB,6

                COPPER_WAIT 56+144+16,0
line_5_bot:    equ *+1
                 COPPER_MOVE LAYER3_SCROLL_X_LSB,5

                COPPER_WAIT 56+144+16+8,0
                COPPER_MOVE LAYER3_SCROLL_X_LSB,0

                COPPER_HALT

tn_cooper_size: equ *-tn_cooper


SINE_1  macro
        db 0,1,2,3,4,5,6,7,7,6,5,4,3,2,1
        endm

tn_sine
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        SINE_1          ; 16 
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gradient_indices: incbin "gfx/gradient/gradient.nxi"
gradient_how_many: equ *-gradient_indices

gradient_9bit_pal: incbin "gfx/gradient/gradient.nxp"

; 144 lines in middle
; image is 90 high so we will store it 3 times

gradient_pals:  ds 90*3*2

make_gradient:  ld b, 90
                ld hl,gradient_indices
                ld ix,gradient_pals
.loop1:
                ld a,(hl)
                inc hl

                ld de,gradient_9bit_pal
                add de,a
                add de,a

                ld a,(de)
                ld (ix),a
                inc de
                inc ix

                ld a,(de)
                ld (ix),a
                inc de
                inc ix
                djnz .loop1

                ld  bc, 90*2*2
                ld  hl,gradient_pals
                ld  de,gradient_pals+90*2

                ldir

                ret
if DO_WOBBLE
palette_index: db 0
copy_palette    ld a,(palette_index)
                inc a
                cp 90
                jr nz,.no_wrap
                ld a,0
.no_wrap:
                ld (palette_index),a

                ld de,gradient_pals
                add de,a
                add de,a
                ld b, 144

                ld hl, gen4_sin+5

.lp:            ld a,(de)       ; copy 9 bit palette
                ld (hl),a
                inc de
                add hl,2
                ld a,(de)
                ld (hl),a
                inc de
 
                add hl,8-2
                djnz .lp

                ret
endif

