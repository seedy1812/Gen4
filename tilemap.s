tilemap_init:
        NEXTREG LAYER3_CTRL,%10000001 ; layer 3 enable 40 col, pal 0 ,256 tile , ontop of ula , full attribute

        nextreg LAYER3_TRANS_INDEX,15

        nextreg LAYER3_MAP_HI, $40

        ld hl, $4000
        ld (hl),0
        ld de, $4000+1
        ld bc ,40 *14-1
        ldir

        ld hl,tm_map7
        ld bc,tm_map7_size
        ldir

        ld l,e
        ld h,d
        inc de
        ld (hl),0
        ld bc ,40 *14-1
        ldir

        add de,255
        ld e,0

        ld a,d
        nextreg LAYER3_TILE_HI,a 

        ld hl, tm_tiles
        ld bc, tm_tiles_size
        ldir 

if 1
        // set palette
        nextreg PAL_CTRL,%00110000

        nextreg PAL_INDEX,0

         // layer 3 Pal 0 , enabel enhanced ula


      ld hl, tm_pal_gen4+2
      ld bc , tm_pal_gen4_size/2
.pal:   ld a,(hl)
	nextreg PAL_VALUE_9BIT,%11100000
        inc hl
        ld a,(hl)
	nextreg PAL_VALUE_9BIT,a
        inc hl        
        djnz .pal
endif

        nextreg PAL_INDEX,$1
	nextreg PAL_VALUE_9BIT,%11100000
	nextreg PAL_VALUE_9BIT,%0




        call patch_copper_y

        call make_gradient


 ;       nextreg CLIP_WINDOW_CTRL,%00001000
 ;       nextreg LAYER3_CLIP_WINDOW,80


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



 tm_pal_gen4:
        incbin "gfx/tilemap/gen4.nxp"
tm_pal_gen4_size: equ *-tm_pal_gen4

tm_tiles:
 gen4_t:       incbin "gfx/tilemap/gen4.nxt"
tm_tiles_size: equ *-tm_tiles

tm_map7:        incbin "gfx/tilemap/gen4.nxm"
tm_map7_size:   equ *-tm_map7


; top_speed , width , top_x , bottom_x
; top_x -= top_speed , botttom_x -= bottom_speed.
                align 16
tm_speeds:
                db -1, -16 ,0,0 ; line1
tm_entry_size  equ *-tm_speeds
                db +1 ,16 ,0,16 ; line2

                db -2, -32 ,0,0 ; line3
                db +2, 32 ,0,32 ; line4

                db -3, -48 ,0,0 ; line5
                db +3, 48 ,0,48 ; line6

                db -4, -64 ,0,0 ; line7
tm_speeds_mid:
                db +4, 64 ,0,64 ; line8
             
; vert flip
;                db +4, 64 ,0,64 ; line8
                db -4, -64 ,0,0 ; line7
tm_speeds_bot:
                db +3, 48 ,0,48 ; line6
                db -3, -48 ,0,0 ; line5

                db +2, 32 ,0,32 ; line4
                db -2, -32 ,0,0 ; line3

                db +1 ,16 ,0,16 ; line2
                db -1, -16 ,0,0 ; line1


tm_speeds_size equ (*-tm_speeds)/tm_entry_size

tm_update:      
                ld ix , tm_speeds
                ld de,tm_entry_size
                ld b,tm_speeds_size
.loop:          
                ld a,(ix+0)
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
      	ld      hl,tn_cooper
	ld      bc,tn_cooper_size
        call    do_copper

        border 3

        ld a, (tm_sine_index)
        inc a
        and 15
        ld (tm_sine_index),a

        ld hl, tn_sine
        add hl,a


        ld de, gen4_sin+3
        ld bc, 144
.lpa:   ld a,7
        and b
        ldi
        add de,1+2*3
        ldi
        add de,1+2*3
        ldi
        add de,1+2*3
        ldi
        add de,1+2*3
        ldi
        add de,1+2*3
        ldi
        add de,1+2*3
        jp pe,.lpa

        border 7

        call copy_palette

        ret


DMA_Copper
    di
    ld a, COPPER_DATA
    call ReadNextreg
    ld (DMASourceCopper),hl
    ld (DMALengthCopper),bc
    ld hl,DMACodeCopper
    ld b,DMACode_LenCopper
    ld c,NEXT_DMA_PORT
    otir
    ei
    ret

DMACodeCopper db DMA_DISABLE
        db %01111101                   ; R0-Transfer mode, A -> B, write adress 
                                       ; + block length
DMASourceCopper dw 0                        ; R0-Port A, Start address (source address)
DMALengthCopper dw 0                        ; R0-Block length (length in bytes)
        db %01010100                   ; R1-read A time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R1-Cycle length port A
        db %01101000                   ; R2-write B time byte, increment, to 
                                       ; memory, bitmask
        db %00000010                   ; R2-Cycle length port B
        db %10101101                   ; R4-Continuous mode (use this for block
                                       ; transfer), write dest adress
        dw $253b           ; R4-Dest address (destination address)
        db %10000010                   ; R5-Restart on end of block, RDY active
                                       ; LOW
        db DMA_LOAD                    ; R6-Load
        db DMA_ENABLE                  ; R6-Enable DMA
DMACode_LenCopper                   equ *-DMACodeCopper


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
        COPPER_MOVE LAYER3_SCROLL_X_LSB,80
        COPPER_MOVE PAL_VALUE_9BIT,0
        COPPER_MOVE PAL_VALUE_9BIT,0
        COPPER_WAIT(\0+1,0)
        COPPER_MOVE LAYER3_SCROLL_X_LSB,0
        COPPER_MOVE PAL_VALUE_9BIT,0
        COPPER_MOVE PAL_VALUE_9BIT,0
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

                COPPER_WAIT 55,0

                COPPER_MOVE PAL_CTRL,%10110000
        	COPPER_MOVE PAL_INDEX,1


gen4_sin:       GEN_4_144(56)

                COPPER_MOVE SPRITE_LAYERS_SYSTEM,%00101011 ; SUL + Sprites in border

                COPPER_WAIT 256,0
                COPPER_MOVE SPRITE_LAYERS_SYSTEM,%01101011 ; SUL + Sprites in border


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
palette_index: db 0
copy_palette    
                ld a,(palette_index)
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
                border 1
.lp:            ld a,(de)       ; copy 9 bit palette
                ld (hl),a
                inc de
                add hl,2
                ld a,(de)
                ld (hl),a
                inc de
 
                add hl,8-2
                djnz .lp
                border 2

                ret


