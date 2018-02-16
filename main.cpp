#include "suffixArray.h"

#include <iostream>
#include <string>
#include <ctime>
#include <vector>

void test()
{
    std::cout << "Hello world!" << std::endl;
    int T[100];
    std::string test = "abacaba";
    suffixArray(test, T);
    std::cout << "For string '" << test << "' suffix array is: ";
    for (int i=0; i<static_cast<int>(test.size()); i++)
    {
        std::cout << T[i] << ' ';
    }
    std::cout << std::endl;
}

int main(int argc, char* argv[])
{

    std::string test = "abacabadabacaba";

    int print = 0;

    for (int i = 0; i < 10000; i++)
    {
        test += rand() % 2 + '0';
    }

    auto start = std::clock();

    std::vector<int> a(test.size());
    suffixArray(test, a.data());

    auto end = std::clock();

    std::cout << "Time: " << (double)(end-start)/CLOCKS_PER_SEC << std::endl;

    if (print) {
        std::cout << "For string '" << test << "' suffix array is: ";
        for (int i=0; i<static_cast<int>(test.size()); i++)
        {
            std::cout << a[i] << ' ';
        }
        std::cout << std::endl;
    }
}
