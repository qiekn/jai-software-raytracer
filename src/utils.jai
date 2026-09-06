#import "Basic";

// ----------------------------------------------------------------------------: format result.png
make_filename :: (extension: string = "png") -> string {
    now := to_calendar(current_time_consensus(), .LOCAL);

    return tprint(
        "%-%-%_%-%-%.%",
        now.year,
        formatInt(now.month_starting_at_0 + 1,        minimum_digits=2),
        formatInt(now.day_of_month_starting_at_0 + 1, minimum_digits=2),
        formatInt(now.hour,                           minimum_digits=2),
        formatInt(now.minute,                         minimum_digits=2),
        formatInt(now.second,                         minimum_digits=2),
        extension,
    );
}

// ----------------------------------------------------------------------------: color

Pixel_Color :: struct {
    x, y, z : u8;
}

write_color :: (pixels: []u8, index: int, color: Vector3) {
    to_u8 :: (num : float) -> u8 {
        return cast(u8)(255.999 * num);
    }

    pixels[index + 0] = to_u8(color.x);
    pixels[index + 1] = to_u8(color.y);
    pixels[index + 2] = to_u8(color.z);
}

write_color :: (pixels: []u8, index: int, color: Pixel_Color) {
    pixels[index + 0] = color.x;
    pixels[index + 1] = color.y;
    pixels[index + 2] = color.z;
}
