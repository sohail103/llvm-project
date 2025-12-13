// this file describes the RISC V instructions in tablegen format
#include "ShaktiInstrFormats.td"

class ImmXLenAsmOperand<string prefix, string suffix = ""> : AsmOperandClass {
    let Name = prefix # "ImmXLen" # suffix;
    let RenderMethod = "addImmOperands";
    let DiagnosticType = !strconcat("Invalid", Name);
}

class ImmAsmOperand<string prefix, int width, string suffix> : AsmOperandClass {
  let Name = prefix # "Imm" # width # suffix;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def ImmZeroAsmOperand : AsmOperandClass {
  let Name = "ImmZero";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
  let DiagnosticString = "immediate must be zero";
}

// A parse method for (${gpr}) or 0(${gpr}), where the 0 is be silently ignored.
def ZeroOffsetMemOpOperand : AsmOperandClass {
  let Name = "ZeroOffsetMemOpOperand";
  let RenderMethod = "addRegOperands";
  let PredicateMethod = "isGPR";
  let ParserMethod = "parseZeroOffsetMemOp";
}

class MemOperand<RegisterClass regClass> : RegisterOperand<regClass>{
  let OperandType = "OPERAND_MEMORY";
}

def GPRMemZeroOffset : MemOperand<GPR> {
  let ParserMatchClass = ZeroOffsetMemOpOperand;
  let PrintMethod = "printZeroOffsetMemOp";
}

def GPRMem : MemOperand<GPR>;

def SPMem : MemOperand<SP>;

def GPRCMem : MemOperand<GPRC>;

// signed immediate
class SImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"S", width, suffix> {
}

// unsigned immediate
class UImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"U", width, suffix> {
}

// class for even numbers (lsb 0) (bare => raw integer)
// required for branch offsets - 2 byte aligned
class BareSImmNLsb0AsmOperand<int width>
    : ImmAsmOperand<"BareS", width, "Lsb0"> {
  let PredicateMethod = "isBareSimmNLsb0<" # width # ">";
}

// for operands of arbitrary lengths
class RISCVOp<ValueType vt = XLenVT> : Operand<vt> {
  let OperandNamespace = "RISCVOp";
}

class RISCVUImmOp<int bitsNum> : RISCVOp {
  let ParserMatchClass = UImmAsmOperand<bitsNum>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeUImmOperand<" # bitsNum # ">";
  let OperandType = "OPERAND_UIMM" # bitsNum;
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    return isUInt<}]# bitsNum #[{>(Imm);
  }];
}

class RISCVUImmLeafOp<int bitsNum> :
  RISCVUImmOp<bitsNum>, ImmLeaf<XLenVT, "return isUInt<" # bitsNum # ">(Imm);">;

class RISCVSImmOp<int bitsNum> : RISCVOp {
  let ParserMatchClass = SImmAsmOperand<bitsNum>;
  let EncoderMethod = "getImmOpValue";
  let DecoderMethod = "decodeSImmOperand<" # bitsNum # ">";
  let OperandType = "OPERAND_SIMM" # bitsNum;
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    return isInt<}] # bitsNum # [{>(Imm);
  }];
}

class RISCVSImmLeafOp<int bitsNum> :
  RISCVSImmOp<bitsNum>, ImmLeaf<XLenVT, "return isInt<" # bitsNum # ">(Imm);">;

def FenceArg : AsmOperandClass {                // this definition is for the FENCE instruction
  let Name = "FenceArg";                        // fence instruction is tricky because it takes 2 strings that represent bitmasks
  let RenderMethod = "addFenceArgOperands";     // have to write custom parsing logic
  let ParserMethod = "parseFenceArg";
}

def fencearg : RISCVOp {
  let ParserMatchClass = FenceArg;
  let PrintMethod = "printFenceArg";
  let DecoderMethod = "decodeUImmOperand<4>";
  let OperandType = "OPERAND_UIMM4";
}

def UImmLog2XLenAsmOperand : AsmOperandClass {
  let Name = "UImmLog2XLen";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidUImmLog2XLen";
}

def uimmlog2xlen : RISCVOp, ImmLeaf<XLenVT, [{      // bit shifts in 32 bit processors need a 5 bit shift but 6 bits in a 64 bit processor
  if (Subtarget->is64Bit())
    return isUInt<6>(Imm);
  return isUInt<5>(Imm);
}]> {
  let ParserMatchClass = UImmLog2XLenAsmOperand;
  let DecoderMethod = "decodeUImmLog2XLenOperand";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    if (STI.getTargetTriple().isArch64Bit())
      return isUInt<6>(Imm);
    return isUInt<5>(Imm);
  }];
  let OperandType = "OPERAND_UIMMLOG2XLEN";
}

def InsnDirectiveOpcode : AsmOperandClass {
  let Name = "InsnDirectiveOpcode";
  let ParserMethod = "parseInsnDirectiveOpcode";
  let RenderMethod = "addImmOperands";
  let PredicateMethod = "isImm";
}

def uimm1 : RISCVUImmLeafOp<1>;
def uimm2 : RISCVUImmLeafOp<2>;
def uimm3 : RISCVUImmLeafOp<3>;
def uimm4 : RISCVUImmLeafOp<4>;
def uimm5 : RISCVUImmLeafOp<5>;
def uimm6 : RISCVUImmLeafOp<6>;
def uimm7_opcode : RISCVUImmOp<7> {
  let ParserMatchClass = InsnDirectiveOpcode;
}
def uimm7 : RISCVUImmLeafOp<7>;
def uimm8 : RISCVUImmOp<8>;
def uimm16 : RISCVUImmOp<16>;
def uimm32 : RISCVUImmOp<32>;
def uimm48 : RISCVUImmOp<48>;
def uimm64 : RISCVUImmOp<64>;

