const std = @import("std");

const MAP_MAX_SIZE = 100;
const input_path = "test_input.txt";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(input_path, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, try file.getEndPos());
    var map = Map.init(content);
    map.print_input_map();
    const result = map.find_antinodes();

    std.debug.print("Answer is {d}\n", .{result});
}

const Node = struct {
    x: usize,
    y: usize,
    value: u8,

    pub fn init(x: usize, y: usize, value: u8) Node {
        return Node{
            .x = x,
            .y = y,
            .value = value,
        };
    }
};

const Map = struct {
    input_map: [MAP_MAX_SIZE][MAP_MAX_SIZE]u8 = undefined,
    antinode_map: [MAP_MAX_SIZE][MAP_MAX_SIZE]u8 = undefined,
    width: usize = 0,
    height: usize = 0,

    pub fn init(input_string: []const u8) Map {
        var new_map: Map = undefined;
        var map_row = std.mem.splitSequence(u8, input_string, "\n");

        if (map_row.peek() != null) {
            new_map.width = map_row.peek().?.len;
        }
        var index: usize = 0;
        while (map_row.peek() != null) : (index += 1) {
            for (map_row.next().?, 0..) |elem, i| {
                new_map.input_map[index][i] = elem;
                new_map.antinode_map[index][i] = '.';
            }
        }
        new_map.height = index;

        return new_map;
    }

    pub fn find_antinodes(self: *Map) usize {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                if (self.input_map[y][x] != '.') {
                    const node = Node.init(x, y, self.input_map[y][x]);
                    self.find_associated_antinodes(node);
                }
            }
        }
        print_antinode_map(self);
        return count_antinodes(self);
    }

    fn find_associated_antinodes(self: *Map, node: Node) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                if (self.input_map[y][x] == node.value and y != node.y and x != node.x) {
                    std.debug.print("found pair {c} at ({d}, {d})\n", .{ node.value, x, y });
                    const cast_old_y: i64 = @intCast(node.y);
                    const cast_old_x: i64 = @intCast(node.x);
                    const cast_y: i64 = @intCast(y);
                    const cast_x: i64 = @intCast(x);
                    const delta_y: i64 = @intCast(cast_y - cast_old_y);
                    const delta_x: i64 = @intCast(cast_x - cast_old_x);

                    std.debug.print("delta y is {d}\n", .{delta_y});
                    std.debug.print("delta x is {d}\n", .{delta_x});

                    var antinode_x: i64 = undefined;
                    var antinode_y: i64 = undefined;
                    if (cast_y < 0) {
                        antinode_y = cast_y - delta_y;
                    } else {
                        antinode_y = cast_y + delta_y;
                    }

                    if (cast_x < 0) {
                        antinode_x = cast_x - delta_x;
                    } else {
                        antinode_x = cast_x + delta_x;
                    }

                    if (antinode_x >= 0 and antinode_x < self.width and antinode_y >= 0 and antinode_y < self.height) {
                        self.antinode_map[@intCast(antinode_y)][@intCast(antinode_x)] = '#';
                        std.debug.print("antiode at ({d}, {d})\n", .{ antinode_x, antinode_y });
                    }
                }
            }
        }
    }

    fn count_antinodes(self: *Map) usize {
        var counter: usize = 0;
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                if (self.antinode_map[y][x] == '#') {
                    counter += 1;
                }
            }
        }
        return counter;
    }

    pub fn print_input_map(self: *Map) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                std.debug.print("{c}", .{self.input_map[y][x]});
            }
            std.debug.print("\n", .{});
        }
    }

    pub fn print_antinode_map(self: *Map) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                std.debug.print("{c}", .{self.antinode_map[y][x]});
            }
            std.debug.print("\n", .{});
        }
    }
};
