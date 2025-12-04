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
    : SubtargetFeature<"", fieldname, value, "", implies>
    // Name field left empty on purpose as we are parsing extensions from string passed to -march and not from -mattr
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

    //Experimental - does extension requre -menable-experimental-extensions
    bit Experimental = false;
}