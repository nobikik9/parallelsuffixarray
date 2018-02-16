#!/bin/sh

BOX=miracle
ROOT='~/suff'
set -x
rsync -auvR -e ssh . "$BOX:$ROOT"
ssh "$BOX" "cd $ROOT; make && ./exec"
