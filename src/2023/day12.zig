const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;
var dp: [200][200]usize = undefined;
// dp[i][j] = number of assignments with the i'th chunk starting at j'th position


pub fn part12() !struct{?i128, ?i128} {
    var lines = u.trimSplit(input, '\n');
    var s1: i64 = 0;
    var s2: i64 = 0;
    u.use3(&s1, &s2, &lines);

    //var mqc: usize = 0;
    //var ml: usize = 0;
    for (lines) |line| {
        const stuff, const junks = u.trimSplit2(line, ' ');
        const junk = u.trimSplitParse(junks, ',');
        var zeroes: usize = 0;
        var ones: usize = 0;
        //stuff = u.reversed(stuff);
        for (stuff, 0..) |c, i| {
            if (c == '.') {
                zeroes |= (@as(usize, 1) << @as(u6, @intCast(i)));
            } else if (c == '#') {
                ones |= (@as(usize, 1) << @as(u6, @intCast(i)));
            }
        }
        var n: usize = 0;
        for (0..(@as(usize, 1) << @as(u6, @intCast(stuff.len)))) |mask| {
            if ((ones & mask) != ones) {
                continue;
            }
            if ((zeroes & ~mask) != zeroes) {
                continue;
            }
            var xd = mask;
            var ok = true;
            for (junk) |j| {
                if (xd == 0) {
                    ok = false;
                    break;
                }
                xd >>= @as(u6,@intCast(@ctz(xd)));
                xd = ~xd;
                if (@ctz(xd) != j) {
                    ok = false;
                    break;
                }
                xd = (~xd) >> @as(u6,@intCast(@ctz(xd)));
            }
            if (xd == 0 and ok) {
                s1 += 1;
                n += 1;
            }
        }
        //std.debug.print("n: {d}\n", .{n});
        const multiplier = 5;
        const l2 = u.alloc(u8, stuff.len * multiplier + (multiplier-1) + 2);
        const j2 = u.alloc(isize, junk.len * multiplier + 1);
        for (0..multiplier) |i| {
            @memcpy(l2[i*(stuff.len+1)..i*(stuff.len+1)+stuff.len], stuff);
            @memcpy(j2[i*(junk.len)..i*(junk.len)+junk.len], junk);
            if (i < multiplier - 1) {
                l2[i*(stuff.len+1)+stuff.len] = '?';
            }
        }
        l2[l2.len-2] = '.';
        l2[l2.len-1] = '#';
        j2[j2.len-1] = 1;
        //std.debug.print("l2: {s}\n", .{l2});
        // dp[i][j] = number of assignments of the chunks i..n
        // with the i'th chunk starting at j'th position
        dp = [_][200]usize{[_]usize{0} ** 200} ** 200;
        //@memset(dp, 0);
        dp[j2.len-1][l2.len-1] = 1;
        var i: usize = j2.len-1;
        var thisn: usize = 0;
        while (i > 0) {
            i -= 1;
            // try to place the i'th chunk at each position j
            const chunklen = @as(usize, @intCast(j2[i]));
            var j: usize = l2.len - chunklen;
            while (j > 0) {
                j -= 1;
                if (i == 0) {
                    // there must be no '#' to the left of j
                    var ok = true;
                    for (0..j) |k| {
                        if (l2[k] == '#') {
                            ok = false;
                            break;
                        }
                    }
                    if (!ok) {
                        continue;
                    }
                }
                if (j > 0 and l2[j-1] == '#') {
                    continue;
                }
                var k: usize = j;
                var ok = true;
                while (k < j + chunklen) {
                    if (l2[k] == '.') {
                        ok = false;
                        break;
                    }
                    k += 1;
                }
                if (!ok) {
                    continue;
                }
                if (l2[k] == '#') {
                    continue;
                }
                k += 1;
                var nways: usize = 0;
                while (k < l2.len) : (k += 1) {
                    nways += dp[i+1][k];
                    if (l2[k] == '#') {
                        break;
                    }
                }
                dp[i][j] = nways;
                if (i == 0) {
                    s2 += @intCast(nways);
                    thisn += nways;
                }
            }
            //std.debug.print("chunklen: {d}\n", .{chunklen});
            //std.debug.print("dp[{d}]: {any}\n", .{ i, dp[i] });
        }
        //std.debug.print("thisn: {d}\n", .{thisn});

    }
    //std.debug.print("ml: {d}\n", .{ml});

        return .{ s1, s2 };
}
