const std = @import("std");

pub const Error = error{failed};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";
    var answer: i64 = 0;
    var cleaning_buffer = true;

    // Read file
    var content = try read_file(allocator, file_name);

    while (cleaning_buffer) {
        if (std.mem.eql(u8, content, remove_trash(allocator, content))) {
            cleaning_buffer = false;
        } else {
            content = remove_trash(allocator, content);
            std.debug.print("cleaning the buffer\n", .{});
        }
    }

    var data = std.mem.tokenizeSequence(u8, content, "mul(");

    while (data.peek() != null) {
        const data_chunck = data.next().?;
        answer += chuck_check(data_chunck, ",") catch {
            continue;
        };
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

fn remove_trash(allocator: std.mem.Allocator, chunk: []const u8) []const u8 {
    const index = std.mem.indexOf(u8, chunk, "don't()");

    if (index == null) {
        return chunk;
    } else {
        const clean_index = index.?;
        const end_index = std.mem.indexOf(u8, chunk[clean_index..], "do()");

        if (end_index == null) {
            return "";
        } else {
            const clean_end_index = end_index.? + clean_index;
            var list = std.ArrayList(u8).init(allocator);
            defer list.deinit();

            list.appendSlice(chunk[0..clean_index]) catch {
                std.debug.print("there has been a mistake\n", .{});
            };
            list.appendSlice(chunk[clean_end_index..]) catch {
                std.debug.print("there has been a mistake\n", .{});
            };

            const items = list.toOwnedSlice() catch {
                std.debug.print("there has been a mistake\n", .{});
                return "";
            };
            return items;
        }
    }
}
