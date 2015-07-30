#!/bin/bash

# Script for processing a coordinate replacement in sweep files
# Also, it creates a cfrad copy for later navigation correction.
#
# Raul Valenzuela
# April, 2015

# I/O  dorade directories
#---------------------------

INDIR="$HOME/P3_v2/dorade/c04/leg10_all"
OUTDIR="${INDIR/all/cor}"
CFDIR="${OUTDIR/dorade/cfrad}"

# standard tape file
#---------------------------
STDTAPE="$HOME/Github/correct_dorade_metadata/010125I.nc"

# python function
#---------------------------
PYFUN="$HOME/Github/correct_dorade_metadata/cfradial_metadata.py"


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
		nfiles="$(find -name 'swp.*' | wc -l)"
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
if [ $? != 0 ]; then
	exit
fi
echo 
echo " Metadata replaced"
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



