// this file describes the RISC V instructions in tablegen format

class ShaktiSDNode<string opcode, SDTypeProfile type_profile,
                   list<SDNodeProperty> properties = []> {
    
    bit HasPassthruOp = false;
    bit HasMaskOp = false;
    let TSFlags{0} = HasPassthruOp;
    let TSFlags{1} = HasMaskOp;
}