// this file describes the RISC V instructions in tablegen format
include "ShaktiInstrFormats.td"
include "ShaktiInstrFormatsC.td" // have to write additional logic in parser
//#include "ShaktiInstrFormatsV.td" // dont need V instructions

class RVSDNode<string opcode, SDTypeProfile type_profile,
               list<SDNodeProperty> properties = []>
    : SDNode<"RISCVISD::" # opcode, type_profile, properties> {
  bit HasPassthruOp = false;
  bit HasMaskOp = false;
  let TSFlags{0} = HasPassthruOp;
  let TSFlags{1} = HasMaskOp;
}

// Target-independent type requirements, but with target-specific formats.
def SDT_CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>,
                                       SDTCisVT<1, i32>]>;
def SDT_CallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>,
                                     SDTCisVT<1, i32>]>;

// Target-dependent type requirements.
def SDT_RISCVCall     : SDTypeProfile<0, -1, [SDTCisVT<0, XLenVT>]>;
def SDT_RISCVSelectCC : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                             SDTCisVT<3, OtherVT>,
                                             SDTCisSameAs<0, 4>,
                                             SDTCisSameAs<4, 5>]>;
def SDT_RISCVBrCC : SDTypeProfile<0, 4, [SDTCisSameAs<0, 1>,
                                         SDTCisVT<2, OtherVT>,
                                         SDTCisVT<3, OtherVT>]>;
def SDT_RISCVIntUnaryOpW : SDTypeProfile<1, 1, [
  SDTCisSameAs<0, 1>, SDTCisVT<0, i64>
]>;
def SDT_RISCVIntBinOpW : SDTypeProfile<1, 2, [
  SDTCisSameAs<0, 1>, SDTCisSameAs<0, 2>, SDTCisVT<0, i64>
]>;

// Target-independent nodes, but with target-specific formats.
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_CallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_CallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def riscv_call      : RVSDNode<"CALL", SDT_RISCVCall,
                               [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                                SDNPVariadic]>;
def riscv_tail      : RVSDNode<"TAIL", SDT_RISCVCall,
                               [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                                SDNPVariadic]>;

// Software guarded calls for large code model
def riscv_sw_guarded_call : RVSDNode<"SW_GUARDED_CALL", SDT_RISCVCall,
                                     [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                                      SDNPVariadic]>;
def riscv_sw_guarded_tail : RVSDNode<"SW_GUARDED_TAIL", SDT_RISCVCall,
                                     [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                                      SDNPVariadic]>;

def riscv_ret_glue  : RVSDNode<"RET_GLUE", SDTNone,
                               [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def riscv_sret_glue : RVSDNode<"SRET_GLUE", SDTNone,
                               [SDNPHasChain, SDNPOptInGlue]>;
def riscv_mret_glue : RVSDNode<"MRET_GLUE", SDTNone,
                               [SDNPHasChain, SDNPOptInGlue]>;
def riscv_mnret_glue : RVSDNode<"MNRET_GLUE", SDTNone,
                                [SDNPHasChain, SDNPOptInGlue]>;
def riscv_mileaveret_glue : RVSDNode<"QC_C_MILEAVERET_GLUE", SDTNone,
                                     [SDNPHasChain, SDNPOptInGlue]>;

// Select with condition operator - This selects between a true value and
// a false value (ops #3 and #4) based on the boolean result of comparing
// the lhs and rhs (ops #0 and #1) of a conditional expression with the
// condition code in op #2, a XLenVT constant from the ISD::CondCode enum.
// The lhs and rhs are XLenVT integers. The true and false values can be
// integer or floating point.
def riscv_selectcc  : RVSDNode<"SELECT_CC", SDT_RISCVSelectCC>;
def riscv_brcc      : RVSDNode<"BR_CC", SDT_RISCVBrCC,
                               [SDNPHasChain]>;

// Software guarded BRIND node. Operand is the target address.
def riscv_sw_guarded_brind : RVSDNode<"SW_GUARDED_BRIND",
                                      SDTBrind, [SDNPHasChain]>;

// RV64I shifts, directly matching the semantics of the named RISC-V
// instructions.
def riscv_sllw      : RVSDNode<"SLLW", SDT_RISCVIntBinOpW>;
def riscv_sraw      : RVSDNode<"SRAW", SDT_RISCVIntBinOpW>;
def riscv_srlw      : RVSDNode<"SRLW", SDT_RISCVIntBinOpW>;

// Reads value of CSR. The first operand is the address of the required CSR.
// The result is the read value.
def riscv_read_csr  : RVSDNode<"READ_CSR",
                               SDTypeProfile<1, 1, [SDTCisInt<0>,
                                                    SDTCisInt<1>]>,
                               [SDNPHasChain]>;
// Write value to CSR. The first operand is the address of the required CSR,
// the second is the value to write.
def riscv_write_csr : RVSDNode<"WRITE_CSR",
                               SDTypeProfile<0, 2, [SDTCisInt<0>,
                                                    SDTCisInt<1>]>,
                               [SDNPHasChain]>;

// Read and write value of CSR. The first operand is the address of the
// required CSR, the second is the value to write, and the result is the
// read value (before modification).
def riscv_swap_csr  : RVSDNode<"SWAP_CSR",
                               SDTypeProfile<1, 2, [SDTCisInt<0>,
                                                    SDTCisInt<1>,
                                                    SDTCisInt<2>]>,
                               [SDNPHasChain]>;

// Clear bits of CSR. The first operand is the address of the required CSR,
// the second is the bitmask of cleared bits.
def riscv_clear_csr  : RVSDNode<"CLEAR_CSR",
                               SDTypeProfile<0, 2, [SDTCisInt<0>,
                                                    SDTCisInt<1>]>,
                               [SDNPHasChain]>;

// Set bits of CSR. The first operand is the address of the required CSR,
// the second is the bitmask of bits to set.
def riscv_set_csr  : RVSDNode<"SET_CSR",
                               SDTypeProfile<0, 2, [SDTCisInt<0>,
                                                    SDTCisInt<1>]>,
                               [SDNPHasChain]>;

// A read of the 64-bit counter CSR on a 32-bit target (returns (Lo, Hi)).
// It takes a chain operand and another two target constant operands (the
// CSR numbers of the low and high parts of the counter).
def riscv_read_counter_wide : RVSDNode<"READ_COUNTER_WIDE",
                                       SDTypeProfile<2, 2, [SDTCisVT<0, i32>,
                                                            SDTCisVT<1, i32>,
                                                            SDTCisInt<2>,
                                                            SDTCisInt<3>]>,
                                       [SDNPHasChain, SDNPSideEffect]>;

// Add the Lo 12 bits from an address. Selected to ADDI.
def riscv_add_lo : RVSDNode<"ADD_LO", SDTIntBinOp>;

// Get the Hi 20 bits from an address. Selected to LUI.
def riscv_hi : RVSDNode<"HI", SDTIntUnaryOp>;

// Represents an AUIPC+ADDI pair. Selected to PseudoLLA.
def riscv_lla : RVSDNode<"LLA", SDTIntUnaryOp>;

// Selected as PseudoAddTPRel. Used to emit a TP-relative relocation.
def riscv_add_tprel : RVSDNode<"ADD_TPREL",
                               SDTypeProfile<1, 3, [SDTCisSameAs<0, 1>,
                                                    SDTCisSameAs<0, 2>,
                                                    SDTCisSameAs<0, 3>,
                                                    SDTCisInt<0>]>>;

// To avoid stack clash, allocation is performed by block and each block is
// probed.
def riscv_probed_alloca : RVSDNode<"PROBED_ALLOCA",
                                   SDTypeProfile<0, 1, [SDTCisPtrTy<0>]>,
                                   [SDNPHasChain, SDNPMayStore]>;


defvar GPRPairVT = untyped;

/// Turn a pair of `i<xlen>`s into an even-odd register pair (`untyped`).
/// - Output: `untyped` even-odd register pair
/// - Input 0: `i<xlen>` low-order bits, for even register.
/// - Input 1: `i<xlen>` high-order bits, for odd register.
def riscv_build_gpr_pair : RVSDNode<"BuildGPRPair",
                                    SDTypeProfile<1, 2, [SDTCisVT<0, GPRPairVT>,
                                                         SDTCisVT<1, XLenVT>,
                                                         SDTCisVT<2, XLenVT>]>>;

/// Turn an even-odd register pair (`untyped`) into a pair of `i<xlen>`s.
/// - Output 0: `i<xlen>` low-order bits, from even register.
/// - Output 1: `i<xlen>` high-order bits, from odd register.
/// - Input: `untyped` even-odd register pair
def riscv_split_gpr_pair : RVSDNode<"SplitGPRPair",
                                    SDTypeProfile<2, 1, [SDTCisVT<0, XLenVT>,
                                                         SDTCisVT<1, XLenVT>,
                                                         SDTCisVT<2, GPRPairVT>]>>;


// part after sdnode definitions
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

// Condition code used by select and short forward branch pseudos.
def cond_code : RISCVOp {
  let OperandType = "OPERAND_COND_CODE";
}

def ixlenimm_li : Operand<XLenVT> {
  let ParserMatchClass = ImmXLenAsmOperand<"", "LI">;
}

// Accepts subset of LI operands, used by LAImm and LLAImm
def ixlenimm_li_restricted : Operand<XLenVT> {
  let ParserMatchClass = ImmXLenAsmOperand<"", "LI_Restricted">;
}

// leaving standalone (codegen-only) immleaf patterns

// instruction class templates
class BranchCC_rri<bits<3> funct3, string opcodestr>
    : RVInstB<funct3, OPC_BRANCH, (outs),
              (ins GPR:$rs1, GPR:$rs2, bare_simm13_lsb0:$imm12),
              opcodestr, "$rs1, $rs2, $imm12">,
      Sched<[/*WriteJmp, ReadJmp, ReadJmp*/]> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
class Load_ri<bits<3> funct3, string opcodestr, DAGOperand rty = GPR>
    : RVInstI<funct3, OPC_LOAD, (outs rty:$rd), (ins GPRMem:$rs1, simm12_lo:$imm12),
              opcodestr, "$rd, ${imm12}(${rs1})">;

class HLoad_r<bits<7> funct7, bits<5> funct5, string opcodestr>
    : RVInstR<funct7, 0b100, OPC_SYSTEM, (outs GPR:$rd),
              (ins GPRMemZeroOffset:$rs1), opcodestr, "$rd, $rs1"> {
  let rs2 = funct5;
}
}

