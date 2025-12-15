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