def simm12_lo : RISCVSImmLeafOp<12> {
  let ParserMatchClass = SImmAsmOperand<12, "LO">;
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<12>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

// A 12-bit signed immediate which cannot fit in 6-bit signed immediate,
// but even negative value fit in 12-bit.
def simm12_no6 : ImmLeaf<XLenVT, [{
  return isInt<12>(Imm) && !isInt<6>(Imm) && isInt<12>(-Imm);}]>;

class BareSImm13Lsb0MaybeSym : Operand<OtherVT> {
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isShiftedInt<12, 1>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

// A 13-bit signed immediate where the least significant bit is zero. The ImmLeaf
// is needed so that the CompressInstEmitter can correctly add checks for the
// compress patterns that involve instructions that use this operand. Similar to
// bare_simm9_lsb0 in RISCVInstrInfoC.td.
def bare_simm13_lsb0 : BareSImm13Lsb0MaybeSym,
                       ImmLeaf<XLenVT, [{return isShiftedInt<12, 1>(Imm);}]> {
  let ParserMatchClass = BareSImmNLsb0AsmOperand<13>;
  let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getImmOpValueAsrN<1>";
  let DecoderMethod = "decodeSImmOperandAndLslN<13, 1>";
  let OperandType = "OPERAND_PCREL";
}

// We need this (sort of) duplicate definition since adding ImmLeaf to
// bare_simm13_lsb0 above makes it not sit well with codegen patterns where it
// is used to match with a basic block (eg. BccPat<>).
def bare_simm13_lsb0_bb : BareSImm13Lsb0MaybeSym;

class UImm20OperandMaybeSym : RISCVUImmOp<20> {
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isUInt<20>(Imm);
    return MCOp.isBareSymbolRef();
  }];
}

def uimm20_lui : UImm20OperandMaybeSym {
  let ParserMatchClass = UImmAsmOperand<20, "LUI">;
}
def uimm20_auipc : UImm20OperandMaybeSym {
  let ParserMatchClass = UImmAsmOperand<20, "AUIPC">;
}

def uimm20 : RISCVUImmOp<20>;

def Simm21Lsb0JALAsmOperand : BareSImmNLsb0AsmOperand<21> {
  let ParserMethod = "parseJALOffset";
}

// A 21-bit signed immediate where the least significant bit is zero.
def simm21_lsb0_jal : Operand<OtherVT>,
                      ImmLeaf<XLenVT, [{return isShiftedInt<20, 1>(Imm);}]>  {
  let ParserMatchClass = Simm21Lsb0JALAsmOperand;
  let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getImmOpValueAsrN<1>";
  let DecoderMethod = "decodeSImmOperandAndLslN<21, 1>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isShiftedInt<20, 1>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  let OperandType = "OPERAND_PCREL";
}

def BareSymbol : AsmOperandClass {
  let Name = "BareSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidBareSymbol";
  let DiagnosticString = "operand must be a bare symbol name";
  let ParserMethod = "parseBareSymbol";
}

// A bare symbol.
def bare_symbol : Operand<XLenVT> {
  let ParserMatchClass = BareSymbol;
}

def CallSymbol : AsmOperandClass {
  let Name = "CallSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidCallSymbol";
  let DiagnosticString = "operand must be a bare symbol name";
  let ParserMethod = "parseCallSymbol";
}

// A bare symbol used in call/tail only.
def call_symbol : Operand<XLenVT> {
  let ParserMatchClass = CallSymbol;
}

def PseudoJumpSymbol : AsmOperandClass {
  let Name = "PseudoJumpSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidPseudoJumpSymbol";
  let DiagnosticString = "operand must be a valid jump target";
  let ParserMethod = "parsePseudoJumpSymbol";
}

// A bare symbol used for pseudo jumps only.
def pseudo_jump_symbol : Operand<XLenVT> {
  let ParserMatchClass = PseudoJumpSymbol;
}

def TPRelAddSymbol : AsmOperandClass {
  let Name = "TPRelAddSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidTPRelAddSymbol";
  let DiagnosticString = "operand must be a symbol with %tprel_add specifier";
  let ParserMethod = "parseOperandWithSpecifier";
}

// A bare symbol with the %tprel_add variant.
def tprel_add_symbol : Operand<XLenVT> {
  let ParserMatchClass = TPRelAddSymbol;
}

def CSRSystemRegister : AsmOperandClass {
  let Name = "CSRSystemRegister";
  let ParserMethod = "parseCSRSystemRegister";
  let DiagnosticType = "InvalidCSRSystemRegister";
}

def csr_sysreg : RISCVOp, TImmLeaf<XLenVT, "return isUInt<12>(Imm);"> {
  let ParserMatchClass = CSRSystemRegister;
  let PrintMethod = "printCSRSystemRegister";
  let DecoderMethod = "decodeUImmOperand<12>";
  let OperandType = "OPERAND_UIMM12";
}

// A parameterized register class alternative to i32imm/i64imm from Target.td.
def ixlenimm : Operand<XLenVT>;

