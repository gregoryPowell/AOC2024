const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";
    const result: u32 = 0;

    const content = try read_file(allocator, file_name);
    std.debug.print("{s}\n", .{content});

    var token = std.mem.tokenizeSequence(u8, content, "\r\n\r\n");

    if (token.peek() != null) {
        const rules_by_line = try parse_lines(allocator, token.next().?);
        std.debug.print("Rules array are: \n{s}\n", .{rules_by_line});
    }
    if (token.peek() != null) {
        const books_by_line = try parse_lines(allocator, token.next().?);
        std.debug.print("Books arrray are: \n{s}\n", .{books_by_line});
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

fn parse_lines(allocator: std.mem.Allocator, data: []const u8) ![][]const u8 {
    var result_array = std.ArrayList([]const u8).init(allocator);
    defer result_array.deinit();
    var line = std.mem.tokenizeAny(u8, data, "\r\n");

    while (line.peek() != null) {
        result_array.append(line.next().?) catch |err| {
            std.debug.print("Error found : {any}\n", .{err});
        };
    }
    return try result_array.toOwnedSlice();
}
