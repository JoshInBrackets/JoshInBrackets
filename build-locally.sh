#!/bin/bash
scribble --dest output ++style custom.css index.scrbl

BASENAME=`dirname $0`
rsync -avr $BASENAME/output/ kdr2@kdr2.com:~/joshinbrackets/
