const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part12() !struct{?i128, ?i128} {
    return .{ try part1(), try part2() };
}

pub fn part1() !?i64 {
    const lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    for (lines) |line| {
        var first_number: i64 = -1;
        var last_number: i64 = -1;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                if (first_number == -1) first_number = c - '0';
                last_number = c - '0';
            }
        }
        sum += first_number * 10 + last_number;
    }
    return sum;
}

const digits: [9][]const u8 = .{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

pub fn part2() !?i64 {
    const lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    for (lines) |line| {
        var first_number: i64 = -1;
        var last_number: i64 = -1;
        for (line, 0..) |c, i| {
            var this_number: i64 = -1;
            if (c >= '0' and c <= '9') {
                this_number = c - '0';
            }
            var j: usize = 0;
            while (j < digits.len) : (j += 1) {
                if (i + digits[j].len > line.len) continue;
                if (mem.eql(u8, digits[j], line[i .. i + digits[j].len])) {
                    this_number = @intCast(j + 1);
                }
            }
            if (this_number == -1) continue;
            if (first_number == -1) first_number = this_number;
            last_number = this_number;
        }
        sum += first_number * 10 + last_number;
    }
    return sum;
}
