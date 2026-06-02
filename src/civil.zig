const days_per_era = 400 * 365 + 97;
const epoch_days_since_0000_02_29 = 730426;

pub fn ymd_to_days(y: i32, m: u32, d: i32) i34 {
    var years: u32 = @intCast(y + 14700 * 400);
    var month_days_temp: u32 = 979 * m;
    if (m <= 2) {
        years -= 1;
        month_days_temp += 8829;
    } else {
        month_days_temp -= 2919;
    }
    const month_days: u32 = month_days_temp / 32;
    const centuries: u32 = years / 100;
    const year_days: u33 = @as(u33, years * 365) + years / 4 - centuries + centuries / 4;
    var days = @as(i34, year_days + month_days) + d;
    days -= 14700 * days_per_era + epoch_days_since_0000_02_29;
    return days;
}


/// This is essentially just ymd_to_days with the month and day parameters fixed as constants.
pub fn year_to_days(y: i32) i34 {
    const years: u32 = @intCast(y + 14700 * 400 - 1);
    const centuries: u32 = years / 100;
    var days: i34 = @as(u33, years * 365) + years / 4 - centuries + centuries / 4 + 307;
    days -= 14700 * days_per_era + epoch_days_since_0000_02_29;
    return days;
}

/// This is kept around for testing purposes; though it can be faster than `year_to_days` in
/// Debug builds, and sometimes slightly faster in release builds, it's usually slower in
/// optimized builds.  It seems to only be faster when the data is already in the L1 cache;
/// perhaps this helps the branch predictor, since `year_to_days` is branchless and seems
/// to retain the same speed regardless of the size of data being processed.
pub fn year_to_days_alt(y: i32) i34 {
    const year_offset = y - 2000;
    var leap_years: i32 = 0;
    if (year_offset <= 0) {
        const century_offset: i32 = @divTrunc(year_offset, 100);
        leap_years = ((year_offset + 3) >> 2) - century_offset + ((century_offset + 3) >> 2);
    } else if (year_offset > 0) {
        // If 'year' is a leap year, the leap day doesn't happen until february, which is after
        // the start of the year.  So we won't actually "pass" it until the next year.  To account
        // for this we can just subtract 1 from the year offset when it's positive and add 1 to
        // leap_years, since epoch_year is a leap year.
        const modified_year_offset: i32 = year_offset - 1;
        const century_offset: i32 = @divTrunc(modified_year_offset, 100);
        leap_years = (modified_year_offset >> 2) - century_offset + (century_offset >> 2) + 1;
    }
    return year_offset * 365 + leap_years;
}

const YMD = struct {
    y: i32,
    m: i32,
    d: i32,
};

pub const civil32 = struct {
    // Date conversion for 32-bit targets
    // based on https://github.com/benjoffe/fast-date-benchmarks/blobmain/algorithms/benjoffe_article_2.hpp
    // Modified for 2000-01-01 epoch instead of 1970-01-01

    const k: u32 = (719162 + 306 - 3845 - days_per_era * 4) * 4 + 3;
    const l: i32 = 14695 * 400;

    pub const year_to_days = civil.year_to_days;
    pub fn days_to_year(days: i32) i32 {
        const d0_33: u33 = @bitCast(@as(i33, days) + 0x8000_0000);
        const d0: u32 = @truncate(d0_33);
        const bucket: u32 = d0 >> 20;
        const era_days: u32 = d0 - (7 * days_per_era) * bucket + 10957;
        const qds: u32 = era_days * 4 + k;
        const cen: u32 = qds / days_per_era;
        const jul: u32 = qds - (cen & ~@as(u32, 3)) + cen * 4;
        const yrs: u32 = jul / 1461;
        const rem: u32 = jul % 1461 / 4;

        var year: i32 = @intCast(yrs + bucket * (7 * 400));
        if (rem >= 306) year += 1;
        year -= l;

        return year;
    }

    pub const ymd_to_days = civil.ymd_to_days;
    pub fn days_to_ymd(days: i32) YMD {
        const d0_33: u33 = @bitCast(@as(i33, days) + 0x8000_0000);
        const d0: u32 = @truncate(d0_33);
        const bucket: u32 = d0 >> 20;
        const era_days: u32 = d0 - (7 * days_per_era) * bucket + 10957;
        const qds: u32 = era_days * 4 + k;
        const cen: u32 = qds / days_per_era;
        const jul: u32 = qds - (cen & ~@as(u32, 3)) + cen * 4;
        const yrs: u32 = jul / 1461;
        const rem: u32 = jul % 1461 / 4;

        // Neri-Schneider technique for Day & Month:
        const n: u32 = rem * 2141 + 197913;
        const m: u32 = n / 65536;
        const d: u32 = n % 65536 / 2141;

        const bump: u1 = @intFromBool(rem >= 306);
        const day: u32 = d + 1;
        const month: u32 = if (bump != 0) m - 12 else m;
        var year: i32 = @intCast(yrs + bucket * (7 * 400) + bump);
        year -= l;

        return .{
            .y = year,
            .m = @intCast(month),
            .d = @intCast(day),
        };
    }
    
};

