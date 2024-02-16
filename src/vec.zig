const std = @import("std");

fn Vector(comptime T: type, len: usize) type {
    switch (@typeInfo(T)) {
        .Int, .Float => {}, else => @compileError("Vector only accepts floats or ints")
    }
    return packed struct {
        i: @Vector(len, T),

        const Self = @This();
        const magFunction: fn(@Vector(len, T)) T = switch (@typeInfo(T)) {
            .Float => magFloat,
            .Int => |integer| if (integer.signedness == .signed) magInt else magUint,
            else => unreachable
        };

        pub fn new(inner: @Vector(len, T)) Self {
            return Self{.i = inner};
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{.i = lhs.i + rhs.i};
        }

        pub fn addS(lhs: Self, rhs: T) Self {
            return Self{.i = lhs.i + @as(@Vector(len, T), @splat(rhs))};
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self{.i = lhs.i - rhs.i};
        }

        pub fn subS(lhs: Self, rhs: T) Self {
            return Self{.i = lhs.i - @as(@Vector(len, T), @splat(rhs))};
        }

        pub fn mul(lhs: Self, rhs: Self) Self {
            return Self{.i = lhs.i * rhs.i};
        }

        pub fn mulS(lhs: Self, rhs: T) Self {
            return Self{.i = lhs.i * @as(@Vector(len, T), @splat(rhs))};
        }

        pub fn div(lhs: Self, rhs: Self) Self {
            return Self{.i = lhs.i / rhs.i};
        }

        pub fn divS(lhs: Self, rhs: T) Self {
            return Self{.i = lhs.i / @as(@Vector(len, T), @splat(rhs))};
        }

        pub fn mag(self: Self) T {
            return Self.magFunction(self.i);
        }

        pub fn dot(lhs: Self, rhs: Self) T {
            return @reduce(.Add, lhs.i * rhs.i);
        }

        pub fn normalise(self: *Self) void {
            if (self.mag() == 0) {
                self.* = self.divS(self.mag());
            }
        }

        fn magFloat(inner: @Vector(len, T)) T {
            return @sqrt(@reduce(.Add, inner * inner));
        }

        fn magUint(inner: @Vector(len, T)) T {
            return std.math.sqrt(@reduce(.Add, inner * inner));
        }

        fn magInt(inner: @Vector(len, T)) T {
            const temp_type = comptime switch (@typeInfo(T)) {
                    .Int => |int| std.meta.Int(.unsigned, int.bits),
                    else => @compileError("how")
                };
            return @intCast(std.math.sqrt(@reduce(.Add, @as(@Vector(len, temp_type), @intCast(inner * inner)))));
        }

    };
}

pub fn Vector2(comptime T: type) @TypeOf(Vector(T, 2)) {
    return Vector(T, 2);
}

pub fn Vector3(comptime T: type) @TypeOf(Vector(T, 3)) {
    return Vector(T, 3);
}

pub fn Vector4(comptime T: type) @TypeOf(Vector(T, 4)) {
    return Vector(T, 4);
}

test Vector {
    const x = Vector(i16, 2).new(.{-4, 5});
    const y = Vector(u16, 2).new(.{4, 5});
    const z = Vector(f16, 2).new(.{-4, 5});

    try std.testing.expectEqual(6, x.mag());
    try std.testing.expectEqual(6, y.mag());
    try std.testing.expectEqual(6, @round(z.mag()));
}

pub const Angle2D = struct {
    num: f64,

    pub fn degrees(self: @This()) f64 {
        return self.num;
    }

    pub fn radians(self: @This()) void {
        std.math.degreesToRadians(f64, self.num);
    }
};

pub fn VectorAngle2(comptime T: type, vec: Vector(T, 2)) Angle2D {
    var ret: f64 = std.math.atan2(@as(f64, @intCast(vec.i[1])), @as(f64, @intCast(vec.i[0])));
    switch (.{vec.i[0] < 0, vec.i[1] < 0}) {
        .{false, false} => ret,
        .{true, false} => ret += 180,
        .{true, true} => ret += 180,
        .{false, true} => ret += 360
    }
    return Angle2D{.num = ret};
}

test VectorAngle2 {

}

pub const Angle3D = struct {
    pitch: f64,
    yaw: f64,
    roll: f64 = 0,
};

pub fn VectorAngle3(comptime T: type, vec: Vector(T, 3)) Angle3D {
    var temp_vec = vec;
    &temp_vec.normalise();
    return Angle3D{.pitch = @sqrt()};
}