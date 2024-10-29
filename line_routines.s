
DRAW_SECTION_PUSH macro
    NextReg $c8,2
    ei

    border 1

    push af
    push bc
    push hl
    endm

DRAW_SECTION_POP macro
    push de
    call toggle_lineHandler
    pop de

    border 2

        pop hl
        pop bc
        pop af
        reti
        endm

UPDATE_SECTION_PUSH macro
    NextReg $c8,2
    ei
    border 4
    push af
    push bc
    push de
    push hl

    push ix
    push iy

    exx

    push af
    push bc
    push de
    push hl
    endm


UPDATE_SECTION_POP macro
    call toggle_lineHandler
    border 3

    pop hl
    pop de
    pop bc
    pop af


    exx

    pop iy
    pop ix

    pop hl
    pop de
    pop bc
    pop af
    reti

    endm





update_toplines:
        UPDATE_SECTION_PUSH

  ;      my_break

        ld bc,tm_entry_size
        ld iy , tm_speeds+(tm_entry_size*0);

        exx
        ld ix,my_buffert1               ;iy+0
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_buffert2               ;iy+1
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_buffert3               ;iy+2
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_buffert4               ;iy+3
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_buffert5_1             ;uy+4
        call shift_line

        ld ix,my_buffert5_2
        call shift_line

        exx
        add iy,bc
        exx

        ld ix,my_buffert6_1
        call shift_line

        ld ix,my_buffert6_2
        call shift_line

        exx
        add iy,bc
        exx

        ld ix,my_buffert7_1
        call shift_line

        ld ix,my_buffert7_2
        call shift_line


        ld ix,my_buffert7_3
        call shift_line

        ld ix,my_buffert7_4
        call shift_line

        UPDATE_SECTION_POP

        ret

update_botlines:
        UPDATE_SECTION_PUSH

        ld bc,-tm_entry_size
        ld iy , tm_speeds_bot+(tm_entry_size*5);

        exx
        ld ix,my_bufferb1
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_bufferb2
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_bufferb3
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_bufferb4
        call shift_line
        exx
        add iy,bc
        exx

        ld ix,my_bufferb5_1
        call shift_line

        ld ix,my_bufferb5_2
        call shift_line

        exx
        add iy,bc
        exx

        ld ix,my_bufferb6_1
        call shift_line

        ld ix,my_bufferb6_2
        call shift_line

        exx
        add iy,bc
        exx

        ld ix,my_bufferb7_1
        call shift_line

        ld ix,my_bufferb7_2
        call shift_line


        ld ix,my_bufferb7_3
        call shift_line

        ld ix,my_bufferb7_4
        call shift_line


        UPDATE_SECTION_POP

        ret



