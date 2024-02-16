const std = @import("std");
const vec = @import("./vec.zig");
const vec2 = vec.Vector2;
const vec3 = vec.Vector3;
const vec4 = vec.Vector4;

pub fn Matrix2x2(comptime T: type) type {
    return packed struct {
        inner: [2]vec2(T)
    };
}

pub fn Matrix2x3(comptime T: type) @TypeOf(packed struct { x: vec3(T), y: vec3(T) }) {
    return packed struct {
        x: vec3(T),
        y: vec3(T),

        const Self = @This();

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{.x = lhs.x.add(rhs.x), .y = lhs.y.add(rhs.y)};
        }

        //pub fn mul3x2(lhs: Self, rhs: Matrix3x2(T)) Matrix2x2(T) {
//
        //}
    };
}

test Matrix2x3 {
    _ = Matrix2x3(f32){.x = vec3(f32).new(.{1, 2, 3}), .y = vec3(f32).new(.{1, 2, 3})};
}

pub fn Matrix3x2(comptime T: type) type {
    return packed struct {
        x: vec2(T),
        y: vec2(T),
        z: vec2(T),

        const Self = @This();

        pub fn getColumn(self: Self, i: usize) vec3(T) {
            return vec3(T){.inner = .{self.x.i(i), self.y.i(i), self.z.i(i)}};
        }
    };
}