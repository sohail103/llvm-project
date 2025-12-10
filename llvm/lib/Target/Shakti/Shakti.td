#include "llvm/Target/Target.td"

#include "ShaktiFeatures.td" // subtarget features and instruction predicates

#include "ShaktiProfiles.td" // currently only defines a profile for the shakti e class

#include "ShaktiSystemOperands.td" // named operands for csr instructions

#include "ShaktiRegisterInfo.td" // register descriptions for GPRs and other register classes for optimizations

#include "ShaktiSchedule.td"

#include "ShaktiCallingConv.td" // describes calling conventions for risc v
                                // the risc v calling convention is handled 
                                // with custom code in RISCVISelLowering.cpp (CC_RISCV)