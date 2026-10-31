// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

// Importing the standard
// namespace.
const std = @import("std");

// Importing the module containing
// functions for basic VM operations.
const fns = @import("fns.zig");

// Importing the module containing
// functions to load dynamic libraries
// and execute functions stored in them.
const ffi = @import("ffi.zig");

// Importing the module containing
// functions for basic VM operations.
const run = @import("run.zig");

// Importing the module containing
// the VM's instruction set.
const inst = @import("inst.zig");

// Importing the module containing
// structures associated with the
// stack to test it.
const stack = @import("stack.zig");

// Testing the module associated with the stack.
test "Testing the module associated with the stack." {
    var ms: stack.Stack = stack.Stack.init(
        std.testing.allocator
    );
    defer ms.deinit();
    var f_one: stack.FrameData = stack.FrameData{
        .Integer = 2
    };
    defer f_one.deinit(std.testing.allocator);
    var f_two: stack.FrameData = stack.FrameData{
        .Integer = 3
    };
    defer f_two.deinit(std.testing.allocator);
    try ms.push(f_one);
    try ms.push(f_two);
    var p_one: stack.FrameData = try ms.pop();
    defer p_one.deinit(std.testing.allocator);
    var p_two: stack.FrameData = try ms.pop();
    defer p_two.deinit(std.testing.allocator);
    try std.testing.expect(p_one.Integer == 3);
    try std.testing.expect(p_two.Integer == 2);
}

// Testing the module containing basic VM functions.
test "Testing the module containing basic VM functions." {
    var f_one: stack.FrameData = stack.FrameData{
        .FloatingPoint = 64.8
    };
    defer f_one.deinit(std.testing.allocator);
    var f_two: stack.FrameData = stack.FrameData{
        .FloatingPoint = 45.8
    };
    defer f_two.deinit(std.testing.allocator);
    var i_one: stack.FrameData = stack.FrameData{
        .Integer = 6
    };
    defer i_one.deinit(std.testing.allocator);
    var i_two: stack.FrameData = stack.FrameData{
        .Integer = 6
    };
    defer i_two.deinit(std.testing.allocator);
    const added: stack.FrameData = try fns.addValues(
        &f_one,
        &f_two
    );
    const subbed: stack.FrameData = try fns.subValues(
        &f_one,
        &f_two
    );
    const muld: stack.FrameData = try fns.mulValues(
        &f_one,
        &f_two
    );
    const divd: stack.FrameData = try fns.divValues(
        &f_one,
        &f_two
    );
    const eqd: stack.FrameData = try fns.eqValues(
        &f_one,
        &f_two
    );
    const neqd: stack.FrameData = try fns.neqValues(
        &f_one,
        &f_two
    );
    const ltd: stack.FrameData = try fns.ltValues(
        &f_one,
        &f_two
    );
    const gtd: stack.FrameData = try fns.gtValues(
        &f_one,
        &f_two
    );
    const mi: stack.FrameData = try fns.modValues(
        &i_one,
        &i_two
    );
    try std.testing.expect(added.FloatingPoint == 110.6);
    try std.testing.expect(subbed.FloatingPoint == 19.0);
    try std.testing.expect(divd.FloatingPoint != 0.0);
    try std.testing.expect(muld.FloatingPoint != 0.0);
    try std.testing.expect(eqd.Bool != true);
    try std.testing.expect(neqd.Bool == true);
    try std.testing.expect(ltd.Bool != true);
    try std.testing.expect(gtd.Bool == true);
    try std.testing.expect(mi.Integer == 0);
}

