const std = @import("std");
const mem = std.mem;
const u = @import("u.zig");

i: []const u8,
a: mem.Allocator,

const Color = enum(u8) {
    red,
    green,
    blue,
};

pub fn part1(this: *const @This()) !?i64 {
    u.a = this.a;
    const lines = try u.trimSplit(this.i, '\n');
    var sum: i64 = 0;
    for (lines) |line| {
        const xd = try u.trimSplit(line, ':');
        const header_str = xd[0];
        const games_str = xd[1];
        const games = try u.trimSplit(games_str, ';');
        var possible: bool = true;
        for (games) |game| {
            const reveals = try u.trimSplit(game, ',');
            for (reveals) |reveal_str| {
                const reveal = try u.trimSplit(reveal_str, ' ');
                const color = std.meta.stringToEnum(Color, reveal[1]) orelse return error.InvalidColor;
                const count = try std.fmt.parseInt(u8, reveal[0], 10);
                if (color == .red and count > 12) possible = false;
                if (color == .green and count > 13) possible = false;
                if (color == .blue and count > 14) possible = false;
            }
        }
        if (possible) {
            const header = try u.trimSplit(header_str, ' ');
            sum += try std.fmt.parseInt(u8, header[1], 10);
        }
    }
    return sum;
}

pub fn part2(this: *const @This()) !?i64 {
    u.a = this.a;
    const lines = try u.trimSplit(this.i, '\n');
    var sum: i64 = 0;
    for (lines) |line| {
        const xd = try u.trimSplit(line, ':');
        //const header_str = xd[0];
        const games_str = xd[1];
        const games = try u.trimSplit(games_str, ';');
        var red: i64 = 0;
        var green: i64 = 0;
        var blue: i64 = 0;
        for (games) |game| {
            const reveals = try u.trimSplit(game, ',');
            for (reveals) |reveal_str| {
                const reveal = try u.trimSplit(reveal_str, ' ');
                const color = std.meta.stringToEnum(Color, reveal[1]) orelse return error.InvalidColor;
                const count = try std.fmt.parseInt(u8, reveal[0], 10);
                if (color == .red) red = @max(red, count);
                if (color == .green) green = @max(green, count);
                if (color == .blue) blue = @max(blue, count);
            }
        }
        sum += red * green * blue;
    }
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