const std = @import("std");
const err = error.OutOfBounds;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";

    const content = try read_file(allocator, file_name);
    var board = try build_board(allocator, content);

    while (contains_gaurd(board)) {
        print_board(board);
        board = new_board(board) catch remove_gaurd(board);
    }

    print_board(board);

    const result = count_spaces(board);
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

fn build_board(allocator: std.mem.Allocator, input: []const u8) ![][]u8 {
    var board = std.ArrayList([]u8).init(allocator);
    defer board.deinit();
    var row = std.ArrayList(u8).init(allocator);
    defer row.deinit();

    var line = std.mem.tokenizeAny(u8, input, "\n\r");
    while (line.peek() != null) {
        for (line.next().?) |elem| {
            try row.append(elem);
        }
        try board.append(try row.toOwnedSlice());
    }

    return try board.toOwnedSlice();
}

fn print_board(board: [][]u8) void {
    for (board) |line| {
        std.debug.print("{s}\n", .{line});
    }
}

fn new_board(board: [][]u8) ![][]u8 {
    for (board, 0..) |line, i| {
        for (line, 0..) |elem, j| {
            switch (elem) {
                '<' => {
                    std.debug.print("moving left...\n", .{});
                    if (j == 0) {
                        std.debug.print("Game Over!!!\n", .{});
                        return remove_gaurd(board);
                    } else {
                        const valid = try valid_move(board, j - 1, i);
                        if (valid) {
                            std.debug.print("good to move...left\n", .{});
                            return move_gaurd(board, j, i, j - 1, i);
                        } else {
                            return rotate_gaurd(board, j, i);
                        }
                    }
                },
                '^' => {
                    std.debug.print("moving up...\n", .{});
                    if (i == 0) {
                        std.debug.print("Game Over!!!\n", .{});
                        return remove_gaurd(board);
                    } else {
                        const valid = try valid_move(board, j, i - 1);
                        if (valid) {
                            std.debug.print("good to move...up\n", .{});
                            return move_gaurd(board, j, i, j, i - 1);
                        } else {
                            return rotate_gaurd(board, j, i);
                        }
                    }
                },
                '>' => {
                    std.debug.print("moving right...\n", .{});
                    const valid = try valid_move(board, j + 1, i);
                    if (valid) {
                        std.debug.print("good to move...right\n", .{});
                        return move_gaurd(board, j, i, j + 1, i);
                    } else {
                        return rotate_gaurd(board, j, i);
                    }
                },
                'v' => {
                    std.debug.print("moving down...\n", .{});
                    const valid = try valid_move(board, j, i + 1);
                    if (valid) {
                        std.debug.print("good to move...down\n", .{});
                        return move_gaurd(board, j, i, j, i + 1);
                    } else {
                        return rotate_gaurd(board, j, i);
                    }
                },
                else => {},
            }
        }
    }
    return board;
}

fn valid_move(board: [][]u8, x: usize, y: usize) !bool {
    if (x >= board[0].len or y >= board.len) {
        return error.OutOfBounds;
    } else if (board[y][x] == '#') {
        return false;
    } else return true;
}

fn move_gaurd(board: [][]u8, x_old: usize, y_old: usize, x_new: usize, y_new: usize) [][]u8 {
    board[y_new][x_new] = board[y_old][x_old];
    board[y_old][x_old] = 'X';

    return board;
}

fn rotate_gaurd(board: [][]u8, x: usize, y: usize) [][]u8 {
    switch (board[y][x]) {
        '<' => board[y][x] = '^',
        '^' => board[y][x] = '>',
        '>' => board[y][x] = 'v',
        'v' => board[y][x] = '<',
        else => {},
    }
    return board;
}

fn remove_gaurd(board: [][]u8) [][]u8 {
    for (board, 0..) |line, i| {
        for (line, 0..) |elem, j| {
            if (elem == '<' or elem == '^' or elem == '>' or elem == 'v') {
                board[i][j] = 'X';
            }
        }
    }
    return board;
}

fn contains_gaurd(board: [][]u8) bool {
    for (board) |line| {
        for (line) |elem| {
            if (elem == '<' or elem == '^' or elem == '>' or elem == 'v') {
                return true;
            }
        }
    }
    return false;
}

fn count_spaces(board: [][]u8) u16 {
    var count: u16 = 0;
    for (board) |line| {
        for (line) |elem| {
            if (elem == 'X') {
                count += 1;
            }
        }
    }

    return count;
}
