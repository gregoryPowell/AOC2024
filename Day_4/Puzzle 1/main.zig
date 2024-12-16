const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";
    var answer: u32 = 0;

    const content = try read_file(allocator, file_name);
    std.debug.print("{s}\n", .{content});

    const grid = try read_line(allocator, content);

    std.debug.print("x length = {d}\n", .{grid[0].len});
    std.debug.print("y length = {d}\n", .{grid.len});

    for (grid, 0..) |line, y| {
        for (line, 0..) |elem, x| {
            if (elem == 'X') {
                if (try check_north(allocator, grid, x, y)) {
                    answer += 1;
                }
                if (try check_north_east(allocator, grid, x, y)) {
                    answer += 1;
                }
                if (try check_east(allocator, line, x)) {
                    answer += 1;
                }
                if (try check_south_east(allocator, grid, x, y)) {
                    answer += 1;
                }
                if (try check_south(allocator, grid, x, y)) {
                    answer += 1;
                }
                if (try check_south_west(allocator, grid, x, y)) {
                    answer += 1;
                }
                if (try check_west(allocator, line, x)) {
                    answer += 1;
                }
                if (try check_north_west(allocator, grid, x, y)) {
                    answer += 1;
                }
            }
        }
    }

    std.debug.print("the result is: {d}\n", .{answer});
}

// get content from file
fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}

// Break input by line
fn read_line(allocator: std.mem.Allocator, content: []const u8) ![][]const u8 {
    var token = std.mem.tokenizeAny(u8, content, "\n\r");
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    while (token.peek() != null) {
        try lines.append(token.next().?);
    }
    return lines.toOwnedSlice();
}

// Check west
fn check_west(allocator: std.mem.Allocator, data: []const u8, start_x: usize) !bool {
    const x: i32 = @intCast(start_x);
    if (x - 3 < 0) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_x - i]);
    }

    std.debug.print("check west found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// Check east
fn check_east(allocator: std.mem.Allocator, data: []const u8, start_x: usize) !bool {
    const x: i32 = @intCast(start_x);
    if (x + 4 > data.len) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_x + i]);
    }

    std.debug.print("check east found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// check north
fn check_north(allocator: std.mem.Allocator, data: [][]const u8, start_x: usize, start_y: usize) !bool {
    const y: i32 = @intCast(start_y);
    if (y - 3 < 0) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_y - i][start_x]);
    }

    std.debug.print("check north found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// check south
fn check_south(allocator: std.mem.Allocator, data: [][]const u8, start_x: usize, start_y: usize) !bool {
    const y: i32 = @intCast(start_y);
    if (y + 4 > data.len) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_y + i][start_x]);
    }

    std.debug.print("check south found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// check north west
fn check_north_west(allocator: std.mem.Allocator, data: [][]const u8, start_x: usize, start_y: usize) !bool {
    const x: i32 = @intCast(start_x);
    const y: i32 = @intCast(start_y);
    if (x - 3 < 0 or y - 3 < 0) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_y - i][start_x - i]);
    }

    std.debug.print("check north west found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// check south west
fn check_south_west(allocator: std.mem.Allocator, data: [][]const u8, start_x: usize, start_y: usize) !bool {
    const x: i32 = @intCast(start_x);
    const y: i32 = @intCast(start_y);
    if (x - 3 < 0 or y + 4 > data.len) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_y + i][start_x - i]);
    }

    std.debug.print("check south west found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// check north east
fn check_north_east(allocator: std.mem.Allocator, data: [][]const u8, start_x: usize, start_y: usize) !bool {
    const x: i32 = @intCast(start_x);
    const y: i32 = @intCast(start_y);
    if (x + 4 > data[0].len or y - 3 < 0) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_y - i][start_x + i]);
    }

    std.debug.print("check north east found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}

// check south east
fn check_south_east(allocator: std.mem.Allocator, data: [][]const u8, start_x: usize, start_y: usize) !bool {
    const x: i32 = @intCast(start_x);
    const y: i32 = @intCast(start_y);
    if (x + 4 > data[0].len or y + 4 > data.len) {
        return false;
    }

    var word = std.ArrayList(u8).init(allocator);
    defer word.deinit();

    for (0..4) |i| {
        try word.append(data[start_y + i][start_x + i]);
    }

    std.debug.print("check south east found the word: {s}\n", .{word.items});

    return std.mem.eql(u8, word.items, "XMAS");
}
