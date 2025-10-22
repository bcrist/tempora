const SYSTEMTIME = extern struct {
    year: win.WORD,
    month: win.WORD,
    day_of_week: win.WORD,
    day: win.WORD,
    hour: win.WORD,
    minute: win.WORD,
    second: win.WORD,
    milliseconds: win.WORD,
};

const DYNAMIC_TIME_ZONE_INFORMATION = extern struct {
    bias: win.LONG,
    standard_name: [32]win.WCHAR,
    standard_date: SYSTEMTIME,
    standard_bias: win.LONG,
    daylight_name: [32]win.WCHAR,
    daylight_date: SYSTEMTIME,
    daylight_bias: win.LONG,
    time_zone_key_name: [128]win.WCHAR,
    dynamic_daylight_time_disabled: win.BOOLEAN,
};

const TIME_ZONE_ID_INVALID: win.DWORD = 0xffffffff;

extern "kernel32" fn GetDynamicTimeZoneInformation(time_zone_information: *DYNAMIC_TIME_ZONE_INFORMATION) callconv(win.WINAPI) win.DWORD;

fn current_timezone_id_windows() ![]const u8 {
    var tzinfo: DYNAMIC_TIME_ZONE_INFORMATION = undefined;
    if (GetDynamicTimeZoneInformation(&tzinfo) == TIME_ZONE_ID_INVALID) {
        return win.unexpectedError(win.kernel32.GetLastError());
    }

    const wide = std.mem.sliceTo(&tzinfo.time_zone_key_name, 0);
    const codepoints = try std.unicode.utf16CountCodepoints(wide);
    if (codepoints <= 40) {
        var buf: [160]u8 = undefined;
        const end = try std.unicode.utf16LeToUtf8(&buf, wide);
        const narrow = buf[0..end];

        // based on territory 001 data from https://github.com/unicode-org/cldr/blob/main/common/supplemental/windowsZones.xml
        if (std.mem.eql(u8, narrow, "Dateline Standard Time")) return "GMT-12";
        if (std.mem.eql(u8, narrow, "UTC-11")) return "GMT-11";
        if (std.mem.eql(u8, narrow, "Aleutian Standard Time")) return "America/Adak";
        if (std.mem.eql(u8, narrow, "Hawaiian Standard Time")) return "Pacific/Honolulu";
        if (std.mem.eql(u8, narrow, "Marquesas Standard Time")) return "Pacific/Marquesas";
        if (std.mem.eql(u8, narrow, "Alaskan Standard Time")) return "America/Anchorage";
        if (std.mem.eql(u8, narrow, "UTC-09")) return "GMT-9";
        if (std.mem.eql(u8, narrow, "UTC-08")) return "GMT-8";
        if (std.mem.eql(u8, narrow, "Pacific Standard Time (Mexico)")) return "America/Tijuana";
        if (std.mem.eql(u8, narrow, "Pacific Standard Time")) return "America/Los_Angeles";
        if (std.mem.eql(u8, narrow, "US Mountain Standard Time")) return "America/Phoenix";
        if (std.mem.eql(u8, narrow, "Mountain Standard Time")) return "America/Denver";
        if (std.mem.eql(u8, narrow, "Mountain Standard Time (Mexico)")) return "America/Mazatlan";
        if (std.mem.eql(u8, narrow, "Yukon Standard Time")) return "America/Whitehorse";
        if (std.mem.eql(u8, narrow, "Central America Standard Time")) return "America/Guatemala";
        if (std.mem.eql(u8, narrow, "Central Standard Time")) return "America/Chicago";
        if (std.mem.eql(u8, narrow, "Easter Island Standard Time")) return "Pacific/Easter";
        if (std.mem.eql(u8, narrow, "Central Standard Time (Mexico)")) return "America/Mexico_City";
        if (std.mem.eql(u8, narrow, "Canada Central Standard Time")) return "America/Regina";
        if (std.mem.eql(u8, narrow, "SA Pacific Standard Time")) return "America/Bogota";
        if (std.mem.eql(u8, narrow, "Eastern Standard Time (Mexico)")) return "America/Cancun";
        if (std.mem.eql(u8, narrow, "Eastern Standard Time")) return "America/New_York";
        if (std.mem.eql(u8, narrow, "Haiti Standard Time")) return "America/Port-au-Prince";
        if (std.mem.eql(u8, narrow, "Cuba Standard Time")) return "America/Havana";
        if (std.mem.eql(u8, narrow, "US Eastern Standard Time")) return "America/Indianapolis";
        if (std.mem.eql(u8, narrow, "Turks And Caicos Standard Time")) return "America/Grand_Turk";
        if (std.mem.eql(u8, narrow, "Paraguay Standard Time")) return "America/Asuncion";
        if (std.mem.eql(u8, narrow, "Atlantic Standard Time")) return "America/Halifax";
        if (std.mem.eql(u8, narrow, "Venezuela Standard Time")) return "America/Caracas";
        if (std.mem.eql(u8, narrow, "Central Brazilian Standard Time")) return "America/Cuiaba";
        if (std.mem.eql(u8, narrow, "SA Western Standard Time")) return "America/La_Paz";
        if (std.mem.eql(u8, narrow, "Pacific SA Standard Time")) return "America/Santiago";
        if (std.mem.eql(u8, narrow, "Newfoundland Standard Time")) return "America/St_Johns";
        if (std.mem.eql(u8, narrow, "Tocantins Standard Time")) return "America/Araguaina";
        if (std.mem.eql(u8, narrow, "E. South America Standard Time")) return "America/Sao_Paulo";
        if (std.mem.eql(u8, narrow, "SA Eastern Standard Time")) return "America/Cayenne";
        if (std.mem.eql(u8, narrow, "Argentina Standard Time")) return "America/Buenos_Aires";
        if (std.mem.eql(u8, narrow, "Greenland Standard Time")) return "America/Godthab";
        if (std.mem.eql(u8, narrow, "Montevideo Standard Time")) return "America/Montevideo";
        if (std.mem.eql(u8, narrow, "Magallanes Standard Time")) return "America/Punta_Arenas";
        if (std.mem.eql(u8, narrow, "Saint Pierre Standard Time")) return "America/Miquelon";
        if (std.mem.eql(u8, narrow, "Bahia Standard Time")) return "America/Bahia";
        if (std.mem.eql(u8, narrow, "UTC-02")) return "GMT-2";
        if (std.mem.eql(u8, narrow, "Azores Standard Time")) return "Atlantic/Azores";
        if (std.mem.eql(u8, narrow, "Cape Verde Standard Time")) return "Atlantic/Cape_Verde";
        if (std.mem.eql(u8, narrow, "UTC")) return "UTC";
        if (std.mem.eql(u8, narrow, "Coordinated Universal Time")) return "GMT";
        if (std.mem.eql(u8, narrow, "GMT Standard Time")) return "Europe/London";
        if (std.mem.eql(u8, narrow, "Greenwich Standard Time")) return "Atlantic/Reykjavik";
        if (std.mem.eql(u8, narrow, "Sao Tome Standard Time")) return "Africa/Sao_Tome";
        if (std.mem.eql(u8, narrow, "Morocco Standard Time")) return "Africa/Casablanca";
        if (std.mem.eql(u8, narrow, "W. Europe Standard Time")) return "Europe/Berlin";
        if (std.mem.eql(u8, narrow, "Central Europe Standard Time")) return "Europe/Budapest";
        if (std.mem.eql(u8, narrow, "Romance Standard Time")) return "Europe/Paris";
        if (std.mem.eql(u8, narrow, "Central European Standard Time")) return "Europe/Warsaw";
        if (std.mem.eql(u8, narrow, "W. Central Africa Standard Time")) return "Africa/Lagos";
        if (std.mem.eql(u8, narrow, "Jordan Standard Time")) return "Asia/Amman";
        if (std.mem.eql(u8, narrow, "GTB Standard Time")) return "Europe/Bucharest";
        if (std.mem.eql(u8, narrow, "Middle East Standard Time")) return "Asia/Beirut";
        if (std.mem.eql(u8, narrow, "Egypt Standard Time")) return "Africa/Cairo";
        if (std.mem.eql(u8, narrow, "E. Europe Standard Time")) return "Europe/Chisinau";
        if (std.mem.eql(u8, narrow, "Syria Standard Time")) return "Asia/Damascus";
        if (std.mem.eql(u8, narrow, "West Bank Standard Time")) return "Asia/Hebron";
        if (std.mem.eql(u8, narrow, "South Africa Standard Time")) return "Africa/Johannesburg";
        if (std.mem.eql(u8, narrow, "FLE Standard Time")) return "Europe/Kiev";
        if (std.mem.eql(u8, narrow, "Israel Standard Time")) return "Asia/Jerusalem";
        if (std.mem.eql(u8, narrow, "South Sudan Standard Time")) return "Africa/Juba";
        if (std.mem.eql(u8, narrow, "Kaliningrad Standard Time")) return "Europe/Kaliningrad";
        if (std.mem.eql(u8, narrow, "Sudan Standard Time")) return "Africa/Khartoum";
        if (std.mem.eql(u8, narrow, "Libya Standard Time")) return "Africa/Tripoli";
        if (std.mem.eql(u8, narrow, "Namibia Standard Time")) return "Africa/Windhoek";
        if (std.mem.eql(u8, narrow, "Arabic Standard Time")) return "Asia/Baghdad";
        if (std.mem.eql(u8, narrow, "Turkey Standard Time")) return "Europe/Istanbul";
        if (std.mem.eql(u8, narrow, "Arab Standard Time")) return "Asia/Riyadh";
        if (std.mem.eql(u8, narrow, "Belarus Standard Time")) return "Europe/Minsk";
        if (std.mem.eql(u8, narrow, "Russian Standard Time")) return "Europe/Moscow";
        if (std.mem.eql(u8, narrow, "E. Africa Standard Time")) return "Africa/Nairobi";
        if (std.mem.eql(u8, narrow, "Iran Standard Time")) return "Asia/Tehran";
        if (std.mem.eql(u8, narrow, "Arabian Standard Time")) return "Asia/Dubai";
        if (std.mem.eql(u8, narrow, "Astrakhan Standard Time")) return "Europe/Astrakhan";
        if (std.mem.eql(u8, narrow, "Azerbaijan Standard Time")) return "Asia/Baku";
        if (std.mem.eql(u8, narrow, "Russia Time Zone 3")) return "Europe/Samara";
        if (std.mem.eql(u8, narrow, "Mauritius Standard Time")) return "Indian/Mauritius";
        if (std.mem.eql(u8, narrow, "Saratov Standard Time")) return "Europe/Saratov";
        if (std.mem.eql(u8, narrow, "Georgian Standard Time")) return "Asia/Tbilisi";
        if (std.mem.eql(u8, narrow, "Volgograd Standard Time")) return "Europe/Volgograd";
        if (std.mem.eql(u8, narrow, "Caucasus Standard Time")) return "Asia/Yerevan";
        if (std.mem.eql(u8, narrow, "Afghanistan Standard Time")) return "Asia/Kabul";
        if (std.mem.eql(u8, narrow, "West Asia Standard Time")) return "Asia/Tashkent";
        if (std.mem.eql(u8, narrow, "Ekaterinburg Standard Time")) return "Asia/Yekaterinburg";
        if (std.mem.eql(u8, narrow, "Pakistan Standard Time")) return "Asia/Karachi";
        if (std.mem.eql(u8, narrow, "Qyzylorda Standard Time")) return "Asia/Qyzylorda";
        if (std.mem.eql(u8, narrow, "India Standard Time")) return "Asia/Calcutta";
        if (std.mem.eql(u8, narrow, "Sri Lanka Standard Time")) return "Asia/Colombo";
        if (std.mem.eql(u8, narrow, "Nepal Standard Time")) return "Asia/Katmandu";
        if (std.mem.eql(u8, narrow, "Central Asia Standard Time")) return "Asia/Almaty";
        if (std.mem.eql(u8, narrow, "Bangladesh Standard Time")) return "Asia/Dhaka";
        if (std.mem.eql(u8, narrow, "Omsk Standard Time")) return "Asia/Omsk";
        if (std.mem.eql(u8, narrow, "Myanmar Standard Time")) return "Asia/Rangoon";
        if (std.mem.eql(u8, narrow, "SE Asia Standard Time")) return "Asia/Bangkok";
        if (std.mem.eql(u8, narrow, "Altai Standard Time")) return "Asia/Barnaul";
        if (std.mem.eql(u8, narrow, "W. Mongolia Standard Time")) return "Asia/Hovd";
        if (std.mem.eql(u8, narrow, "North Asia Standard Time")) return "Asia/Krasnoyarsk";
        if (std.mem.eql(u8, narrow, "N. Central Asia Standard Time")) return "Asia/Novosibirsk";
        if (std.mem.eql(u8, narrow, "Tomsk Standard Time")) return "Asia/Tomsk";
        if (std.mem.eql(u8, narrow, "China Standard Time")) return "Asia/Shanghai";
        if (std.mem.eql(u8, narrow, "North Asia East Standard Time")) return "Asia/Irkutsk";
        if (std.mem.eql(u8, narrow, "Singapore Standard Time")) return "Asia/Singapore";
        if (std.mem.eql(u8, narrow, "W. Australia Standard Time")) return "Australia/Perth";
        if (std.mem.eql(u8, narrow, "Taipei Standard Time")) return "Asia/Taipei";
        if (std.mem.eql(u8, narrow, "Ulaanbaatar Standard Time")) return "Asia/Ulaanbaatar";
        if (std.mem.eql(u8, narrow, "Aus Central W. Standard Time")) return "Australia/Eucla";
        if (std.mem.eql(u8, narrow, "Transbaikal Standard Time")) return "Asia/Chita";
        if (std.mem.eql(u8, narrow, "Tokyo Standard Time")) return "Asia/Tokyo";
        if (std.mem.eql(u8, narrow, "North Korea Standard Time")) return "Asia/Pyongyang";
        if (std.mem.eql(u8, narrow, "Korea Standard Time")) return "Asia/Seoul";
        if (std.mem.eql(u8, narrow, "Yakutsk Standard Time")) return "Asia/Yakutsk";
        if (std.mem.eql(u8, narrow, "Cen. Australia Standard Time")) return "Australia/Adelaide";
        if (std.mem.eql(u8, narrow, "AUS Central Standard Time")) return "Australia/Darwin";
        if (std.mem.eql(u8, narrow, "E. Australia Standard Time")) return "Australia/Brisbane";
        if (std.mem.eql(u8, narrow, "AUS Eastern Standard Time")) return "Australia/Sydney";
        if (std.mem.eql(u8, narrow, "West Pacific Standard Time")) return "Pacific/Port_Moresby";
        if (std.mem.eql(u8, narrow, "Tasmania Standard Time")) return "Australia/Hobart";
        if (std.mem.eql(u8, narrow, "Vladivostok Standard Time")) return "Asia/Vladivostok";
        if (std.mem.eql(u8, narrow, "Lord Howe Standard Time")) return "Australia/Lord_Howe";
        if (std.mem.eql(u8, narrow, "Bougainville Standard Time")) return "Pacific/Bougainville";
        if (std.mem.eql(u8, narrow, "Russia Time Zone 10")) return "Asia/Srednekolymsk";
        if (std.mem.eql(u8, narrow, "Magadan Standard Time")) return "Asia/Magadan";
        if (std.mem.eql(u8, narrow, "Norfolk Standard Time")) return "Pacific/Norfolk";
        if (std.mem.eql(u8, narrow, "Sakhalin Standard Time")) return "Asia/Sakhalin";
        if (std.mem.eql(u8, narrow, "Central Pacific Standard Time")) return "Pacific/Guadalcanal";
        if (std.mem.eql(u8, narrow, "Russia Time Zone 11")) return "Asia/Kamchatka";
        if (std.mem.eql(u8, narrow, "New Zealand Standard Time")) return "Pacific/Auckland";
        if (std.mem.eql(u8, narrow, "UTC+12")) return "GMT+12";
        if (std.mem.eql(u8, narrow, "Fiji Standard Time")) return "Pacific/Fiji";
        if (std.mem.eql(u8, narrow, "Chatham Islands Standard Time")) return "Pacific/Chatham";
        if (std.mem.eql(u8, narrow, "UTC+13")) return "GMT+13";
        if (std.mem.eql(u8, narrow, "Tonga Standard Time")) return "Pacific/Tongatapu";
        if (std.mem.eql(u8, narrow, "Samoa Standard Time")) return "Pacific/Apia";
        if (std.mem.eql(u8, narrow, "Line Islands Standard Time")) return "Pacific/Kiritimati";

        log.warn("No mapping for Windows timezone key '{s}'", .{ narrow });
    } else {
        log.warn("Windows timezone key name too long ({} codepoints; expected < {})", .{ codepoints, 40 });
    }

    const id = switch (std.math.clamp(-@divFloor(tzinfo.bias + 29, 60), -12, 14)) {
        -12 => "GMT-12",
        -11 => "GMT-11",
        -10 => "GMT-10",
        -9 => "GMT-9",
        -8 => "GMT-8",
        -7 => "GMT-7",
        -6 => "GMT-6",
        -5 => "GMT-5",
        -4 => "GMT-4",
        -3 => "GMT-3",
        -2 => "GMT-2",
        -1 => "GMT-1",
        0 => "GMT",
        1 => "GMT+1",
        2 => "GMT+2",
        3 => "GMT+3",
        4 => "GMT+4",
        5 => "GMT+5",
        6 => "GMT+6",
        7 => "GMT+7",
        8 => "GMT+8",
        9 => "GMT+9",
        10 => "GMT+10",
        11 => "GMT+11",
        12 => "GMT+12",
        13 => "GMT+13",
        14 => "GMT+14",
        else => unreachable,
    };

    log.info("Falling back to closest GMT offset: {s}", .{ id });

    return id;
}

fn current_timezone_id_unix() ![]const u8 {
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const raw = try std.fs.cwd().readLink("/etc/localtime", &buf);
    const prefix = "/usr/share/zoneinfo/";

    if (std.mem.startsWith(u8, raw, prefix)) {
        return raw[prefix.len..];
    }

    log.err("Expected /etc/localtime to be a link into {s}; but found {s}", .{ prefix, raw });
    return error.InvalidTimezone;
}

pub fn current_timezone_id() ![]const u8 {
    if (builtin.os.tag == .windows) {
        return current_timezone_id_windows();
    } else {
        return current_timezone_id_unix();
    }
}

const log = std.log.scoped(.tempora);

const win = std.os.windows;
const std = @import("std");
const builtin = @import("builtin");
