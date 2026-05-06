#ifndef GCCJIT_DIALECT
#define GCCJIT_DIALECT

include "mlir/IR/OpBase.td"

//
def GCCJIT_Dialect : Dialect {
  let name = "gccjit";

  let summary = "Dialect for libgccjit";
  let description = [{
    The gccjit dialect allows you to generate code with libgccjit through MLIR.
  }];

  let cppNamespace = "::mlir::gccjit";

  //设置为 0 表示不使用默认的属性/类型打印与解析器
  let useDefaultAttributePrinterParser = 0;
  let useDefaultTypePrinterParser = 0;
  //依赖方言
  let dependentDialects = [
    "::mlir::BuiltinDialect",
    "::mlir::func::FuncDialect",
  ];
  //额外的类定义. 属性和类型： 注册，解析，打印
  let extraClassDeclaration = [{
    void registerTypes();
    void registerAttributes();
    Type parseType(DialectAsmParser &parser) const override;
    void printType(Type type, DialectAsmPrinter &printer) const override;
    Attribute parseAttribute(DialectAsmParser &parser,
                             Type type) const override;

    void printAttribute(Attribute attr, DialectAsmPrinter &os) const override;
  }];
}

class GCCJIT_Op<string mnemonic, list<Trait> traits = []>
    : Op<GCCJIT_Dialect, mnemonic, traits>;

#endif // GCCJIT_DIALECT
