// define scheduler resources associated with def operands

def WriteIALU       : SchedWrite;  // 32 or 64 bit integer alu operations
// def WriteIALU32     : SchedWrite; // for forcing 32 bit integer alu operations on rv64i
def WriteShiftImm   : SchedWrite; // 32 or 64 bit shift by immediate operations
def WriteShiftReg   : SchedWrite; // 32 or 64 bit shift by immediate operations
def WriteIDiv       : SchedWrite; // 32 bit or 64 bit divide
def WriteIRem       : SchedWrite; // 32 or 64 bit remainder
def WriteIMul       : SchedWrite; // 32 or 64 bit multiply
def WriteJmp        : SchedWrite; // jump
def WriteJal        : SchedWrite; // jump and link
def WriteJalr       : SchedWrite; // jump and link register
def WriteNop        : SchedWrite;
def WriteLDB        : SchedWrite; // load byte
def WriteLDH        : SchedWrite; // load half word 
def WriteLDW        : SchedWrite; // load word
def WriteCSR        : SchedWrite; // CSR instructions
def WriteSTB        : SchedWrite; // store byte
def WriteSTH        : SchedWrite; // store half word
def WriteSTW        : SchedWrite; // store word
def WriteAtomicW    : SchedWrite; // atomic memory operation word size
def WriteAtomicLDW  : SchedWrite; // atomic load word
def WriteAtomicSTW  : SchedWrite; // atomic store word

// omitting definitions for floating point instructions

// omitting integer to float conversions

// omitting float to integer conversions

// define scheduler resources associated with use operands
def ReadJmp         : SchedRead;
def ReadJalr        : SchedRead;
def ReadCSR         : SchedRead;
def ReadMemBase     : SchedRead;
def ReadStoreData   : SchedRead;
def ReadIALU        : SchedRead;
def ReadShiftImm    : SchedRead;
def ReadShiftReg    : SchedRead;
def ReadIDiv        : SchedRead;
def ReadIRem        : SchedRead;
def ReadIMul        : SchedRead;
def ReadAtomicWA    : SchedRead;
def ReadAtomicWD    : SchedRead;
def ReadAtomicLDW   : SchedRead;    // Atomic load word
def ReadAtomicSTW   : SchedRead;    // Atomic store word