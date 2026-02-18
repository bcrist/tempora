# Tempora
### Simple Zig Dates/Times/Timezones

## Features
* Efficient storage (32b `Time`, 32b `Date`, 64b `Date_Time`)
* Composition and decomposition (year, ordinal day/week, month, day, weekday, hour, minute, second, ms)
    * Uses Ben Joffe's [fast calendar algorithm](https://www.benjoffe.com/fast-date-64)
* Add/subtract days/hours/minutes/seconds/ms
* Advance to the next weekday/day/ordinal day
* Convert to/from unix timestamps
* Embedded IANA timezone database and modified version of [zig-tzif](https://github.com/leroycep/zig-tzif) (adds about 200k to binary size when used)
* Query current timezone on both unix and Windows systems
* Moment.js style formatting and parsing (through `std.fmt`)

## Limitations
* It's not possible to store most "out of bounds" dates/times (e.g. Jan 32).
* Localized month and weekday names are not supported; only English.
* Non-Gregorian calendars are not supported.
* Date/time values directly correspond to timestamps, so accurate durations that take leap seconds into account are not possible (but leap seconds are being abolished in 2035 anyway).

## Comparison with Zeit
[Zeit](https://github.com/rockorager/zeit) is another Zig date/time library which provides a similar feature set to Tempora, but there are very few exact equivalents between the tempora and zeit APIs.
* `tempora.Time` does not have an equivalent in Zeit
* `tempora.Date` is roughly equivalent to `zeit.Days`, but the latter is a simple alias for `i32` and thus is not type safe or ergonomic for doing anything other than converting into a `zeit.Instant` or `zeit.Date`.  Note tempora also uses a different epoch date.
* `tempora.Year`: Zeit just uses `i32`
* `tempora.Year.Info` does not have an equivalent in Zeit
* `tempora.Month` <=> `zeit.Month`
* `tempora.Week_Day` <=> `zeit.Weekday`
* `tempora.Ordinal_Day` and `tempora.Ordinal_Week` do not have an equivalent in Zeit
* `tempora.Date.YMD` <=> `zeit.Date`
* `zeit.Time` and `zeit.Instant` do not have exact equivalents in Tempora, but similar functionality can be achieved with `tempora.Date_Time.With_Offset`, `tempora.Date.YMD`, `tempora.Date.Info`, etc.
* `zeit.Duration` does not have an equivalent in Tempora.  The closest you can get is converting to timestamps, subtracting, and then constructing a `Time` from the result.
* Tempora's formatting functionality works out-of-the-box with `std.Io.Writer`, while Zeit only has a custom `bufPrint`.
* Tempora's string parsing is more generic and uses the same format strings as for output.  Zeit cannot parse arbitrary string formats, only specific RFC-defined formats.
* Zeit provides a function which closely mirror's C's `strftime` while tempora does not. 
* Zeit assumes the filesystem will contain a zoneinfo database containing all the standard IANA timezone names (except on windows).  Tempora embeds a database directly in the app, allowing timezone operations to work on freestanding targets.
* There are a lot of API differences that just boil down to personal preference:
    * `zeit.instant(.{ ... })` covers a lot of ground that tempora uses many different functions for, e.g. `Date_Time.With_Offset.from_timestamp_ms()`, `Date_Time.With_Offset.from_string()` and `tempora.now()`
    * Zeit uses free functions for a bunch of things that are methods in tempora.
        * `zeit.daysFromCivil()` <=> `tempora.Date.from_ymd()`
        * `zeit.civilFromDays()` <=> `tempora.Date.ymd()`
        * `zeit.weekdayFromDays()` <=> `tempora.Date.week_day()`
        * `zeit.isLeapYear()` <=> `tempora.Year.is_leap()`, `tempora.Year.Info.is_leap`
