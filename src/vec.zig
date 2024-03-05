const std = @import("std");
const lib  = @import("./lib.zig");

pub fn Vector(comptime T: type, comptime length: usize) type {
    switch (@typeInfo(T)) {
        .Int, .Float => {}, else => @compileError("Vector only accepts floats or ints")
    }
    return extern struct {
        data: @Vector(length, T),

        pub const t: type = T;
        pub const len: usize = length;

        const Self = @This();
        const magFunction: fn(@Vector(length, T)) T = switch (@typeInfo(T)) {
            .Float => magFloat,
            .Int => |integer| if (integer.signedness == .signed) magInt else magUint,
            else => unreachable
        };
        const AngleType = switch (length) {
            2 => lib.Angle2D,
            3 => lib.Angle3D,
            else => @compileError("no valid angle type for vector of len " ++ length)
        };
        const angleFunction = switch (length) {
            inline 2 => if (@typeInfo(T) == .Float) angle2Float else angle2,
            inline 3 => if (@typeInfo(T) == .Float) angle3Float else angle3,
            else => @compileError("no valid angle function for vector of len " ++ length)
        };

        pub fn new(inner: @Vector(length, T)) Self {
            return Self{.data = inner};
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.data + rhs.data};
        }

        pub fn addS(lhs: Self, rhs: T) Self {
            return Self{.data = lhs.data + @as(@Vector(length, T), @splat(rhs))};
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.data - rhs.data};
        }

        pub fn subS(lhs: Self, rhs: T) Self {
            return Self{.data = lhs.data - @as(@Vector(length, T), @splat(rhs))};
        }

        pub fn mul(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.data * rhs.data};
        }

        pub fn mulS(lhs: Self, rhs: T) Self {
            return Self{.data = lhs.data * @as(@Vector(length, T), @splat(rhs))};
        }

        pub fn div(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.data / rhs.data};
        }

        pub fn divS(lhs: Self, rhs: T) Self {
            return Self{.data = lhs.data / @as(@Vector(length, T), @splat(rhs))};
        }

        pub fn mag(self: Self) T {
            return Self.magFunction(self.data);
        }

        pub fn dot(lhs: Self, rhs: Self) T {
            return @reduce(.Add, lhs.data * rhs.data);
        }

        pub fn normalise(self: *const Self) Self {
            if (self.mag() != 0) {
                return self.divS(self.mag());
            } else {
                return self.*;
            }
        }

        pub fn normaliseMut(self: *Self) void {
            if (self.mag() != 0) {
                self.* = self.divS(self.mag());
            }
        }

        pub fn angle(self: Self) AngleType {
            return Self.angleFunction(self.data);
        }

        fn magFloat(inner: @Vector(length, T)) T {
            return @sqrt(@reduce(.Add, inner * inner));
        }

        fn magUint(inner: @Vector(length, T)) T {
            return std.math.sqrt(@reduce(.Add, inner * inner));
        }

        fn magInt(inner: @Vector(length, T)) T {
            const temp_type = comptime switch (@typeInfo(T)) {
                    .Int => |int| std.meta.Int(.unsigned, int.bits),
                    else => @compileError("how")
                };
            return @intCast(std.math.sqrt(@reduce(.Add, @as(@Vector(length, temp_type), @intCast(inner * inner)))));
        }
        fn angle2(vec: @Vector(2, T)) lib.Angle2D {
            return lib.Angle2D{std.math.atan2(@as(f64, @floatFromInt(vec[1])), @as(f64, @floatFromInt(vec[0])))};
        }

        fn angle2Float(vec: @Vector(2, T)) lib.Angle2D {
            return lib.Angle2D{std.math.atan2(@as(f64, vec[1]), @as(f64, vec[0]))};
        }

        fn angle3(vec: @Vector(3, T)) lib.Angle3D {
            _ = vec;
            @compileError("unfinished");
            //return lib.Angle3D{.pitch = 1, .yaw = 1};
        }

        fn angle3Float(vec: @Vector(3, T)) lib.Angle3D {
            _ = vec;
            @compileError("unfinished");
            //return lib.Angle3D{.pitch = 1, .yaw = 1};
        }

    };
}

test Vector {
    std.debug.print("\n", .{});
    const x = Vector(i16, 2).new(.{-4, 5});
    const y = Vector(u16, 2).new(.{4, 5});
    const z = Vector(f16, 2).new(.{-4, 5});

    try std.testing.expectEqual(6, x.mag());
    try std.testing.expectEqual(6, y.mag());
    try std.testing.expectEqual(6, @round(z.mag()));

    const a = Vector(i16, 2).new(.{3, 4});
    std.debug.print("{d}", .{std.math.radiansToDegrees(f64, a.angle()[0])});
}
