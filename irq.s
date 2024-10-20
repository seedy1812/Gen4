
    align 32


IM_2_Table:
        dw      linehandler     ; 0 - line interrupt
        dw      inthandler      ; 1 - uart0 rx
        dw      inthandler      ; 2 - uart1 rx
        dw      ctc0handler     ; 3 - ctc 0
        dw      inthandler      ; 4 - ctc 1
        dw      inthandler      ; 5 - ctc 2
        dw      inthandler      ; 6 - ctc 3
        dw      inthandler      ; 7 - ctc 4
        dw      inthandler      ; 8 - ctc 5
        dw      inthandler      ; 9 - ctc 6
        dw      inthandler      ; 10 - ctc 7
        dw      vbl             ; 11 - ula
        dw      inthandler      ; 12 - uart0 tx
        dw      inthandler      ; 13 - uart1 tx
        dw      inthandler      ; 14
        dw      inthandler      ; 15

wait_vbl:
	border 0
    ld hl,irq_counter 
	ld a,(hl)
.loop:
	border 7
	halt
	border 5
    cp (hl)
    jr z,.loop
	ld (hl),0
	border 0
	ret

irq_counter: db 0
irq_last_count: db 0




set_linehandler:

    ld a,c
    nextreg LINE_INT_LSB,a

    ld a,1
    and b
    ld l,a

   	ld a,LINE_INT_CTRL
	call ReadNextReg
    or %00000010
    or l
    nextreg LINE_INT_CTRL,a

    ld (linehandler_address),de

    ret


toggle_linehandler:
    ld a,(toggle_variable)
    cpl
    ld (toggle_variable),a

    or a
    jr z ,.other


    border 1
    ld bc,167-16
    ld de,update_botlines
    jr set_linehandler
.other:
    border 6
    ld bc,192+32
    ld de,update_toplines
    jr set_linehandler

toggle_variable: db 0


init_vbl:

    di

    call toggle_linehandler

    ld a,HI(IM_2_Table)
    ld i,a

    nextreg $c0, 1+(IM_2_Table & %11100000) ;low byte IRQ table  | base vector = 0xa0, im2 hardware mode
   	
	nextreg $c4,1+2				; ULA interrupt no Line
	nextreg $c5,0               ; disable CTC channels
	nextreg $c6,0               ; disable UART

    ; not dma
    nextreg $cc,%10000001    ; NMI will interrupt dma
    nextreg $cd,0            ; ct 0 no interrupt dma
    nextreg $ce,0            ; ct 0 no interrupt dma

    im 2

    ei
    ret


vbl:
	di
	push af

    border 4


 	ld a,(irq_counter)
    inc a
 	ld (irq_counter),a

	pop af

    NextReg $c8,1
    ei
    reti


nothing: ret

linehandler:

    push af
	border 5

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

linehandler_address: equ *+1
    call nothing

    call toggle_lineHandler

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

    NextReg $c8,2
    ei
    reti

ctc0handler:
	my_break
    NextReg $c9,1
    ei
    reti

inthandler:
	my_break
    ei
    reti
    
