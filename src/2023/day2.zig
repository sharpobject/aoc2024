const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

const Color = enum(u8) {
    red,
    green,
    blue,
};

pub fn part1() !?i64 {
    const lines = try u.trimSplit(input, '\n');
    var sum: i64 = 0;
    for (lines) |line| {
        const header_str, const games_str = try u.trimSplit2(line, ':');
        const games = try u.trimSplit(games_str, ';');
        var possible: bool = true;
        for (games) |game| {
            const reveals = try u.trimSplit(game, ',');
            for (reveals) |reveal_str| {
                const count_str, const color_str = try u.trimSplit2(reveal_str, ' ');
                const color = std.meta.stringToEnum(Color, color_str) orelse return error.InvalidColor;
                const count = try std.fmt.parseInt(u8, count_str, 10);
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

pub fn part2() !?i64 {
    const lines = try u.trimSplit(input, '\n');
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
