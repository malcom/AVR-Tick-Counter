//
// Measurement of used AVR microcontroller cycles
// http://blog.malcom.pl/2017/pomiar-wykorzystanych-cykli-mikrokontrolera-avr.html
//
// Copyright (C) 2017 Marcin 'Malcom' Malich <me@malcom.pl>
// Released under the MIT License.
//

#ifndef AVR_TICK_COUNTER_H
#define AVR_TICK_COUNTER_H

#ifdef __cplusplus
extern "C" {
#endif

extern void StartTickCounter(void);
extern void StopTickCounter(void);
extern uint16_t GetTicks(void);

#ifdef __cplusplus
} // extern "C"
#endif

#ifdef __cplusplus

// Additional C++ interface

struct AutoTickCounter {

	AutoTickCounter() {
		StartTickCounter();
	}

	~AutoTickCounter() {
		StopTickCounter();
	}

};

#endif

#endif // AVR_TICK_COUNTER_H
