set(LLVM_DIR /media/heaven7/Elements_SE/study/tools/LLVM/llvm_install)
set(ENV{PATH} "${LLVM_DIR}/bin;$ENV{PATH}")
set(MLIR_DIR ${LLVM_DIR}/lib/cmake/mlir)
#
find_package(MLIR REQUIRED CONFIG)
list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

include(TableGen)
include(AddLLVM)
include(AddMLIR)
include(HandleLLVMOptions)

include_directories(${LLVM_INCLUDE_DIRS} ${MLIR_INCLUDE_DIRS})
