const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";
    var result: i32 = 0;

    const content = try read_file(allocator, file_name);

    var token = std.mem.tokenizeSequence(u8, content, "\n\n");

    var rules: [][]i32 = undefined;
    var books: [][]i32 = undefined;

    if (token.peek() != null) {
        const rules_by_line = try parse_lines(allocator, token.next().?);
        rules = try line_to_array(allocator, rules_by_line);
    }

    if (token.peek() != null) {
        const books_by_line = try parse_lines(allocator, token.next().?);
        books = try line_to_array(allocator, books_by_line);
    }

    const good_books = try valid_books(allocator, rules, books);
    std.debug.print("The good books are: {d}\n", .{good_books});

    for (good_books) |book| {
        result += book[((book.len + 1) / 2) - 1];
        std.debug.print("adding {d} to result\n", .{book[((book.len + 1) / 2) - 1]});
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
    var line = std.mem.tokenizeAny(u8, data, "\n\r");

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

    return try result_array.toOwnedSlice();
}

fn valid_books(allocator: std.mem.Allocator, rules: [][]i32, books: [][]i32) ![][]i32 {
    var good_books = std.ArrayList([]i32).init(allocator);
    defer good_books.deinit();

    for (books) |book| {
        const book_check = good_book(rules, book);
        if (book_check != null) {
            try good_books.append(book_check.?);
        }
    }

    return try good_books.toOwnedSlice();
}

fn good_book(rules: [][]i32, book: []i32) ?[]i32 {
    for (book, 0..) |page, i| {
        for (rules) |rule| {
            for (rule, 0..) |value, j| {
                if (value == page and j == 0 and i != 0) {
                    if (contains(book[0 .. i - 1], rule[1])) {
                        std.debug.print("book {d} failed due to rule {d}\n", .{ book, rule });
                        return null;
                    }
                } else if (value == page and j == 1 and i != book.len - 1) {
                    if (contains(book[i + 1 ..], rule[0])) {
                        std.debug.print("book {d} failed due to rule {d}\n", .{ book, rule });
                        return null;
                    }
                }
            }
        }
    }
    return book;
}

fn contains(array: []i32, check: i32) bool {
    for (array) |elem| {
        if (elem == check) {
            return true;
        }
    }
    return false;
}
