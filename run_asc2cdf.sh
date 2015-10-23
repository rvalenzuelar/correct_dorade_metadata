#!/bin/bash

# Flight level data are converted to RAF
# using matlab function convert_to_raf_ascii.m
#
echo ' '
# ./asc2cdf -d 2001-01-23 -v 010123I.std.ascii.raf 010123I.nc
# ./asc2cdf -d 2001-01-25 -v 010125I.std.ascii.raf 010125I.nc
./asc2cdf -d 2001-02-17 -v 010217I.std.ascii.raf 010217I.nc
echo ' '
