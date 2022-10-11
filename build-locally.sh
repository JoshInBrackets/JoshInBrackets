#!/bin/bash
scribble --dest output ++style custom.css --htmls main.scrbl

BASENAME=`dirname $0`
rsync -avr $BASENAME/output/main/ kdr2@kdr2.com:~/joshinbrackets/
