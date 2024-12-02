const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

fn isSafe(nums: []const i64) bool {
    var safe: bool = true;
    var increasing: bool = false;
    var decreasing: bool = false;
    for (nums[1..], 1..) |num, i| {
        if (num < nums[i-1]) {
            decreasing = true;
        } else if (num > nums[i-1]) {
            increasing = true;
        } else {
            safe = false;
        }
        if (@abs(num - nums[i-1]) > 3) {
            safe = false;
        }
    }
    if (increasing and decreasing) {
        safe = false;
    }
    return safe;
}

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    for (lines) |line| {
        const nums_s = u.trimSplit(line, ' ');
        const nums = u.map(nums_s, struct{fn parse(s: []const u8) !i64 {
            return try std.fmt.parseInt(i64, s, 10);
        }}.parse);
        for (nums_s, 0..) |num_s, i| {
            nums[i] = try std.fmt.parseInt(i64, num_s, 10);
        }
        const safe = isSafe(nums);
        sum += if (safe) 1 else 0;
    }


    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    for (lines) |line| {
        const nums_s = u.trimSplit(line, ' ');
        const nums = try gpa.alloc(i64, nums_s.len);
        for (nums_s, 0..) |num_s, i| {
            nums[i] = try std.fmt.parseInt(i64, num_s, 10);
        }
        var safe = isSafe(nums);
        const othernums = try gpa.alloc(i64, nums.len-1);
        for (0..nums.len) |del| {
            var i: usize = 0;
            for (0..nums.len) |j| {
                if (j == del) continue;
                othernums[i] = nums[j];
                i += 1;
            }
            safe = safe or isSafe(othernums);
        }
        sum += if (safe) 1 else 0;
    }


    return sum;
}
