#ifndef LLVM_LIB_TARGET_SHAKTI_SHAKTI_H
#define LLVM_LIB_TARGET_SHAKTI_SHAKTI_H

#include "MCTargetDesc/ShaktiBaseInfo.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class FunctionPass;
class InstructionSelector;
class ModulePass;
class PassRegistry;
class ShaktiRegisterBankInfo;
class ShaktiSubtarget;
class ShaktiTargetMachine;

class ShaktiCodeGenPreparePass
    : public PassInfoMixin<ShaktiCodeGenPreparePass> {
private:
  const ShaktiTargetMachine *TM;

public:
  ShaktiCodeGenPreparePass(const ShaktiTargetMachine *TM) : TM(TM) {}
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

FunctionPass *createShaktiCodeGenPrepareLegacyPass();
void initializeShaktiCodeGenPrepareLegacyPassPass(PassRegistry &);

FunctionPass *createShaktiDeadRegisterDefinitionsPass();
void initializeShaktiDeadRegisterDefinitionsPass(PassRegistry &);

FunctionPass *createShaktiIndirectBranchTrackingPass();
void initializeShaktiIndirectBranchTrackingPass(PassRegistry &);

FunctionPass *createShaktiLandingPadSetupPass();
void initializeShaktiLandingPadSetupPass(PassRegistry &);

FunctionPass *createShaktiISelDag(ShaktiTargetMachine &TM,
                                  CodeGenOptLevel OptLevel);

FunctionPass *createShaktiLateBranchOptPass();
void initializeShaktiLateBranchOptPass(PassRegistry &);

FunctionPass *createShaktiMakeCompressibleOptPass();
void initializeShaktiMakeCompressibleOptPass(PassRegistry &);

FunctionPass *createShaktiGatherScatterLoweringPass();
void initializeShaktiGatherScatterLoweringPass(PassRegistry &);

FunctionPass *createShaktiVectorPeepholePass();
void initializeShaktiVectorPeepholePass(PassRegistry &);

FunctionPass *createShaktiOptWInstrsPass();
void initializeShaktiOptWInstrsPass(PassRegistry &);

FunctionPass *createShaktiFoldMemOffsetPass();
void initializeShaktiFoldMemOffsetPass(PassRegistry &);

FunctionPass *createShaktiMergeBaseOffsetOptPass();
void initializeShaktiMergeBaseOffsetOptPass(PassRegistry &);

FunctionPass *createShaktiExpandPseudoPass();
void initializeShaktiExpandPseudoPass(PassRegistry &);

FunctionPass *createShaktiPreRAExpandPseudoPass();
void initializeShaktiPreRAExpandPseudoPass(PassRegistry &);

FunctionPass *createShaktiExpandAtomicPseudoPass();
void initializeShaktiExpandAtomicPseudoPass(PassRegistry &);

FunctionPass *createShaktiInsertVSETVLIPass();
void initializeShaktiInsertVSETVLIPass(PassRegistry &);
extern char &ShaktiInsertVSETVLIID;

FunctionPass *createShaktiPostRAExpandPseudoPass();
void initializeShaktiPostRAExpandPseudoPass(PassRegistry &);
FunctionPass *createShaktiInsertReadWriteCSRPass();
void initializeShaktiInsertReadWriteCSRPass(PassRegistry &);

FunctionPass *createShaktiInsertWriteVXRMPass();
void initializeShaktiInsertWriteVXRMPass(PassRegistry &);

FunctionPass *createShaktiRedundantCopyEliminationPass();
void initializeShaktiRedundantCopyEliminationPass(PassRegistry &);

FunctionPass *createShaktiMoveMergePass();
void initializeShaktiMoveMergePass(PassRegistry &);

FunctionPass *createShaktiPushPopOptimizationPass();
void initializeShaktiPushPopOptPass(PassRegistry &);
FunctionPass *createShaktiLoadStoreOptPass();
void initializeShaktiLoadStoreOptPass(PassRegistry &);

FunctionPass *createShaktiPreAllocZilsdOptPass();
void initializeShaktiPreAllocZilsdOptPass(PassRegistry &);

FunctionPass *createShaktiZacasABIFixPass();
void initializeShaktiZacasABIFixPass(PassRegistry &);

InstructionSelector *
createShaktiInstructionSelector(const ShaktiTargetMachine &,
                                const ShaktiSubtarget &,
                                const ShaktiRegisterBankInfo &);
void initializeShaktiDAGToDAGISelLegacyPass(PassRegistry &);

FunctionPass *createShaktiPostLegalizerCombiner();
void initializeShaktiPostLegalizerCombinerPass(PassRegistry &);

FunctionPass *createShaktiO0PreLegalizerCombiner();
void initializeShaktiO0PreLegalizerCombinerPass(PassRegistry &);

FunctionPass *createShaktiPreLegalizerCombiner();
void initializeShaktiPreLegalizerCombinerPass(PassRegistry &);

ModulePass *createShaktiPromoteConstantPass();
void initializeShaktiPromoteConstantPass(PassRegistry &);

FunctionPass *createShaktiVLOptimizerPass();
void initializeShaktiVLOptimizerPass(PassRegistry &);

FunctionPass *createShaktiVMV0EliminationPass();
void initializeShaktiVMV0EliminationPass(PassRegistry &);

void initializeShaktiAsmPrinterPass(PassRegistry &);
} // namespace llvm

#endif