pub const civil64 = struct {
    // Date conversion for 64-bit targets
    // based on https://github.com/benjoffe/fast-date-benchmarks/blob/main/algorithms/benjoffe_fast64.hpp
    // Modified for 2000-01-01 epoch instead of 1970-01-01

    const eras = 14705;
    const d_shift: i64 = eras * days_per_era - epoch_days_since_0000_02_29;
    const y_shift: i64 = 400 * eras - 1;

    const scale = switch (builtin.cpu.arch) {
        .aarch64, .aarch64_be => 1,
        else => 32,
    };

    const shift_0: u32 = 30556 * scale;
    const shift_1: u32 = 5980 * scale;

    const c1: u128 = 505054698555331; // floor(2^64*4/146097)
    const c2: u128 = 50504432782230121; // ceil(2^64*4/1461)
    const c3: u128 = 8619973866219416 * 32 / scale; // floor(2^64/2140);
    const c4: u128 = 24451 * scale;

    pub const year_to_days = civil.year_to_days;
    pub fn days_to_year(days: i32) i32 {
        // 1. Adjust for 100/400 leap year rule
        const reverse_days: u64 = @intCast(d_shift - days);
        const centuries: u64 = @intCast((reverse_days * c1) >> 64); // divide by 36524.25
        const reverse_julian: u64 = reverse_days - centuries / 4 + centuries;

        // 2. Determine year and year-part
        const reverse_years_fixedpoint: u128 = reverse_julian * c2; // divide by 365.25
        const reverse_years: u32 = @intCast(reverse_years_fixedpoint >> 64);
        const years: i32 = @intCast(y_shift - reverse_years);
        const low: u64 = @truncate(reverse_years_fixedpoint);
        const year_part: u32 = @intCast((c4 * low) >> 64);

        // Overflow year when Jan or Feb:
        return if (year_part < 3952 * scale) years + 1 else years;
    }

    pub const ymd_to_days = civil.ymd_to_days;
    pub fn days_to_ymd(days: i32) YMD {
        // 1. Adjust for 100/400 leap year rule
        const reverse_days: u64 = @intCast(d_shift - days);
        const centuries: u64 = @intCast((reverse_days * c1) >> 64); // divide by 36524.25
        const reverse_julian: u64 = reverse_days - centuries / 4 + centuries;

        // 2. Determine year and year-part
        const reverse_years_fixedpoint: u128 = reverse_julian * c2; // divide by 365.25
        const reverse_years: u32 = @intCast(reverse_years_fixedpoint >> 64);
        const years: i32 = @intCast(y_shift - reverse_years);
        const low: u64 = @truncate(reverse_years_fixedpoint);
        const year_part: u32 = @intCast((c4 * low) >> 64);

        var bump: bool = undefined;
        const shift: u32 = if (scale == 1) shift_0 else shift: {
            bump = year_part < 3952 * scale;
            break :shift if (bump) shift_1 else shift_0;
        };

        // 3. Year-modulo-bitshift for leap years, also revert to forward direction.
        const mod: u32 = @intCast(@mod(years, 4));
        const n: u32 = mod * (16 * scale) + shift - year_part;
        var month: u32 = n / (2048 * scale);
        const raw_day: i32 = @intCast((c3 * (n % (2048 * scale))) >> 64);

        if (scale == 1) {
            bump = month > 12;
            if (bump) month -= 12;
        }

        return .{
            .y = if (bump) years + 1 else years,
            .m = @intCast(month),
            .d = raw_day + 1,
        };
    }
};

const civil = @This();

const builtin = @import("builtin");
const std = @import("std");
