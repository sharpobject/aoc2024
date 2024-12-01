const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    const lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, lines);
    var as = try gpa.alloc(i64, lines.len);
    var bs = try gpa.alloc(i64, lines.len);
    for (lines, 0..) |line, i| {
        const xd = try u.trimSplit(line, ' ');
        as[i] = try std.fmt.parseInt(i64, xd[0], 10);
        bs[i] = try std.fmt.parseInt(i64, xd[xd.len-1], 10);
    }
    u.sort(as);
    u.sort(bs);
    for (as, 0..) |a, i| {
        sum += @intCast(@abs(a - bs[i]));
    }


    return sum;
}

pub fn part2() !?i128 {
    const lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, lines);
    var as = try gpa.alloc(i64, lines.len);
    var bs = try gpa.alloc(i64, lines.len);
    for (lines, 0..) |line, i| {
        const xd = try u.trimSplit(line, ' ');
        as[i] = try std.fmt.parseInt(i64, xd[0], 10);
        bs[i] = try std.fmt.parseInt(i64, xd[xd.len-1], 10);
    }
    for (as) |a| {
        for (bs) |b| {
            if (a == b) sum += a;
        }
    }

    return sum;
}