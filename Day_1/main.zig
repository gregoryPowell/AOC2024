const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input";

    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();
    const file_length = (try file.stat()).size;

    const buffer = try std.fs.cwd().readFileAlloc(allocator, file_name, file_length);
    std.debug.print("file size is {d}\n", .{buffer.len});
    std.debug.print("{s}", .{buffer});
}
