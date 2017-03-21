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
extern ticks_t GetTicks(void);

#ifdef __cplusplus
} // extern "C"
#endif

#ifdef __cplusplus

// Additional C++ interface

namespace Tick {

// to be sure that C++ functions will be always inlined even on -O0
#define force_inline __attribute__((always_inline)) inline


force_inline
void StartCounter() {
	::StartTickCounter();
}

force_inline
void StopCounter() {
	::StopTickCounter();
}

force_inline
ticks_t Get() {
	return ::GetTicks();
}

struct AutoCounter {

	force_inline
	AutoCounter() {
		StartCounter();
	}

	force_inline
	~AutoCounter() {
		StopCounter();
	}

};


#undef force_inline

} // namespace Tick

#endif

#endif // AVR_TICK_COUNTER_H
