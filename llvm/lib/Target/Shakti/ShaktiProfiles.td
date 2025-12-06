// currently only defines a profile for the shakti e class
// a SubtargetFeature that implies all the extensions of the shakti e class

defvar ExtensionsShaktiEClass = [Feature32Bit,
                              FeatureStdExtI,
                              FeatureStdExtM,
                              FeatureStdExtA,
                              FeatureStdExtC,
                              FeatureStdExtZicsr,
                              FeatureStdExtZifencei];

class ShaktiProfile<string name, list<SubtargetFeature> features>
    : SubtargetFeature<name, "Is" # NAME, "true",
                        "RISC-V " # name # " profile", features> 
{
    bit Experimental = false;   
}

def ShaktiEClass : ShaktiProfile<"shakti-e-extensions", ExtensionsShaktiEClass>;