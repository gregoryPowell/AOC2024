const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";
    const result: u32 = 0;

    const content = try read_file(allocator, file_name);
    std.debug.print("{s}\n", .{content});

    var token = std.mem.tokenizeSequence(u8, content, "\r\n\r\n");

    var rules: [][]i32 = undefined;
    var books: [][]i32 = undefined;

    if (token.peek() != null) {
        const rules_by_line = try parse_lines(allocator, token.next().?);
        std.debug.print("Rules array are: \n{s}\n", .{rules_by_line});
        rules = try line_to_array(allocator, rules_by_line);
        std.debug.print("Formatted rules array is: \n{d}\n", .{rules});
    }
    if (token.peek() != null) {
        const books_by_line = try parse_lines(allocator, token.next().?);
        std.debug.print("Books arrray are: \n{s}\n", .{books_by_line});
        books = try line_to_array(allocator, books_by_line);
        std.debug.print("Formatted books array are: \n{d}\n", .{books});
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

fn line_to_array(allocator: std.mem.Allocator, data: [][]const u8) ![][]i32 {
    var result_array = std.ArrayList([]i32).init(allocator);
    defer result_array.deinit();
    var line_array = std.ArrayList(i32).init(allocator);
    defer line_array.deinit();
    for (data) |line| {
        var value = std.mem.tokenizeAny(u8, line, ",|\n\r");
        while (value.peek() != null) {
            try line_array.append(try std.fmt.parseInt(i32, value.next().?, 10));
        }
        try result_array.append(try line_array.toOwnedSlice());
    }

    return result_array.toOwnedSlice();
}
