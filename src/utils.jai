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
        return cast(u8)(256 * clamp(INTENSITY, linear_to_gamma(x)));
    }

    return .{to_u8(color.x), to_u8(color.y), to_u8(color.z)};
}

//
// Image viewers expect gamma space; we render in linear space. Use "gamma 2", i.e. sqrt.
//
linear_to_gamma :: (linear_component : float) -> float {
    if linear_component > 0  return sqrt(linear_component);
    return 0;
}

// ----------------------------------------------------------------------------: Vector3

random_vector3 :: () -> Vector3 {
    return .{random_get_zero_to_one_open(), random_get_zero_to_one_open(), random_get_zero_to_one_open()};
}

random_vector3 :: (min : float, max : float) -> Vector3 {
    return .{random_get_within_range(min, max), random_get_within_range(min, max), random_get_within_range(min, max)};
}

//
// Rejection method: pick points in the [-1,1] cube until one lies inside the unit sphere,
// then normalize it onto the surface.
//
random_unit_vector :: () -> Vector3 {
    while true {
        p := random_vector3(-1, 1);
        lensq := length_squared(p);
        // Also reject points so close to the center that normalizing would blow up.
        if FLOAT32_MIN < lensq && lensq <= 1  return p / sqrt(lensq);
    }
    return .{};  // Unreachable
}

//
// Uniform over the hemisphere around `normal`. Superseded by Lambertian
// (`normal + random_unit_vector()`), kept for comparison.
//
random_on_hemisphere :: (normal : Vector3) -> Vector3 {
    on_unit_sphere := random_unit_vector();
    if dot(on_unit_sphere, normal) > 0  return on_unit_sphere;  // Same hemisphere as the normal
    return -on_unit_sphere;
}

//
// True if the vector is close to zero in all dimensions.
//
near_zero :: (v : Vector3) -> bool {
    S :: 1.0e-8;
    return abs(v.x) < S && abs(v.y) < S && abs(v.z) < S;
}

//
// Mirror `v` about the surface with unit normal `n`.
//
reflect :: (v : Vector3, n : Vector3) -> Vector3 {
    return v - 2 * dot(v, n) * n;
}

operator + :: (v : Vector3, x : float) -> Vector3 {
    return .{v.x+x, v.y+x, v.z+x};
}

operator - :: (v : Vector3, x : float) -> Vector3 {
    return .{v.x-x, v.y-x, v.z-x};
}
