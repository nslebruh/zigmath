const std = @import("std");
const vec = @import("./vec.zig");

pub const Vec = vec.Vector;

pub fn Mat4(comptime T: type) type {
    return extern struct {
        data: [4]@Vector(4, T),

        const Self = @This();
        const width = 4;
        const height = 4;

        pub fn new(data: [4]@Vector(4, T)) Self {
            return Self{.data = data};
        }

        pub fn fromFlat(data: [16]T) Self {
            return Self{.data = .{data[0..4].*, data[4..8].*, data[8..12].*, data[12..16].*}};
        }

        pub fn mul(lhs: Self, rhs: Self) Self {
            var ret: Self = undefined;
            for (0..4) |i| {
                for (0..4) |j| {
                    ret.data[i][j] = @reduce(.Add, lhs.data[i] * @Vector(4, T){rhs.data[0][j], rhs.data[1][j], rhs.data[2][j], rhs.data[3][j]});
                }
            }
            return ret;
        }

        pub fn identity() Self {
            return Self{.data = .{.{1, 0, 0, 0}, .{0, 1, 0, 0}, .{0, 0, 1, 0}, .{0, 0, 0, 1}}};
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            var ret: Self = undefined;
            for (0..4) |i| {
                ret.data[i] = lhs.data[i] + rhs.data[i];
            }
            return ret;
        }
        pub fn addS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..4) |i| {
                ret.data[i] = lhs.data[i] + @as(@Vector(4, T), @splat(rhs));
            }
            return ret;
        }
        pub fn sub(lhs: Self, rhs: Self) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] - rhs.data[i];
            }
            return ret;
        }
        pub fn subS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] - @as(@Vector(4, T), @splat(rhs));
            }
            return ret;
        }
        pub fn mulS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] * @as(@Vector(4, T), @splat(rhs));
            }
            return ret;
        }
        pub fn divS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] / @as(@Vector(4, T), @splat(rhs));
            }
            return ret;
        }

        pub fn mulV(self: Self, lhs: vec.Vector(T, 4)) vec.Vector(T, 4) {
            return vec.Vector(T, 4).new(.{
                @reduce(.Add, self.data[0] * @as(@Vector(4, T), @splat(lhs.data[0]))),
                @reduce(.Add, self.data[1] * @as(@Vector(4, T), @splat(lhs.data[1]))),
                @reduce(.Add, self.data[2] * @as(@Vector(4, T), @splat(lhs.data[2]))),
                @reduce(.Add, self.data[3] * @as(@Vector(4, T), @splat(lhs.data[3]))),
            });
        }

        pub fn mul3(self: Self, lhs: vec.Vector(T, 3)) vec.Vector(T, 3) {
            return vec.Vector(T, 3).new(.{
                @reduce(.Add, self.data[0] * @as(@Vector(4, T), @splat(lhs.data[0]))),
                @reduce(.Add, self.data[1] * @as(@Vector(4, T), @splat(lhs.data[1]))),
                @reduce(.Add, self.data[2] * @as(@Vector(4, T), @splat(lhs.data[2]))),
            });
        }
    };
}

test Mat4 {
    std.debug.print("\n", .{});
    const x = Mat4(f32).new(.{.{1, 2, 3, 4}, .{5, 6, 7, 8}, .{9, 10, 11, 12}, .{13, 14, 15, 16}});
    const y = Mat4(f32).fromFlat(.{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16});
    try std.testing.expectEqual(x, y);
    try std.testing.expectEqual(Mat4(f32).new(.{.{ 90, 100, 110, 120 }, .{ 202, 228, 254, 280 }, .{ 314, 356, 398, 440 }, .{ 426, 484, 542, 600 }}), x.mul(y));
    std.debug.print("{}\n", .{x.mulV(vec.Vector(f32, 4).new(.{1, 1, 1, 1}))});


}