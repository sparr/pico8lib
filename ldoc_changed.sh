#!/bin/sh
#
# Run `ldoc` against the current directory, then `git checkout` any files whose only change is the "Last updated" line

ldoc .
git diff -G"<i style=\"float:right;\">Last updated " --numstat | awk '{if ($1==1 && $2==1) {print $3} }' | xargs git checkout