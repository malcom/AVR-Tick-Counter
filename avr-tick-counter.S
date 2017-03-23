//
// Simple and accurate tick counter on AVR microcontrollers
// https://github.com/malcom/AVR-Tick-Counter
//
// Copyright (C) 2017 Marcin 'Malcom' Malich <me@malcom.pl>
// Released under the MIT License.
//

#include <avr/io.h>

.global ResetTickCounter
.global StartTickCounter
.global StopTickCounter
.global GetTicks


; this code uses 16-bit timer T1, but different devices may have other timer1
; config register names/addresses, so correct below if required by your device
; default values for atmega16/32

rTIMSK = TIMSK		; Timer/Counter Interrupt Mask Register
bTOIE = TOIE1		; Overflow Interrupt Enable Bit

rTCCR = TCCR1B		; Timer/Counter Control Register
bCS0 = CS10			; CLK Source Bit

rTCNT = TCNT1		; Timer/Counter Value Register


; this code uses some GCC special regs...
rTmp = 0
rZero = 1


.section .bss

; uint16_t for count additions 8 ticks
.type	AdtTicks, @object
.size	AdtTicks, 2

AdtTicks:
	.zero	2


#ifdef AVR_TICK_COUNTER_USE_32BIT

.section .bss

; uint16_t for count timer overflows
.type	OvfTicks, @object
.size	OvfTicks, 2

OvfTicks:
	.zero	2

.section .text

.global TIMER1_OVF_vect
TIMER1_OVF_vect:
						; 4 cycles int react
						; 3 jmp from int vector
	nop					; 1
	nop					; 1

	push r0				; 2
	push r16			; 2

	; stop timer
	ldi r16, 0			; 1
	sts rTCCR, r16		; 2

	push r24
	push r25
	lds r0, SREG

	lds r24, OvfTicks
	lds r25, OvfTicks+1
	adiw r24, 1
	sts OvfTicks+1, r25
	sts OvfTicks, r24

	lds r24, AdtTicks
	lds r25, AdtTicks+1
	adiw r24, 3
	sts AdtTicks+1, r25
	sts AdtTicks, r24

	sts SREG, r0
	pop r25
	pop r24

	; start timer
	ldi r16, 1<<bCS0	; clk source
	sts rTCCR, r16

	pop r16				; 2 cycles
	pop r0				; 2

	nop					;-1 unknown jitter (todo: investigate)
	reti				; 4

#endif // AVR_TICK_COUNTER_USE_32BIT

.section .text

ResetTickCounter:

	sts rTCNT+1, rZero
	sts rTCNT, rZero

#ifdef AVR_TICK_COUNTER_USE_32BIT
	sts OvfTicks, rZero
	sts OvfTicks+1, rZero
#endif // AVR_TICK_COUNTER_USE_32BIT

	sts AdtTicks, rZero
	sts AdtTicks+1, rZero

	ret


StartTickCounter:
	push r16

	lds r24, AdtTicks
	lds r25, AdtTicks+1
	adiw r24, 1
	sts AdtTicks+1, r25
	sts AdtTicks, r24

#ifdef AVR_TICK_COUNTER_USE_32BIT
	; timer interrupt
	ldi r16, 1<<bTOIE	; timer overflow
	sts rTIMSK, r16

	sei
#endif // AVR_TICK_COUNTER_USE_32BIT

	; start timer
	ldi r16, 1<<bCS0	; clk source
	sts rTCCR, r16

	pop r16				; 2 cycles
	nop					; 1
	nop					; 1
	ret					; 4


StopTickCounter:
						; 4 call StopTickCounter
	nop					; 1
	nop					; 1

	; stop timer
	sts rTCCR, rZero	; 2

	lds r24, AdtTicks
	lds r25, AdtTicks+1
	adiw r24, 1
	sts AdtTicks+1, r25
	sts AdtTicks, r24

	ret


GetTicks:

	; calc additional ticks
	; AdtTicks * 8 == AdtTicks << 3
	lds r26, AdtTicks
	lds r27, AdtTicks+1
	ldi r22, 3
	loop:
	lsl r26
	rol r27
	dec r22
	brne loop

#ifdef AVR_TICK_COUNTER_USE_32BIT

	lds r22,rTCNT
	lds r23, rTCNT+1
	lds r24, OvfTicks
	lds r25, OvfTicks+1

	; subtract additional ticks
	sub r22, r26
	sbc r23, r27
	sbci r24, 0
	sbci r25, 0

#else // !AVR_TICK_COUNTER_USE_32BIT

	lds r24, rTCNT
	lds r25, rTCNT+1

	; subtract additional ticks
	sub r24, r26
	sbc r25, r27

#endif // !AVR_TICK_COUNTER_USE_32BIT

	ret