// Operands for stores are in the order srcreg, base, offset rather than
// reflecting the order these fields are specified in the instruction
// encoding.
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
class Store_rri<bits<3> funct3, string opcodestr, DAGOperand rty = GPR>
    : RVInstS<funct3, OPC_STORE, (outs),
              (ins rty:$rs2, GPRMem:$rs1, simm12_lo:$imm12),
              opcodestr, "$rs2, ${imm12}(${rs1})">;

class HStore_rr<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b100, OPC_SYSTEM, (outs),
              (ins GPR:$rs2, GPRMemZeroOffset:$rs1),
               opcodestr, "$rs2, $rs1"> {
  let rd = 0;
}
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_ri<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_OP_IMM, (outs GPR:$rd), (ins GPR:$rs1, simm12_lo:$imm12),
              opcodestr, "$rd, $rs1, $imm12">,
      Sched<[/*WriteIALU, ReadIALU*/]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class Shift_ri<bits<5> imm11_7, bits<3> funct3, string opcodestr>
    : RVInstIShift<imm11_7, funct3, OPC_OP_IMM, (outs GPR:$rd),
                   (ins GPR:$rs1, uimmlog2xlen:$shamt), opcodestr,
                   "$rd, $rs1, $shamt">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_rr<bits<7> funct7, bits<3> funct3, string opcodestr,
             bit Commutable = 0>
    : RVInstR<funct7, funct3, OPC_OP, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
              opcodestr, "$rd, $rs1, $rs2"> {
  let isCommutable = Commutable;
}

let hasNoSchedulingInfo = 1,
    hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class CSR_ir<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_SYSTEM, (outs GPR:$rd), (ins csr_sysreg:$imm12, GPR:$rs1),
              opcodestr, "$rd, $imm12, $rs1">, Sched<[/*WriteCSR, ReadCSR*/]>;

