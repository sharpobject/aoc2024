const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 1;
    u.use(&sum, &lines);
    const times = u.trimSplitParse(u.trimSplit(lines[0], ':')[1], ' ');
    const dists = u.trimSplitParse(u.trimSplit(lines[1], ':')[1], ' ');
    for (0..times.len) |i| {
        var factor: i64 = 0;
        var j: isize = 0;
        while (j < times[i]) : (j += 1) {
            if ((times[i]-j)*j > dists[i]) {
                factor += 1;
            }
        }
        sum *= factor;
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 1;
    u.use(&sum, &lines);
    const time = try std.fmt.parseInt(i64, u.filterOut(u.trimSplit(lines[0], ':')[1], ' '), 10);
    const dist = try std.fmt.parseInt(i64, u.filterOut(u.trimSplit(lines[1], ':')[1], ' '), 10);
    var factor: i64 = 0;
    var j: isize = 0;
    while (j < time) : (j += 1) {
        if ((time-j)*j > dist) {
            factor += 1;
        }
    }
    sum *= factor;
    return sum;
}