// Testing the module containing the main function to
// run a set of instructions.
test "Testing the function to run instructions." {
    var consts: std.ArrayList(stack.FrameData) = .empty;
    defer {
        for (consts.items) |*item| {
            item.deinit(std.testing.allocator);
        }
        consts.deinit(std.testing.allocator);
    }
    const c_one: stack.FrameData = stack.FrameData {
        .Integer = 1
    };
    const c_two: stack.FrameData = stack.FrameData {
        .Integer = 3
    };
    const c_three: stack.FrameData = stack.FrameData {
        .Integer = 1
    };
    const c_four: stack.FrameData = stack.FrameData {
        .Integer = 1
    };
    const c_five: stack.FrameData = stack.FrameData {
        .Integer = 2
    };
    const c_six: stack.FrameData = stack.FrameData {
        .Bool = false
    };
    try consts.append(std.testing.allocator,c_one);
    try consts.append(std.testing.allocator,c_two);
    try consts.append(std.testing.allocator,c_three);
    try consts.append(std.testing.allocator,c_four);
    try consts.append(std.testing.allocator,c_five);
    try consts.append(std.testing.allocator,c_six);
    var insts: std.ArrayList(inst.Instruction) = .empty;
    defer insts.deinit(std.testing.allocator);
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 0 });
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 2 });
    try insts.append(std.testing.allocator,.MUL);
    try insts.append(std.testing.allocator,inst.Instruction{ .MODIFY_CONST = 0 });
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 2 });
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 3 });
    try insts.append(std.testing.allocator,.ADD);
    try insts.append(std.testing.allocator,inst.Instruction{ .MODIFY_CONST = 2 });
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 1 });
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 3 });
    try insts.append(std.testing.allocator,.ADD);
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 2 });
    try insts.append(std.testing.allocator,.COMPARE_LT);
    try insts.append(std.testing.allocator,inst.Instruction{ .JUMP_BACK_IF_TRUE = 13 });
    try insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 0 });
    try insts.append(std.testing.allocator,.RETURN);
    var result: stack.FrameData = try run.runInstructions(
        std.testing.allocator,
        &consts,
        &insts
    );
    defer result.deinit(std.testing.allocator);
    var test_insts: std.ArrayList(inst.Instruction) = .empty;
    defer test_insts.deinit(std.testing.allocator);
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 1 });
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 0 });
    try test_insts.append(std.testing.allocator,.SUB);
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 3 });
    try test_insts.append(std.testing.allocator,.DIV);
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 0 });
    try test_insts.append(std.testing.allocator,.COMPARE_GT);
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 5 });
    try test_insts.append(std.testing.allocator,.COMPARE_NEQ);
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 5 });
    try test_insts.append(std.testing.allocator,.COMPARE_EQ);
    try test_insts.append(std.testing.allocator,.STORE_CONST);
    try test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 6 });
    try test_insts.append(std.testing.allocator,.RETURN);
    var test_result: stack.FrameData = try run.runInstructions(
        std.testing.allocator,
        &consts,
        &test_insts
    );
    defer test_result.deinit(std.testing.allocator);
    var fn_call_consts: std.ArrayList(stack.FrameData) = .empty;
    defer {
        for (fn_call_consts.items) |*item| {
            @constCast(item).deinit(std.testing.allocator);
        }
        fn_call_consts.deinit(std.testing.allocator);
    }
    const fcc_one: stack.FrameData = stack.FrameData{
        .Integer = 19
    };
    const amsg: [*:0]const u8 = try std.testing.allocator.dupeSentinel(u8, "Welcome", 0);
    const namsg: [*:0]const u8 = try std.testing.allocator.dupeSentinel(u8, "Not Welcome", 0);
    const fcc_two: stack.FrameData = stack.FrameData {
        .String = amsg
    };
    const fcc_three: stack.FrameData = stack.FrameData {
        .String = namsg
    };
    const fcc_four: stack.FrameData = stack.FrameData{
        .Integer = 18
    };
    var ioe_insts: std.ArrayList(inst.Instruction) = .empty;
    try ioe_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 0 });
    try ioe_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 1 });
    try ioe_insts.append(std.testing.allocator,.COMPARE_GT);
    try ioe_insts.append(std.testing.allocator,.RETURN);
    const fcc_five: stack.FrameData = stack.FrameData {
        .Function = .{
            .arg_count = 2,
            .instructions = ioe_insts
        }
    };
    try fn_call_consts.append(std.testing.allocator,fcc_one);
    try fn_call_consts.append(std.testing.allocator,fcc_two);
    try fn_call_consts.append(std.testing.allocator,fcc_three);
    try fn_call_consts.append(std.testing.allocator,fcc_four);
    try fn_call_consts.append(std.testing.allocator,fcc_five);
    var fn_call_insts: std.ArrayList(inst.Instruction) = .empty;
    defer fn_call_insts.deinit(std.testing.allocator);
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 0 });
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 3 });
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .CALL = 4 });
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .JUMP_FRWD_IF_TRUE = 3});
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 2 });
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .JUMP_FRWD = 2 });
    try fn_call_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 1 });
    try fn_call_insts.append(std.testing.allocator,.RETURN);
    const fn_call_test_result: stack.FrameData = try run.runInstructions(
        std.testing.allocator,
        &fn_call_consts,
        &fn_call_insts
    );
    const eql: bool = std.mem.eql(
        u8,
        std.mem.span(fn_call_test_result.String),
        "Welcome"
    );
    var final_test_consts: std.ArrayList(stack.FrameData) = .empty;
    defer {
        for (final_test_consts.items) |*item| {
            @constCast(item).deinit(std.testing.allocator);
        }
        final_test_consts.deinit(std.testing.allocator);
    }
    const ftc_one: stack.FrameData = stack.FrameData {
        .ExternFunction = .{
            .lib_name = try std
                .testing
                .allocator
                .dupeSentinel(u8, "./libadd", 0),
            .function_name = try std
                .testing
                .allocator
                .dupeSentinel(u8, "add_nums", 0),
            .arg_count = 2
        }
    };
    const ftc_two: stack.FrameData = stack.FrameData {
        .Integer = 111
    };
    const ftc_three: stack.FrameData = stack.FrameData {
        .Integer = 555
    };
    try final_test_consts.append(std.testing.allocator,ftc_one);
    try final_test_consts.append(std.testing.allocator,ftc_two);
    try final_test_consts.append(std.testing.allocator,ftc_three);
    var final_test_insts: std.ArrayList(inst.Instruction) = .empty;
    defer final_test_insts.deinit(std.testing.allocator);
    try final_test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 1 });
    try final_test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 2 });
    try final_test_insts.append(std.testing.allocator,.MODULO);
    try final_test_insts.append(std.testing.allocator,inst.Instruction{ .CREATE_STRUCT = 1 });
    try final_test_insts.append(std.testing.allocator,.STORE_CONST);
    try final_test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 1 });
    try final_test_insts.append(std.testing.allocator,inst.Instruction{ .LOAD_CONST = 2 });
    try final_test_insts.append(std.testing.allocator,inst.Instruction{ .EXTERN_CALL = 0 });
    try final_test_insts.append(std.testing.allocator,.RETURN);
    var final_test_result = try run.runInstructions(
        std.testing.allocator,
        &final_test_consts,
        &final_test_insts
    );
    defer final_test_result.deinit(std.testing.allocator);
    try std.testing.expect(test_result.Bool == false);
    try std.testing.expect(result.Integer == 6);
    try std.testing.expect(final_test_consts.items.len == 4);
    try std.testing.expect(final_test_result.Integer == 666);
    try std.testing.expect(eql);
}

