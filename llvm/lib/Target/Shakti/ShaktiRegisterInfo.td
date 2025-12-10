// Shakti register definitions

// declarations to describe shakti register files
let Namespace = "Shakti" in {
    
    class ShaktiReg<bits<5> Enc, string n, list<string> alt = []> : Register<n> {
        let HWEncoding{4-0} = Enc;
        let AltNames = alt;
    }

    class ShaktiRegWithSubRegs<bits<5> Enc, string n, list<Register> subregs, list<string> alt = []>
        : RegisterWithSubRegs<n, subregs> {
            let HWEncoding{4-0} = Enc;
            let AltNames = alt;
        }

    let FallbackRegAltNameIndex = NoRegAltName in
    def ABIRegAltName : RegAltNameIndex;

    def sub_gpr_even : SubRegIndex<32> {
        let SubRegRanges = SubRegRangeByHwMode<[RV32, RV64],
                                               [SubRegRange<32>, SubRegRange<64>]>;
    }
    def sub_gpr_odd : SubRegIndex<32> {
        let SubRegRanges = SubRegRangeByHwMode<[RV32, RV64],
                                               [SubRegRange<32, 32>, SubRegRange<64, 64>]>;
    }
}

// general purpose registers (aka integer registers)
// CostPerUse is set higher for registers that may not be compressible as they 
// are not part of GPRC, the most restrictive register class used by the 
// compressed instruction set. this will influence the greedy register allocator
// to reduce the use of registers that cant be encoded in 16 bit instructions

let RegAltNameIndices = [ABIRegAltName] in {

    let isConstant = true in
        def X0 : ShaktiReg<0, "x0", ["zero"]>;
    
    let CostPerUse = [1] in {                   // cost per use being defined differently from official backend
                                                // this is because CostPerUse = [0,1] is meant to assign a cost 
                                                // to the main register and then to the sub register but in our 
                                                // case we dont have sub registers.
        def X1 : ShaktiReg<1, "x1", ["ra"]>, DwarfRegNum<[1]>;
        def X2 : ShaktiReg<2, "x2", ["sp"]>, DwarfRegNum<[2]>;
        def X3 : ShaktiReg<3, "x3", ["gp"]>, DwarfRegNum<[3]>;
        def X4 : ShaktiReg<4, "x4", ["tp"]>, DwarfRegNum<[4]>;
        def X5 : ShaktiReg<5, "x5", ["t0"]>, DwarfRegNum<[5]>;
        def X6 : ShaktiReg<6, "x6", ["t1"]>, DwarfRegNum<[6]>;
        def X7 : ShaktiReg<7, "x7", ["t2"]>, DwarfRegNum<[7]>;
    }
        
    def X8 : ShaktiReg<8, "x8", ["s0", "fp"]>, DwarfRegNum<[8]>;
    def X9 : ShaktiReg<9, "x9", ["s1"]>, DwarfRegNum<[9]>;
    def X10 : ShaktiReg<10, "x10", ["a0"]>, DwarfRegNum<[10]>;
    def X11 : ShaktiReg<11, "x11", ["a1"]>, DwarfRegNum<[11]>;
    def X12 : ShaktiReg<12, "x12", ["a2"]>, DwarfRegNum<[12]>;
    def X13 : ShaktiReg<13, "x13", ["a3"]>, DwarfRegNum<[13]>;
    def X14 : ShaktiReg<14, "x14", ["a4"]>, DwarfRegNum<[14]>;
    def X15 : ShaktiReg<15, "x15", ["a5"]>, DwarfRegNum<[15]>;
    
    let CostPerUse = [1] in {
        def X16 : ShaktiReg<16, "x16", ["a6"]>, DwarfRegNum<[16]>;
        def X17 : ShaktiReg<17, "x17", ["a7"]>, DwarfRegNum<[17]>;
        def X18 : ShaktiReg<18, "x18", ["s2"]>, DwarfRegNum<[18]>;
        def X19 : ShaktiReg<19, "x19", ["s3"]>, DwarfRegNum<[19]>;
        def X20 : ShaktiReg<20, "x20", ["s4"]>, DwarfRegNum<[20]>;
        def X21 : ShaktiReg<21, "x21", ["s5"]>, DwarfRegNum<[21]>;
        def X22 : ShaktiReg<22, "x22", ["s6"]>, DwarfRegNum<[22]>;
        def X23 : ShaktiReg<23, "x23", ["s7"]>, DwarfRegNum<[23]>;
        def X24 : ShaktiReg<24, "x24", ["s8"]>, DwarfRegNum<[24]>;
        def X25 : ShaktiReg<25, "x25", ["s9"]>, DwarfRegNum<[25]>;
        def X26 : ShaktiReg<26, "x26", ["s10"]>, DwarfRegNum<[26]>;
        def X27 : ShaktiReg<27, "x27", ["s11"]>, DwarfRegNum<[27]>;
        def X28 : ShaktiReg<28, "x28", ["t3"]>, DwarfRegNum<[28]>;
        def X29 : ShaktiReg<29, "x29", ["t4"]>, DwarfRegNum<[29]>;
        def X30 : ShaktiReg<30, "x30", ["t5"]>, DwarfRegNum<[30]>;
        def X31 : ShaktiReg<31, "x31", ["t6"]>, DwarfRegNum<[31]>;
    }
}

