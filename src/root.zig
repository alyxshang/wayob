// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

// Exporting the module containing
// functions to perform very 
// instruction-specific operations.
pub const fns = @import("fns.zig");

// Exporting the module containing
// functions to load a dynamic library
// and run a function defined in that
// library.
pub const ffi = @import("ffi.zig");

// Exporting the module containing
// the data structure to catch
// and handle errors.
pub const err = @import("err.zig");

// Exporting the module containing
// the main function to run a set
// of instructions.
pub const run = @import("run.zig");

// Exporting the module containing
// the data structure containing all
// possible instructions the VM
// can run.
pub const inst = @import("inst.zig");

// Exporting the module containing
// the VM's stack and all involved
// data structures.
pub const stack = @import("stack.zig");
