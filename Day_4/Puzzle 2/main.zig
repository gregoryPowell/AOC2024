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

    for (grid, 0..) |line, y_index| {
        for (line, 0..) |elem, x_index| {
            if (elem == 'A') {
                const x: i32 = @intCast(x_index);
                const y: i32 = @intCast(y_index);
                std.debug.print("A found at ({d}, {d})\n", .{ x_index, y_index });
                if (x - 1 >= 0 and x + 1 < line.len and y - 1 >= 0 and y + 1 < grid.len) {
                    // if (check_cross(grid, x_index, y_index)) {
                    //     answer += 1;
                    //     std.debug.print("found a cross at ({d}, {d})\n", .{ x_index, y_index });
                    // }
                    if (check_diagnol(grid, x_index, y_index)) {
                        answer += 1;
                        std.debug.print("found a diagonol at ({d}, {d})\n", .{ x_index, y_index });
                    }
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

// All cases:
// M.M...S.M...S.S...M.S
// .A.....A.....A.....A.
// S.S...S.M...M.M...M.S
fn check_diagnol(data: [][]const u8, x: usize, y: usize) bool {
    if ((data[y - 1][x - 1] == 'M' and data[y - 1][x + 1] == 'M') and (data[y + 1][x + 1] == 'S' and data[y + 1][x - 1] == 'S')) { // case 1
        return true;
    } else if ((data[y - 1][x - 1] == 'S' and data[y - 1][x + 1] == 'M') and (data[y + 1][x + 1] == 'M' and data[y + 1][x - 1] == 'S')) { // case 2
        return true;
    } else if ((data[y - 1][x - 1] == 'S' and data[y - 1][x + 1] == 'S') and (data[y + 1][x + 1] == 'M' and data[y + 1][x - 1] == 'M')) { // case 3
        return true;
    } else if ((data[y - 1][x - 1] == 'M' and data[y - 1][x + 1] == 'S') and (data[y + 1][x + 1] == 'S' and data[y + 1][x - 1] == 'M')) { // case 4
        return true;
    } else return false;
}

// All cases:
// .M.....M.....S.....S.
// MAS...SAM...SAM...MAS
// .S.....S.....M.....M.
fn check_cross(data: [][]const u8, x: usize, y: usize) bool {
    if ((data[y - 1][x] == 'M' and data[y][x + 1] == 'S') and (data[y + 1][x] == 'S' and data[y][x - 1] == 'M')) { // case 1
        return true;
    } else if ((data[y - 1][x] == 'M' and data[y][x + 1] == 'M') and (data[y + 1][x] == 'S' and data[y][x - 1] == 'S')) { // case 2
        return true;
    } else if ((data[y - 1][x] == 'S' and data[y][x + 1] == 'M') and (data[y + 1][x] == 'M' and data[y][x - 1] == 'S')) { // case 3
        return true;
    } else if ((data[y - 1][x] == 'S' and data[y][x + 1] == 'S') and (data[y + 1][x] == 'M' and data[y][x - 1] == 'M')) { // case 2
        return true;
    } else return false;
}
