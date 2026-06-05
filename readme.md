# Tempora
### Simple Zig Dates, Times, and Timezones

## Features
* Efficient storage (32b `Time`, 32b `Date`, 64b `Date_Time`)
* Conversion to/from unix timestamps
* Composition and decomposition (year, ordinal day/week, month, day, weekday, hour, minute, second, ms)
    * Uses Ben Joffe's [fast calendar algorithm](https://www.benjoffe.com/fast-date-64)
* Find next/previous weekday/day/ordinal day
* Add/subtract days/hours/minutes/seconds/ms
    * With or without timezone offset correction
    * With or without leap second correction
* Compute duration between two dates/times
    * With or without timezone offset correction
    * With or without leap second correction
* String formatting and parsing with custom formats (similar to moment.js and Java's SimpleDateFormat style)
* Query current timezone on both posix and Windows systems
* Embedded IANA timezone database (adds about 100k to binary size when the full database is referenced)
    * If only specific timezones or regions are needed, only a subset of the database needs to be embedded
    * Timezones can also be loaded from a filesystem zoneinfo database or the timezone database in the Windows registry
    * Regenerating the embedded database does not rely on `zic.c` or any system dependencies (just run `zig build -Dcodegen`)
* No dependencies
    * Except when using `zig build -Dcodegen` or `zig build -Dbenchmarks`

## Limitations
* Times are only accurate to millisecond resolution
* It's not possible to store most "out of bounds" dates/times (e.g. Jan 32)
* Localized month and weekday names are not supported; only English
* Non-Gregorian calendars are not supported

## Why another zig date/time library?
There are a bunch of [other zig date/time libraries](readme.md#comparison-with-other-zig-date-time-libraries), so why did I decide to build a new one?  I was motivated to create tempora because the main data structures for other zig date/time libraries generally contain many separate decomposed fields.  In addition to having many opportunities for non-canonical representations, the large memory footprint makes it very hard to stomache using these types inside structs or arrays, particularly when following data-oriented-design principles.
Instead, I wanted something where the main data structures only provided a slight decomposition over timestamps - just separating the date and time parts.  Any further decomposition can be done on demand, or using auxiliary temporary data structures.  And ideally the solution should not use significantly more memory than a timestamp.

It turns out that "rata die" encoded dates stored in a 32 bit integer have enough range to cover over 10 million years.  Ideally then, I wanted to fit a packed time-of-day representation into a 32 bit integer as well.  Unfortunately, this is a little trickier, and I had to compromise on the resolution.  A nanosecond-resolution time-of-day would require at least 47 bits to span 24 hours.  Even a microsecond-resolution time-of-day would require 37 bits.  While I would have preferred to support resolutions smaller than a millisecond, I think it's probably fine for almost all use cases.  If you need more resolution, it's probably better to just process and store nanosecond timestamps and convert to rounded human-centric types only for display.

My second requirement was good support for timezones, including the ability to embed an IANA timezone database directly into the executable.  Other than tempora, only [zdt](https://codeberg.org/FObersteiner/zdt) comes close to this, but I wanted even more flexibility in deciding how and when to load timezones, and I wanted a pure-zig solution to automatically updating the embedded timezone database.

## API/Examples

### `Date`
Dates are represented as a signed 32b number of days since 1 January 2000, embedded in an enum for type safety.  This type of representation is sometimes referred to as "rata die" (although that name usually connotes a different epoch date) and it makes it impossible to represent invalid dates like January 32 or November 31.

Using this packed representation makes composition and decomposition slower, but greatly simplifies most other operations on dates, like modification and comparison.

#### Construction
```zig
const y: i32 = 1984
const m: i32 = 3
const d: i32 = 1
const date: Date = .from_ymd_numbers(y, m, d);
```
```zig
const ymd: Date.YMD = .from_numbers(1984, 3, 1);
const date: Date = .from_ymd(ymd);
```
```zig
const y: Year = .epoch;
const od: Ordinal_Day = .first;
const date: Date = .from_yod(y, od);
```
```zig
const yi: Year.Info = .from_year(.epoch);
const od: Ordinal_Day = .first;
const date: Date = .from_yiod(yi, od);
```
```zig
const y: Year = .epoch;
const iw: ISO_Week = .first;
const wd: Week_Day = .sunday;
const date: Date = .from_ywd(y, iw, wd);
```
```zig
const yi: Year.Info = .from_year(.epoch);
const iw: ISO_Week = .first;
const wd: Week_Day = .sunday;
const date: Date = .from_yiwd(yi, iw, wd);
```
```zig
const y: Year = .epoch;
const starting_date: Date = .from_year(y);
```

#### Convenience Decls
```zig
var d: Date = .epoch; // 2000-01-01
d = .unix_epoch; // 1970-01-01
d = .ntp_epoch; // 1900-01-01
d = .ntfs_epoch; // 1601-01-01
```

#### Decomposition & Conversion
```zig
const date: Date = .epoch;

const y: Year = date.year();
const yi: Year_Info = date.year_info();
const m: Month = date.month();
const d: Day = date.day();
const od: Ordinal_Day = date.ordinal_day();
const ow: Ordinal_Week = date.ordinal_week();
const wd: Week_Day = date.week_day();
const iw: ISO_Week = date.iso_week();
const iwd: ISO_Week_Date = date.iso_week_date();
const di: Date.Info = date.info();
const ymd: Date.YMD = date.ymd();

const time: Time = .midnight;
const dt: Date_Time = date.with_time(time);
```

#### Comparison
```zig
const date1: Date = .epoch;
const date2: Date = Date.next(.epoch);

std.debug.assert(date1.is_before(date2));
std.debug.assert(!date1.is_before(date1));
std.debug.assert(date2.is_after(date1));
std.debug.assert(!date2.is_after(date2));
```

#### Modification
```zig
var date: Date = .epoch;

const days: i32 = 10;
date = date.plus_days(days);

date = date.next();
date = date.prev();

const wd: Week_Day = .sunday;
date = date.next_week_day(wd);
date = date.prev_week_day(wd);

const d: Day = .@"15";
date = date.next_day_of_month(d);
date = date.prev_day_of_month(d);

const m: Month = .january;
date = date.next_month_and_day(m, d);
date = date.prev_month_and_day(m, d);
```

#### Formatting
```zig
const date: Date = Date.next(.epoch);

writer.print("{f}", .{ date.fmt(Date.iso8601) });       // 2000-01-02
writer.print("{f}", .{ date.fmt(Date.rfc2822) });       // Sun, 02 Jan 2000
writer.print("{f}", .{ date.fmt(Date.us) });            // January 2, 2000
writer.print("{f}", .{ date.fmt(Date.uk) });            // 2 January 2000
writer.print("{f}", .{ date.fmt(Date.us_numeric) });    // 1/2/2000
writer.print("{f}", .{ date.fmt(Date.uk_numeric) });    // 2/1/2000
writer.print("{f}", .{ date.fmt("MMMM YYYY") });        // January 2000
writer.print("{f}", .{ date.fmt("YY") });               // 00
```

#### Parsing
```zig
var date: Date = undefined;

date = try .from_string(Date.iso8601, "2025-10-01");
date = try .from_string("YYYY", "2025"); // 2025-01-01
```

### `Date.YMD`
This struct represents a decomposed date, consisting of a year, month, and day of the month.  In some cases it may be more convenient or efficient to use this over `Date`, but it requires twice as much memory, and some operations are not defined for this struct.

#### Construction
```zig
const y: i32 = 1984
const m: i32 = 3
const d: i32 = 1
const ymd: Date.YMD = .from_numbers(y, m, d);
```
```zig
const y: Year = .epoch;
const m: Month = .january;
const d: Day = .first;
const ymd: Date.YMD = .init(y, m, d);
```
```zig
const date: Date = .epoch;
const ymd: Date.YMD = .from_date(date);
```

#### Decomposition/Conversion
```zig
const ymd: Date.YMD = .from_date(.epoch);

const y: Year = ymd.year;
const m: Month = ymd.month;
const d: Day = ymd.day;
const yi: Year.Info = ymd.year_info();
const date: Date = ymd.date();
const di: Date.Info = ymd.info();
const iwd: ISO_Week_Date = ymd.iso_week_date();
```

#### Comparison
```zig
const ymd1: Date.YMD = .from_date(.epoch);
const ymd2: Date.YMD = .from_date(.next(.epoch));

std.debug.assert(ymd1.is_before(ymd2));
std.debug.assert(!ymd1.is_before(ymd1));
std.debug.assert(ymd2.is_after(ymd1));
std.debug.assert(!ymd2.is_after(ymd2));
```

#### Modification
```zig
var ymd: Date.YMD = .from_date(.epoch);

ymd = ymd.next();
ymd = ymd.prev();

const d: Day = .@"15";
ymd = ymd.next_day_of_month(d);
ymd = ymd.prev_day_of_month(d);

const m: Month = .january;
ymd = ymd.next_month_and_day(m, d);
ymd = ymd.prev_month_and_day(m, d);
```

### `Date.Info`
This struct is similar to `Date.YMD`, but also includes some more decomposed information:
    * The raw date as an integer, i.e. `@intFromEnum(date)`
    * The day of the week
    * The ordinal day (day of year)
    * Whether or not the current year is a leap year
    * A `Date` representing the start of the current week
    * A `Date` representing the start of the current month
    * A `Date` representing the start of the current year

#### Construction
```zig
const date: Date = .epoch;
const di: Date.Info = .from_date(date);
```
```zig
const ymd: Date.YMD = .from_date(.epoch);
const di: Date.Info = .from_ymd(ymd);
```
```zig
const yi: Year.Info = .from_year(.epoch);
const m: Month = .january;
const d: Day = .first;
const di: Date.Info = .from_yimd(yi, m, d);
```

#### Decomposition/Conversion
```zig
const di: Date.Info = .from_date(.epoch);

const raw: i32 = di.raw;
const start_of_year: Date = di.start_of_year;
const start_of_month: Date = di.start_of_month;
const start_of_week: Date = di.start_of_week;
const is_leap_year: bool = di.is_leap_year;
const year: Year = di.year;
const month: Month = di.month;
const day: Day = di.day;
const week_day: Week_Day = di.week_day;
const ordinal_day: Ordinal_Day = di.ordinal_day;
const yi: Year.Info = di.year_info();
const ymd: Date.YMD = di.ymd();
const date: Date = di.date();
const iwd: ISO_Week_Date = di.iso_week_date();
```

### `Time`
The `Time` enum represents a millisecond-resolution offset from midnight (the start of an arbitrary day).  It is backed by `i32` which provides a range of around +/- 24 days, but canonical `Time` values (especially when combined with a `Date`) should be between 0 and 85,399,999.

A `Time` value may represent a time under the [UTC](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) or [TAI](https://en.wikipedia.org/wiki/International_Atomic_Time) standards, a fixed offset from UTC, or a wall-clock time in a specific local timezone.  If this information cannot be inferred from context, you may want to use `Time.With_Offset` instead.

#### Construction
```zig
const ms: i32 = 1234;
const t: Time = .from_ms(ms); // 1.234 seconds after midnight
```
```zig
const s: i32 = 1234;
const t: Time = .from_seconds(s); // 20 minutes and 34 seconds after midnight
```
```zig
const m: i32 = -2;
const t: Time = .from_minutes(m); // 2 minutes before midnight (non-canonical time; refers to the previous day)
```
```zig
const h: i32 = 12;
const t: Time = .from_hours(h); // noon
```
```zig
const h: u31 = 20;
const m: u8 = 30;
const s: u8 = 0;
const ms: u10 = 0;
const t: Time = .from_hmsm(h, m, s, ms); // 8:30 pm
```

#### Hourly Convenience Decls
```zig
const start_of_day: Time = .midnight;
const wakeup: Time = .@"7am";
const lunch: Time = .noon;
const bedtime: Time = .@"10pm";
const end_of_day: Time = .midnight_eod;
```

#### Decomposition & Conversion
```zig
const t: Time = .@"1pm";

const whole_hours_since_midnight: i32 = t.hours();
const whole_minutes_since_hour: i32 = t.minutes();
const whole_seconds_since_minute: i32 = t.seconds();
const milliseconds_since_second: i32 = t.ms();
const whole_minutes_since_midnight: i32 = t.minutes_since_midnight();
const whole_seconds_since_midnight: i32 = t.seconds_since_midnight();
const milliseconds_since_midnight: i32 = t.ms_since_midnight();
const dt: Date_Time = time.with_date(date);
const to1: Time.With_Offset = time.with_offset(utc_offset_ms);
const to2: Time.With_Offset = time.with_timezone(tz, utc_offset_ms);
```

#### Comparison
```zig
const t1: Time = .noon;
const t2: Time = .@"1pm";
// assuming times from the same date:
std.debug.assert(t1.is_before(t2));
std.debug.assert(!t1.is_before(t1));
std.debug.assert(t2.is_after(t1));
std.debug.assert(!t2.is_after(t2));
```

#### Modification
```zig
var t: Time = .noon;

const duration: std.Io.Duration = .fromSeconds(1);
t = t.plus_duration(duration);
t = t.minus_duration(duration);

const ms: i32 = 1234;
t = t.plus_ms(ms);

const s: i32 = 1;
t = t.plus_seconds(s);

const m: i32 = 12
t = t.plus_minutes(m);

const h: i32 = -3;
t = t.plus_hours(h);
```

### `Date_Time`
This struct simply combines a `Date` and `Time`, representing a single instant, but without specifying whether that date and time is based on UTC, TAI, or some local time zone (see `Date_Time.With_Offset` for that).

#### Convenience Decls
```zig
var dt: Date_Time = .epoch; // 2000-01-01T00:00:00.000
dt = .unix_epoch; // 1970-01-01T00:00:00.000
dt = .ntp_epoch; // 1900-01-01T00:00:00.000
dt = .ntfs_epoch; // 1601-01-01T00:00:00.000
```

#### Decomposition & Conversion
```zig
const dt: Date_Time = .epoch;

const date: Date = dt.date;
const t: Time = dt.time;

const utc_offset_ms: i32 = 0;
const dto1: Date_Time.With_Offset = dt.with_offset(utc_offset_ms);

const tz: *const Timezone = &Timezone.utc;
const dto2: Date_Time.With_Offset = dt.with_timezone(tz);
```

#### Comparison
```zig
const dt1: Date_Time = .epoch;
const dt2: Date_Time = Date_Time.next(.epoch);

std.debug.assert(dt1.is_before(dt2));
std.debug.assert(!dt1.is_before(dt1));
std.debug.assert(dt2.is_after(dt1));
std.debug.assert(!dt2.is_after(dt2));

// These do not account for leap seconds; see `Date_Time.With_Offset` versions of these functions
const duration: std.Io.Duration = dt2.duration_since(dt1);
const ms: i32 = dt2.ms_since(dt1);
```

#### Modification
```zig
var dt: Date_Time = .epoch;

// This does not account for leap seconds; see `Date_Time.With_Offset` versions of these functions
const days: i32 = 10;
const ms: i32 = 1234;
dt = dt.plus_days_and_ms(days, ms);

// This does not account for leap seconds; see `Date_Time.With_Offset` versions of these functions
const duration: std.Io.Duration = .fromSeconds(60);
dt = dt.plus_duration(duration);
dt = dt.minus_duration(duration);
```

### `Date_Time.With_Offset`
This struct combines a `Date_Time` with a UTC offset, allowing for conversions to/from unix timestamps.  Optionally, it can also include a pointer to a `Timezone`, which can be helpful when formatting, parsing, and modifying the instant.

#### Construction
```zig
const io: std.Io = ...
const dto: Date_Time.With_Offset = tempora.now_utc(io);
```
```zig
const io: std.Io = ...
const tzdb: *const TZDB = ...
const dto: Date_Time.With_Offset = tempora.now_local(io, tzdb);
```
```zig
const io: std.Io = ...
const tz: *const Timezone = &Timezone.utc;
const dto: Date_Time.With_Offset = tempora.now(io, tz);
```
```zig
const ts: std.Io.Timestamp = .fromNanoseconds(0);
const tz: ?*const Timezone = null;
const dto: Date_Time.With_Offset = .from_timestamp(ts, tz);
```
```zig
const ts: i64 = 0;
const tz: ?*const Timezone = null;
const dto: Date_Time.With_Offset = .from_timestamp_ms(ts, tz);
```
```zig
const ts: i64 = 0;
const tz: ?*const Timezone = null;
const dto: Date_Time.With_Offset = .from_timestamp_s(ts, tz);
```

#### Decomposition/Conversion
```zig
const io: std.Io = ...
const dto: Date_Time.With_Offset = tempora.now_utc(io);

const ts: std.Io.Timestamp = dto.timestamp();
const ts_ms: i64 = dto.timestamp_ms();
const ts_s: i64 = dto.timestamp_s();
```

#### Conversion Between Timezones
```zig
const io: std.Io = ...
var dto: Date_Time.With_Offset = tempora.now_utc(io);

const other_tz: Timezone = .fixed(1, 0);
dto = dto.in_timezone(&other_tz);
```

#### Comparison
```zig
const dto1: Date_Time.With_Offset = .from_timestamp_s(0, null);
const dto2: Date_Time.With_Offset = .from_timestamp_s(1, null);
std.debug.assert(dto1.is_before(dto2));
std.debug.assert(!dto1.is_before(dto1));
std.debug.assert(dto2.is_after(dto1));
std.debug.assert(!dto2.is_after(dto2));

// These *do* provide accurate durations across leap second discontinuities in UTC:
const duration: std.Io.Duration = dto2.duration_since(dto1);
const ms: i32 = dto2.ms_since(dto1);

// These *do not* provide accurate durations across leap second discontinuities in UTC:
const duration: std.Io.Duration = dto2.duration_since_ignore_leap_seconds(dto1);
const ms: i32 = dto2.ms_since_ignore_leap_seconds(dto1);
```

#### Modification
```zig
var dto: Date_Time.With_Offset = .from_timestamp_s(0, null);

dto.dt.time = dto.dt.time.plus_hours(25);
dto = dto.canonical();

// This *does* account for leap second discontinuities in UTC:
const days: i32 = 10;
const ms: i32 = 1234;
dto = dto.plus_days_and_ms(days, ms);

// This *does* account for leap second discontinuities in UTC:
const duration: std.Io.Duration = .fromSeconds(60);
dto = dto.plus_duration(duration);
dto = dto.minus_duration(duration);

// This *does not* account for leap second discontinuities in UTC:
const days: i32 = 10;
const ms: i32 = 1234;
dto = dto.plus_days_and_ms_ignore_leap_seconds(days, ms);

// This *does not* account for leap second discontinuities in UTC:
const duration: std.Io.Duration = .fromSeconds(60);
dto = dto.plus_duration_ignore_leap_seconds(duration);
dto = dto.minus_duration_ignore_leap_seconds(duration);
```

#### Formatting
```zig
const dto: Date_Time.With_Offset = .from_timestamp_s(0, &Timezone.utc);

writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.iso8601) });           // 1970-01-01T00:00:00.000+00:00
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.iso8601_local) });     // 1970-01-01T00:00:00.000
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.rfc2822) });           // Thu, 01 Jan 1970 00:00:00 +0000
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.http) });              // Thu, 01 Jan 1970 00:00:00 GMT
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.sql_ms) });            // 1970-01-01 00:00:00.000 UTC
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.sql_ms_local) });      // 1970-01-01 00:00:00.000
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.sql) });               // 1970-01-01 00:00:00 UTC
writer.print("{f}", .{ dto.fmt(Date_Time.With_Offset.sql_local) });         // 1970-01-01 00:00:00
```

#### Parsing
```zig
var dto: Date_Time.With_Offset = undefined;

dto = try .from_string(Date.iso8601, "2025-10-01T12:12:12.000+00:00");
dto = try .from_string("YYYY", "2025"); // 2025-01-01T00:00:00.000+00:00

const tz: Timezone = Timezone.fixed(-1, 0);
dto = try .from_string_tz(Date.iso8601_local, "2025-10-01T12:12:12.000", &tz);

const tzdb: *const TZDB = ...
dto = try .from_string_tzdb("YYYY-MM-DD HH:mm:ss z", "2025-10-01 12:12:12 CDT", tzdb);
```

### `Time.With_Offset`
This struct is like `Date_Time.With_Offset` except without any `Date`.  It is mostly only useful for formatting and parsing strings that do not contain date information.  Otherwise you should prefer to work with `Date_Time.With_Offset` instead.

#### Conversion Between Timezones
```zig
const to: Time.With_Offset = (Time.midnight).with_offset(0);

const other_tz: Timezone = .fixed(1, 0);
to = to.in_timezone(&other_tz);
```

#### Decomposition/Conversion
```zig
const to: Time.With_Offset = (Time.midnight).with_offset(0);

const date: Date = .epoch;
const dto: Date_Time.With_Offset = to.with_date(date);
```

#### Formatting
```zig
const to: Time.With_Offset = (Time.midnight).with_offset(0);

writer.print("{f}", .{ cst.fmt(Time.With_Offset.iso8601) });        // 00:00:00.000-00:00
writer.print("{f}", .{ cst.fmt(Time.With_Offset.iso8601_local) });  // 00:00:00.000
writer.print("{f}", .{ cst.fmt(Time.With_Offset.rfc2822) });        // 00:00:00 +0000
writer.print("{f}", .{ ct.fmt("h:mm a") });                         // 00:00 am
```

#### Parsing
```zig
var parsed_time: Time.With_Offset = undefined;
parsed_time = try .from_string("h:mm a", "1:00 pm");
parsed_time = try .from_string_tz(Time.With_Offset.iso8601, "13:00:00.000-06:00", tz);
parsed_time = try .from_string_tzdb("05:05:05 CDT", tzdb);
```

### `Timezone`
A `Timezone` struct contains all the information required to convert between UTC and local wall clock times for a particular local time zone.

There are two built-in timezone constants, `Timezone.utc` and `Timezone.tai`.  Neither of these "timezones" include any DST rules or UTC offset information, however `Timezone.tai` includes leap-second adjustment information which is needed when trying to work with durations that are accurate to the second or better (see `Date_Time.With_Offset.duration_since`, `Date_Time.With_Offset.plus_duration`, etc.)


### `TZDB`
Most of the time it's convenient to use IANA-style timezone names (`Region/City_Name` or `Region/Sub_Region/City_Name`) to refer to timezones, but this means there needs to be something in your program that can map these strings to the actual `Timezone` data.  In tempora you do this by initializing a `TZDB` struct, typically when your program starts:
```zig
pub fn main(init: std.process.Init) !void {
    var tzdb: tempora.TZDB = .init(init);
    defer tzdb.deinit();
    try tzdb.add(init.io, tempora.tz.all, .system_or_embedded(init.environ_map));
    try tzdb.add_current(init.io, .system_link(init.environ_map));
    // your program here ...
}
```
This will load all of the timezones from the embedded IANA timezone database, but any timezones it can find on the system will be preferred, on the assumption that they're likely to be newer.

If you want to avoid bloating your executable, you can force all timezones to be loaded from the system:
```zig
pub fn main(init: std.process.Init) !void {
    var tzdb: tempora.TZDB = .init(init);
    defer tzdb.deinit();
    try tzdb.add(init.io, tempora.tz.all, .system(init.environ_map));
    try tzdb.add_current(init.io, .system(init.environ_map));
    // your program here ...
}
```

Alternatively, you can include just a portion of the IANA database:
```zig
const tz = tempora.tz;
try tzdb.add(init.io, .{ tz.america, tz.europe, tz.pacific.honolulu }, .system_or_embedded(init.environ_map));
```

You can also force tempora to use *only* the embedded IANA database:
```zig
try tzdb.add(init.io, tempora.tz.all, .embedded);
```

Normally each TZif blob in the embedded IANA database is compressed with zlib, but you can embed it uncompressed instead by using the `tempora.tz.uncompressed` namespace instead of `tempora.tz.all`.
Similarly, if you want to exclude all the timezone IDs which are simply aliases to other zones, you can use `tempora.tz.canonical` or `tempora.tz.canonical_uncompressed`.  This won't significantly affect binary size, but may reduce startup time slightly.

Some programs may want to avoid loading the timezone database at startup entirely (e.g. CLI tools, where even minor startup delays can be highly noticeable).  In this case, `TZDB` can be instructed to only load/parse the timezone data lazily, the first time it is accessed:
```zig
try tzdb.add_lazy(tempora.tz.all, &.system_or_embedded(init.environ_map));
```
Note that for `add_lazy`, you must pass a pointer to the the add options, and it must remain valid for the lifetime of the `TZDB`.

You may also want to support lazily loading TZif files from the filesystem that were never specified by `add` or `add_lazy`, to allow usage of new zones that didn't exist when the program was built:
```zig
tzdb.default_lazy_options = &.system_or_embedded(init.environ_map);
```
Note however, that both of the two above examples have a downside: the `TZDB` can no longer be used concurrently from multiple threads unless external synchronization is provided, or each thread/task has its own separate `TZDB`.

#### Timezone offset designations
If you want to be able to parse date/time strings that contain colloquial timezone offset designators like PST/PDT, you'll need to initialize these in the `TZDB`:
```zig
try tzdb.add_designations(tempora.tz.designations.common);
```
In addition to the `common` namespace, there are a variety of other collections:
   * `nato` (military-style single-letter designations)
   * `north_america`
   * `cuba`
   * `europe`
   * `africa`
   * `middle_east`
   * `asia`
   * `oceania` (Australia, NZ, and Pacific Islands)

You can add several of these collections, however there are a few designations that have different meanings in different regions, like "IST".  The `common` namespace includes almost everything except those ambiguous designations, and the `nato` collection.
You can also add custom designations if you like, but you'll have to specify the UTC offset (in seconds) manually.

When parsing, make sure you use `.from_string_tzdb()` instead of `.from_string()` so that the parser can find your designations.


### `Year`
TODO: Document me!
```zig
```

### `Month`
TODO: Document me!
```zig
```

### `Day` of month
TODO: Document me!
```zig
```

### `Week_Day`
TODO: Document me!
```zig
```

### `Ordinal_Day` of year
TODO: Document me!
```zig
```

### `Ordinal_Week` of year
TODO: Document me!
```zig
```

### `ISO_Week`
TODO: Document me!
```zig
```

### `ISO_Week_Date`
TODO: Document me!
```zig
```

## The `dump` tool
A small demo/tool is provided that prints out the current time in one or more timezones and the last/next time a DST change will happen for that zone:
```
$ zig build dump -- America/Chicago Africa/Maputo
Current Time: 2026-06-02 21:03:49 CDT  offset=-18000s  dst=dst  source=posix_tz
    DST began: 2026-03-08 03:00:00 CDT
    DST ends:  2026-11-01 01:00:00 CST
Current Time: 2026-06-02 28:03:49 CAT  offset=7200s  dst=std  source=posix_tz
    This timezone has permanent standard time
    The current time rules for this zone began on 1908-12-31 23:49:42 CAT
```
You can pass the `--debug` command line option to additionally print out all the internal timezone data in a format similar to TZif, but human-readable.

By default, `dump` will only use it's internal IANA timezone database, but if you use the `--system` command line option it will instead look for a system-provided timezone.

## Comparison with other Zig date/time libraries

|                                 | tempora                                                     | [Zeit](https://github.com/rockorager/zeit)                     | [zdt](https://codeberg.org/FObersteiner/zdt)                                  | [zig-datetime](https://github.com/frmdstryr/zig-datetime) |
| ------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------- |
| Supported zig versions          | 0.15.1 - 0.17.0-dev                                         | 0.13.0 - 0.17.0-dev                                            | 0.15.1 - 0.17.0-dev                                                           | 0.14.0 - 0.15.2                                           |
| Time Resolution                 | 1 millisecond                                               | 1 nanosecond                                                   | 1 nanosecond                                                                  | 1 nanosecond                                              |
| Minimum representable date      | 22 June 5,877,612 BC                                        | 1 January 2,147,483,649 BC                                     | 1 January 1 BC                                                                | 1 January 0001                                            |
| Maximum representable date      | 11 July 5,881,610                                           | 31 December 2,147,483,647                                      | 31 December 9999                                                              | 31 December 9999                                          |
| Gregorian Calendar algorithm    | Joffe                                                       | Joffe                                                          | Hinnant/Neri-Schneider                                                        | unknown                                                   |
| Packed date/time epoch          | 1 January 2000                                              | 1 January 1970                                                 | 1 January 1970                                                                | 1 January 0001                                            |
| Packed date                     | `Date`                                                      | -                                                              | -                                                                             | `u32` (`Date.fromOrdinal()`, `Date.toOrdinal()`)          |
| Decomposed date                 | `Date.YMD`, `Date.Info`                                     | `Date`                                                         | -                                                                             | `datetime.Date`                                           |
| Packed datetime                 | `Date_Time`                                                 | `Nanoseconds` (`i128`)                                         | `i128`                                                                        | `i128`                                                    |
| Decomposed datetime             | -                                                           | -                                                              | -                                                                             | -                                                         |
| Packed datetime (localized)     | `Date_Time.With_Offset`                                     | `Instant`                                                      | -                                                                             | -                                                         |
| Decomposed datetime (localized) | -                                                           | `Time`                                                         | `Datetime`                                                                    | `datetime.Datetime`                                       |
| Packed time                     | `Time`                                                      | -                                                              | -                                                                             | -                                                         |
| Decomposed time                 | -                                                           | -                                                              | -                                                                             | `datetime.Time`                                           |
| Packed time (localized)         | `Time.With_Offset`                                          | -                                                              | -                                                                             | -                                                         |
| Decomposed time (localized)     | -                                                           | -                                                              | -                                                                             | -                                                         |
| Packed duration                 | `std.Io.Duration`                                           | -                                                              | `Duration`                                                                    | -                                                         |
| Decomposed duration             | -                                                           | `Duration`                                                     | `RelativeDelta`                                                               | `datetime.Datetime.Delta`                                 |
| Year                            | `Year`, `Year.Info`                                         | `i32`                                                          | `i16`                                                                         | `u16`                                                     |
| Month                           | `Month`                                                     | `Month`                                                        | `Datetime.Month`                                                              | `datetime.Month`                                          |
| Day of month                    | `Day`                                                       | `u5`                                                           | `u8`                                                                          | `u8`                                                      |
| Day of week                     | `Week_Day`                                                  | `Weekday`                                                      | `Datetime.Weekday`                                                            | `datetime.Weekday`                                        |
| Day of year                     | `Ordinal_Day`                                               | -                                                              | `u16` (`Datetime.dayOfYear()`)                                                | `u8`                                                      |
| Week of year                    | `Ordinal_Week`                                              | -                                                              | -                                                                             | -                                                         |
| ISO week date                   | `ISO_Week`, `ISO_Week_Date`                                 | -                                                              | `Datetime.ISOCalendar`                                                        | `datetime.ISOCalendar`                                    |
| Month/Week name localization    | English only                                                | English only                                                   | English or current locale (Linux, MacOS, Windows)                             | English only                                              |
| Parsed input formats            | moment.js/`SimpleDateFormat` style                          | ISO8601, RFC3339, RFC5322, RFC2822, RFC1123                    | `strptime` style                                                              | ISO8601, RFC1123                                          |
| Formatted output formats        | moment.js/`SimpleDateFormat` style                          | `strftime` style, `gofmt` style                                | `strftime` style                                                              | ISO8601, RFC1123                                          |
| Current date/time               | `now_utc(io)`, `now_local(io, tzdb)`, `now(io, tz)`         | `instant(io, .{...})`                                          | `Datetime.nowUTC(io)`, `Datetime.nowTAI(io)`, `Datetime.now(io, .{...})`      | `datetime.Datetime.now()`                                 |
| Timezone                        | `Timezone`                                                  | `TimeZone`                                                     | `Timezone`                                                                    | `datetime.Timezone`                                       |
| Timezone Database               | `TZDB`                                                      | -                                                              | internal                                                                      | `timezones`                                               |
| Current timezone                | `TZDB.local` (Posix via fs, Windows via registry/ntdll.dll) | `local(alloc, io, env)` (Posix via fs, Windows via advapi.dll) | `Timezone.tzLocal(io, alloc)` (Posix via fs, Windows via registry/advapi.dll) | -                                                         |
| Embedded IANA tzdb?             | yes (configurable)                                          | no                                                             | yes                                                                           | partial (no TZif support)                                 |
| Filesystem tzdb?                | yes                                                         | yes                                                            | yes                                                                           | no                                                        |
| Windows tzdb?                   | yes (via registry/ntdll.dll)                                | yes (via advapi.dll)                                           | no                                                                            | no                                                        |
| Leap second database?           | `Timezone.data.leap_seconds`                                | no                                                             | internal                                                                      | no                                                        |

Other zig date/time libraries include:
* [zig-time](https://github.com/nektro/zig-time) - requires `zigmod`
* [datetime](https://github.com/clickingbuttons/datetime)
* [tempus](https://github.com/jnordwick/tempus)
* [chrono-zig](https://codeberg.org/geemili/chrono-zig)

None of these other libraries support zig 0.15.x or newer, so they are excluded from the above comparison.