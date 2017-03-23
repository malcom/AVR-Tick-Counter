//
// Simple and accurate tick counter on AVR microcontrollers
// https://github.com/malcom/AVR-Tick-Counter
//
// Copyright (C) 2017 Marcin 'Malcom' Malich <me@malcom.pl>
// Released under the MIT License.
//

#include <inttypes.h>

#include <stdio.h>
#include <avr/io.h>
#include <util/delay.h>

#include "lcd.h"
#include "avr-tick-counter.h"

int main(void) {

	char buf[16];

	LcdInit();

	StartTickCounter();
	////////////////////

	__builtin_avr_delay_cycles(100);

	////////////////////
	StopTickCounter();
	// pause counter
	// do sth...
	// resume counter
	StartTickCounter();
	////////////////////

	__builtin_avr_delay_cycles(100);

	////////////////////
	StopTickCounter();

	sprintf(buf, "cycles: %d", GetTicks());
	LcdGoto(0, 0);
	LcdWriteText(buf);

	while (1)
		;

	return 0;
}