let hasNoSchedulingInfo = 1,
    hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class CSR_ii<bits<3> funct3, string opcodestr>
    : RVInstI<funct3, OPC_SYSTEM, (outs GPR:$rd),
              (ins csr_sysreg:$imm12, uimm5:$rs1),
              opcodestr, "$rd, $imm12, $rs1">, Sched<[/*WriteCSR*/]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ShiftW_ri<bits<7> imm11_5, bits<3> funct3, string opcodestr>
    : RVInstIShiftW<imm11_5, funct3, OPC_OP_IMM_32, (outs GPR:$rd),
                    (ins GPR:$rs1, uimm5:$shamt), opcodestr,
                    "$rd, $rs1, $shamt">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALUW_rr<bits<7> funct7, bits<3> funct3, string opcodestr,
              bit Commutable = 0>
    : RVInstR<funct7, funct3, OPC_OP_32, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2), opcodestr, "$rd, $rs1, $rs2"> {
  let isCommutable = Commutable;
}

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class Priv<string opcodestr, bits<7> funct7>
    : RVInstR<funct7, 0b000, OPC_SYSTEM, (outs), (ins), opcodestr, "">;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class Priv_rr<string opcodestr, bits<7> funct7>
    : RVInstR<funct7, 0b000, OPC_SYSTEM, (outs), (ins GPR:$rs1, GPR:$rs2),
              opcodestr, "$rs1, $rs2"> {
  let rd = 0;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class Unary_r<bits<12> imm12, bits<3> funct3, string opcodestr>
    : RVInstIUnary<imm12, funct3, OPC_OP_IMM, (outs GPR:$rd), (ins GPR:$rs1),
                   opcodestr, "$rd, $rs1">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class UnaryW_r<bits<12> imm12, bits<3> funct3, string opcodestr>
    : RVInstIUnary<imm12, funct3, OPC_OP_IMM_32, (outs GPR:$rd), (ins GPR:$rs1),
                   opcodestr, "$rd, $rs1">;

// instructions

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
let isReMaterializable = 1, isAsCheapAsAMove = 1,
    IsSignExtendingOpW = 1 in
def LUI : RVInstU<OPC_LUI, (outs GPR:$rd), (ins uimm20_lui:$imm20),
                  "lui", "$rd, $imm20">, Sched<[/*WriteIALU*/]>;

def AUIPC : RVInstU<OPC_AUIPC, (outs GPR:$rd), (ins uimm20_auipc:$imm20),
                    "auipc", "$rd, $imm20">, Sched<[/*WriteIALU*/]>;

def JAL : RVInstJ<OPC_JAL, (outs GPR:$rd), (ins simm21_lsb0_jal:$imm20),
                  "jal", "$rd, $imm20">, Sched<[/*WriteJal*/]>;

def JALR : RVInstI<0b000, OPC_JALR, (outs GPR:$rd),
                   (ins GPR:$rs1, simm12_lo:$imm12),
                   "jalr", "$rd, ${imm12}(${rs1})">,
           Sched<[/*WriteJalr, ReadJalr*/]>;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

def BEQ  : BranchCC_rri<0b000, "beq">;
def BNE  : BranchCC_rri<0b001, "bne">;
def BLT  : BranchCC_rri<0b100, "blt">;
def BGE  : BranchCC_rri<0b101, "bge">;
def BLTU : BranchCC_rri<0b110, "bltu">;
def BGEU : BranchCC_rri<0b111, "bgeu">;

let IsSignExtendingOpW = 1, canFoldAsLoad = 1, isReMaterializable = 1 in {
def LB  : Load_ri<0b000, "lb">, Sched<[/*WriteLDB, ReadMemBase*/]>;
def LH  : Load_ri<0b001, "lh">, Sched<[/*WriteLDH, ReadMemBase*/]>;
def LW  : Load_ri<0b010, "lw">, Sched<[/*WriteLDW, ReadMemBase*/]>;
def LBU : Load_ri<0b100, "lbu">, Sched<[/*WriteLDB, ReadMemBase*/]>;
def LHU : Load_ri<0b101, "lhu">, Sched<[/*WriteLDH, ReadMemBase*/]>;
}

def SB : Store_rri<0b000, "sb">, Sched<[/*WriteSTB, ReadStoreData, ReadMemBase*/]>;
def SH : Store_rri<0b001, "sh">, Sched<[/*WriteSTH, ReadStoreData, ReadMemBase*/]>;
def SW : Store_rri<0b010, "sw">, Sched<[/*WriteSTW, ReadStoreData, ReadMemBase*/]>;

// ADDI isn't always rematerializable, but isReMaterializable will be used as
// a hint which is verified in isReMaterializableImpl.
let isReMaterializable = 1, isAsCheapAsAMove = 1 in
def ADDI  : ALU_ri<0b000, "addi">;

let IsSignExtendingOpW = 1 in {
def SLTI  : ALU_ri<0b010, "slti">;
def SLTIU : ALU_ri<0b011, "sltiu">;
}

let isReMaterializable = 1, isAsCheapAsAMove = 1 in {
def XORI  : ALU_ri<0b100, "xori">;
def ORI   : ALU_ri<0b110, "ori">;
}

def ANDI  : ALU_ri<0b111, "andi">;

def SLLI : Shift_ri<0b00000, 0b001, "slli">,
           Sched<[/*WriteShiftImm, ReadShiftImm*/]>;
def SRLI : Shift_ri<0b00000, 0b101, "srli">,
           Sched<[/*WriteShiftImm, ReadShiftImm*/]>;
def SRAI : Shift_ri<0b01000, 0b101, "srai">,
           Sched<[/*WriteShiftImm, ReadShiftImm*/]>;

def ADD  : ALU_rr<0b0000000, 0b000, "add", Commutable=1>,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;
def SUB  : ALU_rr<0b0100000, 0b000, "sub">,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;
def SLL  : ALU_rr<0b0000000, 0b001, "sll">,
           Sched<[/*WriteShiftReg, ReadShiftReg, ReadShiftReg*/]>;
let IsSignExtendingOpW = 1 in {
def SLT  : ALU_rr<0b0000000, 0b010, "slt">,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;
def SLTU : ALU_rr<0b0000000, 0b011, "sltu">,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;
}
def XOR  : ALU_rr<0b0000000, 0b100, "xor", Commutable=1>,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;
def SRL  : ALU_rr<0b0000000, 0b101, "srl">,
           Sched<[/*WriteShiftReg, ReadShiftReg, ReadShiftReg*/]>;
def SRA  : ALU_rr<0b0100000, 0b101, "sra">,
           Sched<[/*WriteShiftReg, ReadShiftReg, ReadShiftReg*/]>;
def OR   : ALU_rr<0b0000000, 0b110, "or", Commutable=1>,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;
def AND  : ALU_rr<0b0000000, 0b111, "and", Commutable=1>,
           Sched<[/*WriteIALU, ReadIALU, ReadIALU*/]>;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
def FENCE : RVInstI<0b000, OPC_MISC_MEM, (outs),
                    (ins fencearg:$pred, fencearg:$succ),
                    "fence", "$pred, $succ">, Sched<[/**/]> {
  bits<4> pred;
  bits<4> succ;

  let rs1 = 0;
  let rd = 0;
  let imm12 = {0b0000,pred,succ};
}

def FENCE_TSO : RVInstI<0b000, OPC_MISC_MEM, (outs), (ins), "fence.tso", "">, Sched<[/**/]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = {0b1000,0b0011,0b0011};
}

def FENCE_I : RVInstI<0b001, OPC_MISC_MEM, (outs), (ins), "fence.i", "">, Sched<[/**/]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0;
}

