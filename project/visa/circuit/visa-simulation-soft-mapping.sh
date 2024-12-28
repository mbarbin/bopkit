#!/bin/bash -e

bopkit simu visa.bop --output-only-on-change | \
bopkit digital-calendar map-raw-input | \
bopkit digital-calendar display --no-output
