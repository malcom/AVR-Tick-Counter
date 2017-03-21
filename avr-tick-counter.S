//
// Measurement of used AVR microcontroller cycles
// http://blog.malcom.pl/2017/pomiar-wykorzystanych-cykli-mikrokontrolera-avr.html
//
// Copyright (C) 2017 Marcin 'Malcom' Malich <me@malcom.pl>
// Released under the MIT License.
//

#include <avr/io.h>

.global StartTickCounter
.global StopTickCounter
.global GetTicks

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
	push r24				; 2 cycles
	push r25				; 2

	lds r24, OvfTicks		; 2
	lds r25, OvfTicks+1		; 2

	push r16				; 2
	lds r16, SREG			; 2
	adiw r24, 1				; 2
	sts SREG, r16			; 2
	pop r16					; 2

	sts OvfTicks+1, r25		; 2
	sts OvfTicks, r24		; 2

	pop r25					; 2
	pop r24					; 2

	reti					; 4

; 30 cycles + 4 int react + 3 jmp from int vector - 1 unknown jitter (todo: investigate)
#define TimerOvfTicksAdds 36

#endif // AVR_TICK_COUNTER_USE_32BIT

.section .text

StartTickCounter:
	push r16
	clr r16

	; clear counter
	sts TCNT1H, r16
	sts TCNT1L, r16

#ifdef AVR_TICK_COUNTER_USE_32BIT
	; clear overflow counter
	sts OvfTicks, r16
	sts OvfTicks+1, r16

	; timer interrupt
	ldi r16, 1<<TOIE0	; timer overflow
	sts TIMSK1, r16

	sei
#endif // AVR_TICK_COUNTER_USE_32BIT

	; start timer
	ldi r16, 1<<CS10	; clk source
	sts TCCR1B, r16

	pop r16				; 2 cycles
	ret					; 4

; 6 from StartTickCounter
#define StartTickCounterAdds 6


StopTickCounter:
	push r16			; 2 cycles
	clr r16				; 1

	; stop timer
	sts TCCR1B, r16		; 2

	pop r16
	ret

; 5 from StopTickCounter + 4 call to StopTickCounter
#define StopTickCounterAdds 9


GetTicks:

#ifdef AVR_TICK_COUNTER_USE_32BIT

	lds r22, TCNT1
	lds r23, TCNT1+1
	lds r24, OvfTicks
	lds r25, OvfTicks+1

	; count timer interruption additional cycles
	; multiply OvfTicks (16b) by TimerOvfTicksAdds (8b)
	push r16
	ldi r16, TimerOvfTicksAdds
	mul r24, r16
	movw r26, r0	; r26=r0, r27=r1
	mul r25, r16
	add r27, r0
	pop r16

	; add start/stop additional cycles
	adiw r26, StartTickCounterAdds + StopTickCounterAdds

	clr r0	; for gcc happy
	clr r1	; for gcc happy

	; subtract all additional ticks
	sub r22, r26
	sbc r23, r27
	sbci r24, 0
	sbci r25, 0

#else // !AVR_TICK_COUNTER_USE_32BIT

	lds r24, TCNT1L
	lds r25, TCNT1H

	; subtract additional ticks
	sbiw r24, StartTickCounterAdds + StopTickCounterAdds

#endif // !AVR_TICK_COUNTER_USE_32BIT

	ret
