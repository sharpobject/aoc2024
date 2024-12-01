const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;

const Problem = @import("problem");
const u = Problem.u;

pub fn main() !void {
    const stdout = io.getStdOut().writer();

    var arena = heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    Problem.gpa = allocator;
    Problem.u.gpa = allocator;
    const input_small = @embedFile("input_small");
    const input_small2 = @embedFile("input_small2");
    const input = @embedFile("input");

    Problem.input = input_small;
    if (try Problem.part1()) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution});

    Problem.input = input_small2;
    if (try Problem.part2()) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution});

    Problem.input = input;
    if (try Problem.part1()) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution});

    if (try Problem.part2()) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution});
}
