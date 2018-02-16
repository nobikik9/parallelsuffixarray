#!/bin/bash
ulimit -s 2000000
make fast
g++ -std=c++14 -Ofast fastKarakan.cpp -o fastKarakan
g++ -std=c++14 -Ofast kmr.cpp -o kmr
rm speed.txt
for ((i = 5; i <= 50000000; i *= 10)); do
    echo "Testing... Length = $i"
    echo "Random string of size $i" >> speed.txt
    ./fast $i >> speed.txt
    ./fastKarakan $i >> speed.txt
    ./kmr $i >> speed.txt
done
rm -rf kmr 
rm -rf fastKarakan
echo "DONE"
