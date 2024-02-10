pub const zglm = @import("zglm.zig");

const std = @import("std");

pub fn Vector(comptime T: type, len: comptime_int) type {
    comptime {
        switch (@typeInfo(T)) {
            .Int, .Float => {},
            else => @compileError("Vector can only contain numeric types")
        }
    }
    return packed struct {
        inner: @Vector(len, T),

        const Self = @This();

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.inner + rhs.inner};
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.inner - rhs.inner};
        }

        pub fn mul(lhs: Self, rhs: Self) Self {
            return Self {.data = lhs.inner * rhs.inner};
        }

        pub fn div(lhs: Self, rhs: Self) Self {
            return Self {.data = lhs.inner / rhs.inner};
        }

        pub fn mag(self: Self) T {
            var x: T = 0;
            for (self.inner) |val| {
                x += (val * val);
            }
            return @sqrt(x);
        }

        pub fn normalize(self: *Self) void {
            self.*.inner = if (len != 0) self.inner / @as(@Vector(len, T), @splat(self.mag())) else return;
        }

        pub fn limit(self: *Self, lim: T) void {
            const m = self.mag();
            self.*.inner = if (m > lim) self.inner / @as(@Vector(len, T), @splat(m)) * @as(@Vector(len, T), @splat(lim)) else return;
        }
    };
}

pub fn Matrix(comptime T: type, rows: comptime_int, columns: comptime_int) type {
    return struct {
        inner: [rows]@Vector(columns, T),

        const Self = @This();
        const mat_ty = [rows]@Vector(columns, T);
        const vec_ty = @Vector(columns, T);

        pub fn fromFlatRowSlice(data: [columns * rows]T) Self {
            var vec: mat_ty = undefined;
            comptime var i = 0;
            while (i < data.len): (i += rows) {
                vec[@divFloor(i, rows)] = @as(vec_ty, data[i..i + rows]);
            }
            return vec;
        }

        //pub fn fromFlatColumnSlice(data: [columns * rows]T) Self {
        //
        //}

        //pub fn fromRowColumnSlice(data: [rows][columns]T) Self {
        //
        //}

        //pub fn fromColumnRowSlice(data: [rows][columns]T) Self {
        //
        //}

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.inner + rhs.inner};
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.inner - rhs.inner};
        }
    };
}

test "Matrix addition" {
    const M = Matrix(f32, 2, 2);
    const m1 = M.fromFlatRowSlice(.{11, 12, 21, 22});
    std.testing.expectEqual(m1, M{.inner = .{.{11, 12}, .{21, 22}}});
}