CUDA_INSTALL_PATH ?= /usr/local/cuda
GCC_VER =

# Options
NVCCOPTIONS = -arch sm_30

CXX := /usr/bin/g++$(GCC_VER)
CC := /usr/bin/gcc$(GCC_VER)
CCPATH := ./gcc
NVCC  := $(CUDA_INSTALL_PATH)/bin/nvcc -ccbin $(CCPATH)
LINK := $(NVCC) $(NVCCOPTIONS)

# Includes
INCLUDES = -I. -I$(CUDA_INSTALL_PATH)/include

# Libraries
LIB_CUDA := -L/usr/lib/nvidia-current -lcuda

# Common flags
COMMONFLAGS += $(INCLUDES) -std=c++11
NVCCFLAGS += $(COMMONFLAGS) $(NVCCOPTIONS) --expt-extended-lambda
CXXFLAGS += $(COMMONFLAGS)

OBJS = suffixArray.cu.o main.cpp.o
TARGET = exec
LINKLINE = $(LINK) -o $(TARGET) $(OBJS) $(LIB_CUDA)

.SUFFIXES:	.cpp	.cu	.o
%.cu.o: %.cu
	$(NVCC) $(NVCCFLAGS) -c $< -o $@

%.cpp.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): prepare $(OBJS)
	$(LINKLINE)

clean:
	rm -rf $(TARGET) *.o *.ptx

prepare:
	rm -rf $(CCPATH);\
	mkdir -p $(CCPATH);\
	ln -s $(CXX) $(CCPATH)/g++;\
	ln -s $(CC) $(CCPATH)/gcc

.PHONY: clean prepare