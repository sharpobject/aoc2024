const std = @import("std");
const mem = std.mem;
const u = @import("u.zig");

i: []const u8,
a: mem.Allocator,

pub fn part1(this: *const @This()) !?i128 {
    u.a = this.a;
    const lines = try u.trimSplit(this.i, '\n');
    var sum: u64 = 0;
    u.use(&sum, lines);


    return sum;
}

pub fn part2(this: *const @This()) !?i128 {
    u.a = this.a;
    const lines = try u.trimSplit(this.i, '\n');
    var sum: u64 = 0;
    u.use(&sum, lines);


    return sum;
}

test "it should do nothing" {
    const allocator = std.testing.allocator;
    const input = "";

    const problem: @This() = .{
        .i = input,
        .a = allocator,
    };

    try std.testing.expectEqual(null, try problem.part1());
    try std.testing.expectEqual(null, try problem.part2());
}