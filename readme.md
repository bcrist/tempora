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

## API Documentation/Examples

### `Date`
Dates are represented as a signed 32b number of days since 1 January 2000.  This type of representation is sometimes referred to as "rata die" (although that name usually connotes a different epoch date) and it makes it impossible to represent invalid dates like January 32 or November 31.

Using this packed representation makes composition and decomposition slower, but greatly simplifies most other operations on dates, like modification and comparison.

### `Date.YMD`
This struct represents a decomposed date, consisting of a year, month, and day of the month.  In some cases it may be more convenient or efficient to use this over `Date`, but some operations are not defined for this struct (e.g. day-of-week extraction).

```zig
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
```zig
```

### `Time`
The `Time` enum represents a millisecond-resolution offset from midnight (the start of an arbitrary day).  It is backed by `i32` which provides a range of around +/- 24 days, but canonical `Time` values (especially when combined with a `Date`) should be between 0 and 85_399_999.

A `Time` value may represent a time under the [UTC](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) or [TAI](https://en.wikipedia.org/wiki/International_Atomic_Time) standards, a fixed offset from UTC, or a wall-clock time in a specific local timezone.  If this information cannot be inferred from context, you should use `Time.With_Offset` instead.

#### Construction
```zig
var time: tempora.Time = @enumFromInt(1234); // milliseconds since midnight
time = .from_hmsm(hours, minutes, seconds, milliseconds);
```

#### Hourly convenience decls
```zig
const start_of_day: tempora.Time = .midnight;
const wakeup: tempora.Time = .@"7am";
const lunch: tempora.Time = .noon;
const bedtime: tempora.Time = .@"10pm";
const end_of_day: tempora.Time = .midnight_eod;
```

#### Decomposition
```zig
const whole_hours_since_midnight = time.hours();
const whole_minutes_since_hour = time.minutes();
const whole_seconds_since_minute = time.seconds();
const milliseconds_since_second = time.ms();
const whole_minutes_since_midnight = time.minutes_since_midnight();
const whole_seconds_since_midnight = time.seconds_since_midnight();
const milliseconds_since_midnight = time.ms_since_midnight();
```

#### Comparison
```zig
// assuming times from the same date:
if (time.is_after(.noon)) work_hard();
if (time.is_before(bedtime)) goof_off();
```

#### Modification
```zig
time = time.plus_ms(milliseconds);
time = time.plus_seconds(seconds);
time = time.plus_minutes(minutes);
time = time.plus_hours(hours);
time = time.plus_duration(std.Io.Duration.fromNanoseconds(1_0000_0000_0000));
time = time.minus_duration(std.Io.Duration.fromNanoseconds(1_0000_0000_0000));
```

#### Conversion to other types
```zig
const dt: tempora.Date_Time = time.with_date(date);
const to1: tempora.Time.With_Offset = time.with_offset(utc_offset_ms);
const to2: tempora.Time.With_Offset = time.with_timezone(tz, utc_offset_ms);
```

### `Date_Time`
```zig
```


#### Current date/time
```zig

```

### `Date_Time.With_Offset`
This struct combines a `Date_Time` with a UTC offset, allowing for conversions to/from unix timestamps.  Optionally, it can also include a pointer to a `Timezone`, which can be helpful when formatting, parsing, and modifying the instant.
```zig
```

### `Time.With_Offset`
This struct is like `Date_Time.With_Offset` except without any `Date`.  It is mostly only useful for formatting and parsing strings that do not contain date information.  Otherwise you should prefer to work with `Date_Time.With_Offset` instead.

#### Construction
```zig
const time: tempora.Time = .from_hmsm(23, 59, 59, 999);

const cst_time = time.with_offset(-6 * std.time.ms_per_hour);

const tz = tzdb.timezone(tempora.tz.america.chicago.id);
const ct_time = time.with_timezone(tz, -6 * std.time.ms_per_hour);
```

#### Formatting
```zig
// 23:59:59.999-06:00";
writer.print("{f}", .{ cst.fmt(tempora.Time.With_Offset.iso8601) });

// 23:59:59.999";
writer.print("{f}", .{ cst.fmt(tempora.Time.With_Offset.iso8601_local) });

// 23:59:59 -0600
writer.print("{f}", .{ cst.fmt(tempora.Time.With_Offset.rfc2822) });

// Note the offset designation printed here is based on the timezone's designation on 2000-01-01,
// which happens to match the offset we're using here, but generally you should prefer to use
// Date_Time.With_Offset when using the `z` or `zz` format specifiers.
// 23:59:59 CST
writer.print("{f}", .{ ct.fmt("HH:mm:ss z") });

// 11:59 pm
writer.print("{f}", .{ ct.fmt("h:mm a") });
```

#### Parsing
```zig
var parsed_time: tempora.Time.With_Offset = try .from_string("h:mm a", "1:00 pm");
parsed_time = try .from_string_tz(tempora.Time.With_Offset.iso8601, "13:00:00.000-06:00", tz);
parsed_time = try .from_string_tzdb("05:05:05 CDT", tzdb);
```

#### Conversion to another timezone
```zig
// With a known wall time in Central Time, what is the equivalent wall time in Eastern Time?
const est_time = cst_time.in_timezone(null, -5 * std.time.ms_per_hour);
```

#### Conversion to other types
```zig
const dto: tempora.Date_Time.With_Offset = est_time.with_date(date);
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
```zig
```

### `Month`
```zig
```

### `Day` of month
```zig
```

### `Week_Day`
```zig
```

### `Ordinal_Day` of year
```zig
```

### `Ordinal_Week` of year
```zig
```

### `ISO_Week`
```zig
```

### `ISO_Week_Date`
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