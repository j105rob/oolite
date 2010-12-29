#! /bin/bash

cd ..


# Paths relative to .., i.e. Cocoa-deps.
TEMPDIR="temp-download-libpng"
TARGETDIR="../Cross-platform-deps/libpng"

URLFILE="../URLs/libpng.url"
VERSIONFILE="$TARGETDIR/current.url"

TEMPFILE="$TEMPDIR/libpng.tbz"


DESIREDURL=`head -n 1 $URLFILE`


# Report failure, as an error if there's no existing code but as a warning if there is.
function fail
{
	if [ $LIBRARY_PRESENT -eq 1 ]
	then
		echo "warning: $1, using existing code originating from $CURRENTURL."
		exit 0
	else
		echo "error: $1"
		exit 1
	fi
}


# Determine whether an update is desireable, and whether there's libpng code in place.
if [ -d $TARGETDIR ]
then
	LIBRARY_PRESENT=1
	if [ -e $VERSIONFILE ]
	then
		CURRENTURL=`head -n 1 $VERSIONFILE`
		if [ $DESIREDURL = $CURRENTURL ]
		then
			echo "libpng is up to date."
			exit 0
		else
			echo "libpng is out of date."
		fi
	else
		echo "current.url not present, assuming libpng is out of date."
		CURRENTURL="disk"
	fi
else
	LIBRARY_PRESENT=0
	echo "libpng not present, initial download needed."
fi


# Clean up temp directory if it's hanging about.
if [ -d $TEMPDIR ]
then
	rm -rf $TEMPDIR
fi


# Create temp directory.
mkdir $TEMPDIR
if [ ! $? ]
then
	echo "error: Could not create temporary directory $TEMPDIR."
	exit 1
fi


# Download libpng source.
echo "Downloading libpng source from $DESIREDURL..."
curl "-q#gsS" -o $TEMPFILE $DESIREDURL
RESULT=$?
if [ ! $RESULT ]
then
	echo "Result is $RESULT"
	fail "could not download $DESIREDURL"
fi


# Expand tarball.
tar -xkf $TEMPFILE -C $TEMPDIR
if [ ! $? ]
then
	fail "could not expand $TEMPFILE into $TEMPDIR"
fi


# Remove tarball.
rm $TEMPFILE

# Delete existing code.
rm -rf $TARGETDIR


# Move new code into place.
mv $TEMPDIR/libpng* $TARGETDIR
if [ ! $? ]
then
	echo "error: could not move expanded libpng source into place."
	exit 1
fi

# Note version for future reference.
echo $DESIREDURL > $VERSIONFILE

# Remove temp directory.
rm -rf $TEMPDIR

echo "Successfully updated libpng."