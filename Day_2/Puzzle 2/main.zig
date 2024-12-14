const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "test_input.txt";
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

        std.debug.print("{d} --> ", .{parsed_buffer.items});

        if (try test_level(allocator, parsed_buffer.items)) {
            safe_levels += 1;
        }
    }

    // Print result
    std.debug.print("result is {d}\n", .{safe_levels});
}

fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_len = try file.getEndPos();
    const content = try file.readToEndAlloc(allocator, file_len);
    return content;
}

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

fn test_level(allocator: std.mem.Allocator, data: []i32) !bool {
    var past_val: i32 = undefined;
    var diffed_vals = std.ArrayList(i32).init(allocator);

    for (data, 0..) |value, i| {
        if (i != 0) {
            try diffed_vals.append(value - past_val);
        }
        past_val = value;
    }

    std.debug.print("{d} --> ", .{diffed_vals.items});

    if (sameSign(diffed_vals.items)) {
        return withinBounds(diffed_vals.items);
    } else {
        for (diffed_vals.items, 0..) |diffed_value, i| {
            if (diffed_vals.items[0] >= 0) {
                std.debug.print("was initally positive --> ", .{});
                if (diffed_value < 0) {
                    std.debug.print("then had a negative --> ", .{});
                    if (diffed_value + diffed_vals.items[i - 1] > 0) {
                        std.debug.print("adding 1 below made it positive -->", .{});
                        return withinBounds(diffed_vals.items);
                    } else if (diffed_value + diffed_vals.items[i + 1] > 0) {
                        std.debug.print("adding 1 above made it positive -->", .{});
                        return withinBounds(diffed_vals.items);
                    } else {
                        std.debug.print("was not fixable\n", .{});
                        return false;
                    }
                }
            } else if (diffed_vals.items[0] < 0) {
                std.debug.print("was initally negative --> ", .{});
                if (diffed_value >= 0) {
                    std.debug.print("then had a positive --> ", .{});
                    if (diffed_value + diffed_vals.items[i - 1] < 0) {
                        std.debug.print("adding 1 below made it negative -->", .{});
                        return withinBounds(diffed_vals.items);
                    } else if (diffed_value + diffed_vals.items[i + 1] < 0) {
                        std.debug.print("adding 1 above made it negative -->", .{});
                        return withinBounds(diffed_vals.items);
                    } else {
                        std.debug.print("was not fixable\n", .{});
                        return false;
                    }
                }
            }
        }
        return false;
    }
}

fn sameSign(arr: []i32) bool {
    const first_sign: i16 = if (arr[0] > 0) 1 else if (arr[0] < 0) -1 else 0;

    for (arr) |el| {
        const el_sign: i16 = if (el > 0) 1 else if (el < 0) -1 else 0;
        if (el_sign != first_sign) {
            return false;
        }
    }

    return true;
}

fn withinBounds(data: []i32) bool {
    for (data, 0..) |elem, i| {
        if (@abs(elem) > 3 or elem == 0) {
            if (@abs(elem + data[i - 1]) <= 3 and @abs(elem + data[i - 1]) >= 1) {
                std.debug.print("was fixed by adding 1 below\n", .{});
                return true;
            } else if (@abs(elem + data[i + 1]) <= 3 and @abs(elem + data[i + 1]) >= 1) {
                std.debug.print("was fixed by adding 1 above\n", .{});
                return true;
            } else {
                std.debug.print("was not fixable\n", .{});
                return false;
            }
        }
    }
    std.debug.print("was already good!!!\n", .{});
    return true;
}
