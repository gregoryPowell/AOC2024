const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";
    var safe_levels: i64 = 0;

    // Read file
    const content = try read_file(allocator, file_name);

    // Parse file input to get rid of unwanted data
    const parsed_data = try parse_data_by_line(allocator, content);

    // take the parsed lines then parse them further
    for (parsed_data) |levels| {
        const parsed_level = try parse_data(allocator, levels);
        var parsed_buffer = std.ArrayList(i32).init(allocator);
        defer parsed_buffer.deinit();

        // iterate over each level and pull out values
        for (parsed_level) |value| {
            const num = try std.fmt.parseInt(i32, value, 10);
            try parsed_buffer.append(num);
        }

        std.debug.print("{d} : ", .{parsed_buffer.items});

        // run level tests and increment counter if safe level
        if (try test_level(allocator, parsed_buffer.items)) {
            std.debug.print("Safe Level!!!\n", .{});
            safe_levels += 1;
        } else {
            std.debug.print("Level failed :(\n", .{});
        }
    }

    // Print result
    std.debug.print("result is {d}\n", .{safe_levels});
}

// get content from file
fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}

// parse data by white space
fn parse_data(
    allocator: std.mem.Allocator,
    input_buf: []const u8,
) ![][]const u8 {
    var tokens = std.mem.tokenizeAny(u8, input_buf, " \t\n\r");
    var parsed_buf = std.ArrayList([]const u8).init(allocator);

    while (tokens.next()) |token| {
        const owned_token = try allocator.dupe(u8, token);
        try parsed_buf.append(owned_token);
    }

    return parsed_buf.items;
}

// parse data by line
fn parse_data_by_line(
    allocator: std.mem.Allocator,
    input_buf: []const u8,
) ![][]const u8 {
    var levels = std.mem.tokenizeAny(u8, input_buf, "\n\r");
    var parsed_lvl = std.ArrayList([]const u8).init(allocator);

    while (levels.next()) |token| {
        const owned_token = try allocator.dupe(u8, token);
        try parsed_lvl.append(owned_token);
    }

    return parsed_lvl.items;
}

// test an entire level to decide if its safe or not
fn test_level(allocator: std.mem.Allocator, data: []i32) !bool {
    var past_val: i32 = undefined;
    var diffed_vals = std.ArrayList(i32).init(allocator);

    for (data, 0..) |value, i| {
        if (i != 0) {
            try diffed_vals.append(value - past_val);
        }
        past_val = value;
    }

    var safe: bool = true;
    const check: i16 = @intCast(try is_safe(diffed_vals.items));
    if (check > -1) {
        if ((check <= 1 and try is_safe(diffed_vals.items[1..]) < 0) or ((check == diffed_vals.items.len - 1) and (try is_safe(diffed_vals.items[0 .. diffed_vals.items.len - 1])) < 0)) {
            safe = true;
        } else if ((check == 0) or (try add_and_check(allocator, diffed_vals.items, check, -1) > -1)) {
            if (check == diffed_vals.items.len - 1) {
                safe = false;
            } else if (try add_and_check(allocator, diffed_vals.items, check, 1) > -1) {
                safe = false;
            }
        }
    }
    return safe;
}

fn is_safe(diff_array: []i32) !i32 {
    var prev_diff: i32 = 0;
    for (diff_array, 0..) |diff, i| {
        const abs_diff = @abs(diff);
        if (abs_diff < 1 or abs_diff > 3) { // diff out of bounds
            std.debug.print("issue at index {d} : ", .{i});
            return @intCast(i);
        }
        if (prev_diff == 0) { // init first location
            prev_diff = diff_array[i];
        }
        if ((prev_diff > 0 and diff_array[i] < 0) or (prev_diff < 0 and diff_array[i] > 0)) { // if signs are swapped or 0 fail
            std.debug.print("issue at index {d} : ", .{i});
            return @intCast(i);
        }
    }
    std.debug.print("safty score nothing found : ", .{});
    return -1;
}

// combine one issue location to see if it fixes the issue.  Essentially the same as removing a number
fn add_and_check(allocator: std.mem.Allocator, diff_array: []i32, check_index: i16, side: i16) !i32 {
    var a: i16 = undefined;
    var b: i16 = undefined;
    if (side == -1) { // add to the left of problem location
        a = check_index;
        b = check_index - 1;
    } else { // add to the right of problem location
        a = check_index + 1;
        b = check_index;
    }

    if (diff_array.len == 0) {
        return error.InvalidArraySize; // Handle empty array case (unlikely)
    }

    var new_list = try allocator.alloc(i32, diff_array.len);
    defer allocator.free(new_list);
    @memcpy(new_list, diff_array);
    const new_val: i32 = diff_array[@intCast(a)] + diff_array[@intCast(b)];
    for (@intCast(a)..new_list.len - 1) |i| {
        new_list[i] = new_list[i + 1];
    }
    new_list[@intCast(b)] = new_val;
    new_list = try allocator.realloc(new_list, new_list.len - 1);

    return try is_safe(new_list);
}
