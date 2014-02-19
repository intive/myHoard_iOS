#!/bin/bash

OBJECT_FILE_DIR=`xctool -sdk iphonesimulator -scheme MyHoard -workspace MyHoard.xcworkspace -configuration Debug -showBuildSettings | grep "OBJECT_FILE_DIR_normal ="`
OBJECT_FILE_DIR=`echo $OBJECT_FILE_DIR | cut -d \= -f 2`
OBJECT_FILE_DIR=$OBJECT_FILE_DIR/i386
OBJECT_FILE_DIR=`echo $OBJECT_FILE_DIR | tr -s " "`
declare -r gcov_dir="$OBJECT_FILE_DIR"

generateGcov()
{
	#  doesn't set output dir to gcov...
	OLDPWD='pwd'
	cd "${gcov_dir}"
	for file in ${gcov_dir}/*.gcda
	do
		gcov-4.2 "${file}" -o "${gcov_dir}"
	done
	cd -
}

copyGcovToProjectDir()
{
	cp -r "${gcov_dir}" gcov
}

removeGcov(){
	rm -r gcov
}

main()
{

# generate + copy
 	generateGcov
	copyGcovToProjectDir
# post
	coveralls -e Pods ${@+"$@"}
# clean up
	removeGcov	
}

main ${@+"$@"}

