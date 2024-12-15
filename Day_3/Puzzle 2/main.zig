const std = @import("std");

pub const Error = error{failed};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";
    var answer: i64 = 0;
    var valid_answer: bool = true;

    // Read file
    const content = try read_file(allocator, file_name);
    std.debug.print("File read in is as follows: \n{s}\n", .{content});

    var data = std.mem.tokenizeSequence(u8, content, "mul(");

    while (data.peek() != null) {
        const data_chunck = data.next().?;
        std.debug.print("next value is: {s}\n", .{data_chunck});

        if (valid_answer) {
            answer += chuck_check(data_chunck, ",") catch {
                std.debug.print("error detected\n", .{});
                continue;
            };
        }

        if (chunk_contains_do(data_chunck) > chunk_contains_dont(data_chunck)) {
            std.debug.print("chunk has a do later than don't so is good\n", .{});
            valid_answer = true;
        } else if (chunk_contains_dont(data_chunck) > chunk_contains_do(data_chunck)) {
            std.debug.print("chunk has a don't later than do so is bad\n", .{});
            valid_answer = false;
        }
    }

    std.debug.print("next result is: {d}\n", .{answer});
}

// get content from file
fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}

// see if chunck is valid command
fn chuck_check(chunk: []const u8, delimiter: []const u8) !i64 {
    var check_1 = std.mem.tokenizeAny(u8, chunk, delimiter);
    while (check_1.peek() != null) {
        var new_chunk = check_1.next().?;
        // std.debug.print("next inner chunk is: {s} --> ", .{new_chunk});
        if (new_chunk.len > 3) {
            // std.debug.print("chunk is too big\n", .{});
            return error.failed;
        }

        for (new_chunk) |elem| {
            if ((elem < 48) or (elem > 57)) {
                // std.debug.print("has a non numeric value\n", .{});
                return error.failed;
            }
        }

        const good_value = try std.fmt.parseInt(i64, new_chunk, 10);
        // std.debug.print("is a good value {d}\n", .{good_value});

        if (delimiter[0] == ',') {
            new_chunk = check_1.next().?;
            const answer = chuck_check(new_chunk, ")") catch {
                // std.debug.print("result was bad exiting\n", .{});
                return error.failed;
            };
            // std.debug.print("result is : {d}\n", .{good_value * answer});
            return good_value * answer;
        } else {
            return good_value;
        }
    }
    return error.failed;
}

fn chunk_contains_do(chunk: []const u8) i32 {
    if (std.mem.containsAtLeast(u8, chunk, 1, "do()")) {
        const value = std.mem.indexOf(u8, chunk, "do()").?;
        return @intCast(value);
    } else return -1;
}

fn chunk_contains_dont(chunk: []const u8) i32 {
    if (std.mem.containsAtLeast(u8, chunk, 1, "don't()")) {
        const value = std.mem.indexOf(u8, chunk, "don't()").?;
        return @intCast(value);
    } else return -1;
}
