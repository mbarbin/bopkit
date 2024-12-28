#!/bin/bash -e

bopkit simu visa.bop --output-only-on-change | \
bopkit simu calendar-output.bop -p | \
bopkit digital-calendar display --no-output
