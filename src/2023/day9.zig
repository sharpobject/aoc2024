const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

pub fn part12() !struct{?i128, ?i128} {
    return .{ try part1(), try part2() };
}

var xd: [1000][1000]i64 = @bitCast([_]i64{0} ** (1000 * 1000));

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    for (lines) |line| {
        const nums = u.trimSplitParse(line, ' ');
        const n = nums.len;
        @memcpy(xd[0][0..n], nums);
        var i: usize = 1;
        while(i < n) : (i += 1) {
            var mask: i64 = 0;
            for (0..n-i) |j| {
                xd[i][j] = xd[i-1][j+1] - xd[i-1][j];
                mask |= xd[i][j];
            }
            if (mask == 0) {
                xd[i][n-i] = 0;
                break;
            }
        }
        const maxi = i;
        while (i > 0) {
            i -= 1;
            xd[i][n-i] = xd[i][n-i-1] + xd[i+1][n-i-1];
        }
        i = 0;
        while (i < maxi) : (i += 1) {
            //std.debug.print("{any}\n", .{xd[i][0..n-i+1]});
        }
        sum += xd[0][n];
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    for (lines) |line| {
        const nums = u.trimSplitParse(line, ' ');
        u.reverse(nums);
        const n = nums.len;
        @memcpy(xd[0][0..n], nums);
        var i: usize = 1;
        while(i < n) : (i += 1) {
            var mask: i64 = 0;
            for (0..n-i) |j| {
                xd[i][j] = xd[i-1][j+1] - xd[i-1][j];
                mask |= xd[i][j];
            }
            if (mask == 0) {
                xd[i][n-i] = 0;
                break;
            }
        }
        const maxi = i;
        while (i > 0) {
            i -= 1;
            xd[i][n-i] = xd[i][n-i-1] + xd[i+1][n-i-1];
        }
        i = 0;
        while (i < maxi) : (i += 1) {
            //std.debug.print("{any}\n", .{xd[i][0..n-i+1]});
        }
        sum += xd[0][n];
    }
    return sum;
}
