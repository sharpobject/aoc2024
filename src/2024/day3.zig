const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    for (0..input.len-7) |i| {

        if (std.mem.eql(u8, input[i..i+4], "mul(")) {
            var j = i+4;
            var seen_comma: bool = false;
            var seen_paren: bool = false;
            var nn1: usize = 0;
            var nn2: usize = 0;
            var n1: usize = 0;
            var n2: usize = 0;
            var ok = true;
            while (j < input.len) : (j += 1) {
                if ('0' <= input[j] and input[j] <= '9') {
                    if (seen_comma) {
                        n2 = 10 * n2 + (input[j] - '0');
                        nn2 += 1;
                    } else {
                        n1 = 10 * n1 + (input[j] - '0');
                        nn1 += 1;
                    }
                } else if (input[j] == ',') {
                    if (seen_comma) {
                        ok = false;
                        break;
                    } else {
                        seen_comma = true;
                    }
                } else if (input[j] == ')') {
                    if (seen_comma and nn1 > 0 and nn2 > 0) {
                        seen_paren = true;
                        break;
                    } else {
                        ok = false;
                        break;
                    }
                } else {
                    ok = false;
                    break;
                }
            }
            if (ok and seen_paren) {
                sum += @intCast(n1 * n2);
            }
        }
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    var enable = true;
    for (0..input.len-7) |i| {
        if (std.mem.eql(u8, input[i..i+4], "do()")) {
            enable = true;
        }
        if (std.mem.eql(u8, input[i..i+7], "don't()")) {
            enable = false;
        }
        if (std.mem.eql(u8, input[i..i+4], "mul(")) {
            var j = i+4;
            var seen_comma: bool = false;
            var seen_paren: bool = false;
            var nn1: usize = 0;
            var nn2: usize = 0;
            var n1: usize = 0;
            var n2: usize = 0;
            var ok = true;
            while (j < input.len) : (j += 1) {
                if ('0' <= input[j] and input[j] <= '9') {
                    if (seen_comma) {
                        n2 = 10 * n2 + (input[j] - '0');
                        nn2 += 1;
                    } else {
                        n1 = 10 * n1 + (input[j] - '0');
                        nn1 += 1;
                    }
                } else if (input[j] == ',') {
                    if (seen_comma) {
                        ok = false;
                        break;
                    } else {
                        seen_comma = true;
                    }
                } else if (input[j] == ')') {
                    if (seen_comma and nn1 > 0 and nn2 > 0) {
                        seen_paren = true;
                        break;
                    } else {
                        ok = false;
                        break;
                    }
                } else {
                    ok = false;
                    break;
                }
            }
            if (ok and seen_paren) {
                if(enable) {
                    sum += @intCast(n1 * n2);
                }
            }
        }
    }
    return sum;
}
