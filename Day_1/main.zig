const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input";

    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();
    const file_length = (try file.stat()).size;

    const buffer = try std.fs.cwd().readFileAlloc(allocator, file_name, file_length);
    std.debug.print("file size is {d}\n", .{buffer.len});
    std.debug.print("{s}\n", .{buffer});

    var splits = std.mem.splitSequence(u8, buffer, "\n");
    var original_rows = std.ArrayList(u8).init(allocator);
    defer original_rows.deinit();
    var j: u32 = 0;
    while (splits.next()) |line| {
        std.debug.print("line is {s}\n", .{line});
        try original_rows.appendSlice(line);
        j += 1;
    }
}
