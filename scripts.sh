#!/bin/bash
set -e # exit when any command fails
echo - What you want to do ?
PS3='Your choice: '
OPTIONS_1=$(printf "\e[31m\e[1mRun Test\e[0m")
OPTIONS_2=$(printf "\e[31m\e[1mDeploy\e[0m (Test and Deploy)")
MENU_OPTIONS=( "$OPTIONS_1" "$OPTIONS_2" )
select result in "${MENU_OPTIONS[@]}"; do
    case $REPLY in
        [12]) choice=$REPLY; echo ""; break;;
        *) echo 'Invalid choice' >&2
    esac
done

runTest() {
	flutter test test/*
}

getVersion() {
	file_properties="./android/key.properties"
	if [ -f "$file_properties" ]; then
	  while IFS='=' read -r key value
	  do
	    key=$(echo $key | tr '.' '_')
	    value=$(echo $value)
	    eval ${key}=\${value}
	  done < "$file_properties"

	  echo "$flutter_versionCode ($flutter_versionName)"
	else
	  echo "$file_properties not found."
	fi
}

if [ $choice = 1 ]; then
	 runTest
elif [ $choice = 2 ]; then
	# runTest
	version=$(getVersion)
	read -p "Are you sure to publish version ${version}? [y/N] " -n 1 -r
	echo # Move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		printf "\e[34m\e[1m Running Build!\e[0m"
		echo # Move to a new line
		flutter build appbundle --release
		npm --prefix=./publisher run start production "${version}"
		printf "\e[32m\e[1mScript Completed!\e[0m"
	else
		echo "Script abort!"
	fi
fi

exit
