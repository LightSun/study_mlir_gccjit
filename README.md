# study_mlir_gccjit

## my env
- ubuntu18
- apt install libgccjit-16-dev
- build llvm-mlir. like onnx-mlir
```
git clone -n https://github.com/llvm/llvm-project.git
# Check out a specific branch that is known to work with ONNX-MLIR.
cd llvm-project && git checkout 1053047a4be7d1fece3adaf5e7597f838058c947 && cd ..

mkdir llvm-project/build
cd llvm-project/build

cmake -G Ninja ../llvm \
   -DLLVM_ENABLE_PROJECTS="mlir;clang" \
   -DLLVM_ENABLE_RUNTIMES="openmp" \
   -DLLVM_TARGETS_TO_BUILD="host" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_LIBEDIT=OFF

cmake --build . -- ${MAKEFLAGS}
cmake --build . --target check-mlir
```

## test
```
LLVM_TOOL_DIR=/media/heaven7/Elements_SE/study/tools/LLVM/llvm_install/bin

SRCD=/media/heaven7/Elements_SE/study/mine/TODO/mlir_libgccjit/mlir-gccjit/test

SRC_FILE=${SRCD}/compile/global.mlir

./gccjit-translate -o global.mlir.tmp.gimple ${SRC_FILE} -mlir-to-gccjit-gimple

./gccjit-translate -o global.mlir.tmp.exe ${SRC_FILE} -mlir-to-gccjit-executable

${LLVM_TOOL_DIR}/FileCheck --input-file=global.mlir.tmp.gimple ${SRC_FILE} -check-prefix=CHECK-GIMPLE
//global.mlir.tmp.exe: is executable
```
