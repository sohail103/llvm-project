#ifndef LLVM_LIB_TARGET_SHAKTI_MCTARGETDESC_SHAKTIMCTARGETDESC_H
#define LLVM_LIB_TARGET_SHAKTI_MCTARGETDESC_SHAKTIMCTARGETDESC_H

#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/DataTypes.h"
#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class Target;

MCCodeEmitter *createShaktiMCCodeEmitter(const MCInstrInfo &MCII,
                                         MCContext &Ctx);

MCAsmBackend *createShaktiAsmBackend(const Target &T,
                                     const MCSubtargetInfo &STI,
                                     const MCRegisterInfo &MRI,
                                     const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter> createShaktiELFObjectWriter(uint8_t OSABI,
                                                                  bool is64Bit);
} // namespace llvm

// define symbolic names for shakti registers
#define GET_REGINFO_ENUM
#include "ShaktiGenRegisterInfo.inc"

// defines symbolic names for shakti instructions
#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_MC_HELPER_DECLS
#include "ShaktiGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "ShaktiGenSubtargetInfo.inc"

#endif