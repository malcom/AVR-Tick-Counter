# The AVR Tick Counter

This small piece of assembly code implements a very accurate tick counter functionality over a built-in 16-bit timer on AVR microcontrollers. It can be used as a tool to determine the number of cycles used by CPU to execute a specified code in real-time or as a simple general purpose tick counter.


## Preface

The *project* was created in the need oh the hour when author wanted to know how many cycles does it take the microcontrollers to execute tested algorithms and other fragments of code. Some simulators and debuggers have a cycle counter, but unfortunately not all of them have such tools when it is necessary. So it was decided to write something quickly in assembler.

Why in assembler? To practice and recall some sort of asm skills on other platform than x86/64. And the most important, to have full control over the processor and the executed instruction set, to know how much additional ticks and delays they introduce. Which will help make some corrections to the final result and get a very accurate measurement.

Of course, this could be written in C/C++ as *naked* functions full of inline-assembler, but the inline-assembler is ugly, `__asm__` statement accepts only text strings with instructions and requires `EOL` marks `"\n"` at the end of each line, which is very annoying, especially while creating larger pieces of code.

More information in the author's blog post: [Pomiar wykorzystanych cykli mikrokontrolera AVR](http://blog.malcom.pl/2017/pomiar-wykorzystanych-cykli-mikrokontrolera-avr.html) [PL only].


## API/interface

The assembly code provides several functions which names describe exactly their operation:

``` c
void ResetTickCounter(void);
void StartTickCounter(void);
void StopTickCounter(void);
ticks_t GetTicks(void);
```

These functions can be used without any problem in C and C++ code, also in others with C (`avr-gcc`) calling convention.

There is an additional interface, especially for C++, located in `Tick` namespace. It contains some short aliases for C-style function from the global namespace:

``` cpp
namespace Tick {

void ResetCounter();
void StartCounter();
void StopCounter();
ticks_t Get();

} // namespace Tick
```

and simple RAII for automate start and stop counter in any scope:

``` cpp
namespace Tick {

struct AutoCounter {
	AutoCounter(bool reset = true);
	~AutoCounter();
};

} // namespace Tick
```

See the header file [avr-tick-counter.h](avr-tick-counter.h) if you need more info.


## Usage

The API is very simple, so the use is also quite natural. The repo contains an examples, see [example.c](example.c) and [example.cpp](example.cpp) files.

The code is preconfigured to use 16-bit timer `T1` on Atmega16/32. Different devices may have different timer config register names/addresses. You can change the timer configuration for you device by changing values for some specified constants. The config is located at the beginning of [avr-tick-counter.S](avr-tick-counter.S) file:

```
rTIMSK = TIMSK		; Timer/Counter Interrupt Mask Register
bTOIE = TOIE1		; Overflow Interrupt Enable Bit

rTCCR = TCCR1B		; Timer/Counter Control Register
bCS0 = CS10		; CLK Source Bit

rTCNT = TCNT1		; Timer/Counter Value Register
```

The tick counter is based on 16-bit timer, so in standard mode (default) the tick counter can hold `65 535` clock cycles (minus some additional ticks added by implementation). In this mode the `ticks_t` is simple alias to 16-bit integral type (`uint16_t`).

If this is insufficient, you can enable 32-bit support by defining `AVR_TICK_COUNTER_USE_32BIT`. In this mode the `ticks_t` type is simple typedef to `uint32_t` and tick counter can hold up to `429 496 729 532` (minus implementation overhead).


## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