def ECALL : RVInstI<0b000, OPC_SYSTEM, (outs), (ins), "ecall", "">, Sched<[/*WriteJmp*/]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0;
}

let isTrap = 1 in
def EBREAK : RVInstI<0b000, OPC_SYSTEM, (outs), (ins), "ebreak", "">,
             Sched<[/**/]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 1;
}

// This is a de facto standard (as set by GNU binutils) 32-bit unimplemented
// instruction (i.e., it should always trap, if your implementation has invalid
// instruction traps).
let isTrap = 1 in
def UNIMP : RVInstI<0b001, OPC_SYSTEM, (outs), (ins), "unimp", "">,
            Sched<[/**/]> {
  let rs1 = 0;
  let rd = 0;
  let imm12 = 0b110000000000;
}

} // hasSideEffects = 1, mayLoad = 0, mayStore = 0

def CSRRW : CSR_ir<0b001, "csrrw">;
def CSRRS : CSR_ir<0b010, "csrrs">;
def CSRRC : CSR_ir<0b011, "csrrc">;

def CSRRWI : CSR_ii<0b101, "csrrwi">;
def CSRRSI : CSR_ii<0b110, "csrrsi">;
def CSRRCI : CSR_ii<0b111, "csrrci">;

// ignoring RV64I instructions section

// privileged instructions
/*
let isBarrier = 1, isReturn = 1, isTerminator = 1 in {
def SRET : Priv<"sret", 0b0001000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00010;
}

def MRET : Priv<"mret", 0b0011000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00010;
}

//let Predicates = [HasStdExtSmrnmi] in { - for non maskable interrupts
//def MNRET : Priv<"mnret", 0b0111000>, Sched<[]> {
//  let rd = 0;
//  let rs1 = 0;
//  let rs2 = 0b00010;
//}
//}// Predicates = [HasStdExtSmrnmi]
//} // isBarrier = 1, isReturn = 1, isTerminator = 1


def WFI : Priv<"wfi", 0b0001000>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b00101;
}
*/

// ignoring parts for std extensiond Svinval

// def SFENCE_VMA  : Priv_rr<"sfence.vma", 0b0001001>, Sched<[]>;

// ignoring parts for std extension H

// ignoring debug instructions
/*
let isBarrier = 1, isReturn = 1, isTerminator = 1 in {
def DRET : Priv<"dret", 0b0111101>, Sched<[]> {
  let rd = 0;
  let rs1 = 0;
  let rs2 = 0b10010;
}
*/

// assembler pseudo instructions

// Note that the size is 32 because up to 8 32-bit instructions are needed to
// generate an arbitrary 64-bit immediate. However, the size does not really
// matter since PseudoLI is currently only used in the AsmParser where it gets
// expanded to real instructions immediately.
/*
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, Size = 32,
    isCodeGenOnly = 0, isAsmParserOnly = 1 in
def PseudoLI : Pseudo<(outs GPR:$rd), (ins ixlenimm_li:$imm), [],
                      "li", "$rd, $imm">;

def PseudoLB  : PseudoLoad<"lb">;
def PseudoLBU : PseudoLoad<"lbu">;
def PseudoLH  : PseudoLoad<"lh">;
def PseudoLHU : PseudoLoad<"lhu">;
def PseudoLW  : PseudoLoad<"lw">;

def PseudoSB  : PseudoStore<"sb">;
def PseudoSH  : PseudoStore<"sh">;
def PseudoSW  : PseudoStore<"sw">;

let Predicates = [IsRV64] in {
def PseudoLWU : PseudoLoad<"lwu">;
def PseudoLD  : PseudoLoad<"ld">;
def PseudoSD  : PseudoStore<"sd">;
} // Predicates = [IsRV64] */

def : InstAlias<"nop",           (ADDI      X0,      X0,           0), 3>;
def : InstAlias<"li $rd, $imm",  (ADDI GPR:$rd,      X0, simm12_lo:$imm), 2>;
def : InstAlias<"mv $rd, $rs",   (ADDI GPR:$rd, GPR:$rs,           0)>;

def : InstAlias<"not $rd, $rs",  (XORI GPR:$rd, GPR:$rs,      -1)>;
def : InstAlias<"neg $rd, $rs",  (SUB  GPR:$rd,      X0, GPR:$rs)>;

/*let Predicates = [IsRV64] in {
def : InstAlias<"negw $rd, $rs",   (SUBW  GPR:$rd,      X0, GPR:$rs)>;
def : InstAlias<"sext.w $rd, $rs", (ADDIW GPR:$rd, GPR:$rs,       0)>;
} // Predicates = [IsRV64]*/

def : InstAlias<"seqz $rd, $rs", (SLTIU GPR:$rd, GPR:$rs,       1)>;
def : InstAlias<"snez $rd, $rs", (SLTU  GPR:$rd,      X0, GPR:$rs)>;
def : InstAlias<"sltz $rd, $rs", (SLT   GPR:$rd, GPR:$rs,      X0)>;
def : InstAlias<"sgtz $rd, $rs", (SLT   GPR:$rd,      X0, GPR:$rs)>;

// sgt/sgtu are recognised by the GNU assembler but the canonical slt/sltu
// form will always be printed. Therefore, set a zero weight.
def : InstAlias<"sgt $rd, $rs, $rt", (SLT GPR:$rd, GPR:$rt, GPR:$rs), 0>;
def : InstAlias<"sgtu $rd, $rs, $rt", (SLTU GPR:$rd, GPR:$rt, GPR:$rs), 0>;

def : InstAlias<"beqz $rs, $offset",
                (BEQ GPR:$rs,      X0, bare_simm13_lsb0:$offset)>;
def : InstAlias<"bnez $rs, $offset",
                (BNE GPR:$rs,      X0, bare_simm13_lsb0:$offset)>;
def : InstAlias<"blez $rs, $offset",
                (BGE      X0, GPR:$rs, bare_simm13_lsb0:$offset)>;
def : InstAlias<"bgez $rs, $offset",
                (BGE GPR:$rs,      X0, bare_simm13_lsb0:$offset)>;
def : InstAlias<"bltz $rs, $offset",
                (BLT GPR:$rs,      X0, bare_simm13_lsb0:$offset)>;
def : InstAlias<"bgtz $rs, $offset",
                (BLT      X0, GPR:$rs, bare_simm13_lsb0:$offset)>;

// Always output the canonical mnemonic for the pseudo branch instructions.
// The GNU tools emit the canonical mnemonic for the branch pseudo instructions
// as well (e.g. "bgt" will be recognised by the assembler but never printed by
// objdump). Match this behaviour by setting a zero weight.
def : InstAlias<"bgt $rs, $rt, $offset",
                (BLT  GPR:$rt, GPR:$rs, bare_simm13_lsb0:$offset), 0>;
