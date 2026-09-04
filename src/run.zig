// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

// Importing the standard
// namespace.
const std = @import("std");

// Importing the "ArrayList" structure
// from the standard library.
const ArrayList = std.ArrayList;

// Importing the "Allocator"
// structure from the standard
// library.
const Allocator = std.mem.Allocator; 

/// Importing the data structure representing
/// the stack of the Wayob VM.
const Stack = @import("stack.zig").Stack;

// Importing the structure to catch
// and handle errors.
const WayobErr = @import("err.zig").WayobErr;

// Importing the function to check if
// the first frame data unit is less
// than the second.
const ltValues = @import("fns.zig").ltValues;

// Importing the function to check if
// the first frame data unit is equal to
// the second.
const eqValues = @import("fns.zig").eqValues;

// Importing the function to check if
// the first frame data unit is greater
// than the second.
const gtValues = @import("fns.zig").gtValues;

// Importing the function to perform a modulus
// operation on two integer units of data.
const modValues = @import("fns.zig").modValues;

// Importing the function to check if
// the first frame data unit is not equal
// the second.
const neqValues = @import("fns.zig").neqValues;

// Importing the function to add two frame
// data units together.
const addValues = @import("fns.zig").addValues;

// Importing the function to subtract two frame
// data units from each other.
const subValues = @import("fns.zig").subValues;

// Importing the function to multiply two frame
// data units with each other.
const mulValues = @import("fns.zig").mulValues;

// A function to run a function inside
// a dynamic library.
const runExtern = @import("ffi.zig").runExtern;

// Importing the function to divide two frame
// data units by each other.
const divValues = @import("fns.zig").divValues;

// Importing the structure representing
// a single unit of data on the stack.
const FrameData = @import("stack.zig").FrameData;

// Importing the enumeration union
// representing every possible 
// instruction that the VM 
// "understands".
const Instruction = @import("inst.zig").Instruction;

