#!/usr/bin/env bash

workflowFilePath=/tmp/build_$1.alfredworkflow

cd $1

rm -f $workflowFilePath

zip -rq $workflowFilePath ./*

open $workflowFilePath

