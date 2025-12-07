#include "llvm/TableGen/SearchableTable.td"

class SysReg <string name, bits<12> op> // generic CSR format
{
    string Name = name;
    
    string EnumName = !subst(".", "_", name); // for custom vendor CSRs with a <vendor>. prefix
    bits<12> Encoding = op;

    // privilege access: read and write = 0, 1, 2; read only = 3
    // privilege mode: user = 0, system = 1, machine = 3
    // bits<2> ReadWrite = op{11-10};
    // bits<2> XMode = op{9-8};

    code FeaturesRequired = [{ {} }];
    bit isRV32Only = 0;
    bit isAltName = 0;
    bit isDeprecatedName = 0;
}

def SysRegsList : GenericTable {     // table for all CSRs
    let FilterClass = "SysReg";
    let Fields = [
        "Name", "Encoding", "FeaturesRequired",
        "isRV32Only", "isAltName", "isDeprecatedName"
    ];

    let PrimaryKey = [ "Encoding" ];
    let PrimaryKeyName = "lookupSysRegByEncoding";
    let PrimaryKeyReturnRange = true;
}

def SysRegEncodings : GenericEnum {  // enum used for convenience while building backend
    let FilterClass = "SysReg";
    let NameField = "EnumName";
    let ValueField = "Encoding";
}

def lookupSysRegByName : SearchIndex {  // function for assembler to look up CSR from string name
    let Table = SysRegsList;
    let Key = [ "Name" ];
}

// unprivileged counters/timers - user counters/timers in spec
def CYCLE   : SysReg<"cycle", 0xC00>;       // cycle counter for RDCYCLE instruction
def TIME    : SysReg<"time", 0xC01>;        // timer for RDTIME instruction
def INSTRET : SysReg<"instret", 0xC02>;     // instructions retired counter for RDINSTRET instruction

// hpmcounter3-hpmcounter31 - performance monitoring counter
foreach i = 3...31 in
    def : SysReg<"hpmcounter"#i, !add(0xC03, !sub(i, 3))>;

// RV32I specific CSRs
let isRV32Only = 1 in 
{
    def CYCLEH      : SysReg<"cycleh", 0xC80>;
    def TIMEH       : SysReg<"timeh", 0xC81>;
    def INSTRETH    : SysReg<"instreth", 0xC82>;

    // hpmcounter3h-hpmcounter31h - performance monitoring counters high bits
    foreach i = 3...31 in
        def : SysReg<"hpmcounter"#i#"h", !add(0xC83, !sub(i, 3))>;
}