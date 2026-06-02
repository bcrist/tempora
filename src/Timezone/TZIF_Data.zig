id: []const u8,
kind: union (enum) {
    system,
    uncompressed: []const u8,
    compressed_zlib: []const u8,
    link: *const TZIF_Data,
},

pub const init = init_uncompressed;

pub fn init_uncompressed(id: []const u8, bytes: []const u8) TZIF_Data {
    return .{
        .id = id,
        .kind = .{ .uncompressed = bytes },
    };
}

pub fn init_compressed(id: []const u8, compressed_bytes: []const u8) TZIF_Data {
    return .{
        .id = id,
        .kind = .{ .compressed_zlib = compressed_bytes },
    };
}

pub fn init_link(id: []const u8, link: *const TZIF_Data) TZIF_Data {
    return .{
        .id = id,
        .kind = .{ .link = link },
    };
}

const TZIF_Data = @This();