def XLenRI : RegInfoByHwMode<
        [RV32, RV64],
        [RegInfo<32,32,32>, RegInfo<64,64,64>]>;

class ShaktiRegisterClass<list<ValueType> regTypes, int align, dag regList>
    : RegisterClass<"Shakti", regTypes, align, regList> {

        bit IsVRegClass = 0;
        int VLMul = 1;
        int NF = 1;

        let TSFlags{0} = IsVRegClass;
        let TSFlags{2-1} = !logtwo(VLMul);
        let TSFlags{5-3} = !sub(NF, 1);
}

class GPRRegisterClass<dag regList>
    : ShaktiRegisterClass<[], 32, regList> {
        
        let RegInfos = XLenRI;
}

// the order of registers represents the preferred allocation sequence
// registers are listed in the order caller-save, callee-save, specials
def GPR : GPRRegisterClass<(add (sequence "X%u", 10, 17),
                                (sequence "X%u", 5, 7),
                                (sequence "X%u", 28, 31),
                                (sequence "X%u", 8, 9),
                                (sequence "X%u", 18, 27),
                                (sequence "X%u", 0, 4))>;

def GPRX0 : GPRRegisterClass<(add X0)>;

def GPRX1 : GPRRegisterClass<(add X1)> {
    let DiagnosticType = "InvalidRegClassGPRX1";
    let DiagnosticString = "register must be ra (x1)";
}

def GPRX5 : GPRRegisterClass<(add X5)> {
    let DiagnosticType = "InvalidRegClassGPRX5";
    let DiagnosticString = "register must be t0 (x5)";
}

def GPRNoX0 : GPRRegisterClass<(sub GPR, X0)> {
    let DiagnosticType = "InvalidRegClassGPRNoX0";
    let DiagnosticString = "register must be a GPR excluding zero (x0)";
}

def GPRNoX2 : GPRRegisterClass<(sub GPR, X2)> {
    let DiagnosticType = "InvalidRegClassGPRNoX2";
    let DiagnosticString = "register must be a GPR excluding sp (x2)";
}

def GPRNoX0X2 : GPRRegisterClass<(sub GPR, X0, X2)> {
    let DiagnosticType = "InvalidRegClassGPRNoX0X2";
    let DiagnosticString = "register must be a GPR excluding zero (x0) and sp (x2)";
}

def GPRX7 : GPRRegisterClass<(add X7)>;