def : InstAlias<"ble $rs, $rt, $offset",
                (BGE  GPR:$rt, GPR:$rs, bare_simm13_lsb0:$offset), 0>;
def : InstAlias<"bgtu $rs, $rt, $offset",
                (BLTU GPR:$rt, GPR:$rs, bare_simm13_lsb0:$offset), 0>;
def : InstAlias<"bleu $rs, $rt, $offset",
                (BGEU GPR:$rt, GPR:$rs, bare_simm13_lsb0:$offset), 0>;

def : InstAlias<"j $offset",   (JAL X0, simm21_lsb0_jal:$offset)>;
def : InstAlias<"jal $offset", (JAL X1, simm21_lsb0_jal:$offset)>;

// Non-zero offset aliases of "jalr" are the lowest weight, followed by the
// two-register form, then the one-register forms and finally "ret".
def : InstAlias<"jr $rs",                (JALR      X0, GPR:$rs, 0), 3>;
def : InstAlias<"jr ${offset}(${rs})",   (JALR      X0, GPR:$rs, simm12_lo:$offset)>;
def : InstAlias<"jalr $rs",              (JALR      X1, GPR:$rs, 0), 3>;
def : InstAlias<"jalr ${offset}(${rs})", (JALR      X1, GPR:$rs, simm12_lo:$offset)>;
def : InstAlias<"jalr $rd, $rs",         (JALR GPR:$rd, GPR:$rs, 0), 2>;
def : InstAlias<"ret",                   (JALR      X0,      X1, 0), 4>;

// Non-canonical forms for jump targets also accepted by the assembler.
def : InstAlias<"jr $rs, $offset",        (JALR      X0, GPR:$rs, simm12_lo:$offset), 0>;
def : InstAlias<"jalr $rs, $offset",      (JALR      X1, GPR:$rs, simm12_lo:$offset), 0>;
def : InstAlias<"jalr $rd, $rs, $offset", (JALR GPR:$rd, GPR:$rs, simm12_lo:$offset), 0>;
def : InstAlias<"jr (${rs})",             (JALR      X0, GPR:$rs, 0), 0>;
def : InstAlias<"jalr (${rs})",           (JALR      X1, GPR:$rs, 0), 0>;
def : InstAlias<"jalr $rd, (${rs})",      (JALR GPR:$rd, GPR:$rs, 0), 0>;

def : InstAlias<"fence", (FENCE 0xF, 0xF)>; // 0xF == iorw

//let Predicates = [HasStdExtZihintpause] in
//def : InstAlias<"pause", (FENCE 0x1, 0x0)>; // 0x1 == w

def : InstAlias<"rdinstret $rd", (CSRRS GPR:$rd, INSTRET.Encoding, X0), 2>;
def : InstAlias<"rdcycle $rd",   (CSRRS GPR:$rd, CYCLE.Encoding, X0), 2>;
def : InstAlias<"rdtime $rd",    (CSRRS GPR:$rd, TIME.Encoding, X0), 2>;

let Predicates = [IsRV32] in {
def : InstAlias<"rdinstreth $rd", (CSRRS GPR:$rd, INSTRETH.Encoding, X0), 2>;
def : InstAlias<"rdcycleh $rd",   (CSRRS GPR:$rd, CYCLEH.Encoding, X0), 2>;
def : InstAlias<"rdtimeh $rd",    (CSRRS GPR:$rd, TIMEH.Encoding, X0), 2>;
} // Predicates = [IsRV32]

def : InstAlias<"csrr $rd, $csr", (CSRRS GPR:$rd, csr_sysreg:$csr,      X0)>;
def : InstAlias<"csrw $csr, $rs", (CSRRW      X0, csr_sysreg:$csr, GPR:$rs)>;
def : InstAlias<"csrs $csr, $rs", (CSRRS      X0, csr_sysreg:$csr, GPR:$rs)>;
def : InstAlias<"csrc $csr, $rs", (CSRRC      X0, csr_sysreg:$csr, GPR:$rs)>;

def : InstAlias<"csrwi $csr, $imm", (CSRRWI X0, csr_sysreg:$csr, uimm5:$imm)>;
def : InstAlias<"csrsi $csr, $imm", (CSRRSI X0, csr_sysreg:$csr, uimm5:$imm)>;
def : InstAlias<"csrci $csr, $imm", (CSRRCI X0, csr_sysreg:$csr, uimm5:$imm)>;

let EmitPriority = 0 in {
def : InstAlias<"csrw $csr, $imm", (CSRRWI X0, csr_sysreg:$csr, uimm5:$imm)>;
def : InstAlias<"csrs $csr, $imm", (CSRRSI X0, csr_sysreg:$csr, uimm5:$imm)>;
def : InstAlias<"csrc $csr, $imm", (CSRRCI X0, csr_sysreg:$csr, uimm5:$imm)>;

def : InstAlias<"csrrw $rd, $csr, $imm", (CSRRWI GPR:$rd, csr_sysreg:$csr, uimm5:$imm)>;
def : InstAlias<"csrrs $rd, $csr, $imm", (CSRRSI GPR:$rd, csr_sysreg:$csr, uimm5:$imm)>;
def : InstAlias<"csrrc $rd, $csr, $imm", (CSRRCI GPR:$rd, csr_sysreg:$csr, uimm5:$imm)>;
}

//def : InstAlias<"sfence.vma",     (SFENCE_VMA      X0, X0), 2>;
//def : InstAlias<"sfence.vma $rs", (SFENCE_VMA GPR:$rs, X0)>;

//def : InstAlias<"hfence.gvma",     (HFENCE_GVMA      X0, X0), 2>;
//def : InstAlias<"hfence.gvma $rs", (HFENCE_GVMA GPR:$rs, X0)>;

//def : InstAlias<"hfence.vvma",     (HFENCE_VVMA      X0, X0), 2>;
//def : InstAlias<"hfence.vvma $rs", (HFENCE_VVMA GPR:$rs, X0)>;

