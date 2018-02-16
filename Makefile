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
COMMONFLAGS += $(INCLUDES) -std=c++11 -O2
NVCCFLAGS += $(COMMONFLAGS) $(NVCCOPTIONS) --expt-extended-lambda
CXXFLAGS += $(COMMONFLAGS)

EXEC_OBJ = main.cpp.o
CORR_OBJ = corr.cpp.o
FAST_OBJ = fast.cpp.o
OBJS = suffixArray.cu.o

.SUFFIXES:	.cpp	.cu	.o
%.cu.o: %.cu
	$(NVCC) $(NVCCFLAGS) -c $< -o $@

%.cpp.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

exec: prepare $(EXEC_OBJ) $(OBJS)
	$(LINK) -o exec $(OBJS) $(EXEC_OBJ) $(LIB_CUDA)

fast: prepare $(FAST_OBJ) $(OBJS)
	$(LINK) -o fast $(OBJS) $(FAST_OBJ) $(LIB_CUDA)

corr: prepare $(CORR_OBJ) $(OBJS)
	$(LINK) -o corr $(OBJS) $(CORR_OBJ) $(LIB_CUDA)

clean:
	rm -rf $(TARGET) *.o *.ptx

prepare:
	rm -rf $(CCPATH);\
	mkdir -p $(CCPATH);\
	ln -s $(CXX) $(CCPATH)/g++;\
	ln -s $(CC) $(CCPATH)/gcc

.PHONY: clean prepare