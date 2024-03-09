# Tempora
### Simple Zig Dates/Times/Timezones

Tempora stores dates with a non-exhaustive enum backed by a 32-bit signed integer, which represents the number of days since January 1, 2000.
It provides functions to compute year/month/day, ordinal day, ordinal week, and day-of-week, and to format and parse date strings.

Times are stored as a non-exhaustive enum backed by a 32-bit signed integer, which represents the number of milliseconds since midnight (of an unspecified day).
Functions are provided to access hours/minutes/seconds and format/parse strings.

Combining a Date and Time uses 64 bits of storage, and provides approximately the same range as a 64-bit millisecond resolution unix timestamp (millions of years).

Tempora supports timezone computations and embeds a copy of the [TZif-encoded](https://github.com/leroycep/zig-tzif) IANA timezone data that can be found on most unix systems.
A tool is provided to automatically crawl the zoneinfo files on such a system to update the bundled data.
This data typically adds ~200kiB to the size of executables that use timezones.
On Windows hosts, Tempora will attempt to map the current timezone to an appropriate entry from the IANA database.

Timezones are not stored in `Date_Time`/`Date`/`Time` structs.  It's up to the programmer to decide whether these values represent local time or UTC.
When initializing a `Date_Time` from a unix timestamp, a timezone can be specified, which will automatically apply the appropriate offset to create a local `Date_Time`.
When converting a local `Date_Time` back to a unix timestamp, the local timezone must be provided to undo the offset.  Note that timezones with an annual DST cycle pose a problem here,
e.g. 2023-11-05 01:30 central time could refer to either 2023-11-05 06:30 +00:00 or 2023-11-05 07:30 +00:00, so converting local times back to UTC is best avoided if possible.

When formatting `Date_Time` or `Time` values, a timezone may be provided by using the `fmt_utc` or `fmt_local` functions.  The former assumes that the date/time is in UTC, and applies
the timezone offset before formatting.  The latter assumes that the timezone offset has already been applied, and only provides the timezone in case the format includes the offset or time designation (CST, CDT, etc.)
When parsing `Date_Time` or `Time` values from strings, if the format includes an offset, it will always be subtracted from the raw parsed time, but will be provided along with the result in a `Date_Time_With_Offset` or `Time_With_Offset` struct.

## Limitations
* It's not possible to store most "out of bounds" dates/times (e.g. Jan 32).
* Localized month and weekday names are not supported; only English.
* Non-Gregorian calendars are not supported.
* Date/time values directly correspond to timestamps, so accurate durations that take leap seconds into account are not possible (but leap seconds are being abolished in 2035 anyway).
* I am certain that there are more optimized algorithms for timestamp <--> calendar conversions (but performance should be fine for all but the most demanding use cases).
