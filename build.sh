#!/bin/bash
INPUT=dvd-freesoft.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && echo "$INPUT file not found" && exit 99
while read NAME CATEGORY SUMMARY ABOUT LICENSE WEBSITE DOWNLOAD LOGO
do
	# Create FILENAME and CATDIR
	FILENAME=`echo "${NAME,,}" | sed 's/ /-/g' | sed 's/+//g'`.html
	CATDIR=`echo "${CATEGORY,,}" | sed 's/[ěé]/e/g' | sed 's/š/s/g' | sed 's/č/c/g' | sed 's/ř/r/g' | sed 's/ž/z/g' | sed 's/ý/y/g' | sed 's/á/a/g' | sed 's/í/i/g' | sed 's/[úů]/u/g'`
	# Replace ; back to , in ABOUT
	ABOUT=`echo $ABOUT | sed 's/;/,/'`
	echo $CATDIR/$FILENAME
done < $INPUT
IFS=$OLDIFS
