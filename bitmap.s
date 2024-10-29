

bitmap_init:
    ld bc,LAYER2_OUT

    ld a,%10

    out(c),a

    nextreg LAYER2_CONTROL_REGISTER, %00010000

    nextreg PAL_CTRL,%00010001
    nextreg PAL_INDEX,0

    ld bc, 256/2

    ld hl, background_pal
.pal_lp:
    ld a,(hl)
    nextreg PAL_VALUE_9BIT,a
    inc hl

    ld a,(hl)
    nextreg PAL_VALUE_9BIT,a
    inc hl

    dec bc

    ld a,b
    or c
    jr nz,.pal_lp

    ret

bitmap_update:
    ld ix,tm_speeds_mid
    xor a
    sub (ix+2)
    nextreg LAYER2_SCROLL_X_LSB,a
    ret

