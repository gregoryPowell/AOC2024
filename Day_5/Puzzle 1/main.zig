const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";
    const result: u32 = 0;

    const content = try read_file(allocator, file_name);
    std.debug.print("{s}\n", .{content});

    var token = std.mem.tokenizeSequence(u8, content, "\r\n\r\n");
    var rules: []const u8 = undefined;
    var books: []const u8 = undefined;
    if (token.peek() != null) {
        rules = token.next().?;
        std.debug.print("Rules are: \n{s}\n", .{rules});
    }
    if (token.peek() != null) {
        books = token.next().?;
        std.debug.print("Books are: \n{s}\n", .{books});
    }

    std.debug.print("Result is: {d}\n", .{result});
}

// get content from file
fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}
