#!/bin/bash

# use .exe or not
which racket.exe > /dev/null
if [[ $? -eq 0 ]]; then
    EXT=.exe
else
    EXT=
fi

scribble$EXT --dest output ++style src/custom.css --htmls scribble/main.scrbl

if [[ "$1" == "sync" ]]; then
    cat <<EOF

[WARNING]
Since GitHub Action has been setup, we don't synchronize the output with
this script, if it is really needed, please run the command below:

EOF
   echo rsync -avr output/main/ kdr2@kdr2.com:~/joshinbrackets/
fi
