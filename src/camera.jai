// Camera parameters: set these before calling render().
aspect_ratio      : float = 4.0 / 3.0;  // Ratio of image width over height
image_width       : s32   = 400;        // Rendered image width in pixel count
samples_per_pixel : s32   = 10;         // Count of random samples for each pixel
max_depth         : s32   = 10;         // Maximum number of ray bounces into scene

// Derived state, filled by init_camera().
image_height        : s32;      // Rendered image height
pixel_samples_scale : float;    // Color scale factor for a sum of pixel samples
camera_center       : Vector3;  // Camera center
pixel00_loc         : Vector3;  // Location of pixel 0, 0
pixel_delta_u       : Vector3;  // Offset to pixel to the right
pixel_delta_v       : Vector3;  // Offset to pixel below

render :: (world : World) {
    init_camera();

    pixels := NewArray(image_width * image_height, Pixel);

    for y : 0..image_height-1 {
        print("\rScanlines remaining: %    ", image_height - y);
        for x : 0..image_width-1 {
            color : Vector3;
            for 1..samples_per_pixel {
                color += ray_color(get_ray(x, y), max_depth, world);
            }
            pixels[y * image_width + x] = to_pixel(pixel_samples_scale * color);
        }
    }
    print("\rDone.                     \n");

    filename := make_filename();
    stbi_write_png(filename.data, image_width, image_height, 3, pixels.data, image_width * 3);
}

init_camera :: () {
    image_height = xx (image_width / aspect_ratio);
    image_height = max(image_height, 1);

    pixel_samples_scale = 1.0 / samples_per_pixel;

    camera_center = .{0, 0, 0};

    focal_length    := 1.0;
    viewport_height := 2.0;
    viewport_width  := viewport_height * (cast(float)image_width / image_height);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    viewport_u := Vector3.{viewport_width, 0, 0};
    viewport_v := Vector3.{0, -viewport_height, 0};

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    pixel_delta_u = viewport_u / image_width.(float);
    pixel_delta_v = viewport_v / image_height.(float);

    // Upper-left corner of the viewport.
    viewport_upper_left := camera_center - Vector3.{0, 0, focal_length}
                                         - viewport_u / 2.0
                                         - viewport_v / 2.0;

    // Center of pixel (0, 0).
    pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);
}

//
// A ray from the camera center through a random point inside pixel (x, y).
//
get_ray :: (x : s32, y : s32) -> Ray {
    offset := sample_square();
    pixel_sample := pixel00_loc
                  + (x.(float) + offset.x) * pixel_delta_u
                  + (y.(float) + offset.y) * pixel_delta_v;

    return .{origin = camera_center, direction = pixel_sample - camera_center};
}

//
// A random point in the [-.5,-.5]-[+.5,+.5] unit square.
//
sample_square :: () -> Vector3 {
    return .{random_get_zero_to_one_open() - 0.5, random_get_zero_to_one_open() - 0.5, 0};
}

ray_color :: (ray : Ray, depth : s32, world : World) -> Vector3 {
    // If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0  return .{0, 0, 0};

    // t starts at 0.001, not 0: a bounced ray whose origin rounded to just below
    // the surface would otherwise hit that same surface again ("shadow acne").
    ok, rec := hit(world, ray, Interval.{0.001, FLOAT32_INFINITY});
    if ok {
        did_scatter, attenuation, scattered := scatter(rec.material, ray, rec);
        if did_scatter  return attenuation * ray_color(scattered, depth - 1, world);
        return .{0, 0, 0};
    }

    unit_direction := unit_vector(ray.direction);
    a := 0.5 * (unit_direction.y + 1.0);
    return (1.0 - a) * Vector3.{1, 1, 1} + a * Vector3.{0.5, 0.7, 1.0};
}
