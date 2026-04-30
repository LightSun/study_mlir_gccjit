
LLVM_TOOL_DIR=/media/heaven7/Elements_SE/study/tools/LLVM/llvm_install/bin

SRCD=/media/heaven7/Elements_SE/study/mine/TODO/mlir_libgccjit/mlir-gccjit/test

SRC_FILE=${SRCD}/compile/global.mlir

./gccjit-translate -o global.mlir.tmp.gimple ${SRC_FILE} -mlir-to-gccjit-gimple

./gccjit-translate -o global.mlir.tmp.exe ${SRC_FILE} -mlir-to-gccjit-executable

${LLVM_TOOL_DIR}/FileCheck --input-file=global.mlir.tmp.gimple ${SRC_FILE} -check-prefix=CHECK-GIMPLE
#${LLVM_TOOL_DIR}/FileCheck --check-prefix=CHECK-OUTPUT global.mlir.tmp.exe
