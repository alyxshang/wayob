// WAYOB by Alyx Shang.
// Licensed under the FSL v1.

// Importing the standard
// namespace.
const std = @import("std");

// Importing the "ArrayList" structure
// from the standard library.
const ArrayList = std.ArrayList;

// Importing the function to create
// a formatted string.
const allocPrint = std.fmt.allocPrint;

// Importing the structure to catch
// and handle errors.
const WayobErr = @import("err.zig").WayobErr;

/// Importing the structure representing
/// a single unit of data on the stack.
const FrameData = @import("stack.zig").FrameData;

/// A function to add two units of data if 
/// they are each of the same type and that
/// type is either an integer or a floating
/// point number. If either one of these conditions
/// is not met, a type error is returned. If the
/// operation is successful, an integer unit of data
/// or a floating point unit of data is returned.
pub fn addValues(
    one: *const FrameData,
    two: *const FrameData
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Integer = one.Integer + two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .FloatingPoint = one.FloatingPoint + two.FloatingPoint };
    }
    else {
        return WayobErr.TypeError;
    }
}

/// A function to subtract two units of data if 
/// they are each of the same type and that
/// type is either an integer or a floating
/// point number. If either one of these conditions
/// is not met, a type error is returned. If the
/// operation is successful, an integer unit of data
/// or a floating point unit of data is returned.
pub fn subValues(
    one: *const FrameData,
    two: *const FrameData
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Integer = one.Integer - two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .FloatingPoint = one.FloatingPoint - two.FloatingPoint };
    }
    else {
        return WayobErr.TypeError;
    }
}

/// A function to multiply two units of data if 
/// they are each of the same type and that
/// type is either an integer or a floating
/// point number. If either one of these conditions
/// is not met, a type error is returned. If the
/// operation is successful, an integer unit of data
/// or a floating point unit of data is returned.
pub fn mulValues(
    one: *const FrameData,
    two: *const FrameData
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Integer = one.Integer * two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .FloatingPoint = one.FloatingPoint * two.FloatingPoint };
    }
    else {
        return WayobErr.TypeError;
    }
}

/// A function to divide two units of data if 
/// they are each of the same type and that
/// type is either an integer or a floating
/// point number. If either one of these conditions
/// is not met, a type error is returned. If the
/// operation is successful, an integer unit of data
/// or a floating point unit of data is returned. Integers
/// are rounded down.
pub fn divValues(
    one: *const FrameData,
    two: *const FrameData
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){ 
        return FrameData{ .Integer = @divTrunc(one.Integer, two.Integer) };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .FloatingPoint = @divExact(one.FloatingPoint, two.FloatingPoint ) };
    }
    else {
        return WayobErr.TypeError;
    }
}

/// A function to perform a less-than
/// comparison on two units of data if 
/// they are each of the same type and that
/// type is either an integer or a floating
/// point number. If either one of these conditions
/// is not met, a type error is returned. If the
/// operation is successful, a boolean unit of data
/// is returned.
pub fn ltValues(
    one: *const FrameData,
    two: *const FrameData
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Bool = one.Integer < two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .Bool = one.FloatingPoint < two.FloatingPoint };
    }
    else {
        return WayobErr.TypeError;
    }
}

/// A function to perform a greater-than
/// comparison on two units of data if 
/// they are each of the same type and that
/// type is either an integer or a floating
/// point number. If either one of these conditions
/// is not met, a type error is returned. If the
/// operation is successful, a boolean unit of data
/// is returned.
pub fn gtValues(
    one: *const FrameData,
    two: *const FrameData
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Bool = one.Integer > two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .Bool = one.FloatingPoint > two.FloatingPoint };
    }
    else {
        return WayobErr.TypeError;
    }
}
 
/// A function to perform an is-equal
/// comparison on two units of data if 
/// they are each of the same type.
/// If this condition is not met, 
/// a type error is returned. If the
/// operation is successful, a boolean 
/// unit of data is returned.
pub fn eqValues(
    one: *const FrameData,
    two: *const FrameData,
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Bool = one.Integer == two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .Bool = one.FloatingPoint == two.FloatingPoint };
    }
    else if (one.* == .Bool and two.* == .Bool){
        return FrameData{ .Bool = one.Bool == two.Bool };
    }
    else if (one.* == .String and two.* == .String){
        const eql: bool = std.mem.eql(
            u8,
            std.mem.span(one.String),
            std.mem.span(two.String)
        );
        return FrameData{ .Bool = eql };
    } 
    else {
        return WayobErr.TypeError;
    }
}

/// A function to perform an is-not-equal
/// comparison on two units of data if 
/// they are each of the same type.
/// If this condition is not met, 
/// a type error is returned. If the
/// operation is successful, a boolean 
/// unit of data is returned.
pub fn neqValues(
    one: *const FrameData,
    two: *const FrameData,
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Bool = one.Integer != two.Integer };
    }
    else if (one.* == .FloatingPoint and two.* == .FloatingPoint){
        return FrameData{ .Bool = one.FloatingPoint != two.FloatingPoint };
    }
    else if (one.* == .Bool and two.* == .Bool){
        return FrameData{ .Bool = one.Bool != two.Bool };
    }
    else if (one.* == .String and two.* == .String){
        const eql: bool = std.mem.eql(
            u8,
            std.mem.span(one.String),
            std.mem.span(two.String)
        );
        return FrameData{ .Bool = !eql };
    } 
    else {
        return WayobErr.TypeError;
    }
}

/// A function to perform a 
/// modulo operation on two units of data if 
/// they are each integers. If this condition
/// is not met, a type error is returned. If the
/// operation is successful, an integer unit of data
/// is returned.
pub fn modValues(
    one: *const FrameData,
    two: *const FrameData,
) !FrameData {
    if (one.* == .Integer and two.* == .Integer){
        return FrameData{ .Integer = @mod(one.Integer, two.Integer) };
    }
    else {
        return WayobErr.TypeError;
    }
}
