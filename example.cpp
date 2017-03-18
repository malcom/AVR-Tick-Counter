//
// Measurement of used AVR microcontroller cycles
// http://blog.malcom.pl/2017/pomiar-wykorzystanych-cykli-mikrokontrolera-avr.html
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

int main() {

	LcdInit();
	LcdGoto(0, 0);

	StartTickCounter();

	////////////////////

	__builtin_avr_delay_cycles(1000);

	////////////////////

	StopTickCounter();

	char buf[16];
	sprintf(buf, "cycles: %d", GetTicks());
	LcdWriteText(buf);

	while (true) {
		;
	}

	return 0;
}
