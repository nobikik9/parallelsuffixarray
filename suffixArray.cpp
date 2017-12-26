#include "suffixArray.h"

#include "cudaWrapper.h"

#include <iostream>
#include <memory>
#include <stdexcept>

namespace
{
    constexpr std::size_t BLOCK_SIZE = 1024;
}

void suffixArray(const std::string& in, int* out)
{
    try
    {
        CtxWrapper ctx("suffixArray.ptx");
        const std::size_t size23 = (2 * in.length() + 4) / 3;
        auto S23 = std::make_unique<int[]>(size23);
    }
    catch (const std::exception& ex)
    {
        std::cerr << ex.what() << std::endl;
    }
}
