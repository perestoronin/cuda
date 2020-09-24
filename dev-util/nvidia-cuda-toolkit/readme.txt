nvcc -Xcompiler -fPIC -shared test.cu -arch=compute_61 -rdc=true -o implement.so