// dont use x1 or x5 for jalr since that is a hint to pop the return address
// stack on some microarchitectures. also remove the reserved registers
// x0, x2. x3 and x4 as it reduces the number of register classes that get
// synthesized by tablegen
def GPRJALR : GPRRegisterClass<(sub GPR, (sequence "X%u", 0, 5))>;
def GPRJALRNonX7 : GPRRegisterClass<(sub GPRJALR, X7)>;
def GPRC : GPRRegisterClass<(add (sequence "X%u", 10, 15),
                                 (sequence "X%u", 8, 9))>;

// for indirect tail calls, we cant use callee saved registers as they are
// restored to the saved value before the tail call, which would clobber a call
// address. we shouldnt use x5 since that is a hint for to pop the return
// address stack on some microarchitectures
def GPRTC : GPRRegisterClass<(add (sequence "X%u", 6, 7),
                                  (sequence "X%u", 10, 17),
                                  (sequence "X%u", 28, 31))>;
def GPRTCNonX7 : GPRRegisterClass<(sub GPRTC, X7)>;

def SP : GPRRegisterClass<(add X2)> {
    let DiagnosticType = "InvalidRegClassSP";
    let DiagnosticString = "register must be sp (x2)";
}

def GPRX1X5 : GPRRegisterClass<(add X1, X5)> {
    let DiagnosticType = "InvalidRegClassGPRX1X5";
    let DiagnosticString = "register must be ra or t0 (x1 or x5)";
}

def GPRNoX31 : GPRRegisterClass<(sub GPR, X31)> {
    let DiagnosticType = "InvalidRegClassGPRX31";
    let DiagnosticString = "register must be a GPR excluding t6 (x31)";
}

// even-odd gpr pairs
def XLenPairRI : RegInfoByHwMode<
    [RV32, RV64],
    [RegInfo<64, 64, 32>, RegInfo<128, 128, 64>]>;

// dummy zero register for use in the register pair containing x0
// (as x1 is not read to or written when the x0 register pair is used)
def DUMMY_REG_PAIR_WITH_X0 : ShaktiReg<0, "0">;

// must add DUMMY_REG_PAIR_WITH_X0 to a separate register class to prevent the
// register's existence from changing codegen (due to the regPressureSetLimit)
// for the GPR register class being altered
def GPRAll : GPRRegisterClass<(add GPR, DUMMY_REG_PAIR_WITH_X0)>;

let RegAltNameIndices = [ABIRegAltName] in {
    
    def X0_Pair : ShaktiRegWithSubRegs<0, X0.AsmName, 
                                       [X0, DUMMY_REG_PAIR_WITH_X0], X0.AltNames> {
        let SubRegIndices = [sub_gpr_even, sub_gpr_odd];
        let CoveredBySubRegs = 1;
    }

    foreach I = 1-15 in {
        defvar Index = !shl(I, 1);
        defvar IndexP1 = !add(Index, 1);
        defvar Reg = !cast<Register>("X"#Index);
        defvar RegP1 = !cast<Register>("X"#IndexP1);
        def "X" # Index #"_X" # IndexP1 : ShaktiRegWithSubRegs<Index, 
                                                               Reg.AsmName,
                                                               [Reg, RegP1], 
                                                               Reg.AltNames> {
            let SubRegIndices = [sub_gpr_even, sub_gpr_odd];
            let CoveredBySubRegs = 1;
        } 
    }
}

let RegInfos = XLenPairRI, CopyCost = 2 in {
    def GPRPair : ShaktiRegisterClass<[], 64, (add 
    X10_X11, X12_X13, X14_X15, X16_X17,
    X6_X7,
    X28_X29, X30_X31,
    X8_X9,
    X18_X19, X20_X21, X22_X23, X24_X25, X26_X27,
    X0_Pair, X2_X3, X4_X5
    )>;

    def GPRPairNoX0 : ShaktiRegisterClass<[], 64, (sub GPRPair, X0_Pair)>;

    def GPRPairC : ShaktiRegisterClass<[], 64, (add 
     X10_X11, X12_X13, X14_X15, X8_X9)>;
} // let RegInfos = XLenPairRI, CopyCost=2