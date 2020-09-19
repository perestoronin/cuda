#include <cuda.h>
#ifndef CUDA_VERSION
#error CUDA_VERSION undefined
#elif CUDA_VERSION < 3020
#error CUDA_VERSION too old
#endif

int i = 3;

