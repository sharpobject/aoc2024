const std = @import("std");
const mem = std.mem;
pub const u = @import("u.zig");

pub var input: []const u8 = undefined;
pub var gpa: mem.Allocator = undefined;

const HandRank = enum(u8) {
    high_card = 0,
    pair = 1,
    two_pair = 2,
    three_of_a_kind = 3,
    full_house = 4,
    four_of_a_kind = 5,
    five_of_a_kind = 6,
};

fn classify(hand: []const u8) HandRank {
    const hist_ = u.histogram(hand[0..5]);
    const hist = u.histogram(&hist_);
    if (hist[5] > 0) {
        return .five_of_a_kind;
    } else if (hist[4] > 0) {
        return .four_of_a_kind;
    } else if (hist[3] > 0) {
        if (hist[2] > 0) {
            return .full_house;
        }
        return .three_of_a_kind;
    } else if (hist[2] > 1) {
        return .two_pair;
    } else if (hist[2] > 0) {
        return .pair;
    }
    return .high_card;
}

const labels = [_]u8{'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'};

fn classify2(hand_: []const u8) HandRank {
    var hand: [5]u8 = undefined;
    var rank: HandRank = .high_card;
    for (labels) |label| {
        @memcpy(&hand, hand_[0..5]);
        for (hand[0..5]) |*ch| {
            if (ch.* == 'J') {
                ch.* = @intCast(label);
            }
        }
        const otherRank = classify(&hand);
        rank = @enumFromInt(@max(@intFromEnum(rank), @intFromEnum(otherRank)));
    }
    return rank;
}

fn get_ch_to_power() [256]u8 {
    var ret: [256]u8 = [_]u8{0} ** 256;
    for ('2'..('9'+1)) |ch| {
        ret[ch] = ch;
    }
    var value = '9' + 1;
    ret['T'] = value;
    value += 1;
    ret['J'] = value;
    value += 1;
    ret['Q'] = value;
    value += 1;
    ret['K'] = value;
    value += 1;
    ret['A'] = value;
    return ret;
}

const ch_to_power = get_ch_to_power();

fn powerify(hand: []const u8) [5]u8 {
    var ret: [5]u8 = undefined;
    for (hand[0..5], 0..) |ch, i| {
        ret[i] = ch_to_power[ch];
    }
    return ret;
}

fn powerify2(hand: []const u8) [5]u8 {
    var ret: [5]u8 = undefined;
    for (hand[0..5], 0..) |ch, i| {
        ret[i] = ch_to_power[ch];
        if (ret[i] == ch_to_power['J']) {
            ret[i] = 0;
        }
    }
    return ret;
}

pub fn part1() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    u.sortCmp(lines, struct{pub fn lessThan(a: []const u8, b: []const u8) bool {
        const a_rank = classify(a);
        const b_rank = classify(b);
        if (a_rank != b_rank) {
            return @intFromEnum(a_rank) < @intFromEnum(b_rank);
        }
        return std.mem.lessThan(u8, &powerify(a), &powerify(b));
    }}.lessThan);
    for (lines, 1..) |line, i| {
        std.debug.print("fucker: {s}\n", .{line});
        sum += @as(i64, @intCast(i)) * try std.fmt.parseInt(i64, u.trimSplit(line, ' ')[1], 10);
    }
    return sum;
}

pub fn part2() !?i128 {
    var lines = u.trimSplit(input, '\n');
    var sum: i64 = 0;
    u.use(&sum, &lines);
    u.sortCmp(lines, struct{pub fn lessThan(a: []const u8, b: []const u8) bool {
        const a_rank = classify2(a);
        const b_rank = classify2(b);
        if (a_rank != b_rank) {
            return @intFromEnum(a_rank) < @intFromEnum(b_rank);
        }
        return std.mem.lessThan(u8, &powerify2(a), &powerify2(b));
    }}.lessThan);
    for (lines, 1..) |line, i| {
        std.debug.print("fucker: {s}\n", .{line});
        sum += @as(i64, @intCast(i)) * try std.fmt.parseInt(i64, u.trimSplit(line, ' ')[1], 10);
    }
    return sum;
}
