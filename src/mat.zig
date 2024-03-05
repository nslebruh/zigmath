const std = @import("std");

fn UnsizedMatrix(comptime T: type) type {
    return struct {
        data: []T,
        width: usize,
        height: usize,

        pub fn new(data: [*]const T, height: usize, width: usize) MatrixSlice(T) {
            return MatrixSlice(T){.data = data, .height = height, .width = width};
        }

        pub fn as(self: @This(), comptime ty: type) @TypeOf(T) {
            switch (@typeInfo(ty)) {
                .Struct => {
                    if (@hasField(ty, "data") and @hasDecl(ty, "row") and @hasDecl(ty, "column")) {
                        if (self.width == ty.column and self.height == ty.row) {
                            return @TypeOf(T){.data = self.data.*};
                        } else @compileError("rows and columns of type must match the internal rows and columns");
                    } else @compileError("struct must have contain the fields data, row and column");
                },
                else => @compileError("must be a struct"),
            }
        }
    };
}

fn MatrixSlice(comptime T: type) type {
    return struct {
        data: [*]const T,
        width: usize,
        height: usize,

        pub fn get(self: @This(), row: usize, col: usize) T {
            return self.data[self.idx(row, col)];
        }

        pub fn idx(self: @This(), row: usize, col: usize) usize {
            std.debug.assert(row < self.height);
            std.debug.assert(col < self.width);
            return col + row * self.width;
        }
    };
}

test MatrixSlice {
    std.debug.print("\n", .{});
    //const x = Matrix(f32, 2, 2).new(.{1, 2, 3, 4});
}

pub fn Matrix(comptime T: type, height: usize, width: usize) type {
    return extern struct {
        data: [height * width]T,

        const Self = @This();

        pub fn new(data: [height * width]T) Self {
            return Self{.data = data};
        }

        pub fn asSlice(self: Self) MatrixSlice(T) {
            std.debug.assert(width < 4);
            return MatrixSlice(T){.data = &self.data, .height = height, .width = width};
        }

        pub fn get(self: Self, r: usize, col: usize) T {
            return self.data[Self.idx(r, col)];
        }

        pub fn idx(y: usize, x: usize) usize {
            std.debug.assert(y < height);
            std.debug.assert(x < width);
            return x + y * width;
        }

        pub fn column(self: Self, c: usize) []const T {
            std.debug.assert(c < height);
            var ret: [height]T = undefined;
            for (0..height) |i| {
                ret[i] = self.get(i, c);
            }
            return &ret;
        }
        test "Matrix.column" {
            std.debug.print("\n", .{});
            const x = Matrix(f32, 2, 2).new(.{1, 2, 3, 4});
            std.debug.print("{any}\n", .{x.column(0)});
        }

        pub fn row(self: Self, r: usize) []const T {
            std.debug.assert(r < width);
            return self.data[width * r..width * r + width];
        }

        pub fn identity() Self {
            comptime if (height != width) @compileError("not a square matrix");
            var ret: Self = undefined;
            for (0..height) |i| {
                for (0..width) |j| {
                    ret.data[i * height + j] = if (i == j) 1 else 0;
                }
            }
            return ret;
        }

        pub fn add(lhs: Self, rhs: Self) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] + rhs.data[i];
            }
            return ret;
        }
        pub fn addS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] + rhs;
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
                ret.data[i] = lhs.data[i] - rhs;
            }
            return ret;
        }
        pub fn mulS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] * rhs;
            }
            return ret;
        }
        pub fn divS(lhs: Self, rhs: T) Self {
            var ret: Self = undefined;
            for (0..lhs.data.len) |i| {
                ret.data[i] = lhs.data[i] / rhs;
            }
            return ret;
        }

        fn dot(lhs: []const T, rhs: []const T) T {
            var ret: T = 0;
            for (lhs, rhs) |i, j| {
                ret += (i * j);
            }
            return ret;
        }
    };
}

test Matrix {
    std.debug.print("\n", .{});
    const M1 = Matrix(f32, 2, 2);
    //const M2 = Matrix(f32, 2, 3);

    const x = M1.new(.{1, 2, 3, 4});
    const y = M1.new(.{1, 2, 3, 4});

    try std.testing.expectEqual(M1.new(.{2, 4, 6, 8}), x.add(y));
    try std.testing.expectEqual(M1.new(.{0, 0, 0, 0}), x.sub(y));

}