/// A function to loop through the array of
/// instructions, load data from the constant
/// pool and execute instructions. If retrieval
/// execution or allocation fails, an error 
/// is returned.
pub fn runInstructions(
    allocator: Allocator,
    const_pool: *ArrayList(FrameData),
    instruction_pool: *const ArrayList(Instruction)
) !FrameData {
    var cursor: u64 = 0;
    var stack: Stack = Stack.init(allocator);
    defer stack.deinit();
    while (cursor < instruction_pool.items.len) {
        const inst: Instruction = instruction_pool.items[cursor];
        switch (inst){
            .ADD => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try addValues(&one, &two));
                cursor = cursor + 1;
            },
            .MODULO => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try modValues(&one, &two));
                cursor = cursor + 1;
            },
            .SUB => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try subValues(&one, &two));
                cursor = cursor + 1;
            },
            .DIV => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try divValues(&one, &two));
                cursor = cursor + 1;
            },
            .MUL => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try mulValues(&one, &two));
                cursor = cursor + 1;
            },
            .CALL => |idx| {
                const possible_fn: FrameData = const_pool.items[idx];
                if (possible_fn == .Function){
                    const arg_count: u64 = possible_fn.Function.arg_count;
                    var fn_const_pool: ArrayList(FrameData) = ArrayList(FrameData)
                        .init(allocator); 
                    defer {
                        for (fn_const_pool.items) |item| {
                            item.deinit(allocator);
                        }
                        fn_const_pool.deinit();
                    }
                    for (0..arg_count) |_| {
                        const popped: FrameData = try stack.pop();
                        const cloned: FrameData = try popped.clone(allocator);
                        errdefer cloned.deinit(allocator);
                        fn_const_pool.append(cloned)
                           catch return WayobErr.WriteErr;
                    } 
                    const result: FrameData = try runInstructions(
                        allocator,
                        &fn_const_pool,
                        &possible_fn.Function.instructions
                    );
                    try stack.push(result);
                    cursor = cursor + 1;
                }
                else {
                    return WayobErr.TypeError;
                }
            },
            .RETURN => {
                const data: FrameData = try stack.pop();
                return data;
            },
            .JUMP_FRWD => |idx| cursor = cursor + idx,
            .LOAD_CONST => |idx| {
                const loaded: FrameData = const_pool.items[idx];
                try stack.push(loaded);
                cursor = cursor + 1;
            },
            .STORE_CONST => {
                const popped: FrameData = try stack.pop();
                const_pool.append(popped)
                    catch return WayobErr.WriteErr;
                cursor = cursor + 1;
            },
            .MODIFY_CONST => |idx| {
                const popped: FrameData = try stack.pop();
                const Tag = @typeInfo(FrameData).@"union".tag_type.?;
                if (@as(Tag,const_pool.items[idx]) == @as(Tag, popped)){
                    const_pool.items[idx] = popped;
                    cursor = cursor + 1;
                }
                else {
                    return WayobErr.TypeError;
                }
            },
            .COMPARE_EQ => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try eqValues(&one, &two));
                cursor = cursor + 1;
            },
            .COMPARE_GT => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try gtValues(&one, &two));
                cursor = cursor + 1;
            },
            .COMPARE_LT => {
                const one: FrameData = try stack.pop(); // 18
                const two: FrameData = try stack.pop(); // 19
                try stack.push(try ltValues(&one, &two));
                cursor = cursor + 1;
            },
            .COMPARE_NEQ => {
                const one: FrameData = try stack.pop();
                const two: FrameData = try stack.pop();
                try stack.push(try neqValues(&one, &two));
                cursor = cursor + 1;
            },
            .CREATE_STRUCT => |idx| {
                    var struct_fields: ArrayList(FrameData) = ArrayList(FrameData)
                        .init(allocator); 
                    errdefer {
                        for (struct_fields.items) |item| {
                            item.deinit(allocator);
                        }
                        struct_fields.deinit();
                    }
                    for (0..idx) |_| {
                        const popped: FrameData = try stack.pop();
                        const cloned: FrameData = try popped.clone(allocator);
                        errdefer cloned.deinit(allocator);
                        struct_fields.append(cloned)
                           catch return WayobErr.WriteErr;
                    }
                    const data: FrameData = FrameData{
                        .Structure = struct_fields
                    };
                    try stack.push(data);
                    cursor = cursor + 1;
            },
            .EXTERN_CALL => |idx| {
                const possible_fn: FrameData = const_pool.items[idx];
                if (possible_fn == .ExternFunction){
                    const arg_count: u64 = possible_fn.ExternFunction.arg_count;
                    var fn_const_pool: ArrayList(FrameData) = ArrayList(FrameData)
                        .init(allocator); 
                    defer {
                        for (fn_const_pool.items) |item| {
                            item.deinit(allocator);
                        }
                        fn_const_pool.deinit();
                    }
                    for (0..arg_count) |_| {
                        const popped: FrameData = try stack.pop();
                        const cloned: FrameData = try popped.clone(allocator);
                        errdefer cloned.deinit(allocator);
                        fn_const_pool.append(cloned)
                           catch return WayobErr.WriteErr;
                    } 
                    const result: FrameData = try runExtern(
                        possible_fn.ExternFunction.lib_name,
                        possible_fn.ExternFunction.function_name,
                        &fn_const_pool,
                        allocator
                    );
                    try stack.push(result);
                    cursor = cursor + 1;
                }
                else {
                    return WayobErr.TypeError;
                }
            },
            .JUMP_BACK_IF_TRUE => |idx| {
                const comp: FrameData = try stack.pop();
                if (comp == .Bool){
                    if(comp.Bool == true){
                        cursor = cursor - idx;
                    }
                    else {
                        cursor = cursor + 1;
                    }
                }
                else {
                    return WayobErr.TypeError;
                }
            },
            .JUMP_FRWD_IF_TRUE => |idx| {
                const comp: FrameData = try stack.pop();
                if (comp == .Bool){
                    if(comp.Bool == true){
                        cursor = cursor + idx;
                    }
                    else {
                        cursor = cursor + 1;
                    }
                }
                else {
                    return WayobErr.TypeError;
                }
            },
        }
    }
    return WayobErr.MissingValue;
}
