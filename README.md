# PICO8lib

The [PICO-8](https://www.lexaloffle.com/pico-8.php) is a fantasy console with limited space for programs and data, programmed in a flavor of Lua with a very small standard library. This repository is meant to serve as a collection of useful functions and tables built, curated, and optimized by the pico8 developer community.

### Utility Functions
* [`strings`](strings.p8) - Manipulating and creating strings
* [`tables`](tables.p8) - Manipulating and creating tables
* [`functions`](functions.p8) - Manipulating and creating functions
* [`math`](math.p8) - Mathematical operations, mostly on numbers
* [`number`](number.p8) - Non-mathematical maniuplation of numbers
* [`json`](json.p8) - JSON(ish) parser
* [`graphics`](graphics.p8) - Drawing and sprite manipulation
* [`physics`](physics.p8) - Collision functions, etc
* ['memory'](memory.p8) - Reading, writing, manipulating memory

### Classes
* [`vector`](vector.p8) - 2d vectors
* [`rational`](rational.p8) - rational numbers

### Snippets
* [`snippets`](snippets.p8) - inline snippets to mix with your own code

## Conventions
Code is not minified for character count; that is a job for a minifier if desired or necessary. Code is minified for token count.

Functions and variables are `local` where possible, for performance reasons. Thanks to zep for giving it to us as a free token!

Some functions are provided in multiple forms, optimized for tokens, size, and/or speed. Some functions have lines or blocks commented with variations.

`-- inline[t,c]` marks code that could be inlined to save `t` tokens and `c` characters, usually at the cost of cpu or memory.

`-- remove[t,c]` marks code that can be removed, usually at the cost of reduced functionality or code safety.

## Contributing
PRs are welcome! I am looking to collect a variety of best-of-breed examples of common library functions. Additional (or any) tests would also be helpful.

The best place to chat with other PICO-8 developers is on the [PICO-8 Discord](https://discord.gg/zM9SD7N).