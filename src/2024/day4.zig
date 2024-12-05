const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    lines = u.pad(lines, '.', 4);
    const dxs: [8]u64 = @bitCast([8]i64{ 1, 1, 1,  0, -1, -1, -1,  0 });
    const dys: [8]u64 = @bitCast([8]i64{-1, 0, 1,  1,  1,  0, -1, -1 });
    for (0..lines.len) |i| {
        for (0..lines[0].len) |j| {
            if (lines[i][j] == 'X') {
                for (0..dxs.len) |k| {
                    const dx = dxs[k];
                    const dy = dys[k];
                    if (lines[i+%dx][j+%dy] == 'M' and lines[i+%dx*%2][j+%dy*%2] == 'A' and lines[i+%dx*%3][j+%dy*%3] == 'S') {
                        sum += 1;
                    }
                }
            }
        }
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    lines = u.pad(lines, '.', 4);
    for (0..lines.len) |i| {
        for (0..lines[0].len) |j| {
            if (lines[i][j] == 'A') {
                if ((lines[i-1][j-1] == 'M' or lines[i+1][j+1] == 'M') and
                    (lines[i-1][j+1] == 'M' or lines[i+1][j-1] == 'M') and
                    (lines[i-1][j-1] == 'S' or lines[i+1][j+1] == 'S') and
                    (lines[i-1][j+1] == 'S' or lines[i+1][j-1] == 'S')) {
                        sum += 1;
                }
            }
        }
    }
    return sum;
}
