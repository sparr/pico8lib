-- Meta Data
project = "pico8lib"
title = "pico8lib"
description = "best-of-breed examples of common library functions"
readme = "README.md"

-- Output Options
backtick_references = true
all = true
file = {"."}
format = "html"
dir = "doc"
ext = "html"
boilerplate = true
template = "!"

examples = {
   "tests/test_class.p8",
   "tests/test_functions.p8",
   "tests/test_json.p8",
   "tests/test_test.p8",   
}

-- Allow ldoc to process .p8 files as lua 
add_language_extension("p8","lua")
