#!/bin/bash
if [ -z "$1" ]; then
    echo "usage: ./test_correctness.sh number_of_tests"
    exit 1
fi
make corr
g++ -std=c++14 kmr_corr.cpp -o kmr_corr
for ((i = 0; i < ($1); ++i)); do
    ./corr $i > corr.out
    ./kmr_corr $i > kmr_corr.out
    cmp -s corr.out kmr_corr.out && echo 'OK' || echo 'WA'
done
rm -rf corr.out
rm -rf kmr_corr.out
rm -r kmr_corr
echo "DONE"

