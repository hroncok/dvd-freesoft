#!/bin/bash

# Create ISO dir and backup the old one
rm ISO.old -rf
mv ISO ISO.old
mkdir -p ISO/images
mkdir ISO/installers

# Parse data
INPUT=dvd-freesoft.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && echo "$INPUT file not found" && exit 99
while read NAME CATEGORY SUMMARY ABOUT LICENSE WEBPAGE DOWNLOAD LOGO
do
	# Create FILENAME and CATDIR
	FILENAME=`echo "${NAME,,}" | sed 's/ /-/g' | sed 's/+//g'`
	CATDIR=`echo "${CATEGORY,,}" | sed 's/[ěé]/e/g' | sed 's/š/s/g' | sed 's/č/c/g' | sed 's/ř/r/g' | sed 's/ž/z/g' | sed 's/ý/y/g' | sed 's/á/a/g' | sed 's/í/i/g' | sed 's/[úů]/u/g'`
	
	# Create catgeory directory if not there
	[ ! -d ISO/$CATDIR ] && {
		echo "Creating ISO/$CATDIR/index.html"
		mkdir ISO/$CATDIR
		cp catstart.html ISO/$CATDIR/index.html
		sed -i "s|{HOME_LINK}|../index.html|g" ISO/$CATDIR/index.html
		sed -i "s|{CATEGORY}|$CATEGORY|g" ISO/$CATDIR/index.html
		sed -i "s|{CATEGORY_IMAGE}|../images/$CATDIR.png|g" ISO/$CATDIR/index.html
	}
	
	# Replace ; back to , in ABOUT and SUMMARY
	ABOUT="`echo $ABOUT | sed 's/;/,/'`"
	SUMMARY="`echo $SUMMARY | sed 's/;/,/'`"
	
	# Create simple URL from the full one
	WEBPAGE_SIMPLE=`echo $WEBPAGE | sed 's|http://||'`
	WEBPAGE_SIMPLE=`echo $WEBPAGE_SIMPLE | sed 's|https://||'`
	WEBPAGE_SIMPLE=`echo $WEBPAGE_SIMPLE | sed 's|/$||'`
	
	# Creating app page
	echo "Creating ISO/$CATDIR/$FILENAME.html"
	cp template.html ISO/$CATDIR/$FILENAME.html
	sed -i "s|{NAME}|$NAME|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{HOME_LINK}|../index.html|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{CATEGORY_LINK}|index.html|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{CATEGORY}|$CATEGORY|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{SUMMARY}|$SUMMARY|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{ABOUT}|$ABOUT|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{WEBPAGE}|$WEBPAGE|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{WEBPAGE_SIMPLE}|$WEBPAGE_SIMPLE|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{LICENSE}|$LICENSE|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{INSTALL}|$INSTALL|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{FOOTER}|`cat footer.html`|g" ISO/$CATDIR/$FILENAME.html
	sed -i "s|{IMAGE}|../images/$FILENAME.png|g" ISO/$CATDIR/$FILENAME.html
	
	# Add the application to the category
	echo -e "\t\t\t<tr>" >> ISO/$CATDIR/index.html
	echo -e "\t\t\t\t<td><img class=\"minilogo\" src=\"../images/$FILENAME-mini.png\" alt="$NAME" /></td>" >> ISO/$CATDIR/index.html
	echo -e "\t\t\t\t<td class=\"name\">$NAME</td>" >> ISO/$CATDIR/index.html
	echo -e "\t\t\t\t<td class=\"summary\">$SUMMARY</td>" >> ISO/$CATDIR/index.html
	echo -e "\t\t\t\t<td><a class=\"more\" href=\"$FILENAME.html\">Více...</a></td>" >> ISO/$CATDIR/index.html
	echo -e "\t\t\t</tr>" >> ISO/$CATDIR/index.html
	
	# Download the logo and convert it
	echo "Downloading the logo"
	extension=${LOGO##*.}
	wget -q "$LOGO" -O tmpimg.$extension
	[ -f tmpimg.svg ] && inkscape --export-png=tmpimg.png --export-width=500 tmpimg.svg && extension=png
	convert tmpimg.$extension -trim -resize 32x32\> ISO/images/$FILENAME-mini.png
	convert tmpimg.$extension -trim -resize 256x256\> ISO/images/$FILENAME.png
	rm tmpimg.*
done < $INPUT
IFS=$OLDIFS

# Close categories
for CAT in ISO/*;
do
	echo "Closing ISO/$CATDIR/index.html"
	cat catend.html >> $CAT/index.html
	sed -i "s|{FOOTER}|`cat footer.html`|g" $CAT/index.html
done

# Remove colateral damage
rm -f ISO/installers/index.html ISO/images/index.html 
