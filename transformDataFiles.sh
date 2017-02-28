#!/bin/bash
# This removes the quotes from the numeric columns of all the input files
# No need to run again, the data files have already been corrected

for file in `ls data/Method`; do
  data/strings2nums.sh "data/Method/$file"
done
for file in `ls data/Class`; do
  data/strings2nums.sh "data/Class/$file"
done
for file in `ls data/Package`; do
  data/strings2nums.sh "data/Package/$file"
done

mv data/Method/owncloud_android-Method.csv data/Method/android-Method.csv
mv data/Class/owncloud_android-Class.csv data/Class/android-Class.csv
mv data/Package/owncloud_android-Package.csv data/Package/android-Package.csv
