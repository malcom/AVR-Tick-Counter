//
// Simple and accurate tick counter on AVR microcontrollers
// https://github.com/malcom/AVR-Tick-Counter
//
// Copyright (C) 2017 Marcin 'Malcom' Malich <me@malcom.pl>
// Released under the MIT License.
//

#ifndef AVR_TICK_COUNTER_H
#define AVR_TICK_COUNTER_H


#ifdef AVR_TICK_COUNTER_USE_32BIT
	typedef uint32_t ticks_t;
#else
	typedef uint16_t ticks_t;
#endif


#ifdef __cplusplus
extern "C" {
#endif

extern void ResetTickCounter(void);
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
void ResetCounter() {
	::ResetTickCounter();
}

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
	AutoCounter(bool reset = true) {
		if (reset)
			ResetCounter();
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
