const vec = @import("./vec.zig");
const mat = @import("./mat.zig");

const std = @import("std");

/// 2 Dimensional angle in radians
pub const Angle2D = struct { f64 };

/// 3 Dimensional angle in radians
pub const Angle3D = struct {
    yaw: f64,
    pitch: f64,
    roll: f64 = 0
};