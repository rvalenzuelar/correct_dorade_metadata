#!/usr/bin/python

# Replace some metadata values in cfradial files
# 
# See http://www.unidata.ucar.edu/software/netcdf/examples/programs/
#
# Raul Valenzuela
# April, 2015

import sys 
from netCDF4 import Dataset
import glob
import pandas as pd	
import math
import numpy as np

# define function
def replace_cfradial_metadata( stdtape_filepath ):

	# open standard tape file for reading
	stdtape_file = Dataset(stdtape_filepath,'r') 

	# get stdtape timestamp
	base_time=stdtape_file.variables['base_time'][:]
	stdtape_secs=stdtape_file.variables['Time'][:]
	stdtape_timestamp=pd.to_datetime(stdtape_secs+base_time,unit='s')
	stdtape_lats=stdtape_file.variables['LAT'][:]
	stdtape_lons=stdtape_file.variables['LON'][:]
	stdtape_geo_alt=stdtape_file.variables['GEOPOT_ALT'][:]
	stdtape_pres_alt=stdtape_file.variables['PRES_ALT'][:]

	# close the file
	stdtape_file.close()

	# creates dictionary
	dict_stdtape={	'lats':stdtape_lats,
			'lons':stdtape_lons,
			'galt': stdtape_geo_alt,
			'palt': stdtape_pres_alt}
	
	# pandas dataframe for standar tape		
	df_stdtape=pd.DataFrame(data=dict_stdtape,index=stdtape_timestamp)

	# get a list cfradial files in the current directory
	# (bash script changes current directory)
	nclist = glob.glob('cfrad.*')
	nlist=len(nclist)
	print "Folder contains ",str(nlist)," cfradial files"

	for f in range(nlist):
		# open cfradial file for reading and writing
		print 'Processing: '+nclist[f]
		cfrad_file = Dataset(nclist[f],'r+') 

		# get cfradial timestamp
		start_datetime_nparray=cfrad_file.variables['time_coverage_start'][0:20]
		strpattern=''
		start_datetime_str=strpattern.join(str(v) for v in start_datetime_nparray)
		time_format="%Y-%m-%dT%H:%M:%SZ"
		cfrad_start_datetime=pd.to_datetime(start_datetime_str,format=time_format)
		cfrad_time = cfrad_file.variables['time'][:]
		cfrad_secs=pd.to_timedelta(cfrad_time.astype(int),unit='s')
		cfrad_timestamp=cfrad_start_datetime+cfrad_secs
		
		# create timestamp2 to miliseconds precision
		foo=[math.modf(x) for x in cfrad_time]
		f=zip(*foo) # unpair list of tuples
		ms = np.asarray(f[0])*100
		s = f[1]
		cfrad_ms=pd.to_timedelta(ms,unit='ms')
		cfrad_s=pd.to_timedelta(s,unit='s')		
		cfrad_timestamp2=cfrad_start_datetime+cfrad_s+cfrad_ms

		# remove duplicated timestamps (str type)
		unique_timestamp=cfrad_timestamp.drop_duplicates()
		nstamps=unique_timestamp.nunique()

		# cfradial information
		cfrad_lats = cfrad_file.variables['latitude'][:]
		cfrad_lons = cfrad_file.variables['longitude'][:]
		cfrad_altitude = cfrad_file.variables['altitude'][:]
		cfrad_altitude_agl = cfrad_file.variables['altitude_agl'][:]

		# creates dictionary
		dict_cfrad = {	'lats':cfrad_lats,
				'lons':cfrad_lons,
				'alt': cfrad_altitude,
				'alt_agl': cfrad_altitude_agl }

		# pandas dataframe for cfradial file	
		df_cfrad=pd.DataFrame(data=dict_cfrad,index=cfrad_timestamp)
		df_cfrad_new=df_cfrad.copy()

		for t in range(nstamps):
			timestamp=str(unique_timestamp[t])

			# from std_tape
			try:
				new_lats=df_stdtape[timestamp]['lats']
				new_lons=df_stdtape[timestamp]['lons']
				new_galts=df_stdtape[timestamp]['galt']
				new_palts=df_stdtape[timestamp]['palt']
			except:
				print "\nERROR: check STDTAPE file is correct"
				cfrad_file.close()
				sys.exit(1)

			# to cfradial
			# since the 'altitude' field does not exist in dict_cfrad
			# pandas creates a new column (field). See if it's more
			# efficient creating a dict_cfrad with 'altitude' and
			# 'altitude_agl' fields
			df_cfrad_new.loc[timestamp,'lats']=new_lats
			df_cfrad_new.loc[timestamp,'lons']=new_lons
			df_cfrad_new.loc[timestamp,'altitude']=new_palts
			df_cfrad_new.loc[timestamp,'altitude_agl']=new_galts

		cfrad_file.variables['latitude'][:]=df_cfrad_new['lats'].values
		cfrad_file.variables['longitude'][:]=df_cfrad_new['lons'].values
		cfrad_file.variables['altitude'][:]=df_cfrad_new['altitude'].values
		cfrad_file.variables['altitude_agl'][:]=df_cfrad_new['altitude_agl'].values
		
		# print ''
		# print df_cfrad['lats'].values
		# print ''
		# print type(df_cfrad_new['lats'].values)
		# print ''
		# print df_cfrad_new['2001-01-25 18:44:51']['lats']
		# print ''

		# close the file.
		cfrad_file.close()

# call function
stdtape=sys.argv[1]
replace_cfradial_metadata(stdtape)