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

.section .text


StartTickCounter:
	push r16
	clr r16

	; clear counter
	sts TCNT1H, r16
	sts TCNT1L, r16

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
	lds r24, TCNT1L
	lds r25, TCNT1H

	; subtract additional tics
	sbiw r24, StartTickCounterAdds + StopTickCounterAdds

	ret
