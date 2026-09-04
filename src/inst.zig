// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

/// An enumeration union representing
/// all possible instructions the Wayob
/// virtual machine can run or "interpret."
pub const Instruction = union(enum) {
    ADD: void,
    SUB: void,
    DIV: void,
    MUL: void,
    CALL: u64,
    MODULO: void,
    RETURN: void,
    JUMP_FRWD: u64, 
    LOAD_CONST: u64,
    EXTERN_CALL: u64,
    COMPARE_EQ: void,
    COMPARE_GT: void,
    COMPARE_LT: void,
    COMPARE_NEQ: void,
    STORE_CONST: void,
    MODIFY_CONST: u64,
    CREATE_STRUCT: u64, 
    JUMP_BACK_IF_TRUE: u64,
    JUMP_FRWD_IF_TRUE: u64,
};
