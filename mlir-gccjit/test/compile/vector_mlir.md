
# vector.mlir 函数 alpha_flipcase_small 类似下面这段c代码

void __attribute__((always_inline)) alpha_flipcase_small(char *str, size_t len) {
    const char c32 = 32;
    const size_t zero = 0;
    const size_t one = 1;

    size_t iter;
    iter = zero;

loop_header:
    if (iter == len)
        goto loop_exit;

loop_body:
    // 取 str[iter] 并翻转大小写
    str[iter] ^= c32;
    iter++;
    goto loop_header;

loop_exit:
    return;
}

// 等价 C 语言（SIMD 矢量优化）
void alpha_flipcase(char *str, size_t len) {
    // 16 字节矢量常量：[32,32,...32]（共16个）
    typedef char __attribute__((vector_size(16))) vec16char;
    const vec16char vec32 = {32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32};

    size_t iter = 0;
    // 矢量循环：每次处理 16 字节
    while (len - iter >= 16) {
        vec16char *p = (vec16char *)&str[iter];
        *p ^= vec32;  // 一次翻转 16 个字符！
        iter += 16;
    }
    // 剩余字节调用标量版处理
    alpha_flipcase_small(&str[iter], len - iter);
}

### 用 MIR作为后端
```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mir.h"

int main() {
    // ==============================
    // 1. 初始化 MIR JIT
    // ==============================
    MIR_context_t ctx = MIR_init();
    MIR_set_interp_interface(ctx, NULL);

    // ==============================
    // 2. 创建函数：alpha_flipcase_small(char* ptr, size_t len)
    // ==============================
    MIR_item_t func = MIR_new_func(ctx, "alpha_flipcase_small", 2);
    MIR_set_func_param(ctx, func, 0, MIR_T_P);
    MIR_set_func_param(ctx, func, 1, MIR_T_N);

    // ==============================
    // 3. 创建基本块
    // ==============================
    MIR_label_t entry = MIR_new_label(ctx, "entry");
    MIR_label_t loop_header = MIR_new_label(ctx, "loop_header");
    MIR_label_t loop_body = MIR_new_label(ctx, "loop_body");
    MIR_label_t loop_exit = MIR_new_label(ctx, "loop_exit");

    // ==============================
    // 4. 函数体开始
    // ==============================
    MIR_start_func(ctx, func);

    // ------------------------------
    // entry 块
    // ------------------------------
    MIR_emit_label(ctx, entry);

    // 局部变量 %iter = 0
    MIR_reg_t iter = MIR_new_reg(ctx, MIR_T_N, "iter");
    MIR_emit_mov_i(ctx, iter, 0);

    // goto loop_header
    MIR_emit_jmp(ctx, loop_header);

    // ------------------------------
    // loop_header 块
    // ------------------------------
    MIR_emit_label(ctx, loop_header);

    // %cond = iter == len
    MIR_reg_t cond = MIR_new_reg(ctx, MIR_T_B, "cond");
    MIR_emit_cmpeq(ctx, cond, iter, MIR_get_func_param(ctx, func, 1));

    // if (cond) goto exit else body
    MIR_emit_jcc(ctx, cond, loop_exit, loop_body);

    // ------------------------------
    // loop_body 块
    // ------------------------------
    MIR_emit_label(ctx, loop_body);

    // ptr + iter → addr
    MIR_reg_t addr = MIR_new_reg(ctx, MIR_T_P, "addr");
    MIR_emit_add(ctx, addr, MIR_get_func_param(ctx, func, 0), iter);

    // load *addr
    MIR_reg_t c = MIR_new_reg(ctx, MIR_T_B1, "c");
    MIR_emit_ld1(ctx, c, addr, 0);

    // c ^= 32
    MIR_reg_t c32 = MIR_new_reg(ctx, MIR_T_B1, "c32");
    MIR_emit_mov_i(ctx, c32, 32);
    MIR_emit_xor(ctx, c, c, c32);

    // store back
    MIR_emit_st1(ctx, c, addr, 0);

    // iter++
    MIR_emit_add_i(ctx, iter, iter, 1);

    // goto loop_header
    MIR_emit_jmp(ctx, loop_header);

    // ------------------------------
    // loop_exit
    // ------------------------------
    MIR_emit_label(ctx, loop_exit);
    MIR_emit_ret(ctx);

    // ==============================
    // 5. 结束函数并编译 JIT
    // ==============================
    MIR_finish_func(ctx);
    MIR_finish_module(ctx);

    // 编译成机器码
    MIR_compile(ctx);

    // 获取函数指针
    void (*jit_flip)(char*, size_t) = MIR_get_func_addr(ctx, "alpha_flipcase_small");

    // ==============================
    // 6. 测试运行！
    // ==============================
    char str[] = "HELLO WORLD!";
    printf("before: %s\n", str);

    jit_flip(str, strlen(str));

    printf("after:  %s\n", str);

    // 释放
    MIR_finish(ctx);
    return 0;
}
```
