// Shakti subtarget features and instruction predicates

// instruction predicates - boolean conditions attached to instruction definitions (usually in tablegen files)
// - control when an instruction is valid, when an instruction should be selected during instruction selection, how an instruction behaves depending on subtarget features, etc

// Subclass of SubtargetFeature to be used when feature is also a risc v extension
// "FeatureStdExt" for standard extensions
// "Featurevendor" for vendor-specific extensions
// - according to official llvm risc v backend
// major - major version of extension
// minor - minor version of extension
// (V1.0 => major = 1, minor = 0)
// desc - description of extension
// implies - extensions or features implied by this extension
// fieldname - i think it substitutes Feature with Has in record name 
// value - value to assign to the field when extension is enabled, usually true
// isExperimental - indicates whether the extension is experimental

// this might look like a cpp template class definition but it is actually a tablegen record generator. c++ code is generated from this
class ShaktiExtension<int major, int minor, string desc,
                    list<SubtargetFeature> implies = [],
                    string fieldname = !subst("Feature", "Has", NAME),
                    string value = "true", bit IsExperimental = false>
    : SubtargetFeature<NAME, fieldname, value, "", implies>
    // Name field was left empty on purpose as we are parsing extensions from string passed to -march and not from -mattr
    // in this backend, we are giving in NAME so that we can disable options using mattr easier
    // parsing logic is in RISCVISAParsing.cpp
{
    defvar extName = !subst("FeatureVendor", "", !subst("FeatureStdExt", "", NAME));

    // Name - name of the extension in lowercase
    let Name = !if(IsExperimental, "experimental-", "") # !tolower(extName);

    // Desc - description of extension with its name
    let Desc = "'" # extName # "'(" # desc # ")";

    // MajorVersion - major version for this extension
    int MajorVersion = major;

    // MinorVersion - minor version for this extension
    int MinorVersion = minor;

}

// groupID/bitmask of ShaktiExtension (corresponds to RISCVExtension) is used to retrieve a specific bit value from
// __riscv_feature_bits based on the groupID and bitmask
// groupID - groupID of extension
// bitPos - bit position of extension bitmask
class ShaktiExtensionBitmask<bits<3> groupID, int bitPos> {
    int GroupID = groupID;
    int BitPos = bitPos;
}

// base integer instruction set v2.0 according to risc v isa manual v2.2 (from 2017)
// extension version is different from current risc v backend
// bitmask is assumed to be same
def FeatureStdExtI
    : ShaktiExtension<2, 0, "base integer instruction set v2.0">,
      ShaktiExtensionBitmask<0, 8>;

// embedded base integer instruction set v1.9 - will implement later - needs changes in register info, calling convention, etc
// reduces number of integer registers to 16 and remove counters that are mandatory in rv32i
// def FeatureStdExtE
//    : ShaktiExtension<1, 9, "embedded instruction set with 16 GPRs">,
//      ShaktiExtensionBitmask<0, 4>;

// multiply extensions
// Zmmul is an extension that is a subset of M - contains only multiplication instructions
def FeatureStdExtZmmul
    : ShaktiExtension<1, 0, "integer multiplication">;
def HasStdExtZmmul : Predicate<"Subtarget->hasStdExtZmmul()">,
                     AssemblerPredicate<(all_of FeatureStdExtZmmul),
                     "'Zmmul' (integer multiplication)">;

// M - contains instructions for multiplication and division
// for the Shakti platform, we only need M.
// Separation between Zmmul and M is only needed if Zmmul is supported without M
// but for the sake of having an example of an implied extension, we keep Zmmul
def FeatureStdExtM
    : ShaktiExtension<2, 0, "integer multiplication and division",
                            [FeatureStdExtZmmul]>,
      ShaktiExtensionBitmask<0, 12>;
def HasStdExtM : Predicate<"Subtarget->hasStdExtM()">,
                 AssemblerPredicate<(all_of FeatureStdExtM),
                    "'M' (integer multiplication and division)">;

// atomic extensions
def FeatureStdExtZaamo
    : ShaktiExtension<1, 0, "atomic memory operations">;
def HasStdExtZaamo
    : Predicate<"Subtarget->hasStdExtZaamo()">,
      AssemblerPredicate<(any_of FeatureStdExtZaamo),
                "'Zaamo' (atomic memory operations)">;
def NoStdExtZaamo : Predicate<"!Subtarget->hasStdExtZaamo()">;

def FeatureStdExtZalrsc
    : ShaktiExtension<1, 0, "load-reserved/store-conditional">;
def HasStdExtZalrsc
    : Predicate<"Subtarget->hasStdExtZalrsc()">,
      AssemblerPredicate<(any_of FeatureStdExtZalrsc),
                "'Zalrsc' (load-reserved/store-conditional)">;

def FeatureStdExtA
    : ShaktiExtension<2, 0, "atomic instructions",
                            [FeatureStdExtZaamo, FeatureStdExtZalrsc]>,
      ShaktiExtensionBitmask<0, 0>;
def HasStdExtA : Predicate<"Subtarget->hasStdExtA()">,
                 AssemblerPredicate<(all_of FeatureStdExtA),
                    "'A' (atomic instructions)">;

// compressed extensions
def FeatureStdExtZca
    : ShaktiExtension<1, 0, "subset of C extension">,
      ShaktiExtensionBitmask<1,2>;
def HasStdExtZca
    : Predicate<"Subtarget->hasStdExtZca()">,
      AssemblerPredicate<(any_of FeatureStdExtZca), 
                    "'Zca' (subset of the C extension)">;

def FeatureStdExtC
    : ShaktiExtension<2, 0, "compressed instructions", [FeatureStdExtZca]>,
      ShaktiExtensionBitmask<0,2>;
def HasStdExtC : Predicate<"Subtarget->hasStdExtC()">,
                 AssemblerPredicate<(all_of FeatureStdExtC),
                    "'C' (compressed instructions)">;

def FeatureStdExtZicsr
    : ShaktiExtension<2, 0, "CSRs">;
def HasStdExtZicsr : Predicate<"Subtarget->hasStdExtZicsr()">,
                     AssemblerPredicate<(all_of FeatureStdExtZicsr),
                        "'Zicsr' (CSRs)">;

def FeatureStdExtZifencei
    : ShaktiExtension<2, 0, "fence.i">;
def HasStdExtZifencei : Predicate<"Subtarget->hasStdExtZifencei()">,
                        AssemblerPredicate<(all_of FeatureStdExtZifencei),
                        "'Zifencei' (fence.i)">;

def Feature32Bit
    : SubtargetFeature<"32bit", "IsRV32", "true", "Implements RV32">;
def Feature64Bit
    : SubtargetFeature<"64bit", "IsRV64", "true", "Implements RV64">;
def IsRV32 : Predicate<"!Subtarget->is64Bit()">,
             AssemblerPredicate<(all_of (not Feature64Bit)), 
                                "RV32I Base instruction set">;
def IsRV64 : Predicate<"Subtarget->is64Bit()">,
             AssemblerPredicate<(all_of Feature64Bit),
                                "RV64I Base instruction set">;

defvar RV32 = DefaultMode;
def RV64 : HwMode<[IsRV64]>;