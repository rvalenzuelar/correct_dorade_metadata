#!/bin/bash

# Script for processing a coordinate replacement in sweep files
# and creating cfrad text files for later navigation correction.
#
# Raul Valenzuela
# April, 2015

# I/O  dorade directories
#---------------------------
# INDIR="$HOME/P3/dorade/case04"
# # OUTDIR="$HOME/P3/dorade/case04_coords_cor2"
# OUTDIR="$HOME/P3/dorade/dummy"

# INDIR="$HOME/P3/dorade/case03/leg01"
# OUTDIR="$HOME/P3/dorade/case03_coords_cor"

# INDIR="$HOME/P3/dorade/case03/leg02"
# OUTDIR="$HOME/P3/dorade/case03_coords_cor/leg02"

# INDIR="$HOME/P3/dorade/case03_all/leg03"
# OUTDIR="$HOME/P3/dorade/case03_coords_cor/leg03_new"

#--------------------------------
# INDIR="$HOME/P3_v2/dorade/c03/leg01_all"
INDIR="$HOME/P3_v2/dorade/c03/leg03_all"

# standard tape file
#---------------------------
# STDTAPE="$HOME/Github/correct_coords/010125I.nc"
STDTAPE="$HOME/Github/correct_coords/010123I.nc"

# python function
#---------------------------
PYFUN="$HOME/Github/correct_coords/replace_cfradial_coords.py"

# dorade outdir
#---------------------
# OUTDIR="$HOME/P3_v2/dorade/c03/leg03_cor"
OUTDIR="${INDIR/all/cor}"

# cfradial outdir
#-------------------------
CFDIR="${OUTDIR/dorade/cfrad}"

# check existence of directories
#------------------------------------------------
if [ ! -d $CFDIR ]; then
	cf_flag=false
else
	cf_flag=true
fi

if [ ! -d $OUTDIR ]; then
	out_flag=false
else
	out_flag=true
fi


# Processing
#---------------------------
if [ "$out_flag" = true ]; then
	echo
	echo " Output directory: "
	echo " $OUTDIR"
	echo " already exists and might contain processed files. "
	echo " If you continue existing files will be overwritten."
	echo
	read -r -p " Do you want to continue? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo " Overwriting"
		echo
		cd $OUTDIR
		nfiles="$(ls -1 | wc -l)"
		if [ "${nfiles}" != 0 ];then
			rm swp.*
		fi				
		if [ "$cf_flag" = true ]; then		
			cd $CFDIR
			nfiles="$(ls -1 | wc -l)"
			if [ "${nfiles}" != 0 ];then
				rm cfrad.*
			fi
		else
			mkdir -p $CFDIR
		fi
	else
		echo " Stopping script"
		echo
		exit 
	fi
else
	mkdir -p $OUTDIR
	mkdir -p $CFDIR
fi

echo " Changing to input directory: $INDIR"
echo
cd $INDIR
echo " Running RadxConvert"
RadxConvert -f swp* -cfradial -outdir .
RDXOUT="$(ls -d 2*/)"
echo
echo " Changing to RadxConvert directory: $RDXOUT'"
echo
cd $RDXOUT
echo " Running replace_cfradial_coords.py"
echo
python $PYFUN $STDTAPE
echo 
echo " Coordinates replaced"
echo
echo " Cleaning and moving files to $OUTDIR"
mv cfrad.* $CFDIR
cd $INDIR
rm -rf $RDXOUT
cd $CFDIR
RadxConvert -f cfrad* -dorade -outdir $OUTDIR
cd $OUTDIR/$RDXOUT
mv swp* $OUTDIR
cd $OUTDIR
rm -rf $RDXOUT
echo
echo " Done"
echo



