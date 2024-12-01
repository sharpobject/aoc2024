const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    const lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, lines);


    return sum;
}

pub fn part2() !?i128 {
    const lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, lines);


    return sum;
}
