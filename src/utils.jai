#import "Basic";

// ----------------------------------------------------------------------------: format result.png

//
// So our output file be like:   "2026-09-17_14-49-11.png"
//
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

// ----------------------------------------------------------------------------: math

// PI and FLOAT32_INFINITY already come from Math.
degrees_to_radians :: (degrees : float) -> float {
    return degrees * PI / 180.0;
}

// ----------------------------------------------------------------------------: color

//
// `Vector3` is the float color used while rendering, in [0, 1].
// `Pixel` is what gets written to the PNG. `to_pixel` is the only conversion between them.
//
Pixel :: struct {
    r, g, b : u8;
}
#assert size_of(Pixel) == 3;  // stbi_write_png expects tightly packed RGB

to_pixel :: (color : Vector3) -> Pixel {
    // Translate the [0,1] component values to the byte range [0,255].
    to_u8 :: (x : float) -> u8 {
        INTENSITY :: Interval.{0.000, 0.999};
        return cast(u8)(256 * clamp(INTENSITY, x));
    }

    return .{to_u8(color.x), to_u8(color.y), to_u8(color.z)};
}

// ----------------------------------------------------------------------------: Vector3

operator + :: (v : Vector3, x : float) -> Vector3 {
    return .{v.x+x, v.y+x, v.z+x};
}

operator - :: (v : Vector3, x : float) -> Vector3 {
    return .{v.x-x, v.y-x, v.z-x};
}
