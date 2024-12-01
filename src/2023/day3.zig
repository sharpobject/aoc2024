const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    var lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    lines = try u.pad(lines, '.', 10);
    const dxs: [4]i64 = .{ 1, 0, -1, 0 };
    const dys: [4]i64 = .{ 0, 1, 0, -1 };
    for (lines, 0..) |line, i| {
        var num: i64 = 0;
        var adj: bool = false;
        for (line, 0..) |c, j| {
            if (c >= '0' and c <= '9') {
                num = 10 * num + (c - '0');
                for (dxs) |dx| {
                    for (dys) |dy| {
                        const x: usize = @intCast(@as(i64, @intCast(i)) + dx);
                        const y: usize = @intCast(@as(i64, @intCast(j)) + dy);
                        if ((lines[x][y] < '0' or lines[x][y] > '9') and lines[x][y] != '.') {
                            adj = true;
                        }
                    }
                }
            } else {
                sum += if (adj) num else 0;
                num = 0;
                adj = false;
            }
        }
    }
    return sum;
}

const Xd = struct {
    ch: u8,
    label: u64,
    fn init(ch: u8) Xd {
        return .{ .ch = ch, .label = 0 };
    }
};

pub fn part2() !?i128 {
    var lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    lines = try u.pad(lines, '.', 10);
    const xd = try u.map(lines, Xd.init);
    const dxs: [8]i64 = .{ 1, 1,  1,  0, -1, -1, -1, 0 };
    const dys: [8]i64 = .{ 1, 0, -1, -1, -1,  0,  1, 1 };
    var label: u64 = 1;
    var label_to_value: std.AutoArrayHashMap(u64, i64) = .init(gpa);
    var num: i64 = 0;
    for (xd) |xdd| {
        label += 1;
        num = 0;
        for (xdd) |*xddd| {
            if (xddd.ch >= '0' and xddd.ch <= '9') {
                xddd.label = label;
                num = 10 * num + (xddd.ch - '0');
                try label_to_value.put(label, num);
            } else {
                label += 1;
                num = 0;
            }
        }
    }
    for (xd, 0..) |xdd, i| {
        for (xdd, 0..) |xddd, j| {
            if (xddd.ch == '*') {
                const adj = u.adj(xd, i, j, dxs, dys);
                var n_labels: usize = 0;
                var labels: [2]u64 = .{ 0, 0 };
                for (adj) |a| {
                    if (a.label != 0 and a.label != labels[0] and a.label != labels[1]) {
                        if (n_labels < 2) {
                            labels[n_labels] = a.label;
                        }
                        n_labels += 1;
                    }
                }
                if (n_labels == 2) {
                    const a = label_to_value.get(labels[0]) orelse return error.InvalidLabel;
                    const b = label_to_value.get(labels[1]) orelse return error.InvalidLabel;
                    sum += a * b;
                }
            }
        }
    }
    return sum;
}
