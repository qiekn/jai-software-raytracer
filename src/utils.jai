#import "Basic";

make_filename :: (extension: string = "png") -> string {
    now := to_calendar(current_time_consensus(), .LOCAL);

    return tprint(
        "%-%-%_%-%-%.%",
        now.year,
        formatInt(now.month_starting_at_0 + 1,        minimum_digits=2),
        formatInt(now.day_of_month_starting_at_0 + 1, minimum_digits=2),
        formatInt(now.hour,   minimum_digits=2),
        formatInt(now.minute, minimum_digits=2),
        formatInt(now.second, minimum_digits=2),
        extension,
    );
}
