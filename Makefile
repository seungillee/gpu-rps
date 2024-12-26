IDIR=./
COMPILER=nvcc
COMPILER_FLAGS=-I$(IDIR) -I/usr/local/cuda/include -lcuda --std c++17

.PHONY: clean build run

build: rps.cu
	$(COMPILER) $(COMPILER_FLAGS) rps.cu -o rps.exe -Wno-deprecated-gpu-targets

run:
	./rps.exe
	

clean:
	rm -f multi_gpu.exe

all: clean build run

