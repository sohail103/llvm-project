// Shakti register definitions

// declarations to describe shakti register files
let Namespace = "Shakti" in {
    class ShaktiReg<bits<5> Enc, string n, list<string> alt = []> : Register<n> {
        let HWEncoding{4-0} = Enc;
        let AltNames = alt;
    }
}

let FallbackRegAltNameIndex = NoRegAltName in
def ABIRegAltName : RegAltNameIndex;

// general purpose registers (aka integer registers)
// CostPerUse is set higher for registers that may not be compressible as they 
// are not part of GPRC, the most restrictive register class used by the 
// compressed instruction set. this will influence the greedy register allocator
// to reduce the use of registers that cant be encoded in 16 bit instructions

