pub const zglm = @import("zglm.zig");

pub fn Vector(comptime T: type, len: comptime_int) type {
    comptime {
        switch (@typeInfo(T)) {
            .Int, .Float => {},
            else => @compileError("Vector can only contain numeric types")
        }
    }
    return packed struct {
        data: @Vector(len, T),

        const Self = @This();

        pub fn add(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.data + rhs.data};
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self{.data = lhs.data - rhs.data};
        }

        pub fn mul(lhs: Self, rhs: Self) Self {
            return Self {.data = lhs.data * rhs.data};
        }

        pub fn div(lhs: Self, rhs: Self) Self {
            return Self {.data = lhs.data / rhs.data};
        }

        pub fn mag(self: Self) T {
            var x: T = 0;
            for (self.data) |val| {
                x += (val * val);
            }
            return @sqrt(x);
        }

        pub fn normalize(self: *Self) void {
            self.*.data = if (len != 0) self.data / @as(@Vector(len, T), @splat(self.mag())) else return;
        }

        pub fn limit(self: *Self, lim: T) void {
            const m = self.mag();
            self.*.data = if (m > lim) self.data / @as(@Vector(len, T), @splat(m)) * @as(@Vector(len, T), @splat(lim)) else return;
        }
    };
}