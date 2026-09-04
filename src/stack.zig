// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

// Importing the standard
// namespace.
const std = @import("std");

// Importing the "Mutex"
// structure to lock access
// to stack frames.
const Mutex = std.Thread.Mutex;

// Importing the "ArrayList" structure
// from the standard library.
const ArrayList = std.ArrayList;

// Importing the "Allocator"
// structure from the standard
// library.
const Allocator = std.mem.Allocator;

// Importing the structure to catch
// and handle errors.
const WayobErr = @import("err.zig").WayobErr;

/// Importing the enumeration union
/// representing every possible 
/// instruction that the VM 
/// "understands".
const Instruction = @import("inst.zig").Instruction;

/// A union of enumerations to
/// represent one unit of data
/// on the stack.
pub const FrameData = union(enum) {
    Void: void,
    Bool: bool,
    Integer: i64,
    FloatingPoint: f64,
    String: [*:0]const u8,
    Structure: ArrayList(FrameData),
    Function: struct {
        arg_count: u64,
        instructions: ArrayList(Instruction)
    },
    ExternFunction: struct {
        arg_count: u64,
        lib_name: [*:0]const u8,
        function_name: [*:0]const u8,
    },

    /// A function to duplicate
    /// the current instance of
    /// the structure to allow
    /// other scopes to take
    /// ownership. If allocations
    /// fail, an error is returned.
    pub fn clone(
        self: *const FrameData,
        allocator: Allocator
    ) !FrameData {
        switch (self.*){
            .Bool => |b| return FrameData{ .Bool = b },
            .Integer => |i| return FrameData{ .Integer = i },
            .FloatingPoint => |f| return FrameData{ .FloatingPoint = f },
            .String => |s| {
                const dupd: [*:0]const u8 = allocator.dupeZ(
                    u8,
                    std.mem.span(s)
                ) catch return WayobErr.AllocErr;
                return FrameData{ .String = dupd };
            },
            .Structure => |s| {
                var items: ArrayList(FrameData) = ArrayList(FrameData)
                    .init(allocator);
                errdefer {
                    for (items.items) |item| {
                        item.deinit(allocator);
                    }
                    items.deinit();
                }
                for (s.items) |item| {
                    items.append(try item.clone(allocator))
                        catch return WayobErr.WriteErr;
                }
                return FrameData{ .Structure = items };
            },
            .Function => |f| {
                const cloned = try f.instructions.clone();
                return FrameData{
                    .Function = .{
                        .arg_count = f.arg_count,
                        .instructions = cloned
                    }
                };
            },
            .ExternFunction => |e| {
                const dupd_l: [*:0]const u8 = allocator.dupeZ(
                    u8,
                    std.mem.span(e.lib_name)
                ) catch return WayobErr.AllocErr;
                errdefer allocator.free(std.mem.span(dupd_l));
                const dupd_f: [*:0]const u8 = allocator.dupeZ(
                    u8,
                    std.mem.span(e.function_name)
                ) catch return WayobErr.AllocErr;
                errdefer allocator.free(std.mem.span(dupd_f));
                return FrameData {
                    .ExternFunction = .{
                        .lib_name = dupd_l,
                        .function_name = dupd_f,
                        .arg_count = e.arg_count
                    }
                };

            },
            .Void => return .Void
        }
    }

    /// A function to drop
    /// all heap-allocated
    /// resources this union
    /// may have.
    pub fn deinit(
        self: *const FrameData,
        allocator: Allocator
    ) void {
        switch (self.*) {
            .String => |s| allocator.free(
                std.mem.span(s)
            ),
            .Structure => |s| {
                for (s.items) |item| {
                    item.deinit(allocator);
                }
                s.deinit();
            },
            .Function => |f| f.instructions.deinit(),
            .ExternFunction => |e| {
                allocator.free(std.mem.span(e.lib_name));
                allocator.free(std.mem.span(e.function_name));
            },
            else => {}
        }
    }

};

/// A structure to represent
/// a single frame of data on
/// the Wayob stack.
pub const Frame = struct {
    data: FrameData,
    previous: ?*Frame, 

    /// A function to drop
    /// all heap-allocated
    /// resources this structure
    /// may have.
    pub fn deinit(
        self: *Frame,
        allocator: Allocator
    ) void {
        self.data.deinit(allocator);
        if (self.previous) |fr|{
            fr.deinit(allocator);
        }
    }
};

/// A data structure 
/// representing the Wayob stack.
pub const Stack = struct {
    guard: Mutex,
    current: ?*Frame, 
    allocator: Allocator,

    /// A function to initialize
    /// the stack to be empty and
    /// return the created instance.
    pub fn init(
        allocator: Allocator
    ) Stack {
        return Stack{
            .guard = .{},
            .current = null,
            .allocator = allocator
        };
    }

    /// A function to push a new
    /// piece of data onto the stack.
    /// A new frame is created and the
    /// frame's `data` field is populated
    /// with the passed data.
    pub fn push(
        self: *Stack,
        data: FrameData
    ) !void {
        self.guard.lock();
        defer self.guard.unlock();
        const new_frame_ptr = self.allocator.create(Frame)
            catch return WayobErr.AllocErr;
        new_frame_ptr.* = Frame {
            .data = data,
            .previous = self.current
        };
        self.current = new_frame_ptr;
    }

    /// A function to pop
    /// a frame of data off of
    /// the stack. If the current
    /// frame is `null`, an error
    /// is returned. In any other
    /// case the current frame's data
    /// is returned.
    pub fn pop(
        self: *Stack,
    ) !FrameData { 
        if (self.current) |fr| {
            self.guard.lock();
            defer self.guard.unlock();
            const data = fr.data; 
            const next_top = fr.previous;
            self.allocator.destroy(fr);
            self.current = next_top;
            return data;
        }
        else {
            return WayobErr.EmptyStack;
        }
    } 

    /// A function to drop
    /// all heap-allocated
    /// resources this structure
    /// may have.
    pub fn deinit(
        self: *Stack,
    ) void {
        while (self.current) |fr| {
            const data = fr.data;
            const next_top = fr.previous;
            self.allocator.destroy(fr);
            self.current = next_top;
            data.deinit(self.allocator);
        }
    }
};