let EmitPriority = 0 in {
def : InstAlias<"lb $rd, (${rs1})",
                (LB  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lh $rd, (${rs1})",
                (LH  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lw $rd, (${rs1})",
                (LW  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lbu $rd, (${rs1})",
                (LBU  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lhu $rd, (${rs1})",
                (LHU  GPR:$rd, GPR:$rs1, 0)>;

def : InstAlias<"sb $rs2, (${rs1})",
                (SB  GPR:$rs2, GPR:$rs1, 0)>;
def : InstAlias<"sh $rs2, (${rs1})",
                (SH  GPR:$rs2, GPR:$rs1, 0)>;
def : InstAlias<"sw $rs2, (${rs1})",
                (SW  GPR:$rs2, GPR:$rs1, 0)>;

def : InstAlias<"add $rd, $rs1, $imm12",
                (ADDI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"and $rd, $rs1, $imm12",
                (ANDI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"xor $rd, $rs1, $imm12",
                (XORI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"or $rd, $rs1, $imm12",
                (ORI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"sll $rd, $rs1, $shamt",
                (SLLI  GPR:$rd, GPR:$rs1, uimmlog2xlen:$shamt)>;
def : InstAlias<"srl $rd, $rs1, $shamt",
                (SRLI  GPR:$rd, GPR:$rs1, uimmlog2xlen:$shamt)>;
def : InstAlias<"sra $rd, $rs1, $shamt",
                (SRAI  GPR:$rd, GPR:$rs1, uimmlog2xlen:$shamt)>;
/*let Predicates = [IsRV64] in {
def : InstAlias<"lwu $rd, (${rs1})",
                (LWU  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"ld $rd, (${rs1})",
                (LD  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"sd $rs2, (${rs1})",
                (SD  GPR:$rs2, GPR:$rs1, 0)>;

def : InstAlias<"addw $rd, $rs1, $imm12",
                (ADDIW  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"sllw $rd, $rs1, $shamt",
                (SLLIW  GPR:$rd, GPR:$rs1, uimm5:$shamt)>;
def : InstAlias<"srlw $rd, $rs1, $shamt",
                (SRLIW  GPR:$rd, GPR:$rs1, uimm5:$shamt)>;
def : InstAlias<"sraw $rd, $rs1, $shamt",
                (SRAIW  GPR:$rd, GPR:$rs1, uimm5:$shamt)>;
} // Predicates = [IsRV64]*/
def : InstAlias<"slt $rd, $rs1, $imm12",
                (SLTI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"sltu $rd, $rs1, $imm12",
                (SLTIU  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
}

def : MnemonicAlias<"move", "mv">;

// The SCALL and SBREAK instructions were renamed to ECALL and EBREAK in
// version 2.1 of the user-level ISA. Like the GNU toolchain, we still accept
// the old name for backwards compatibility.
def : MnemonicAlias<"scall", "ecall">;
def : MnemonicAlias<"sbreak", "ebreak">;

def : InstAlias<"zext.b $rd, $rs", (ANDI GPR:$rd, GPR:$rs, 0xFF)>;

/*let Predicates = [HasStdExtZicfilp] in {
def : InstAlias<"lpad $imm20", (AUIPC X0, uimm20:$imm20)>;
}*/

// .insn directive instructions
let EmitPriority = 0 in {
def : InstAlias<"lb $rd, (${rs1})",
                (LB  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lh $rd, (${rs1})",
                (LH  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lw $rd, (${rs1})",
                (LW  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lbu $rd, (${rs1})",
                (LBU  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"lhu $rd, (${rs1})",
                (LHU  GPR:$rd, GPR:$rs1, 0)>;

def : InstAlias<"sb $rs2, (${rs1})",
                (SB  GPR:$rs2, GPR:$rs1, 0)>;
def : InstAlias<"sh $rs2, (${rs1})",
                (SH  GPR:$rs2, GPR:$rs1, 0)>;
def : InstAlias<"sw $rs2, (${rs1})",
                (SW  GPR:$rs2, GPR:$rs1, 0)>;

def : InstAlias<"add $rd, $rs1, $imm12",
                (ADDI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"and $rd, $rs1, $imm12",
                (ANDI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"xor $rd, $rs1, $imm12",
                (XORI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"or $rd, $rs1, $imm12",
                (ORI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"sll $rd, $rs1, $shamt",
                (SLLI  GPR:$rd, GPR:$rs1, uimmlog2xlen:$shamt)>;
def : InstAlias<"srl $rd, $rs1, $shamt",
                (SRLI  GPR:$rd, GPR:$rs1, uimmlog2xlen:$shamt)>;
def : InstAlias<"sra $rd, $rs1, $shamt",
                (SRAI  GPR:$rd, GPR:$rs1, uimmlog2xlen:$shamt)>;
/*let Predicates = [IsRV64] in {
def : InstAlias<"lwu $rd, (${rs1})",
                (LWU  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"ld $rd, (${rs1})",
                (LD  GPR:$rd, GPR:$rs1, 0)>;
def : InstAlias<"sd $rs2, (${rs1})",
                (SD  GPR:$rs2, GPR:$rs1, 0)>;

def : InstAlias<"addw $rd, $rs1, $imm12",
                (ADDIW  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"sllw $rd, $rs1, $shamt",
                (SLLIW  GPR:$rd, GPR:$rs1, uimm5:$shamt)>;
def : InstAlias<"srlw $rd, $rs1, $shamt",
                (SRLIW  GPR:$rd, GPR:$rs1, uimm5:$shamt)>;
def : InstAlias<"sraw $rd, $rs1, $shamt",
                (SRAIW  GPR:$rd, GPR:$rs1, uimm5:$shamt)>;
} // Predicates = [IsRV64]*/
def : InstAlias<"slt $rd, $rs1, $imm12",
                (SLTI  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
def : InstAlias<"sltu $rd, $rs1, $imm12",
                (SLTIU  GPR:$rd, GPR:$rs1, simm12_lo:$imm12)>;
}

def : MnemonicAlias<"move", "mv">;

// The SCALL and SBREAK instructions were renamed to ECALL and EBREAK in
// version 2.1 of the user-level ISA. Like the GNU toolchain, we still accept
// the old name for backwards compatibility.
def : MnemonicAlias<"scall", "ecall">;
def : MnemonicAlias<"sbreak", "ebreak">;

def : InstAlias<"zext.b $rd, $rs", (ANDI GPR:$rd, GPR:$rs, 0xFF)>;

/*let Predicates = [HasStdExtZicfilp] in {
def : InstAlias<"lpad $imm20", (AUIPC X0, uimm20:$imm20)>;
}*/

// isCodeGenOnly = 1 to hide them from the tablegened assembly parser.
let isCodeGenOnly = 1, hasSideEffects = 1, mayLoad = 1, mayStore = 1,
    hasNoSchedulingInfo = 1 in {
def Insn16 : RVInst16<(outs), (ins uimm16:$value), "", "", [], InstFormatOther> {
  bits<16> value;

  let Inst{15-0} = value;
  let AsmString = ".insn 0x2, $value";
}
def Insn32 : RVInst<(outs), (ins uimm32:$value), "", "", [], InstFormatOther> {
  bits<32> value;

  let Inst{31-0} = value;
  let AsmString = ".insn 0x4, $value";
}
def Insn48 : RVInst48<(outs), (ins uimm48:$value), "", "", [], InstFormatOther> {
  bits<48> value;
  let Inst{47-0} = value;
  let AsmString = ".insn 0x6, $value";
}
def Insn64 : RVInst64<(outs), (ins uimm64:$value), "", "", [], InstFormatOther> {
  bits<64> value;
  let Inst{63-0} = value;
  let AsmString = ".insn 0x8, $value";
}
} // isCodeGenOnly, hasSideEffects, mayLoad, mayStore, hasNoSchedulingInfo

// isCodeGenOnly = 1 to hide them from the tablegened assembly parser.
/*
let isCodeGenOnly = 1, hasSideEffects = 1, mayLoad = 1, mayStore = 1,
    hasNoSchedulingInfo = 1 in {
def InsnR : DirectiveInsnR<(outs AnyReg:$rd), (ins uimm7_opcode:$opcode, uimm3:$funct3,
                                                   uimm7:$funct7, AnyReg:$rs1,
                                                   AnyReg:$rs2),
                           "$opcode, $funct3, $funct7, $rd, $rs1, $rs2">;
def InsnR4 : DirectiveInsnR4<(outs AnyReg:$rd), (ins uimm7_opcode:$opcode,
                                                     uimm3:$funct3,
                                                     uimm2:$funct2,
                                                     AnyReg:$rs1, AnyReg:$rs2,
                                                     AnyReg:$rs3),
                            "$opcode, $funct3, $funct2, $rd, $rs1, $rs2, $rs3">;
def InsnI : DirectiveInsnI<(outs AnyReg:$rd), (ins uimm7_opcode:$opcode, uimm3:$funct3,
                                                   AnyReg:$rs1, simm12_lo:$imm12),
                           "$opcode, $funct3, $rd, $rs1, $imm12">;
def InsnI_Mem : DirectiveInsnI<(outs AnyReg:$rd), (ins uimm7_opcode:$opcode,
                                                       uimm3:$funct3,
                                                       AnyReg:$rs1,
                                                       simm12_lo:$imm12),
                               "$opcode, $funct3, $rd, ${imm12}(${rs1})">;
def InsnB : DirectiveInsnB<(outs), (ins uimm7_opcode:$opcode, uimm3:$funct3,
                                        AnyReg:$rs1, AnyReg:$rs2,
                                        bare_simm13_lsb0:$imm12),
                           "$opcode, $funct3, $rs1, $rs2, $imm12">;
def InsnU : DirectiveInsnU<(outs AnyReg:$rd), (ins uimm7_opcode:$opcode,
                                                   uimm20_lui:$imm20),
                           "$opcode, $rd, $imm20">;
def InsnJ : DirectiveInsnJ<(outs AnyReg:$rd), (ins uimm7_opcode:$opcode,
                                                   simm21_lsb0_jal:$imm20),
                           "$opcode, $rd, $imm20">;
def InsnS : DirectiveInsnS<(outs), (ins uimm7_opcode:$opcode, uimm3:$funct3,
                                        AnyReg:$rs2, AnyReg:$rs1,
                                        simm12_lo:$imm12),
                           "$opcode, $funct3, $rs2, ${imm12}(${rs1})">;
} // isCodeGenOnly, hasSideEffects, mayLoad, mayStore, hasNoSchedulingInfo */

// Use InstAliases to match these so that we can combine the insn and format
// into a mnemonic to use as the key for the tablegened asm matcher table. The
// parser will take care of creating these fake mnemonics and will only do it
// for known formats.
/*
let EmitPriority = 0 in {
def : InstAlias<".insn_r $opcode, $funct3, $funct7, $rd, $rs1, $rs2",
                (InsnR AnyReg:$rd, uimm7_opcode:$opcode, uimm3:$funct3, uimm7:$funct7,
                       AnyReg:$rs1, AnyReg:$rs2)>;
// Accept 4 register form of ".insn r" as alias for ".insn r4".
def : InstAlias<".insn_r $opcode, $funct3, $funct2, $rd, $rs1, $rs2, $rs3",
                (InsnR4 AnyReg:$rd, uimm7_opcode:$opcode, uimm3:$funct3, uimm2:$funct2,
                        AnyReg:$rs1, AnyReg:$rs2, AnyReg:$rs3)>;
def : InstAlias<".insn_r4 $opcode, $funct3, $funct2, $rd, $rs1, $rs2, $rs3",
                (InsnR4 AnyReg:$rd, uimm7_opcode:$opcode, uimm3:$funct3, uimm2:$funct2,
                        AnyReg:$rs1, AnyReg:$rs2, AnyReg:$rs3)>;
def : InstAlias<".insn_i $opcode, $funct3, $rd, $rs1, $imm12",
                (InsnI AnyReg:$rd, uimm7_opcode:$opcode, uimm3:$funct3, AnyReg:$rs1,
                       simm12_lo:$imm12)>;
def : InstAlias<".insn_i $opcode, $funct3, $rd, ${imm12}(${rs1})",
                (InsnI_Mem AnyReg:$rd, uimm7_opcode:$opcode, uimm3:$funct3,
                           AnyReg:$rs1, simm12_lo:$imm12)>;
def : InstAlias<".insn_i $opcode, $funct3, $rd, (${rs1})",
                (InsnI_Mem AnyReg:$rd, uimm7_opcode:$opcode, uimm3:$funct3,
                           AnyReg:$rs1, 0)>;
def : InstAlias<".insn_b $opcode, $funct3, $rs1, $rs2, $imm12",
                (InsnB uimm7_opcode:$opcode, uimm3:$funct3, AnyReg:$rs1,
                       AnyReg:$rs2, bare_simm13_lsb0:$imm12)>;
// Accept sb as an alias for b.
def : InstAlias<".insn_sb $opcode, $funct3, $rs1, $rs2, $imm12",
                (InsnB uimm7_opcode:$opcode, uimm3:$funct3, AnyReg:$rs1,
                       AnyReg:$rs2, bare_simm13_lsb0:$imm12)>;
def : InstAlias<".insn_u $opcode, $rd, $imm20",
                (InsnU AnyReg:$rd, uimm7_opcode:$opcode, uimm20_lui:$imm20)>;
def : InstAlias<".insn_j $opcode, $rd, $imm20",
                (InsnJ AnyReg:$rd, uimm7_opcode:$opcode, simm21_lsb0_jal:$imm20)>;
// Accept uj as an alias for j.
def : InstAlias<".insn_uj $opcode, $rd, $imm20",
                (InsnJ AnyReg:$rd, uimm7_opcode:$opcode, simm21_lsb0_jal:$imm20)>;
def : InstAlias<".insn_s $opcode, $funct3, $rs2, ${imm12}(${rs1})",
                (InsnS uimm7_opcode:$opcode, uimm3:$funct3, AnyReg:$rs2,
                       AnyReg:$rs1, simm12_lo:$imm12)>;
def : InstAlias<".insn_s $opcode, $funct3, $rs2, (${rs1})",
                (InsnS uimm7_opcode:$opcode, uimm3:$funct3, AnyReg:$rs2,
                       AnyReg:$rs1, 0)>;
}
*/
/// Access to system registers

// Helpers for defining specific operations. They are defined for each system
// register separately. Side effect is not used because dependencies are
// expressed via use-def properties.

class ReadSysReg<SysReg SR, list<Register> Regs>
  : Pseudo<(outs GPR:$rd), (ins),
           [(set GPR:$rd, (XLenVT (riscv_read_csr (XLenVT SR.Encoding))))]>,
    PseudoInstExpansion<(CSRRS GPR:$rd, SR.Encoding, X0)> {
  let hasSideEffects = 0;
  let Uses = Regs;
}

class WriteSysReg<SysReg SR, list<Register> Regs>
  : Pseudo<(outs), (ins GPR:$val),
           [(riscv_write_csr (XLenVT SR.Encoding), (XLenVT GPR:$val))]>,
    PseudoInstExpansion<(CSRRW X0, SR.Encoding, GPR:$val)> {
  let hasSideEffects = 0;
  let Defs = Regs;
}

class WriteSysRegImm<SysReg SR, list<Register> Regs>
  : Pseudo<(outs), (ins uimm5:$val),
           [(riscv_write_csr (XLenVT SR.Encoding), uimm5:$val)]>,
    PseudoInstExpansion<(CSRRWI X0, SR.Encoding, uimm5:$val)> {
  let hasSideEffects = 0;
  let Defs = Regs;
}

class SwapSysReg<SysReg SR, list<Register> Regs>
  : Pseudo<(outs GPR:$rd), (ins GPR:$val),
           [(set GPR:$rd, (riscv_swap_csr (XLenVT SR.Encoding), (XLenVT GPR:$val)))]>,
    PseudoInstExpansion<(CSRRW GPR:$rd, SR.Encoding, GPR:$val)> {
  let hasSideEffects = 0;
  let Uses = Regs;
  let Defs = Regs;
}

class SwapSysRegImm<SysReg SR, list<Register> Regs>
  : Pseudo<(outs GPR:$rd), (ins uimm5:$val),
           [(set GPR:$rd, (XLenVT (riscv_swap_csr (XLenVT SR.Encoding), uimm5:$val)))]>,
    PseudoInstExpansion<(CSRRWI GPR:$rd, SR.Encoding, uimm5:$val)> {
  let hasSideEffects = 0;
  let Uses = Regs;
  let Defs = Regs;
}

class ClearSysReg<SysReg SR, list<Register> Regs>
  : Pseudo<(outs), (ins GPR:$val),
           [(riscv_clear_csr (XLenVT SR.Encoding), (XLenVT GPR:$val))]>,
    PseudoInstExpansion<(CSRRC X0, SR.Encoding, GPR:$val)> {
  let hasSideEffects = 0;
  let Uses = Regs;
  let Defs = Regs;
}

class ClearSysRegImm<SysReg SR, list<Register> Regs>
  : Pseudo<(outs), (ins uimm5:$val),
           [(riscv_clear_csr (XLenVT SR.Encoding), uimm5:$val)]>,
    PseudoInstExpansion<(CSRRCI X0, SR.Encoding, uimm5:$val)> {
  let hasSideEffects = 0;
  let Uses = Regs;
  let Defs = Regs;
}

class SetSysReg<SysReg SR, list<Register> Regs>
  : Pseudo<(outs), (ins GPR:$val),
           [(riscv_set_csr (XLenVT SR.Encoding), (XLenVT GPR:$val))]>,
    PseudoInstExpansion<(CSRRS X0, SR.Encoding, GPR:$val)> {
  let hasSideEffects = 0;
  let Uses = Regs;
  let Defs = Regs;
}

class SetSysRegImm<SysReg SR, list<Register> Regs>
  : Pseudo<(outs), (ins uimm5:$val),
           [(riscv_set_csr (XLenVT SR.Encoding), uimm5:$val)]>,
    PseudoInstExpansion<(CSRRSI X0, SR.Encoding, uimm5:$val)> {
  let hasSideEffects = 0;
  let Uses = Regs;
  let Defs = Regs;
}
/*
def ReadFRM : ReadSysReg<SysRegFRM, [FRM]>;
let hasPostISelHook = 1 in {
def WriteFRM : WriteSysReg<SysRegFRM, [FRM]>;
def WriteFRMImm : WriteSysRegImm<SysRegFRM, [FRM]>;
def SwapFRMImm : SwapSysRegImm<SysRegFRM, [FRM]>;
}*/

// def WriteVXRMImm : WriteSysRegImm<SysRegVXRM, [VXRM]>;
/*
let hasSideEffects = true in {
def ReadFFLAGS : ReadSysReg<SysRegFFLAGS, [FFLAGS]>;
def WriteFFLAGS : WriteSysReg<SysRegFFLAGS, [FFLAGS]>;
}

let hasPostISelHook = 1 in {
def ReadFCSR : ReadSysReg<SysRegFCSR, [FRM, FFLAGS]>;
def WriteFCSR : WriteSysReg<SysRegFCSR, [FRM, FFLAGS]>;
def WriteFCSRImm : WriteSysRegImm<SysRegFCSR, [FRM, FFLAGS]>;
def ClearFCSR : ClearSysReg<SysRegFCSR, [FRM, FFLAGS]>;
def ClearFCSRImm : ClearSysRegImm<SysRegFCSR, [FRM, FFLAGS]>;
def SetFCSR : SetSysReg<SysRegFCSR, [FRM, FFLAGS]>;
def SetFCSRImm : SetSysRegImm<SysRegFCSR, [FRM, FFLAGS]>;
}

/// Other pseudo-instructions

// Pessimistically assume the stack pointer will be clobbered
let Defs = [X2], Uses = [X2] in {
def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                              [(callseq_start timm:$amt1, timm:$amt2)]>;
def ADJCALLSTACKUP   : Pseudo<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                              [(callseq_end timm:$amt1, timm:$amt2)]>;
} // Defs = [X2], Uses = [X2]
*/

//include "ShaktiInstrInfoM.td"
//include "ShaktiInstrInfoA.td"
//include "ShaktiInstrInfoC.td"
// #include "ShaktiInstrInfoZa.td"
// #include "ShaktiInstrInfoZalasr.td"

// #include "ShaktiInstrGISel.td" // global i sel