#ifndef __CUDAWRAPPER_H__
#define __CUDAWRAPPER_H__

#include <stdexcept>

#include <cuda.h>

class CtxWrapper
{

public:
    explicit CtxWrapper(const char* moduleName)
    {
        cuInit(0);
        tryFunc(cuDeviceGet, &device, 0);
        tryFunc(cuCtxCreate, &context, 0, device);
        tryFunc(cuModuleLoad, &module, moduleName);
    }

    CUfunction getFunction(const char* func)
    {
        CUfunction ret;
        tryFunc(cuModuleGetFunction, &ret, module, func);
        return ret;
    }

    template<typename F, typename... Ts>
    static void tryFunc(const F& f, Ts&&... args)
    {
        const auto result = f(std::forward<Ts>(args)...);
        if (result != CUDA_SUCCESS){
            const char *c1, *c2;
            cuGetErrorName(result, &c1);
            cuGetErrorString(result, &c2);
            throw std::runtime_error(std::string(c1) + ": " + std::string(c2));
        }
    }

private:
    CUdevice device;
    CUmodule module;
    CUcontext context;
};

#endif
