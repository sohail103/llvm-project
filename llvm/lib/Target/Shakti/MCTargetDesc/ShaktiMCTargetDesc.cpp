#include "ShaktiMCTargetDesc.h"
#include "ShaktiELFStreamer.h"
#include "ShaktiInstPrinter.h"
#include "ShaktiMCAsmInfo.h"
#include "ShaktiMCObjectFileInfo.h"
#include "ShaktiTargetStreamer.h"
#include "TargetInfo/ShaktiTargetInfo.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCInstrAnalysis.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include <bitset>

#define GET_INSTRINFO_MC_DESC
#define ENABLE_INSTR_PREDICATE_VERIFIER
#include "ShaktiGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "ShaktiGenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "ShaktiGenSubtargetInfo.inc"