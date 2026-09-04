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

// Importing the structure to catch
// and handle errors.
const WayobErr = @import("err.zig").WayobErr;

/// Importing the data structure representing
/// the stack of the Wayob VM.
const FrameData = @import("stack.zig").FrameData;

/// An enumeration
/// containing all
/// possible types
/// of data a `CFrame`
/// can contain.
pub const CFrameType = enum(c_int) {
    Void,
    Bool,
    String,
    Integer,
    Structure,
    FloatingPoint
};

/// A structure to
/// encapsulate data
// about user-created
// data structures.
pub const CStructure = extern struct {
    data: [*]CFrame,
    arg_count: usize,

    /// A function to drop all
    /// heap-allocated resources
    /// of this structure.
    pub fn deinit(
        self: *const CStructure,
        allocator: Allocator
    ) void {
        const frames_slice = self.data[0..self.arg_count];
        for (frames_slice) |*frame| {
            frame.deinit(allocator);
        }
        allocator.free(frames_slice);
    }
};

/// A union containing
/// every possible unit
/// of data that Wayob can
/// process and that can be
/// used in an FFI context.
pub const CFramePayload = extern union {
    Void: void,
    Bool: bool,
    Integer: i64,
    FloatingPoint: f64,
    String: [*:0]const u8,
    Structure: CStructure,
};

/// A structure encapsulating
/// data about a single unit
/// of data in an FFI context.
pub const CFrame = extern struct {
    tag: CFrameType,
    payload: CFramePayload,

    /// A function to drop all
    /// heap-allocated resources
    /// of this structure.
    pub fn deinit(
        self: *const CFrame,
        allocator: Allocator
    ) void {
        switch (self.tag) {
            .String => {
                const str_ptr = std.mem.span(self.payload.String);
                allocator.free(str_ptr);
            },
            .Structure => self.payload.Structure.deinit(allocator),
            else => {}
        }
    }
};

/// A function to take an instance
/// of the `FrameData` structure and
/// convert it to an instance of the 
/// `CFrame` structure. If allocations
/// or write operations fail, an error
/// is returned. If the operation is 
/// successful, an instance of the 
/// `CFrame` data structure is returned.
pub fn toCFrame(
    sub: *const FrameData,
    allocator: Allocator
) !CFrame {
    switch (sub.*) {
        .Void => return CFrame{
            .tag = .Void,
            .payload = .{ .Void = {} }
        },
        .Bool => |b| return CFrame{
            .tag = .Bool,
            .payload = .{ .Bool = b }
        },
        .Integer => |i| return CFrame{
            .tag = .Integer,
            .payload = .{ .Integer = i }
        },
        .String => |s| {
            const dupd: [*:0]const u8 = allocator.dupeZ(
                u8,
                std.mem.span(s)
            ) catch return WayobErr.AllocErr;
            return CFrame {
                .tag = .String,
                .payload = .{ .String = dupd }
            };
        },
        .Structure => |p| {
            var data_list: ArrayList(CFrame) = ArrayList(CFrame)
                .init(allocator);
            errdefer {
                for (data_list.items) |item| {
                    item.deinit(allocator);
                }
                data_list.deinit();
            }
            for (p.items) |item| {
                const convd: CFrame = try toCFrame(&item, allocator);
                data_list.append(convd)
                    catch return WayobErr.WriteErr;
            }
            const owned_slice = data_list.toOwnedSlice() catch return WayobErr.AllocErr;
            return CFrame{
                .tag = .Structure,
                .payload = .{ 
                    .Structure = CStructure{
                        .arg_count = owned_slice.len,
                        .data = owned_slice.ptr 
                    }
                }
            };
        },
        .FloatingPoint => |f| return CFrame{
            .tag = .FloatingPoint,
            .payload = .{ .FloatingPoint = f }
        },
        else => {
            return WayobErr.TypeError;
        }
    }
}

/// A function to take an instance
/// of the `CFrame` structure and
/// convert it to an instance of the 
/// `FrameData` structure. If allocations
/// or write operations fail, an error
/// is returned. If the operation is 
/// successful, an instance of the 
/// `FrameData` data structure is returned.
pub fn fromCFrame(
    sub: *const CFrame,
    allocator: Allocator
) !FrameData {
    switch (sub.tag) {
        .Void => return .Void,
        .Bool => return FrameData{ .Bool = sub.payload.Bool },
        .Integer => return FrameData{ .Integer = sub.payload.Integer },
        .String => {
            const dupd: [*:0]const u8 = allocator.dupeZ(
                u8,
                std.mem.span(sub.payload.String)
            ) catch return WayobErr.AllocErr;
            return FrameData{ .String = dupd };
        },
        .Structure => {
            var data_list: ArrayList(FrameData) = ArrayList(FrameData)
                .init(allocator);
            errdefer {
                for (data_list.items) |item| {
                    item.deinit(allocator);
                }
                data_list.deinit();
            }
            const frames = sub.payload.Structure.data[0..sub.payload.Structure.arg_count];
            for (0..sub.payload.Structure.arg_count) |idx| {
                const frame: CFrame = frames[idx];
                const convd: FrameData = try fromCFrame(&frame, allocator);
                data_list.append(convd)
                    catch return WayobErr.WriteErr;
            }
            return FrameData{ 
                .Structure = data_list
            };
        },
        .FloatingPoint => return FrameData{ .FloatingPoint = sub.payload.FloatingPoint },
        
    }
}

/// A function to take an instance of
/// an `ArrayList` containing instances
/// of the `FrameData` structure and
/// convert it to an instance of the 
/// `ArrayList` structure containing 
/// instances of the `CFrame` structure. 
/// If allocations or write operations 
/// fail, an error is returned. If 
/// the operation is successful, an 
/// instance of the `ArrayList` structure 
/// containing instances of the `CFrame` 
/// data structure is returned.
pub fn toCFrames(
    sub: *ArrayList(FrameData),
    allocator: Allocator
) !ArrayList(CFrame) {
    var result: ArrayList(CFrame) = ArrayList(CFrame)
        .init(allocator);
    errdefer {
        for (result.items) |item| {
            item.deinit(allocator);
        }
        result.deinit();
    }
    for (sub.items) |item| {
        const convd: CFrame = try toCFrame(&item, allocator);
        result.append(convd)
            catch return WayobErr.WriteErr;
    }
    return result;
}

/// A function attempting to load the
/// dyanmic library at the specified path,
/// search for the symbol representing a
/// function with the specified name, and run
/// the function with the specified symbol. If
/// allocations fail, the library or function does
/// not exist or conversions fail, an error is 
/// returned. If the operation is successful,
/// an instance of the `FrameData` structure is
/// returned.
pub fn runExtern(
    lib: [*:0]const u8,
    fn_name: [*:0]const u8,
    arguments: *ArrayList(FrameData),
    allocator: Allocator
) !FrameData {
    var f_lib = std.DynLib.open(std.mem.span(lib))
        catch return WayobErr.DynLibOpenErr;
    defer f_lib.close();
    const fn_symbol = f_lib.lookup(
        *const fn (ptr: [*]CFrame, len: usize) callconv(.C) CFrame, 
        std.mem.span(fn_name)
    ) orelse return WayobErr.FnNotFound;
    const args: ArrayList(CFrame) = try toCFrames(arguments, allocator);
    defer {
        for (args.items) |item| {
            item.deinit(allocator);
        }
        args.deinit();
    }
    const fn_result: CFrame = fn_symbol(args.items.ptr, args.items.len);
    defer fn_result.deinit(allocator);
    const result: FrameData = try fromCFrame(&fn_result, allocator);
    return result;
}
