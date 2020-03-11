#! /bin/bash
# auther:uweiyuan
# version:1.0.0
printf "====================\n\n\nEx:\n$0 object1.o object2.o lib.a\n\n\n====================\n"
# argument number
argumentCount=$#
if [ "$argumentCount" -lt 2 ]; then
	echo "[ Tips: Please refer to the example above! ]"
	exit 1
fi
# last object must be library file
libraryIndex=$(($argumentCount - 1))
# arm types
arms=(armv7 arm64 i386 x86_64)
IFS=' '
# get all arguments for command lie
arguments=($*)
libraryPath=${arguments[libraryIndex]}
if [ ! -f "$libraryPath" ]; then
	echo "[ Error: not found target file! ]"
	exit 1
fi

# get library name
libraryName=""
tmpLibraryName=""
# use pattern to search directory
if [[ $libraryPath =~ "/" ]]; then
	libraryName=${libraryPath##*/}
	tmpLibraryName=${libraryPath%/*}/"tmp"$libraryName
	cp $libraryPath ${libraryPath%/*}/"tmp"$libraryName

else
	libraryName=$libraryPath
	tmpLibraryName="tmp"$libraryName
	cp $libraryPath "tmp"$libraryName
fi

# check library is empty
if [ -z $libraryName ]; then
	echo "[ Error: Not find library! ]"
	exit 1
fi

# thin library files
thinLibraryList=()

for arm in "${arms[@]}"; do
	index=0
	for item in "${arguments[@]}"; do
		if [ $index == $libraryIndex ]; then
			break
		else
			libraryLength=${#tmpLibraryName}
			name=${tmpLibraryName:0:$(($libraryLength - 2))}

			thinLibraryName=$name$arm".a"

			# create thin library
			lipo $tmpLibraryName -thin $arm -o $thinLibraryName

			# remove the object file from the above thin library
			# redirect the stderr to stdout
			arResult=$(ar -d $thinLibraryName $item 2>&1)

			# check error from stdout
			if [ -n "$arResult" ]; then
				echo "The $item not found in $arm file!"
			else
				echo "The $item found in $arm file and removed it!"
			fi

			thinLibraryList+=($thinLibraryName)
		fi
		((index++))
	done
done

thinLibraryString=""
for thinLib in ${thinLibraryList[*]}; do
	thinLibraryString=" "$thinLib$thinLibraryString
done

stringLength=${#thinLibraryString}
thinLibraryString=${thinLibraryString:1:stringLength}

# create new library file
newLibraryName="new"$libraryName
outputNewLibraryPath=""
if [[ $libraryPath =~ "/" ]]; then
	outputNewLibraryPath=${libraryPath%/*}/$newLibraryName
else
	outputNewLibraryPath=$newLibraryName
fi

lipo -create $thinLibraryString -o $outputNewLibraryPath
echo "Clip $libraryPath to $outputNewLibraryPath done!"

# remove the temporary file
for tmp in ${thinLibraryList[*]}; do
	rm $tmp
done
rm $tmpLibraryName
