const std = @import("std");

const INPUT_BUFFER_SIZE = 1048576;

const Direction = enum {
    N,
    S,
    E,
    W,
    NE,
    NW,
    SE,
    SW,
};
const XY = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    const input_file = "input.txt";
    const map_init: CharMap = try .init(input_file);
    var map = map_init;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var result: u16 = 0;

    const start: usize = map.getChar('^').?;
    var first_guard: Guard = try .init(.N, start, '^', allocator);
    try first_guard.patrol(&map);
    // const max_locations = first_guard.visited.count();

    for (map_init.grid_string, 0..) |elem, i| {
        if (elem == '.') {
            var temp_map = map_init;
            temp_map.grid_string[i] = '#';
            var temp_gaurd: Guard = try .init(.N, start, '^', allocator);
            // std.debug.print("{s}\n", .{temp_map.grid_string});
            try temp_gaurd.patrol(&temp_map);

            if (temp_gaurd.visited.get(temp_gaurd.location).? > 4) {
                std.debug.print("Loop!!!\n", .{});
                std.debug.print("{s}\n", .{temp_map.grid_string});
                result += 1;
            }
            // std.debug.print("{s}\n", .{temp_map.grid_string});
            // std.debug.print("locations visited: {d}\n", .{temp_gaurd.visited.count()});
        }
    }

    std.debug.print("result is {d}\n", .{result});
}

const CharMap = struct {
    grid_string: [INPUT_BUFFER_SIZE]u8 = undefined,
    grid_string_len: usize = undefined,
    width: usize = undefined,
    height: usize = undefined,

    const Self = @This();

    pub fn init(input_path: []const u8) !Self {
        var self: Self = .{};
        var file = try std.fs.cwd().openFile(input_path, .{});
        defer file.close();
        self.grid_string_len = try file.read(&self.grid_string);
        // std.debug.print("file length is {d}\n", .{self.grid_string_len});
        self.width = std.mem.indexOf(u8, &self.grid_string, "\n").? + 1;
        // std.debug.print("width of each line is {d}\n", .{self.width});
        self.height = self.grid_string_len / self.width + 1;
        // std.debug.print("height is {d}\n", .{self.height});
        return self;
    }

    pub fn init_slice(input: []const u8) Self {
        var self: Self = .{};
        std.mem.copyForwards(u8, &self.grid_string, input);
        self.grid_string_len = std.mem.indexOf(u8, &self.grid_string, "\x00").?;
        self.width = std.mem.indexOf(u8, &self.grid_string, "\n").? + 1;
        self.height = self.grid_string_len.self.width;
        return self;
    }

    pub fn getXY(self: *Self, i: usize) XY {
        return .{ .x = i % self.width, .y = i / self.width };
    }

    pub fn indexFromXY(self: *Self, xy: XY) usize {
        return xy.y * self.width + xy.x;
    }

    pub fn getChar(self: *Self, needle: u8) ?usize {
        for (self.grid_string, 0..) |c, i| {
            if (needle == c) {
                return i;
            }
        }
        return null;
    }

    pub fn checkDirection(self: *Self, i: usize, dir: Direction) ?usize {
        var xy = self.getXY(i);
        switch (dir) {
            .N => {
                if (xy.y > 0) xy.y -= 1 else return null;
            },
            .S => {
                if (xy.y < self.height - 1) {
                    xy.y += 1;
                } else {
                    // std.debug.print("failed because location ({d}, {d}) is less than height {d}\n", .{ xy.x, xy.y, self.height });
                    return null;
                }
            },
            .E => {
                if (xy.x < self.width - 2) xy.x += 1 else return null;
            },
            .W => {
                if (xy.x > 0) xy.x -= 1 else return null;
            },
            else => unreachable,
        }
        return self.indexFromXY(xy);
    }
};

const Guard = struct {
    direction: Direction,
    location: usize,
    char: u8,
    visited: std.AutoArrayHashMap(usize, u32),

    const Self = @This();

    pub fn init(direction: Direction, location: usize, char: u8, allocator: std.mem.Allocator) !Self {
        var self: Self = .{ .direction = direction, .location = location, .char = char, .visited = .init(allocator) };
        try self.visited.put(location, 1);
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.visited.deinit();
    }

    pub fn turn(self: *Self) void {
        switch (self.direction) {
            .N => {
                self.char = '>';
                self.direction = Direction.E;
            },
            .E => {
                self.char = 'v';
                self.direction = Direction.S;
            },
            .S => {
                self.char = '<';
                self.direction = Direction.W;
            },
            .W => {
                self.char = '^';
                self.direction = Direction.N;
            },
            else => unreachable,
        }
    }

    pub fn patrol(self: *Self, map: *CharMap) !void {
        while (try self.step(map)) {
            // std.debug.print("{s}\n", .{map.grid_string});
        }
    }

    pub fn step(self: *Self, map: *CharMap) !bool {
        const next_i: usize = if (map.checkDirection(self.location, self.direction)) |i| i else return false;

        if (map.grid_string[next_i] == '#') {
            self.turn();
            map.grid_string[self.location] = self.char;
        } else {
            map.grid_string[self.location] = 'X';
            self.location = next_i;
            const result = try self.visited.getOrPut(self.location);
            if (!result.found_existing) {
                result.value_ptr.* = 0;
            }
            result.value_ptr.* += 1;
            if (self.visited.get(self.location).? > 4) {
                // std.debug.print("infinte loop found\n", .{});
                return false;
            }
            map.grid_string[self.location] = self.char;
        }
        return true;
    }
};
