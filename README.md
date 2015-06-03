# correct_dorade_metadata
Replace metadata information in dorade sweep files using 
NOAA-P3 flight level data (standard tape)

asc2cdf: converts from RAF (ascii) format to netCDF
cfradial_metadata.py: performs the metadata replacement
run_asc2cdf: runs asc2cdf with parameters
replace_dorade_metadata.sh: runs python script

Note:
NOAA-P3 flight level data are converted first to RAF format
using matlab function convert_to_raf_ascii.m