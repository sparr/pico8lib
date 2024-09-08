# PICO8lib

The [PICO-8](https://www.lexaloffle.com/pico-8.php) is a fantasy console with limited space for programs and data, programmed in a flavor of Lua with a very small standard library. This repository is meant to serve as a collection of useful functions and tables built, curated, and optimized by the pico8 developer community.

The focus of this repository is on game-agnostic code and functions. Most of the code you will find here is applicable to any type of game or game engine, and represents code you might generally expect to find in the lua standard library (string, table, math, etc) or in a more comprehensive console I/O library (drawing, memory access, etc).

What you will not find here is code related to gameplay implementation, such as actor and component frameworks, rendering engines, or game rule logic. I would like to add this sort of content in the future, but it will require significant additional organization and documentation efforts above and beyond those requires for the current contents of the repo.

### Utility Functions
* [`class`](pico8lib/class.p8) - Create object oriented classes with inheritance
* [`functions`](pico8lib/functions.p8) - Function manipulation, creation, and helpers
* [`graphics`](pico8lib/graphics.p8) - Drawing and sprite manipulation
* [`json`](pico8lib/json.p8) - JSON(ish) parser
* [`log`](pico8lib/log.p8) - Write timestamped and leveled logs to STDOUT
* [`math`](pico8lib/math.p8) - Mathematical operations, mostly on numbers
* [`memory`](pico8lib/memory.p8) - Reading, writing, and manipulating memory
* [`number`](pico8lib/number.p8) - Non-mathematical manipulation of numbers
* [`physics`](pico8lib/physics.p8) - Collision functions, etc
* [`strings`](pico8lib/strings.p8) - String manipulation and creation
* [`tables`](pico8lib/tables.p8) - Table manipulation and creation

### Classes
* [`vector`](vector.p8) - Vectors (points and directions)
* [`rational`](rational.p8) - Rational Numbers (Fractions)
* [`test`](test.p8) - Unit testing
* [`uint32`](uint32.p8) - Unsigned 32-bit Integers

### Other
* [`snippets`](snippets.p8) - Inline snippets to mix with your own code
* [`boilerplate`](boilerplate.p8) - Mostly empty pico8 cart with profiling and comments

### Examples
Some usage examples can be found in [`examples/`](examples) and [`tests/`](tests)

## Conventions
Code is not minified for character count; that is a job for a minifier if desired or necessary. I try to aim for 3-5 character identifiers in moderate to complex functions, 1-3 characters in simple functions.

Functions and variables are `local` where possible, for performance reasons. Thanks to zep for giving it to us as a free token!

Some functions are provided in multiple variations, optimized for tokens, size, speed, and/or functionality. Every function should have at least a token-optimized version. Some functions have lines or blocks commented with variations.

`-- inline[t,c]` marks code that could be inlined to save `t` tokens and `c` characters, usually at the cost of cpu or memory.

`-- remove[t,c]` marks code that can be removed, usually at the cost of reduced functionality or code safety.

`#include` lines are commented out because nested includes are a syntax error in pico8. You will need to put all required includes in your own top level script file. e.g. if you want to do `#include json.lua` then you need to `#include strings.lua` earlier in the same file.

## Tests
Thanks to [mindfilleter](/mindfilleter) we can use [`test`](test.p8) to perform unit tests on this repo.

Individual tests are in [`tests/`](tests), and can run with a command like `pico8 -x tests/test_test.p8`.

[`tests/template.p8`](tests/template.p8) contains a template for new tests, which can be used in this repo or on your own project that uses the test library.

## Contributing
PRs are welcome! I am looking to collect a variety of best-of-breed examples of common library functions. Additional tests would also be helpful.

The best place to chat with other PICO-8 developers is on the [PICO-8 Discord](https://discord.gg/zM9SD7N).

## Related Projects and Links

### Libraries
* [pico8-missing-builtins](https://github.com/adamscott/pico8-missing-builtins)
* [Lib-Pico8](https://github.com/clowerweb/Lib-Pico8)
* https://github.com/0xcafed00d/pico-8-games/blob/master/lib/

### Game engine implementations
* https://github.com/jkingsDigiPen/pico-game/tree/master/carts/game0

### Well engineered cart collections
* https://github.com/freds72/pico8

### Coding tips
* https://github.com/seleb/PICO-8-Token-Optimizations

### Documentation
* https://www.lexaloffle.com/pico-8.php?page=manual
* https://pico-8.fandom.com/wiki/Pico-8_Wikia
