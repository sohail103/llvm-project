#ifndef LLVM_LIB_TARGET_SHAKTI_MCTARGETDESC_SHAKTITARGETSTREAMER_H
#define LLVM_LIB_TARGET_SHAKTI_MCTARGETDESC_SHAKTITARGETSTREAMER_H

#include "Shakti.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/FormattedStream.h"

namespace llvm {

class formatted_raw_ostream;

enum class ShaktiOptionArchArgType {
  Full,
  Plus,
  Minus,
};

struct ShaktiOptionArchArg {
  ShaktiOptionArchArgType Type;
  std::string Value;

  ShaktiOptionArchArg(ShaktiOptionArchArgType Type, std::string Value)
      : Type(Type), Value(Value) {}
};

class ShaktiTargetStreamer : public MCTargetStreamer {
  ShaktiABI::ABI TargetABI = ShaktiABI::ABI_Unknown;
  bool HasRVC = false;
  bool HasTSO = false;

public:
  ShaktiTargetStreamer(MCStreamer &S);
  void finish() override;
  virtual void reset();

  virtual void emitDirectiveOptionArch(ArrayRef<ShaktiOptionArchArg> Args);
  virtual void emitDirectiveOptionExact();
  virtual void emitDirectiveOptionNoExact();
  virtual void emitDirectiveOptionPIC();
  virtual void emitDirectiveOptionNoPIC();
  virtual void emitDirectiveOptionPop();
}
} // namespace llvm