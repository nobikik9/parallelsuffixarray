#!/bin/sh

BOX=miracle
ROOT='~/suff'

rsync -auvR -e ssh . "$BOX:$ROOT"
ssh "$BOX" "cd $ROOT; make && ./exec"
