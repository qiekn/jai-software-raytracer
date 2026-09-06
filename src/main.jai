#import "Basic";
#import "Math";
#import "stb_image_write";

#load "utils.jai";
#load "ray.jai";

WIDTH  :: 512;
HEIGHT :: 512;

main :: () {
    aspect_ratio := 4.0 / 3.0;
    image_width  : s32 = 400;
    image_height : s32 = xx (image_width / aspect_ratio);

    // Camera
    focal_length   := 1.0;
    viewport_height := 2.0;
    viewport_width  := viewport_height * (cast(float)image_width / image_height); // aspect_ratio is the ideal ratio not real, so we don't use it.

    camera_center := Vector3.{0, 0, 0};

    // Viewport horizontal/vertical edge vectors.
    viewport_u := Vector3.{viewport_width, 0, 0};
    viewport_v := Vector3.{0, -viewport_height, 0};

    // Distance from one pixel center to the next.
    pixel_delta_u := viewport_u / image_width.(float);
    pixel_delta_v := viewport_v / image_height.(float);

    // Upper-left corner of the viewport.
    viewport_upper_left := camera_center - Vector3.{0, 0, focal_length}
                                         - viewport_u / 2.0
                                         - viewport_v / 2.0;

    // Center of pixel (0, 0).
    pixel00_loc := viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);

    pixels := NewArray(image_width * image_height * 3, u8);
    color : Pixel_Color;

    for y : 0..image_height-1 {
        print("\rScanlines remaining: %    ", image_height - y);
        for x : 0..image_width-1 {
            index := (y * image_width + x) * 3;
            pixel_center := pixel00_loc + x.(float) * pixel_delta_u + y.(float) * pixel_delta_v;

            ray : Ray;
            ray.direction = pixel_center - camera_center;
            ray.origin = camera_center;

            color := ray_color();

            write_color(pixels, index, color);
        }
    }
    print("\rDone.                     \n");

    filename := make_filename();
    stbi_write_png(filename.data, image_width, image_height, 3, pixels.data, image_width * 3);
}

ray_color :: () -> Vector3 #expand {
    unit_direction := unit_vector(`ray.direction);
    a := 0.5 * (unit_direction.y + 1.0);
    return (1.0 - a) * Vector3.{1, 1, 1} + a * Vector3.{0.5, 0.7, 1.0};
}
