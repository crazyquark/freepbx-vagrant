#!/bin/bash
cat debug.xml | curl -X POST -d @- http://192.168.8.1/CGI

