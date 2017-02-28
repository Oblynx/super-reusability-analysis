#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Syntax: $0 <filename>";
fi

sed -i 's/"\([0-9]\+\.\?[0-9]*\)"/\1/g' $@
