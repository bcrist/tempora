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

Timezones are not stored in `Date_Time`/`Date`/`Time` structs; these can represent either local or UTC times/dates.
`Date_Time.With_Offset` and `Time.With_Offset` augment these structs with a timezone and/or UTC offset.  The `with_offset` and `with_timezone` functions will produce these, as will `from_string`.
Formatting `Date_Time` and `Time` structs, and is only possible using the full `With_Offset` version.
Converting to/from unix timestamps is only possible with `Date_Time.With_Offset`.
The timezone can be changed (without changing the instant in time being represented) using `With_Offset.in_timezone`.

## Limitations
* It's not possible to store most "out of bounds" dates/times (e.g. Jan 32).
* Localized month and weekday names are not supported; only English.
* Non-Gregorian calendars are not supported.
* Date/time values directly correspond to timestamps, so accurate durations that take leap seconds into account are not possible (but leap seconds are being abolished in 2035 anyway).
* I am certain that there are more optimized algorithms for timestamp <--> calendar conversions (but performance should be fine for all but the most demanding use cases).
