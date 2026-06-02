//! This file is generated based on information from the Unicode Common Locale Data Repository:
//! https://github.com/unicode-org/cldr/blob/main/common/supplemental/windowsZones.xml

pub const registry_version = "7e11800";

pub fn windows_registry_key_to_iana(key: []const u8, region: []const u8) ?[]const u8 {
    if (key.len == 0) return null;
    switch (key[0] | 0x20) {
        'a' => {
            if (std.mem.eql(u8, key, "Aleutian Standard Time")) {
                return "America/Adak";
            }
            if (std.mem.eql(u8, key, "Alaskan Standard Time")) {
                return "America/Anchorage";
            }
            if (std.mem.eql(u8, key, "Atlantic Standard Time")) {
                if (std.mem.eql(u8, region, "BM")) return "Atlantic/Bermuda";
                if (std.mem.eql(u8, region, "GL")) return "America/Thule";
                return "America/Halifax";
            }
            if (std.mem.eql(u8, key, "Argentina Standard Time")) {
                return "America/Buenos_Aires";
            }
            if (std.mem.eql(u8, key, "Azores Standard Time")) {
                if (std.mem.eql(u8, region, "GL")) return "America/Scoresbysund";
                return "Atlantic/Azores";
            }
            if (std.mem.eql(u8, key, "Arabic Standard Time")) {
                return "Asia/Baghdad";
            }
            if (std.mem.eql(u8, key, "Arab Standard Time")) {
                if (std.mem.eql(u8, region, "BH")) return "Asia/Bahrain";
                if (std.mem.eql(u8, region, "KW")) return "Asia/Kuwait";
                if (std.mem.eql(u8, region, "QA")) return "Asia/Qatar";
                if (std.mem.eql(u8, region, "YE")) return "Asia/Aden";
                return "Asia/Riyadh";
            }
            if (std.mem.eql(u8, key, "Arabian Standard Time")) {
                if (std.mem.eql(u8, region, "OM")) return "Asia/Muscat";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-4";
                return "Asia/Dubai";
            }
            if (std.mem.eql(u8, key, "Astrakhan Standard Time")) {
                return "Europe/Astrakhan";
            }
            if (std.mem.eql(u8, key, "Azerbaijan Standard Time")) {
                return "Asia/Baku";
            }
            if (std.mem.eql(u8, key, "Afghanistan Standard Time")) {
                return "Asia/Kabul";
            }
            if (std.mem.eql(u8, key, "Altai Standard Time")) {
                return "Asia/Barnaul";
            }
            if (std.mem.eql(u8, key, "Aus Central W. Standard Time")) {
                return "Australia/Eucla";
            }
            if (std.mem.eql(u8, key, "AUS Central Standard Time")) {
                return "Australia/Darwin";
            }
            if (std.mem.eql(u8, key, "AUS Eastern Standard Time")) {
                return "Australia/Sydney";
            }
        },
        'b' => {
            if (std.mem.eql(u8, key, "Bahia Standard Time")) {
                return "America/Bahia";
            }
            if (std.mem.eql(u8, key, "Belarus Standard Time")) {
                return "Europe/Minsk";
            }
            if (std.mem.eql(u8, key, "Bangladesh Standard Time")) {
                if (std.mem.eql(u8, region, "BT")) return "Asia/Thimphu";
                return "Asia/Dhaka";
            }
            if (std.mem.eql(u8, key, "Bougainville Standard Time")) {
                return "Pacific/Bougainville";
            }
        },
        'c' => {
            if (std.mem.eql(u8, key, "Central America Standard Time")) {
                if (std.mem.eql(u8, region, "BZ")) return "America/Belize";
                if (std.mem.eql(u8, region, "CR")) return "America/Costa_Rica";
                if (std.mem.eql(u8, region, "EC")) return "Pacific/Galapagos";
                if (std.mem.eql(u8, region, "HN")) return "America/Tegucigalpa";
                if (std.mem.eql(u8, region, "NI")) return "America/Managua";
                if (std.mem.eql(u8, region, "SV")) return "America/El_Salvador";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+6";
                return "America/Guatemala";
            }
            if (std.mem.eql(u8, key, "Central Standard Time")) {
                if (std.mem.eql(u8, region, "CA")) return "America/Winnipeg";
                if (std.mem.eql(u8, region, "MX")) return "America/Matamoros";
                return "America/Chicago";
            }
            if (std.mem.eql(u8, key, "Central Standard Time (Mexico)")) {
                return "America/Mexico_City";
            }
            if (std.mem.eql(u8, key, "Canada Central Standard Time")) {
                return "America/Regina";
            }
            if (std.mem.eql(u8, key, "Cuba Standard Time")) {
                return "America/Havana";
            }
            if (std.mem.eql(u8, key, "Central Brazilian Standard Time")) {
                return "America/Cuiaba";
            }
            if (std.mem.eql(u8, key, "Cape Verde Standard Time")) {
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+1";
                return "Atlantic/Cape_Verde";
            }
            if (std.mem.eql(u8, key, "Central Europe Standard Time")) {
                if (std.mem.eql(u8, region, "AL")) return "Europe/Tirane";
                if (std.mem.eql(u8, region, "CZ")) return "Europe/Prague";
                if (std.mem.eql(u8, region, "ME")) return "Europe/Podgorica";
                if (std.mem.eql(u8, region, "RS")) return "Europe/Belgrade";
                if (std.mem.eql(u8, region, "SI")) return "Europe/Ljubljana";
                if (std.mem.eql(u8, region, "SK")) return "Europe/Bratislava";
                return "Europe/Budapest";
            }
            if (std.mem.eql(u8, key, "Central European Standard Time")) {
                if (std.mem.eql(u8, region, "BA")) return "Europe/Sarajevo";
                if (std.mem.eql(u8, region, "HR")) return "Europe/Zagreb";
                if (std.mem.eql(u8, region, "MK")) return "Europe/Skopje";
                return "Europe/Warsaw";
            }
            if (std.mem.eql(u8, key, "Caucasus Standard Time")) {
                return "Asia/Yerevan";
            }
            if (std.mem.eql(u8, key, "Central Asia Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/Vostok";
                if (std.mem.eql(u8, region, "CN")) return "Asia/Urumqi";
                if (std.mem.eql(u8, region, "IO")) return "Indian/Chagos";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-6";
                return "Asia/Bishkek";
            }
            if (std.mem.eql(u8, key, "China Standard Time")) {
                if (std.mem.eql(u8, region, "HK")) return "Asia/Hong_Kong";
                if (std.mem.eql(u8, region, "MO")) return "Asia/Macau";
                return "Asia/Shanghai";
            }
            if (std.mem.eql(u8, key, "Cen. Australia Standard Time")) {
                return "Australia/Adelaide";
            }
            if (std.mem.eql(u8, key, "Central Pacific Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/Casey";
                if (std.mem.eql(u8, region, "FM")) return "Pacific/Ponape";
                if (std.mem.eql(u8, region, "NC")) return "Pacific/Noumea";
                if (std.mem.eql(u8, region, "VU")) return "Pacific/Efate";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-11";
                return "Pacific/Guadalcanal";
            }
            if (std.mem.eql(u8, key, "Chatham Islands Standard Time")) {
                return "Pacific/Chatham";
            }
        },
        'd' => {
            if (std.mem.eql(u8, key, "Dateline Standard Time")) {
                return "Etc/GMT+12";
            }
        },
        'e' => {
            if (std.mem.eql(u8, key, "Easter Island Standard Time")) {
                return "Pacific/Easter";
            }
            if (std.mem.eql(u8, key, "Eastern Standard Time (Mexico)")) {
                return "America/Cancun";
            }
            if (std.mem.eql(u8, key, "Eastern Standard Time")) {
                if (std.mem.eql(u8, region, "BS")) return "America/Nassau";
                if (std.mem.eql(u8, region, "CA")) return "America/Toronto";
                return "America/New_York";
            }
            if (std.mem.eql(u8, key, "E. South America Standard Time")) {
                return "America/Sao_Paulo";
            }
            if (std.mem.eql(u8, key, "Egypt Standard Time")) {
                return "Africa/Cairo";
            }
            if (std.mem.eql(u8, key, "E. Europe Standard Time")) {
                return "Europe/Chisinau";
            }
            if (std.mem.eql(u8, key, "E. Africa Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/Syowa";
                if (std.mem.eql(u8, region, "DJ")) return "Africa/Djibouti";
                if (std.mem.eql(u8, region, "ER")) return "Africa/Asmera";
                if (std.mem.eql(u8, region, "ET")) return "Africa/Addis_Ababa";
                if (std.mem.eql(u8, region, "KM")) return "Indian/Comoro";
                if (std.mem.eql(u8, region, "MG")) return "Indian/Antananarivo";
                if (std.mem.eql(u8, region, "SO")) return "Africa/Mogadishu";
                if (std.mem.eql(u8, region, "TZ")) return "Africa/Dar_es_Salaam";
                if (std.mem.eql(u8, region, "UG")) return "Africa/Kampala";
                if (std.mem.eql(u8, region, "YT")) return "Indian/Mayotte";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-3";
                return "Africa/Nairobi";
            }
            if (std.mem.eql(u8, key, "Ekaterinburg Standard Time")) {
                return "Asia/Yekaterinburg";
            }
            if (std.mem.eql(u8, key, "E. Australia Standard Time")) {
                return "Australia/Brisbane";
            }
        },
        'f' => {
            if (std.mem.eql(u8, key, "FLE Standard Time")) {
                if (std.mem.eql(u8, region, "AX")) return "Europe/Mariehamn";
                if (std.mem.eql(u8, region, "BG")) return "Europe/Sofia";
                if (std.mem.eql(u8, region, "EE")) return "Europe/Tallinn";
                if (std.mem.eql(u8, region, "FI")) return "Europe/Helsinki";
                if (std.mem.eql(u8, region, "LT")) return "Europe/Vilnius";
                if (std.mem.eql(u8, region, "LV")) return "Europe/Riga";
                return "Europe/Kiev";
            }
            if (std.mem.eql(u8, key, "Fiji Standard Time")) {
                return "Pacific/Fiji";
            }
        },
        'g' => {
            if (std.mem.eql(u8, key, "Greenland Standard Time")) {
                return "America/Godthab";
            }
            if (std.mem.eql(u8, key, "GMT Standard Time")) {
                if (std.mem.eql(u8, region, "ES")) return "Atlantic/Canary";
                if (std.mem.eql(u8, region, "FO")) return "Atlantic/Faeroe";
                if (std.mem.eql(u8, region, "GG")) return "Europe/Guernsey";
                if (std.mem.eql(u8, region, "IE")) return "Europe/Dublin";
                if (std.mem.eql(u8, region, "IM")) return "Europe/Isle_of_Man";
                if (std.mem.eql(u8, region, "JE")) return "Europe/Jersey";
                if (std.mem.eql(u8, region, "PT")) return "Europe/Lisbon";
                return "Europe/London";
            }
            if (std.mem.eql(u8, key, "Greenwich Standard Time")) {
                if (std.mem.eql(u8, region, "BF")) return "Africa/Ouagadougou";
                if (std.mem.eql(u8, region, "CI")) return "Africa/Abidjan";
                if (std.mem.eql(u8, region, "GH")) return "Africa/Accra";
                if (std.mem.eql(u8, region, "GL")) return "America/Danmarkshavn";
                if (std.mem.eql(u8, region, "GM")) return "Africa/Banjul";
                if (std.mem.eql(u8, region, "GN")) return "Africa/Conakry";
                if (std.mem.eql(u8, region, "GW")) return "Africa/Bissau";
                if (std.mem.eql(u8, region, "LR")) return "Africa/Monrovia";
                if (std.mem.eql(u8, region, "ML")) return "Africa/Bamako";
                if (std.mem.eql(u8, region, "MR")) return "Africa/Nouakchott";
                if (std.mem.eql(u8, region, "SH")) return "Atlantic/St_Helena";
                if (std.mem.eql(u8, region, "SL")) return "Africa/Freetown";
                if (std.mem.eql(u8, region, "SN")) return "Africa/Dakar";
                if (std.mem.eql(u8, region, "TG")) return "Africa/Lome";
                return "Atlantic/Reykjavik";
            }
            if (std.mem.eql(u8, key, "GTB Standard Time")) {
                if (std.mem.eql(u8, region, "CY")) return "Asia/Nicosia";
                if (std.mem.eql(u8, region, "GR")) return "Europe/Athens";
                return "Europe/Bucharest";
            }
            if (std.mem.eql(u8, key, "Georgian Standard Time")) {
                return "Asia/Tbilisi";
            }
        },
        'h' => {
            if (std.mem.eql(u8, key, "Hawaiian Standard Time")) {
                if (std.mem.eql(u8, region, "CK")) return "Pacific/Rarotonga";
                if (std.mem.eql(u8, region, "PF")) return "Pacific/Tahiti";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+10";
                return "Pacific/Honolulu";
            }
            if (std.mem.eql(u8, key, "Haiti Standard Time")) {
                return "America/Port-au-Prince";
            }
        },
        'i' => {
            if (std.mem.eql(u8, key, "Israel Standard Time")) {
                return "Asia/Jerusalem";
            }
            if (std.mem.eql(u8, key, "Iran Standard Time")) {
                return "Asia/Tehran";
            }
            if (std.mem.eql(u8, key, "India Standard Time")) {
                return "Asia/Calcutta";
            }
        },
        'j' => {
            if (std.mem.eql(u8, key, "Jordan Standard Time")) {
                return "Asia/Amman";
            }
        },
        'k' => {
            if (std.mem.eql(u8, key, "Kaliningrad Standard Time")) {
                return "Europe/Kaliningrad";
            }
            if (std.mem.eql(u8, key, "Korea Standard Time")) {
                return "Asia/Seoul";
            }
        },
        'l' => {
            if (std.mem.eql(u8, key, "Libya Standard Time")) {
                return "Africa/Tripoli";
            }
            if (std.mem.eql(u8, key, "Lord Howe Standard Time")) {
                return "Australia/Lord_Howe";
            }
            if (std.mem.eql(u8, key, "Line Islands Standard Time")) {
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-14";
                return "Pacific/Kiritimati";
            }
        },
        'm' => {
            if (std.mem.eql(u8, key, "Marquesas Standard Time")) {
                return "Pacific/Marquesas";
            }
            if (std.mem.eql(u8, key, "Mountain Standard Time (Mexico)")) {
                return "America/Mazatlan";
            }
            if (std.mem.eql(u8, key, "Mountain Standard Time")) {
                if (std.mem.eql(u8, region, "CA")) return "America/Edmonton";
                if (std.mem.eql(u8, region, "MX")) return "America/Ciudad_Juarez";
                return "America/Denver";
            }
            if (std.mem.eql(u8, key, "Montevideo Standard Time")) {
                return "America/Montevideo";
            }
            if (std.mem.eql(u8, key, "Magallanes Standard Time")) {
                return "America/Punta_Arenas";
            }
            if (std.mem.eql(u8, key, "Morocco Standard Time")) {
                if (std.mem.eql(u8, region, "EH")) return "Africa/El_Aaiun";
                return "Africa/Casablanca";
            }
            if (std.mem.eql(u8, key, "Middle East Standard Time")) {
                return "Asia/Beirut";
            }
            if (std.mem.eql(u8, key, "Mauritius Standard Time")) {
                if (std.mem.eql(u8, region, "RE")) return "Indian/Reunion";
                if (std.mem.eql(u8, region, "SC")) return "Indian/Mahe";
                return "Indian/Mauritius";
            }
            if (std.mem.eql(u8, key, "Myanmar Standard Time")) {
                if (std.mem.eql(u8, region, "CC")) return "Indian/Cocos";
                return "Asia/Rangoon";
            }
            if (std.mem.eql(u8, key, "Magadan Standard Time")) {
                return "Asia/Magadan";
            }
        },
        'n' => {
            if (std.mem.eql(u8, key, "Newfoundland Standard Time")) {
                return "America/St_Johns";
            }
            if (std.mem.eql(u8, key, "Namibia Standard Time")) {
                return "Africa/Windhoek";
            }
            if (std.mem.eql(u8, key, "Nepal Standard Time")) {
                return "Asia/Katmandu";
            }
            if (std.mem.eql(u8, key, "North Asia Standard Time")) {
                return "Asia/Krasnoyarsk";
            }
            if (std.mem.eql(u8, key, "N. Central Asia Standard Time")) {
                return "Asia/Novosibirsk";
            }
            if (std.mem.eql(u8, key, "North Asia East Standard Time")) {
                return "Asia/Irkutsk";
            }
            if (std.mem.eql(u8, key, "North Korea Standard Time")) {
                return "Asia/Pyongyang";
            }
            if (std.mem.eql(u8, key, "Norfolk Standard Time")) {
                return "Pacific/Norfolk";
            }
            if (std.mem.eql(u8, key, "New Zealand Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/McMurdo";
                return "Pacific/Auckland";
            }
        },
        'o' => {
            if (std.mem.eql(u8, key, "Omsk Standard Time")) {
                return "Asia/Omsk";
            }
        },
        'p' => {
            if (std.mem.eql(u8, key, "Pacific Standard Time (Mexico)")) {
                return "America/Tijuana";
            }
            if (std.mem.eql(u8, key, "Pacific Standard Time")) {
                if (std.mem.eql(u8, region, "CA")) return "America/Vancouver";
                return "America/Los_Angeles";
            }
            if (std.mem.eql(u8, key, "Paraguay Standard Time")) {
                return "America/Asuncion";
            }
            if (std.mem.eql(u8, key, "Pacific SA Standard Time")) {
                return "America/Santiago";
            }
            if (std.mem.eql(u8, key, "Pakistan Standard Time")) {
                return "Asia/Karachi";
            }
        },
        'q' => {
            if (std.mem.eql(u8, key, "Qyzylorda Standard Time")) {
                return "Asia/Qyzylorda";
            }
        },
        'r' => {
            if (std.mem.eql(u8, key, "Romance Standard Time")) {
                if (std.mem.eql(u8, region, "BE")) return "Europe/Brussels";
                if (std.mem.eql(u8, region, "DK")) return "Europe/Copenhagen";
                if (std.mem.eql(u8, region, "ES")) return "Europe/Madrid";
                return "Europe/Paris";
            }
            if (std.mem.eql(u8, key, "Russian Standard Time")) {
                if (std.mem.eql(u8, region, "UA")) return "Europe/Simferopol";
                return "Europe/Moscow";
            }
            if (std.mem.eql(u8, key, "Russia Time Zone 3")) {
                return "Europe/Samara";
            }
            if (std.mem.eql(u8, key, "Russia Time Zone 10")) {
                return "Asia/Srednekolymsk";
            }
            if (std.mem.eql(u8, key, "Russia Time Zone 11")) {
                return "Asia/Kamchatka";
            }
        },
        's' => {
            if (std.mem.eql(u8, key, "SA Pacific Standard Time")) {
                if (std.mem.eql(u8, region, "BR")) return "America/Rio_Branco";
                if (std.mem.eql(u8, region, "CA")) return "America/Coral_Harbour";
                if (std.mem.eql(u8, region, "EC")) return "America/Guayaquil";
                if (std.mem.eql(u8, region, "JM")) return "America/Jamaica";
                if (std.mem.eql(u8, region, "KY")) return "America/Cayman";
                if (std.mem.eql(u8, region, "PA")) return "America/Panama";
                if (std.mem.eql(u8, region, "PE")) return "America/Lima";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+5";
                return "America/Bogota";
            }
            if (std.mem.eql(u8, key, "SA Western Standard Time")) {
                if (std.mem.eql(u8, region, "AG")) return "America/Antigua";
                if (std.mem.eql(u8, region, "AI")) return "America/Anguilla";
                if (std.mem.eql(u8, region, "AW")) return "America/Aruba";
                if (std.mem.eql(u8, region, "BB")) return "America/Barbados";
                if (std.mem.eql(u8, region, "BL")) return "America/St_Barthelemy";
                if (std.mem.eql(u8, region, "BQ")) return "America/Kralendijk";
                if (std.mem.eql(u8, region, "BR")) return "America/Manaus";
                if (std.mem.eql(u8, region, "CA")) return "America/Blanc-Sablon";
                if (std.mem.eql(u8, region, "CW")) return "America/Curacao";
                if (std.mem.eql(u8, region, "DM")) return "America/Dominica";
                if (std.mem.eql(u8, region, "DO")) return "America/Santo_Domingo";
                if (std.mem.eql(u8, region, "GD")) return "America/Grenada";
                if (std.mem.eql(u8, region, "GP")) return "America/Guadeloupe";
                if (std.mem.eql(u8, region, "GY")) return "America/Guyana";
                if (std.mem.eql(u8, region, "KN")) return "America/St_Kitts";
                if (std.mem.eql(u8, region, "LC")) return "America/St_Lucia";
                if (std.mem.eql(u8, region, "MF")) return "America/Marigot";
                if (std.mem.eql(u8, region, "MQ")) return "America/Martinique";
                if (std.mem.eql(u8, region, "MS")) return "America/Montserrat";
                if (std.mem.eql(u8, region, "PR")) return "America/Puerto_Rico";
                if (std.mem.eql(u8, region, "SX")) return "America/Lower_Princes";
                if (std.mem.eql(u8, region, "TT")) return "America/Port_of_Spain";
                if (std.mem.eql(u8, region, "VC")) return "America/St_Vincent";
                if (std.mem.eql(u8, region, "VG")) return "America/Tortola";
                if (std.mem.eql(u8, region, "VI")) return "America/St_Thomas";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+4";
                return "America/La_Paz";
            }
            if (std.mem.eql(u8, key, "SA Eastern Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/Rothera";
                if (std.mem.eql(u8, region, "BR")) return "America/Fortaleza";
                if (std.mem.eql(u8, region, "FK")) return "Atlantic/Stanley";
                if (std.mem.eql(u8, region, "SR")) return "America/Paramaribo";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+3";
                return "America/Cayenne";
            }
            if (std.mem.eql(u8, key, "Saint Pierre Standard Time")) {
                return "America/Miquelon";
            }
            if (std.mem.eql(u8, key, "Sao Tome Standard Time")) {
                return "Africa/Sao_Tome";
            }
            if (std.mem.eql(u8, key, "Syria Standard Time")) {
                return "Asia/Damascus";
            }
            if (std.mem.eql(u8, key, "South Africa Standard Time")) {
                if (std.mem.eql(u8, region, "BI")) return "Africa/Bujumbura";
                if (std.mem.eql(u8, region, "BW")) return "Africa/Gaborone";
                if (std.mem.eql(u8, region, "CD")) return "Africa/Lubumbashi";
                if (std.mem.eql(u8, region, "LS")) return "Africa/Maseru";
                if (std.mem.eql(u8, region, "MW")) return "Africa/Blantyre";
                if (std.mem.eql(u8, region, "MZ")) return "Africa/Maputo";
                if (std.mem.eql(u8, region, "RW")) return "Africa/Kigali";
                if (std.mem.eql(u8, region, "SZ")) return "Africa/Mbabane";
                if (std.mem.eql(u8, region, "ZM")) return "Africa/Lusaka";
                if (std.mem.eql(u8, region, "ZW")) return "Africa/Harare";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-2";
                return "Africa/Johannesburg";
            }
            if (std.mem.eql(u8, key, "South Sudan Standard Time")) {
                return "Africa/Juba";
            }
            if (std.mem.eql(u8, key, "Sudan Standard Time")) {
                return "Africa/Khartoum";
            }
            if (std.mem.eql(u8, key, "Saratov Standard Time")) {
                return "Europe/Saratov";
            }
            if (std.mem.eql(u8, key, "Sri Lanka Standard Time")) {
                return "Asia/Colombo";
            }
            if (std.mem.eql(u8, key, "SE Asia Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/Davis";
                if (std.mem.eql(u8, region, "CX")) return "Indian/Christmas";
                if (std.mem.eql(u8, region, "ID")) return "Asia/Jakarta";
                if (std.mem.eql(u8, region, "KH")) return "Asia/Phnom_Penh";
                if (std.mem.eql(u8, region, "LA")) return "Asia/Vientiane";
                if (std.mem.eql(u8, region, "VN")) return "Asia/Saigon";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-7";
                return "Asia/Bangkok";
            }
            if (std.mem.eql(u8, key, "Singapore Standard Time")) {
                if (std.mem.eql(u8, region, "BN")) return "Asia/Brunei";
                if (std.mem.eql(u8, region, "ID")) return "Asia/Makassar";
                if (std.mem.eql(u8, region, "MY")) return "Asia/Kuala_Lumpur";
                if (std.mem.eql(u8, region, "PH")) return "Asia/Manila";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-8";
                return "Asia/Singapore";
            }
            if (std.mem.eql(u8, key, "Sakhalin Standard Time")) {
                return "Asia/Sakhalin";
            }
            if (std.mem.eql(u8, key, "Samoa Standard Time")) {
                return "Pacific/Apia";
            }
        },
        't' => {
            if (std.mem.eql(u8, key, "Turks And Caicos Standard Time")) {
                return "America/Grand_Turk";
            }
            if (std.mem.eql(u8, key, "Tocantins Standard Time")) {
                return "America/Araguaina";
            }
            if (std.mem.eql(u8, key, "Turkey Standard Time")) {
                return "Europe/Istanbul";
            }
            if (std.mem.eql(u8, key, "Tomsk Standard Time")) {
                return "Asia/Tomsk";
            }
            if (std.mem.eql(u8, key, "Taipei Standard Time")) {
                return "Asia/Taipei";
            }
            if (std.mem.eql(u8, key, "Transbaikal Standard Time")) {
                return "Asia/Chita";
            }
            if (std.mem.eql(u8, key, "Tokyo Standard Time")) {
                if (std.mem.eql(u8, region, "ID")) return "Asia/Jayapura";
                if (std.mem.eql(u8, region, "PW")) return "Pacific/Palau";
                if (std.mem.eql(u8, region, "TL")) return "Asia/Dili";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-9";
                return "Asia/Tokyo";
            }
            if (std.mem.eql(u8, key, "Tasmania Standard Time")) {
                return "Australia/Hobart";
            }
            if (std.mem.eql(u8, key, "Tonga Standard Time")) {
                return "Pacific/Tongatapu";
            }
        },
        'u' => {
            if (std.mem.eql(u8, key, "UTC-11")) {
                if (std.mem.eql(u8, region, "AS")) return "Pacific/Pago_Pago";
                if (std.mem.eql(u8, region, "NU")) return "Pacific/Niue";
                if (std.mem.eql(u8, region, "UM")) return "Pacific/Midway";
                return "Etc/GMT+11";
            }
            if (std.mem.eql(u8, key, "UTC-09")) {
                if (std.mem.eql(u8, region, "PF")) return "Pacific/Gambier";
                return "Etc/GMT+9";
            }
            if (std.mem.eql(u8, key, "UTC-08")) {
                if (std.mem.eql(u8, region, "PN")) return "Pacific/Pitcairn";
                return "Etc/GMT+8";
            }
            if (std.mem.eql(u8, key, "US Mountain Standard Time")) {
                if (std.mem.eql(u8, region, "CA")) return "America/Creston";
                if (std.mem.eql(u8, region, "MX")) return "America/Hermosillo";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT+7";
                return "America/Phoenix";
            }
            if (std.mem.eql(u8, key, "US Eastern Standard Time")) {
                return "America/Indianapolis";
            }
            if (std.mem.eql(u8, key, "UTC-02")) {
                if (std.mem.eql(u8, region, "BR")) return "America/Noronha";
                if (std.mem.eql(u8, region, "GS")) return "Atlantic/South_Georgia";
                return "Etc/GMT+2";
            }
            if (std.mem.eql(u8, key, "UTC")) {
                return "Etc/UTC";
            }
            if (std.mem.eql(u8, key, "Ulaanbaatar Standard Time")) {
                return "Asia/Ulaanbaatar";
            }
            if (std.mem.eql(u8, key, "UTC+12")) {
                if (std.mem.eql(u8, region, "KI")) return "Pacific/Tarawa";
                if (std.mem.eql(u8, region, "MH")) return "Pacific/Majuro";
                if (std.mem.eql(u8, region, "NR")) return "Pacific/Nauru";
                if (std.mem.eql(u8, region, "TV")) return "Pacific/Funafuti";
                if (std.mem.eql(u8, region, "UM")) return "Pacific/Wake";
                if (std.mem.eql(u8, region, "WF")) return "Pacific/Wallis";
                return "Etc/GMT-12";
            }
            if (std.mem.eql(u8, key, "UTC+13")) {
                if (std.mem.eql(u8, region, "KI")) return "Pacific/Enderbury";
                if (std.mem.eql(u8, region, "TK")) return "Pacific/Fakaofo";
                return "Etc/GMT-13";
            }
        },
        'v' => {
            if (std.mem.eql(u8, key, "Venezuela Standard Time")) {
                return "America/Caracas";
            }
            if (std.mem.eql(u8, key, "Volgograd Standard Time")) {
                return "Europe/Volgograd";
            }
            if (std.mem.eql(u8, key, "Vladivostok Standard Time")) {
                return "Asia/Vladivostok";
            }
        },
        'w' => {
            if (std.mem.eql(u8, key, "W. Europe Standard Time")) {
                if (std.mem.eql(u8, region, "AD")) return "Europe/Andorra";
                if (std.mem.eql(u8, region, "AT")) return "Europe/Vienna";
                if (std.mem.eql(u8, region, "CH")) return "Europe/Zurich";
                if (std.mem.eql(u8, region, "GI")) return "Europe/Gibraltar";
                if (std.mem.eql(u8, region, "IT")) return "Europe/Rome";
                if (std.mem.eql(u8, region, "LI")) return "Europe/Vaduz";
                if (std.mem.eql(u8, region, "LU")) return "Europe/Luxembourg";
                if (std.mem.eql(u8, region, "MC")) return "Europe/Monaco";
                if (std.mem.eql(u8, region, "MT")) return "Europe/Malta";
                if (std.mem.eql(u8, region, "NL")) return "Europe/Amsterdam";
                if (std.mem.eql(u8, region, "NO")) return "Europe/Oslo";
                if (std.mem.eql(u8, region, "SE")) return "Europe/Stockholm";
                if (std.mem.eql(u8, region, "SJ")) return "Arctic/Longyearbyen";
                if (std.mem.eql(u8, region, "SM")) return "Europe/San_Marino";
                if (std.mem.eql(u8, region, "VA")) return "Europe/Vatican";
                return "Europe/Berlin";
            }
            if (std.mem.eql(u8, key, "W. Central Africa Standard Time")) {
                if (std.mem.eql(u8, region, "AO")) return "Africa/Luanda";
                if (std.mem.eql(u8, region, "BJ")) return "Africa/Porto-Novo";
                if (std.mem.eql(u8, region, "CD")) return "Africa/Kinshasa";
                if (std.mem.eql(u8, region, "CF")) return "Africa/Bangui";
                if (std.mem.eql(u8, region, "CG")) return "Africa/Brazzaville";
                if (std.mem.eql(u8, region, "CM")) return "Africa/Douala";
                if (std.mem.eql(u8, region, "DZ")) return "Africa/Algiers";
                if (std.mem.eql(u8, region, "GA")) return "Africa/Libreville";
                if (std.mem.eql(u8, region, "GQ")) return "Africa/Malabo";
                if (std.mem.eql(u8, region, "NE")) return "Africa/Niamey";
                if (std.mem.eql(u8, region, "TD")) return "Africa/Ndjamena";
                if (std.mem.eql(u8, region, "TN")) return "Africa/Tunis";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-1";
                return "Africa/Lagos";
            }
            if (std.mem.eql(u8, key, "West Bank Standard Time")) {
                return "Asia/Hebron";
            }
            if (std.mem.eql(u8, key, "West Asia Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/Mawson";
                if (std.mem.eql(u8, region, "KZ")) return "Asia/Oral";
                if (std.mem.eql(u8, region, "MV")) return "Indian/Maldives";
                if (std.mem.eql(u8, region, "TF")) return "Indian/Kerguelen";
                if (std.mem.eql(u8, region, "TJ")) return "Asia/Dushanbe";
                if (std.mem.eql(u8, region, "TM")) return "Asia/Ashgabat";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-5";
                return "Asia/Tashkent";
            }
            if (std.mem.eql(u8, key, "W. Mongolia Standard Time")) {
                return "Asia/Hovd";
            }
            if (std.mem.eql(u8, key, "W. Australia Standard Time")) {
                return "Australia/Perth";
            }
            if (std.mem.eql(u8, key, "West Pacific Standard Time")) {
                if (std.mem.eql(u8, region, "AQ")) return "Antarctica/DumontDUrville";
                if (std.mem.eql(u8, region, "FM")) return "Pacific/Truk";
                if (std.mem.eql(u8, region, "GU")) return "Pacific/Guam";
                if (std.mem.eql(u8, region, "MP")) return "Pacific/Saipan";
                if (std.mem.eql(u8, region, "ZZ")) return "Etc/GMT-10";
                return "Pacific/Port_Moresby";
            }
        },
        'y' => {
            if (std.mem.eql(u8, key, "Yukon Standard Time")) {
                return "America/Whitehorse";
            }
            if (std.mem.eql(u8, key, "Yakutsk Standard Time")) {
                return "Asia/Yakutsk";
            }
        },
        else => {},
    }

    return null;
}

pub fn windows_registry_key_to_designation(key: []const u8, is_dst: bool) []const u8 {
    return (if (is_dst) dst_designators.get(key) else std_designators.get(key)) orelse "";
}

const std_designators: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "Alaskan Standard Time", "AKST" },
    .{ "Aleutian Standard Time", "HST" },
    .{ "Atlantic Standard Time", "AST" },
    .{ "AUS Central Standard Time", "ACST" },
    .{ "AUS Eastern Standard Time", "AEST" },
    .{ "Canada Central Standard Time", "CST" },
    .{ "Cen. Australia Standard Time", "ACST" },
    .{ "Central America Standard Time", "CST" },
    .{ "Central Europe Standard Time", "CET" },
    .{ "Central European Standard Time", "CET" },
    .{ "Central Standard Time (Mexico)", "CST" },
    .{ "Central Standard Time", "CST" },
    .{ "China Standard Time", "CST" },
    .{ "Cuba Standard Time", "CST" },
    .{ "E. Africa Standard Time", "EAT" },
    .{ "E. Australia Standard Time", "AEST" },
    .{ "E. Europe Standard Time", "EET" },
    .{ "Eastern Standard Time (Mexico)", "EST" },
    .{ "Eastern Standard Time", "EST" },
    .{ "Egypt Standard Time", "EET" },
    .{ "FLE Standard Time", "EET" },
    .{ "GMT Standard Time", "WET" },
    .{ "Greenwich Standard Time", "GMT" },
    .{ "GTB Standard Time", "EET" },
    .{ "Haiti Standard Time", "EST" },
    .{ "Hawaiian Standard Time", "HST" },
    .{ "India Standard Time", "IST" },
    .{ "Israel Standard Time", "IST" },
    .{ "Kaliningrad Standard Time", "EET" },
    .{ "Korea Standard Time", "KST" },
    .{ "Libya Standard Time", "EET" },
    .{ "Middle East Standard Time", "EET" },
    .{ "Mountain Standard Time (Mexico)", "MST" },
    .{ "Mountain Standard Time", "MST" },
    .{ "Namibia Standard Time", "CAT" },
    .{ "New Zealand Standard Time", "NZST" },
    .{ "Newfoundland Standard Time", "NST" },
    .{ "North Korea Standard Time", "KST" },
    .{ "Pacific Standard Time (Mexico)", "PST" },
    .{ "Pacific Standard Time", "PST" },
    .{ "Pakistan Standard Time", "PKT" },
    .{ "Romance Standard Time", "CET" },
    .{ "Russian Standard Time", "MSK" },
    .{ "Sao Tome Standard Time", "GMT" },
    .{ "South Africa Standard Time", "SAST" },
    .{ "South Sudan Standard Time", "CAT" },
    .{ "Sudan Standard Time", "CAT" },
    .{ "Taipei Standard Time", "CST" },
    .{ "Tasmania Standard Time", "AEST" },
    .{ "Tokyo Standard Time", "JST" },
    .{ "Turks And Caicos Standard Time", "EST" },
    .{ "US Eastern Standard Time", "EST" },
    .{ "US Mountain Standard Time", "MST" },
    .{ "Volgograd Standard Time", "MSK" },
    .{ "W. Australia Standard Time", "AWST" },
    .{ "W. Central Africa Standard Time", "WAT" },
    .{ "W. Europe Standard Time", "CET" },
    .{ "West Bank Standard Time", "EET" },
    .{ "Yukon Standard Time", "MST" },
});

const dst_designators: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "Alaskan Standard Time", "AKDT" },
    .{ "Aleutian Standard Time", "HDT" },
    .{ "Atlantic Standard Time", "ADT" },
    .{ "AUS Eastern Standard Time", "AEDT" },
    .{ "Cen. Australia Standard Time", "ACDT" },
    .{ "Central Europe Standard Time", "CEST" },
    .{ "Central European Standard Time", "CEST" },
    .{ "Central Standard Time", "CDT" },
    .{ "Cuba Standard Time", "CDT" },
    .{ "E. Europe Standard Time", "EEST" },
    .{ "Eastern Standard Time", "EDT" },
    .{ "Egypt Standard Time", "EEST" },
    .{ "FLE Standard Time", "EEST" },
    .{ "GMT Standard Time", "WEST" },
    .{ "GTB Standard Time", "EEST" },
    .{ "Haiti Standard Time", "EDT" },
    .{ "Israel Standard Time", "IDT" },
    .{ "Middle East Standard Time", "EEST" },
    .{ "Mountain Standard Time", "MDT" },
    .{ "New Zealand Standard Time", "NZDT" },
    .{ "Newfoundland Standard Time", "NDT" },
    .{ "Pacific Standard Time (Mexico)", "PDT" },
    .{ "Pacific Standard Time", "PDT" },
    .{ "Romance Standard Time", "CEST" },
    .{ "Tasmania Standard Time", "AEDT" },
    .{ "Turks And Caicos Standard Time", "EDT" },
    .{ "US Eastern Standard Time", "EDT" },
    .{ "W. Europe Standard Time", "CEST" },
    .{ "West Bank Standard Time", "EEST" },
});

pub const iana_to_windows_registry_key: std.StaticStringMap([]const u8) = .initComptime(.{
    .{ "Etc/GMT+12", "Dateline Standard Time" },
    .{ "Etc/GMT+11", "UTC-11" },
    .{ "Pacific/Pago_Pago", "UTC-11" },
    .{ "Pacific/Niue", "UTC-11" },
    .{ "Pacific/Midway", "UTC-11" },
    .{ "America/Adak", "Aleutian Standard Time" },
    .{ "Pacific/Honolulu", "Hawaiian Standard Time" },
    .{ "Pacific/Rarotonga", "Hawaiian Standard Time" },
    .{ "Pacific/Tahiti", "Hawaiian Standard Time" },
    .{ "Etc/GMT+10", "Hawaiian Standard Time" },
    .{ "Pacific/Marquesas", "Marquesas Standard Time" },
    .{ "America/Anchorage", "Alaskan Standard Time" },
    .{ "America/Juneau", "Alaskan Standard Time" },
    .{ "America/Metlakatla", "Alaskan Standard Time" },
    .{ "America/Nome", "Alaskan Standard Time" },
    .{ "America/Sitka", "Alaskan Standard Time" },
    .{ "America/Yakutat", "Alaskan Standard Time" },
    .{ "Etc/GMT+9", "UTC-09" },
    .{ "Pacific/Gambier", "UTC-09" },
    .{ "America/Tijuana", "Pacific Standard Time (Mexico)" },
    .{ "Etc/GMT+8", "UTC-08" },
    .{ "Pacific/Pitcairn", "UTC-08" },
    .{ "America/Los_Angeles", "Pacific Standard Time" },
    .{ "America/Vancouver", "Pacific Standard Time" },
    .{ "America/Phoenix", "US Mountain Standard Time" },
    .{ "America/Creston", "US Mountain Standard Time" },
    .{ "America/Dawson_Creek", "US Mountain Standard Time" },
    .{ "America/Fort_Nelson", "US Mountain Standard Time" },
    .{ "America/Hermosillo", "US Mountain Standard Time" },
    .{ "Etc/GMT+7", "US Mountain Standard Time" },
    .{ "America/Mazatlan", "Mountain Standard Time (Mexico)" },
    .{ "America/Denver", "Mountain Standard Time" },
    .{ "America/Edmonton", "Mountain Standard Time" },
    .{ "America/Cambridge_Bay", "Mountain Standard Time" },
    .{ "America/Inuvik", "Mountain Standard Time" },
    .{ "America/Ciudad_Juarez", "Mountain Standard Time" },
    .{ "America/Boise", "Mountain Standard Time" },
    .{ "America/Whitehorse", "Yukon Standard Time" },
    .{ "America/Dawson", "Yukon Standard Time" },
    .{ "America/Guatemala", "Central America Standard Time" },
    .{ "America/Belize", "Central America Standard Time" },
    .{ "America/Costa_Rica", "Central America Standard Time" },
    .{ "Pacific/Galapagos", "Central America Standard Time" },
    .{ "America/Tegucigalpa", "Central America Standard Time" },
    .{ "America/Managua", "Central America Standard Time" },
    .{ "America/El_Salvador", "Central America Standard Time" },
    .{ "Etc/GMT+6", "Central America Standard Time" },
    .{ "America/Chicago", "Central Standard Time" },
    .{ "America/Winnipeg", "Central Standard Time" },
    .{ "America/Rankin_Inlet", "Central Standard Time" },
    .{ "America/Resolute", "Central Standard Time" },
    .{ "America/Matamoros", "Central Standard Time" },
    .{ "America/Ojinaga", "Central Standard Time" },
    .{ "America/Indiana/Knox", "Central Standard Time" },
    .{ "America/Indiana/Tell_City", "Central Standard Time" },
    .{ "America/Menominee", "Central Standard Time" },
    .{ "America/North_Dakota/Beulah", "Central Standard Time" },
    .{ "America/North_Dakota/Center", "Central Standard Time" },
    .{ "America/North_Dakota/New_Salem", "Central Standard Time" },
    .{ "Pacific/Easter", "Easter Island Standard Time" },
    .{ "America/Mexico_City", "Central Standard Time (Mexico)" },
    .{ "America/Bahia_Banderas", "Central Standard Time (Mexico)" },
    .{ "America/Merida", "Central Standard Time (Mexico)" },
    .{ "America/Monterrey", "Central Standard Time (Mexico)" },
    .{ "America/Chihuahua", "Central Standard Time (Mexico)" },
    .{ "America/Regina", "Canada Central Standard Time" },
    .{ "America/Swift_Current", "Canada Central Standard Time" },
    .{ "America/Bogota", "SA Pacific Standard Time" },
    .{ "America/Rio_Branco", "SA Pacific Standard Time" },
    .{ "America/Eirunepe", "SA Pacific Standard Time" },
    .{ "America/Coral_Harbour", "SA Pacific Standard Time" },
    .{ "America/Guayaquil", "SA Pacific Standard Time" },
    .{ "America/Jamaica", "SA Pacific Standard Time" },
    .{ "America/Cayman", "SA Pacific Standard Time" },
    .{ "America/Panama", "SA Pacific Standard Time" },
    .{ "America/Lima", "SA Pacific Standard Time" },
    .{ "Etc/GMT+5", "SA Pacific Standard Time" },
    .{ "America/Cancun", "Eastern Standard Time (Mexico)" },
    .{ "America/New_York", "Eastern Standard Time" },
    .{ "America/Nassau", "Eastern Standard Time" },
    .{ "America/Toronto", "Eastern Standard Time" },
    .{ "America/Iqaluit", "Eastern Standard Time" },
    .{ "America/Detroit", "Eastern Standard Time" },
    .{ "America/Indiana/Petersburg", "Eastern Standard Time" },
    .{ "America/Indiana/Vincennes", "Eastern Standard Time" },
    .{ "America/Indiana/Winamac", "Eastern Standard Time" },
    .{ "America/Kentucky/Monticello", "Eastern Standard Time" },
    .{ "America/Louisville", "Eastern Standard Time" },
    .{ "America/Port-au-Prince", "Haiti Standard Time" },
    .{ "America/Havana", "Cuba Standard Time" },
    .{ "America/Indianapolis", "US Eastern Standard Time" },
    .{ "America/Indiana/Marengo", "US Eastern Standard Time" },
    .{ "America/Indiana/Vevay", "US Eastern Standard Time" },
    .{ "America/Grand_Turk", "Turks And Caicos Standard Time" },
    .{ "America/Asuncion", "Paraguay Standard Time" },
    .{ "America/Halifax", "Atlantic Standard Time" },
    .{ "Atlantic/Bermuda", "Atlantic Standard Time" },
    .{ "America/Glace_Bay", "Atlantic Standard Time" },
    .{ "America/Goose_Bay", "Atlantic Standard Time" },
    .{ "America/Moncton", "Atlantic Standard Time" },
    .{ "America/Thule", "Atlantic Standard Time" },
    .{ "America/Caracas", "Venezuela Standard Time" },
    .{ "America/Cuiaba", "Central Brazilian Standard Time" },
    .{ "America/Campo_Grande", "Central Brazilian Standard Time" },
    .{ "America/La_Paz", "SA Western Standard Time" },
    .{ "America/Antigua", "SA Western Standard Time" },
    .{ "America/Anguilla", "SA Western Standard Time" },
    .{ "America/Aruba", "SA Western Standard Time" },
    .{ "America/Barbados", "SA Western Standard Time" },
    .{ "America/St_Barthelemy", "SA Western Standard Time" },
    .{ "America/Kralendijk", "SA Western Standard Time" },
    .{ "America/Manaus", "SA Western Standard Time" },
    .{ "America/Boa_Vista", "SA Western Standard Time" },
    .{ "America/Porto_Velho", "SA Western Standard Time" },
    .{ "America/Blanc-Sablon", "SA Western Standard Time" },
    .{ "America/Curacao", "SA Western Standard Time" },
    .{ "America/Dominica", "SA Western Standard Time" },
    .{ "America/Santo_Domingo", "SA Western Standard Time" },
    .{ "America/Grenada", "SA Western Standard Time" },
    .{ "America/Guadeloupe", "SA Western Standard Time" },
    .{ "America/Guyana", "SA Western Standard Time" },
    .{ "America/St_Kitts", "SA Western Standard Time" },
    .{ "America/St_Lucia", "SA Western Standard Time" },
    .{ "America/Marigot", "SA Western Standard Time" },
    .{ "America/Martinique", "SA Western Standard Time" },
    .{ "America/Montserrat", "SA Western Standard Time" },
    .{ "America/Puerto_Rico", "SA Western Standard Time" },
    .{ "America/Lower_Princes", "SA Western Standard Time" },
    .{ "America/Port_of_Spain", "SA Western Standard Time" },
    .{ "America/St_Vincent", "SA Western Standard Time" },
    .{ "America/Tortola", "SA Western Standard Time" },
    .{ "America/St_Thomas", "SA Western Standard Time" },
    .{ "Etc/GMT+4", "SA Western Standard Time" },
    .{ "America/Santiago", "Pacific SA Standard Time" },
    .{ "America/St_Johns", "Newfoundland Standard Time" },
    .{ "America/Araguaina", "Tocantins Standard Time" },
    .{ "America/Sao_Paulo", "E. South America Standard Time" },
    .{ "America/Cayenne", "SA Eastern Standard Time" },
    .{ "Antarctica/Rothera", "SA Eastern Standard Time" },
    .{ "Antarctica/Palmer", "SA Eastern Standard Time" },
    .{ "America/Fortaleza", "SA Eastern Standard Time" },
    .{ "America/Belem", "SA Eastern Standard Time" },
    .{ "America/Maceio", "SA Eastern Standard Time" },
    .{ "America/Recife", "SA Eastern Standard Time" },
    .{ "America/Santarem", "SA Eastern Standard Time" },
    .{ "Atlantic/Stanley", "SA Eastern Standard Time" },
    .{ "America/Paramaribo", "SA Eastern Standard Time" },
    .{ "Etc/GMT+3", "SA Eastern Standard Time" },
    .{ "America/Buenos_Aires", "Argentina Standard Time" },
    .{ "America/Argentina/La_Rioja", "Argentina Standard Time" },
    .{ "America/Argentina/Rio_Gallegos", "Argentina Standard Time" },
    .{ "America/Argentina/Salta", "Argentina Standard Time" },
    .{ "America/Argentina/San_Juan", "Argentina Standard Time" },
    .{ "America/Argentina/San_Luis", "Argentina Standard Time" },
    .{ "America/Argentina/Tucuman", "Argentina Standard Time" },
    .{ "America/Argentina/Ushuaia", "Argentina Standard Time" },
    .{ "America/Catamarca", "Argentina Standard Time" },
    .{ "America/Cordoba", "Argentina Standard Time" },
    .{ "America/Jujuy", "Argentina Standard Time" },
    .{ "America/Mendoza", "Argentina Standard Time" },
    .{ "America/Godthab", "Greenland Standard Time" },
    .{ "America/Montevideo", "Montevideo Standard Time" },
    .{ "America/Punta_Arenas", "Magallanes Standard Time" },
    .{ "America/Coyhaique", "Magallanes Standard Time" },
    .{ "America/Miquelon", "Saint Pierre Standard Time" },
    .{ "America/Bahia", "Bahia Standard Time" },
    .{ "Etc/GMT+2", "UTC-02" },
    .{ "America/Noronha", "UTC-02" },
    .{ "Atlantic/South_Georgia", "UTC-02" },
    .{ "Atlantic/Azores", "Azores Standard Time" },
    .{ "America/Scoresbysund", "Azores Standard Time" },
    .{ "Atlantic/Cape_Verde", "Cape Verde Standard Time" },
    .{ "Etc/GMT+1", "Cape Verde Standard Time" },
    .{ "Etc/UTC", "UTC" },
    .{ "Etc/GMT", "UTC" },
    .{ "Europe/London", "GMT Standard Time" },
    .{ "Atlantic/Canary", "GMT Standard Time" },
    .{ "Atlantic/Faeroe", "GMT Standard Time" },
    .{ "Europe/Guernsey", "GMT Standard Time" },
    .{ "Europe/Dublin", "GMT Standard Time" },
    .{ "Europe/Isle_of_Man", "GMT Standard Time" },
    .{ "Europe/Jersey", "GMT Standard Time" },
    .{ "Europe/Lisbon", "GMT Standard Time" },
    .{ "Atlantic/Madeira", "GMT Standard Time" },
    .{ "Atlantic/Reykjavik", "Greenwich Standard Time" },
    .{ "Africa/Ouagadougou", "Greenwich Standard Time" },
    .{ "Africa/Abidjan", "Greenwich Standard Time" },
    .{ "Africa/Accra", "Greenwich Standard Time" },
    .{ "America/Danmarkshavn", "Greenwich Standard Time" },
    .{ "Africa/Banjul", "Greenwich Standard Time" },
    .{ "Africa/Conakry", "Greenwich Standard Time" },
    .{ "Africa/Bissau", "Greenwich Standard Time" },
    .{ "Africa/Monrovia", "Greenwich Standard Time" },
    .{ "Africa/Bamako", "Greenwich Standard Time" },
    .{ "Africa/Nouakchott", "Greenwich Standard Time" },
    .{ "Atlantic/St_Helena", "Greenwich Standard Time" },
    .{ "Africa/Freetown", "Greenwich Standard Time" },
    .{ "Africa/Dakar", "Greenwich Standard Time" },
    .{ "Africa/Lome", "Greenwich Standard Time" },
    .{ "Africa/Sao_Tome", "Sao Tome Standard Time" },
    .{ "Africa/Casablanca", "Morocco Standard Time" },
    .{ "Africa/El_Aaiun", "Morocco Standard Time" },
    .{ "Europe/Berlin", "W. Europe Standard Time" },
    .{ "Europe/Andorra", "W. Europe Standard Time" },
    .{ "Europe/Vienna", "W. Europe Standard Time" },
    .{ "Europe/Zurich", "W. Europe Standard Time" },
    .{ "Europe/Busingen", "W. Europe Standard Time" },
    .{ "Europe/Gibraltar", "W. Europe Standard Time" },
    .{ "Europe/Rome", "W. Europe Standard Time" },
    .{ "Europe/Vaduz", "W. Europe Standard Time" },
    .{ "Europe/Luxembourg", "W. Europe Standard Time" },
    .{ "Europe/Monaco", "W. Europe Standard Time" },
    .{ "Europe/Malta", "W. Europe Standard Time" },
    .{ "Europe/Amsterdam", "W. Europe Standard Time" },
    .{ "Europe/Oslo", "W. Europe Standard Time" },
    .{ "Europe/Stockholm", "W. Europe Standard Time" },
    .{ "Arctic/Longyearbyen", "W. Europe Standard Time" },
    .{ "Europe/San_Marino", "W. Europe Standard Time" },
    .{ "Europe/Vatican", "W. Europe Standard Time" },
    .{ "Europe/Budapest", "Central Europe Standard Time" },
    .{ "Europe/Tirane", "Central Europe Standard Time" },
    .{ "Europe/Prague", "Central Europe Standard Time" },
    .{ "Europe/Podgorica", "Central Europe Standard Time" },
    .{ "Europe/Belgrade", "Central Europe Standard Time" },
    .{ "Europe/Ljubljana", "Central Europe Standard Time" },
    .{ "Europe/Bratislava", "Central Europe Standard Time" },
    .{ "Europe/Paris", "Romance Standard Time" },
    .{ "Europe/Brussels", "Romance Standard Time" },
    .{ "Europe/Copenhagen", "Romance Standard Time" },
    .{ "Europe/Madrid", "Romance Standard Time" },
    .{ "Africa/Ceuta", "Romance Standard Time" },
    .{ "Europe/Warsaw", "Central European Standard Time" },
    .{ "Europe/Sarajevo", "Central European Standard Time" },
    .{ "Europe/Zagreb", "Central European Standard Time" },
    .{ "Europe/Skopje", "Central European Standard Time" },
    .{ "Africa/Lagos", "W. Central Africa Standard Time" },
    .{ "Africa/Luanda", "W. Central Africa Standard Time" },
    .{ "Africa/Porto-Novo", "W. Central Africa Standard Time" },
    .{ "Africa/Kinshasa", "W. Central Africa Standard Time" },
    .{ "Africa/Bangui", "W. Central Africa Standard Time" },
    .{ "Africa/Brazzaville", "W. Central Africa Standard Time" },
    .{ "Africa/Douala", "W. Central Africa Standard Time" },
    .{ "Africa/Algiers", "W. Central Africa Standard Time" },
    .{ "Africa/Libreville", "W. Central Africa Standard Time" },
    .{ "Africa/Malabo", "W. Central Africa Standard Time" },
    .{ "Africa/Niamey", "W. Central Africa Standard Time" },
    .{ "Africa/Ndjamena", "W. Central Africa Standard Time" },
    .{ "Africa/Tunis", "W. Central Africa Standard Time" },
    .{ "Etc/GMT-1", "W. Central Africa Standard Time" },
    .{ "Asia/Amman", "Jordan Standard Time" },
    .{ "Europe/Bucharest", "GTB Standard Time" },
    .{ "Asia/Nicosia", "GTB Standard Time" },
    .{ "Asia/Famagusta", "GTB Standard Time" },
    .{ "Europe/Athens", "GTB Standard Time" },
    .{ "Asia/Beirut", "Middle East Standard Time" },
    .{ "Africa/Cairo", "Egypt Standard Time" },
    .{ "Europe/Chisinau", "E. Europe Standard Time" },
    .{ "Asia/Damascus", "Syria Standard Time" },
    .{ "Asia/Hebron", "West Bank Standard Time" },
    .{ "Asia/Gaza", "West Bank Standard Time" },
    .{ "Africa/Johannesburg", "South Africa Standard Time" },
    .{ "Africa/Bujumbura", "South Africa Standard Time" },
    .{ "Africa/Gaborone", "South Africa Standard Time" },
    .{ "Africa/Lubumbashi", "South Africa Standard Time" },
    .{ "Africa/Maseru", "South Africa Standard Time" },
    .{ "Africa/Blantyre", "South Africa Standard Time" },
    .{ "Africa/Maputo", "South Africa Standard Time" },
    .{ "Africa/Kigali", "South Africa Standard Time" },
    .{ "Africa/Mbabane", "South Africa Standard Time" },
    .{ "Africa/Lusaka", "South Africa Standard Time" },
    .{ "Africa/Harare", "South Africa Standard Time" },
    .{ "Etc/GMT-2", "South Africa Standard Time" },
    .{ "Europe/Kiev", "FLE Standard Time" },
    .{ "Europe/Mariehamn", "FLE Standard Time" },
    .{ "Europe/Sofia", "FLE Standard Time" },
    .{ "Europe/Tallinn", "FLE Standard Time" },
    .{ "Europe/Helsinki", "FLE Standard Time" },
    .{ "Europe/Vilnius", "FLE Standard Time" },
    .{ "Europe/Riga", "FLE Standard Time" },
    .{ "Asia/Jerusalem", "Israel Standard Time" },
    .{ "Africa/Juba", "South Sudan Standard Time" },
    .{ "Europe/Kaliningrad", "Kaliningrad Standard Time" },
    .{ "Africa/Khartoum", "Sudan Standard Time" },
    .{ "Africa/Tripoli", "Libya Standard Time" },
    .{ "Africa/Windhoek", "Namibia Standard Time" },
    .{ "Asia/Baghdad", "Arabic Standard Time" },
    .{ "Europe/Istanbul", "Turkey Standard Time" },
    .{ "Asia/Riyadh", "Arab Standard Time" },
    .{ "Asia/Bahrain", "Arab Standard Time" },
    .{ "Asia/Kuwait", "Arab Standard Time" },
    .{ "Asia/Qatar", "Arab Standard Time" },
    .{ "Asia/Aden", "Arab Standard Time" },
    .{ "Europe/Minsk", "Belarus Standard Time" },
    .{ "Europe/Moscow", "Russian Standard Time" },
    .{ "Europe/Kirov", "Russian Standard Time" },
    .{ "Europe/Simferopol", "Russian Standard Time" },
    .{ "Africa/Nairobi", "E. Africa Standard Time" },
    .{ "Antarctica/Syowa", "E. Africa Standard Time" },
    .{ "Africa/Djibouti", "E. Africa Standard Time" },
    .{ "Africa/Asmera", "E. Africa Standard Time" },
    .{ "Africa/Addis_Ababa", "E. Africa Standard Time" },
    .{ "Indian/Comoro", "E. Africa Standard Time" },
    .{ "Indian/Antananarivo", "E. Africa Standard Time" },
    .{ "Africa/Mogadishu", "E. Africa Standard Time" },
    .{ "Africa/Dar_es_Salaam", "E. Africa Standard Time" },
    .{ "Africa/Kampala", "E. Africa Standard Time" },
    .{ "Indian/Mayotte", "E. Africa Standard Time" },
    .{ "Etc/GMT-3", "E. Africa Standard Time" },
    .{ "Asia/Tehran", "Iran Standard Time" },
    .{ "Asia/Dubai", "Arabian Standard Time" },
    .{ "Asia/Muscat", "Arabian Standard Time" },
    .{ "Etc/GMT-4", "Arabian Standard Time" },
    .{ "Europe/Astrakhan", "Astrakhan Standard Time" },
    .{ "Europe/Ulyanovsk", "Astrakhan Standard Time" },
    .{ "Asia/Baku", "Azerbaijan Standard Time" },
    .{ "Europe/Samara", "Russia Time Zone 3" },
    .{ "Indian/Mauritius", "Mauritius Standard Time" },
    .{ "Indian/Reunion", "Mauritius Standard Time" },
    .{ "Indian/Mahe", "Mauritius Standard Time" },
    .{ "Europe/Saratov", "Saratov Standard Time" },
    .{ "Asia/Tbilisi", "Georgian Standard Time" },
    .{ "Europe/Volgograd", "Volgograd Standard Time" },
    .{ "Asia/Yerevan", "Caucasus Standard Time" },
    .{ "Asia/Kabul", "Afghanistan Standard Time" },
    .{ "Asia/Tashkent", "West Asia Standard Time" },
    .{ "Antarctica/Mawson", "West Asia Standard Time" },
    .{ "Asia/Oral", "West Asia Standard Time" },
    .{ "Asia/Almaty", "West Asia Standard Time" },
    .{ "Asia/Aqtau", "West Asia Standard Time" },
    .{ "Asia/Aqtobe", "West Asia Standard Time" },
    .{ "Asia/Atyrau", "West Asia Standard Time" },
    .{ "Asia/Qostanay", "West Asia Standard Time" },
    .{ "Indian/Maldives", "West Asia Standard Time" },
    .{ "Indian/Kerguelen", "West Asia Standard Time" },
    .{ "Asia/Dushanbe", "West Asia Standard Time" },
    .{ "Asia/Ashgabat", "West Asia Standard Time" },
    .{ "Asia/Samarkand", "West Asia Standard Time" },
    .{ "Etc/GMT-5", "West Asia Standard Time" },
    .{ "Asia/Yekaterinburg", "Ekaterinburg Standard Time" },
    .{ "Asia/Karachi", "Pakistan Standard Time" },
    .{ "Asia/Qyzylorda", "Qyzylorda Standard Time" },
    .{ "Asia/Calcutta", "India Standard Time" },
    .{ "Asia/Colombo", "Sri Lanka Standard Time" },
    .{ "Asia/Katmandu", "Nepal Standard Time" },
    .{ "Asia/Bishkek", "Central Asia Standard Time" },
    .{ "Antarctica/Vostok", "Central Asia Standard Time" },
    .{ "Asia/Urumqi", "Central Asia Standard Time" },
    .{ "Indian/Chagos", "Central Asia Standard Time" },
    .{ "Etc/GMT-6", "Central Asia Standard Time" },
    .{ "Asia/Dhaka", "Bangladesh Standard Time" },
    .{ "Asia/Thimphu", "Bangladesh Standard Time" },
    .{ "Asia/Omsk", "Omsk Standard Time" },
    .{ "Asia/Rangoon", "Myanmar Standard Time" },
    .{ "Indian/Cocos", "Myanmar Standard Time" },
    .{ "Asia/Bangkok", "SE Asia Standard Time" },
    .{ "Antarctica/Davis", "SE Asia Standard Time" },
    .{ "Indian/Christmas", "SE Asia Standard Time" },
    .{ "Asia/Jakarta", "SE Asia Standard Time" },
    .{ "Asia/Pontianak", "SE Asia Standard Time" },
    .{ "Asia/Phnom_Penh", "SE Asia Standard Time" },
    .{ "Asia/Vientiane", "SE Asia Standard Time" },
    .{ "Asia/Saigon", "SE Asia Standard Time" },
    .{ "Etc/GMT-7", "SE Asia Standard Time" },
    .{ "Asia/Barnaul", "Altai Standard Time" },
    .{ "Asia/Hovd", "W. Mongolia Standard Time" },
    .{ "Asia/Krasnoyarsk", "North Asia Standard Time" },
    .{ "Asia/Novokuznetsk", "North Asia Standard Time" },
    .{ "Asia/Novosibirsk", "N. Central Asia Standard Time" },
    .{ "Asia/Tomsk", "Tomsk Standard Time" },
    .{ "Asia/Shanghai", "China Standard Time" },
    .{ "Asia/Hong_Kong", "China Standard Time" },
    .{ "Asia/Macau", "China Standard Time" },
    .{ "Asia/Irkutsk", "North Asia East Standard Time" },
    .{ "Asia/Singapore", "Singapore Standard Time" },
    .{ "Asia/Brunei", "Singapore Standard Time" },
    .{ "Asia/Makassar", "Singapore Standard Time" },
    .{ "Asia/Kuala_Lumpur", "Singapore Standard Time" },
    .{ "Asia/Kuching", "Singapore Standard Time" },
    .{ "Asia/Manila", "Singapore Standard Time" },
    .{ "Etc/GMT-8", "Singapore Standard Time" },
    .{ "Australia/Perth", "W. Australia Standard Time" },
    .{ "Asia/Taipei", "Taipei Standard Time" },
    .{ "Asia/Ulaanbaatar", "Ulaanbaatar Standard Time" },
    .{ "Australia/Eucla", "Aus Central W. Standard Time" },
    .{ "Asia/Chita", "Transbaikal Standard Time" },
    .{ "Asia/Tokyo", "Tokyo Standard Time" },
    .{ "Asia/Jayapura", "Tokyo Standard Time" },
    .{ "Pacific/Palau", "Tokyo Standard Time" },
    .{ "Asia/Dili", "Tokyo Standard Time" },
    .{ "Etc/GMT-9", "Tokyo Standard Time" },
    .{ "Asia/Pyongyang", "North Korea Standard Time" },
    .{ "Asia/Seoul", "Korea Standard Time" },
    .{ "Asia/Yakutsk", "Yakutsk Standard Time" },
    .{ "Asia/Khandyga", "Yakutsk Standard Time" },
    .{ "Australia/Adelaide", "Cen. Australia Standard Time" },
    .{ "Australia/Broken_Hill", "Cen. Australia Standard Time" },
    .{ "Australia/Darwin", "AUS Central Standard Time" },
    .{ "Australia/Brisbane", "E. Australia Standard Time" },
    .{ "Australia/Lindeman", "E. Australia Standard Time" },
    .{ "Australia/Sydney", "AUS Eastern Standard Time" },
    .{ "Australia/Melbourne", "AUS Eastern Standard Time" },
    .{ "Pacific/Port_Moresby", "West Pacific Standard Time" },
    .{ "Antarctica/DumontDUrville", "West Pacific Standard Time" },
    .{ "Pacific/Truk", "West Pacific Standard Time" },
    .{ "Pacific/Guam", "West Pacific Standard Time" },
    .{ "Pacific/Saipan", "West Pacific Standard Time" },
    .{ "Etc/GMT-10", "West Pacific Standard Time" },
    .{ "Australia/Hobart", "Tasmania Standard Time" },
    .{ "Antarctica/Macquarie", "Tasmania Standard Time" },
    .{ "Asia/Vladivostok", "Vladivostok Standard Time" },
    .{ "Asia/Ust-Nera", "Vladivostok Standard Time" },
    .{ "Australia/Lord_Howe", "Lord Howe Standard Time" },
    .{ "Pacific/Bougainville", "Bougainville Standard Time" },
    .{ "Asia/Srednekolymsk", "Russia Time Zone 10" },
    .{ "Asia/Magadan", "Magadan Standard Time" },
    .{ "Pacific/Norfolk", "Norfolk Standard Time" },
    .{ "Asia/Sakhalin", "Sakhalin Standard Time" },
    .{ "Pacific/Guadalcanal", "Central Pacific Standard Time" },
    .{ "Antarctica/Casey", "Central Pacific Standard Time" },
    .{ "Pacific/Ponape", "Central Pacific Standard Time" },
    .{ "Pacific/Kosrae", "Central Pacific Standard Time" },
    .{ "Pacific/Noumea", "Central Pacific Standard Time" },
    .{ "Pacific/Efate", "Central Pacific Standard Time" },
    .{ "Etc/GMT-11", "Central Pacific Standard Time" },
    .{ "Asia/Kamchatka", "Russia Time Zone 11" },
    .{ "Asia/Anadyr", "Russia Time Zone 11" },
    .{ "Pacific/Auckland", "New Zealand Standard Time" },
    .{ "Antarctica/McMurdo", "New Zealand Standard Time" },
    .{ "Etc/GMT-12", "UTC+12" },
    .{ "Pacific/Tarawa", "UTC+12" },
    .{ "Pacific/Majuro", "UTC+12" },
    .{ "Pacific/Kwajalein", "UTC+12" },
    .{ "Pacific/Nauru", "UTC+12" },
    .{ "Pacific/Funafuti", "UTC+12" },
    .{ "Pacific/Wake", "UTC+12" },
    .{ "Pacific/Wallis", "UTC+12" },
    .{ "Pacific/Fiji", "Fiji Standard Time" },
    .{ "Pacific/Chatham", "Chatham Islands Standard Time" },
    .{ "Etc/GMT-13", "UTC+13" },
    .{ "Pacific/Enderbury", "UTC+13" },
    .{ "Pacific/Fakaofo", "UTC+13" },
    .{ "Pacific/Tongatapu", "Tonga Standard Time" },
    .{ "Pacific/Apia", "Samoa Standard Time" },
    .{ "Pacific/Kiritimati", "Line Islands Standard Time" },
    .{ "Etc/GMT-14", "Line Islands Standard Time" },
});

const std = @import("std");
