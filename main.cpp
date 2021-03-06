#include "suffixArray.h"

#include <iostream>
#include <string>
#include <ctime>
#include <vector>

int main()
{
    int n = 10;
    std::string test;
    for (int i = 0; i < n; i++)
    {
        test += rand() % 2 + '0';
    }
    std::vector<int> a(test.size());
    suffixArray(test, a.data());
    std::cout << "For string '" << test << "' suffix array is: ";
    for (int i=0; i<static_cast<int>(test.size()); i++)
    {
        std::cout << a[i] << ' ';
    }
    std::cout << std::endl;
}
