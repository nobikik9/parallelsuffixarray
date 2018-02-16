#!/bin/sh

BOX=z1121415@miracle.tcs.uj.edu.pl
ROOT='~/suff'
set -x
rsync -auvR -e ssh . "$BOX:$ROOT"
ssh "$BOX" "cd $ROOT; make && ./exec"
