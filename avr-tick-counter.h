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

namespace Tick {

void StartCounter() {
	::StartTickCounter();
}

void StopCounter() {
	::StopTickCounter();
}

uint16_t Get() {
	return ::GetTicks();
}

struct AutoCounter {

	AutoCounter() {
		StartCounter();
	}

	~AutoCounter() {
		StopCounter();
	}

};

} // namespace Tick

#endif

#endif // AVR_TICK_COUNTER_H
