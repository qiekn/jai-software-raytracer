#import "Basic";
#import "Math";
#import "stb_image_write";
#load "utils.jai";

WIDTH  :: 512;
HEIGHT :: 512;

main :: () {
    pixels := NewArray(WIDTH * HEIGHT * 3, u8);
    color : Pixel_Color;

    for y : 0..HEIGHT-1 {
        print("\rScanlines remaining: %    ", HEIGHT - y);
        for x : 0..WIDTH-1 {
            index := (y * WIDTH + x) * 3;

            color.x = cast(u8)(x * 255.0 / (WIDTH  - 1));
            color.y = cast(u8)(y * 255.0 / (HEIGHT - 1));

            write_color(pixels, index, color);
        }
    }
    print("\rDone.                     \n");

    filename := make_filename();
    stbi_write_png(filename.data, WIDTH, HEIGHT, 3, pixels.data, WIDTH * 3);
}
