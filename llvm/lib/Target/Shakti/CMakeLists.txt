add_llvm_component_group(Shakti)
set (LLVM_TARGET_DEFINITIONS Shakti.td)

tablegen(LLVM ShaktiGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM ShaktiGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM ShaktiGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM ShaktiGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM ShaktiGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM ShaktiGenAsmWriter.inc -gen-asm-writer)
# tablegen(LLVM ShaktiGenDAGISel.inc -gen-dag-isel)

add_llvm_target(ShaktiCodeGen
                ShaktiTargetMachine.cpp
)

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)