// Testing the module containing functions for FFI.
test "Testing the module containing functions for FFI." {
    var test_frame: stack.FrameData = stack.FrameData{
        .Integer = 4
    };
    defer test_frame.deinit(std.testing.allocator);
    const c_frame: ffi.CFrame = try ffi.toCFrame(
        &test_frame, 
        std.testing.allocator
    );
    defer c_frame.deinit(std.testing.allocator);
    var bc: stack.FrameData = try ffi.fromCFrame(
        &c_frame,
        std.testing.allocator
    );
    defer bc.deinit(std.testing.allocator);
    var data_frames: std.ArrayList(stack.FrameData) = .empty;
    defer {
        for (data_frames.items) |*item| {
            @constCast(item).deinit(std.testing.allocator);
        }
        data_frames.deinit(std.testing.allocator);
    }
    const dupd = try std.testing.allocator.dupeSentinel(u8, "Hello", 0);
    try data_frames.append(std.testing.allocator,stack.FrameData{ .String = dupd });
    try data_frames.append(std.testing.allocator,stack.FrameData{ .Integer = 8 });
    var convd: std.ArrayList(ffi.CFrame) = try ffi.toCFrames(
        &data_frames,
        std.testing.allocator
    );
    defer {
        for (convd.items) |*item| {
            @constCast(item).deinit(std.testing.allocator);
        }
        convd.deinit(std.testing.allocator);
    }
    var sum_args: std.ArrayList(stack.FrameData) = .empty;
    defer {
        for (sum_args.items) |*item| {
            @constCast(item).deinit(std.testing.allocator);
        }
        sum_args.deinit(std.testing.allocator);
    }
    try sum_args.append(std.testing.allocator,stack.FrameData{ .Integer = 111 });
    try sum_args.append(std.testing.allocator,stack.FrameData{ .Integer = 555 });
    const result = try ffi.runExtern(
        "./libadd",
        "add_nums",
        &sum_args,
        std.testing.allocator
    );
    try std.testing.expect(result.Integer == 666);
    try std.testing.expect(c_frame.payload.Integer == 4);
    try std.testing.expect(bc.Integer == 4);
    try std.testing.expect(convd.items.len == 2);
}
