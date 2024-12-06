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

    {
        Problem.input = input_small;
        const solution = try Problem.part12();
        try stdout.print(switch (@TypeOf(solution[0])) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution[0]});
    }
    {
        Problem.input = input_small2;
        const solution = try Problem.part12();
        try stdout.print(switch (@TypeOf(solution[1])) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution[1]});
    }
    {
        Problem.input = input;
        const solution = try Problem.part12();
        //_ = solution;
        try stdout.print(switch (@TypeOf(solution[0])) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution[0]});
        try stdout.print(switch (@TypeOf(solution[1])) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution[1]});
    }
}
