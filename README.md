# README #

This is a simple implementation of parallel version of Karkkainen's algorithm (sequential version has complexity **O(N)**) for computing suffix array. 
It was written using thrust library.

### How to use ###
Just use `make`.

### Dependencies ###
CUDA SDK with [thrust](https://github.com/thrust/thrust).

### Authors ###
* Rafał Burczyński
* Vladyslav Hlembotskyi

### Notes ###
Main code is in suffixArray.cu, sequential implementation was taken from ICPC Jagiellonian Team Reference Document.
