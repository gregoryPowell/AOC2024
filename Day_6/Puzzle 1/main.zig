const std = @import("std");
const err = error.OutOfBounds;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";
    const result: u32 = 0;

    const content = try read_file(allocator, file_name);
    const board = try build_board(allocator, content);
    print_board(board);
    _ = move_gaurd(board) catch {
        std.debug.print("game over gaurd left board! \n", .{});
    };

    std.debug.print("Result: {d}\n", .{result});
}

// get content from file
fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}

fn build_board(allocator: std.mem.Allocator, input: []const u8) ![][]const u8 {
    var board = std.ArrayList([]const u8).init(allocator);
    defer board.deinit();

    var line = std.mem.tokenizeAny(u8, input, "\n\r");
    while (line.peek() != null) {
        try board.append(line.next().?);
    }

    return try board.toOwnedSlice();
}

fn print_board(board: [][]const u8) void {
    for (board) |line| {
        std.debug.print("{s}\n", .{line});
    }
}

fn move_gaurd(board: [][]const u8) ![][]const u8 {
    for (board, 0..) |line, i| {
        for (line, 0..) |elem, j| {
            switch (elem) {
                '<' => {
                    std.debug.print("moving left...\n", .{});
                    const valid = try valid_move(board, j - 1, i);
                    if (valid) {
                        std.debug.print("good to move...left", .{});
                    }
                },
                '^' => {
                    std.debug.print("moving up...\n", .{});
                    const valid = try valid_move(board, j, i - 1);
                    if (valid) {
                        std.debug.print("good to move...up\n", .{});
                    }
                },
                '>' => {
                    std.debug.print("moving right...\n", .{});
                    const valid = try valid_move(board, j + 1, i);
                    if (valid) {
                        std.debug.print("good to move...right\n", .{});
                    }
                },
                'V' => {
                    std.debug.print("moving down...", .{});
                    const valid = try valid_move(board, j, i + 1);
                    if (valid) {
                        std.debug.print("good to move...down\n", .{});
                    }
                },
                else => {},
            }
        }
    }
    return board;
}

fn valid_move(board: [][]const u8, x: usize, y: usize) !bool {
    if (x < 0 or x >= board[0].len or y < 0 or y >= board.len) {
        return error.OutOfBounds;
    } else if (board[y][x] == '#') {
        return false;
    } else return true;
}

fn move_gaurd(board: [][]const u8, x_old: usize, y_old: usize, x_new: usize, y_new: usize) [][]const u8 {
    board[y_new][x_new] = board[x]

    return board;
}
