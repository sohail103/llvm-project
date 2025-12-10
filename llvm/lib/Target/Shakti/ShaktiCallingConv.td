// calling conventions for risc v
// the risc v calling convention is handled with custom code in RISCVISelLowering.cpp

// for embedded calling convention which tries to use fewer registers
// function must save X1(return address), X8(frame pointer), X9(saved register 1)
def CSR_ILP32E : CalleeSavedRegs<(add X1, X8, X9)>; 

// take embedded list defined above and add X18 through X27 which correspond to s2-s11
// standard unix like calling convention 
def CSR_ILP32 : CalleeSavedRegs<(add CSR_ILP32E, (sequence "X%u", 18, 27))>;

// needed for implementation of ShaktiRegisterInfo::getNoPreservedMask()
def CSR_NoRegs : CalleeSavedRegs<(add)>;

def CSR_IPRA : CalleeSavedRegs<(add X1)>;

// interrupt handler needs to save/restore all registers that are used,
// both caller and callee saved registers - because executing code had no 
// idea it was going to be interrupted
def CSR_Interrupt : CalleeSavedRegs<(add X1, (sequence "X%u", 5, 31))>;

def CSR_RT_MostRegs : CalleeSavedRegs<(sub CSR_Interrupt, X6, X7, X28)>;

// not defining CSR_RT_MostRegs_RVE for embedded set