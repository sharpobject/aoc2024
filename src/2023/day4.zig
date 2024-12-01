const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    var lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    for (lines) |line| {
        const junk, const card = try u.trimSplit2(line, ':');
        _ = junk;
        const winnings, const mines = try u.trimSplit2(card, '|');
        var winning: std.ArrayList(i64) = .init(gpa);
        var n_winning: usize = 0;
        for (try u.trimSplit(winnings, ' ')) |w| {
            try winning.append(try std.fmt.parseInt(i64, w, 10));
        }
        for (try u.trimSplit(mines, ' ')) |m| {
            const x = try std.fmt.parseInt(i64, m, 10);
            for (winning.items) |w| {
                if (w == x) {
                    n_winning += 1;
                    break;
                }
            }
        }
        sum += (@as(i64, 1) << @intCast(n_winning)) >> 1;
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    const copies = try gpa.alloc(i64, lines.len);
    @memset(copies, 1);
    for (lines, 0..) |line, i| {
        const junk, const card = try u.trimSplit2(line, ':');
        _ = junk;
        const winnings, const mines = try u.trimSplit2(card, '|');
        var winning: std.ArrayList(i64) = .init(gpa);
        var n_winning: usize = 0;
        for (try u.trimSplit(winnings, ' ')) |w| {
            try winning.append(try std.fmt.parseInt(i64, w, 10));
        }
        for (try u.trimSplit(mines, ' ')) |m| {
            const x = try std.fmt.parseInt(i64, m, 10);
            for (winning.items) |w| {
                if (w == x) {
                    n_winning += 1;
                    break;
                }
            }
        }
        var j: usize = i+1;
        while (j < i + n_winning+1) : (j += 1) {
            copies[j] += copies[i];
        }
        sum += copies[i];
    }
    return sum;
}
