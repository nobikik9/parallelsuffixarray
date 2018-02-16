#include "suffixArray.h"

#include <iostream>
#include <string>
#include <ctime>
#include <vector>

int main(int argc, char* argv[])
{
    srand(std::stoi(argv[1]));

    int n = rand() % 1000 + 1;
    std::string test;

    for (int i = 0; i < n; i++)
    {
        test += rand() % 26 + 'a';
    }

    std::vector<int> a(test.size());
    suffixArray(test, a.data());

    std::cout << test << std::endl;

    for (auto& element : a)
    {
        std::cout << element << ' ';
    }
    std::cout << std::endl;
}
