#include "suffixArray.h"

#include <iostream>
#include <string>
#include <ctime>
#include <vector>

int main(int argc, char* argv[])
{
    srand(42);

    int n = std::stoi(argv[1]);
    std::string test;

    for (int i = 0; i < n; i++)
    {
        test += rand() % 2 + '0';
    }

    std::vector<int> a(test.size());
    auto start = std::clock();
    suffixArray(test, a.data());
    auto end = std::clock();

    std::cout << "Time (Parallel Karkkainen): " << (double)(end-start)/CLOCKS_PER_SEC << std::endl;
}
