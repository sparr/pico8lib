-- Meta Data
project = "pico8lib"
title = "pico8lib"
description = "Helpful modules and best-in-class implementations of commonly needed functions and algorithms"
readme = "README.md"

-- Output Options
backtick_references = true
all = true
file = {"."}
format = "markdown"
dir = "doc"
ext = "html"
boilerplate = true
template = "!"
ignore = true -- ignore any 'no doc comment or no module' warnings

examples = {
   "snippets.p8",
   "tests/test_class.p8",
   "tests/test_functions.p8",
   "tests/test_json.p8",
   "tests/test_test.p8",
   "examples/",
   excludes = {
      "snippets.p8",
      "boilerplate.p8",
   }
   
}

-- Allow ldoc to process .p8 files as lua 
add_language_extension("p8","lua")
