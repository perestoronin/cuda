nvcc -Xcompiler -fPIC -shared test.cu -arch=compute_35 -rdc=true -o implement.so
