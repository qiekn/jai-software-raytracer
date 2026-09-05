#import "Basic";
#import "stb_image_write";
#load "utils.jai";

WIDTH  :: 512;
HEIGHT :: 512;

main :: () {
    pixels := NewArray(WIDTH * HEIGHT * 3, u8);

    for y : 0..HEIGHT-1 {
        for x : 0..WIDTH-1 {
            index := (y * WIDTH + x) * 3;

            r := cast(u8)(x * 255 / (WIDTH  - 1));
            g := cast(u8)(y * 255 / (HEIGHT - 1));
            b := cast(u8)((x + y) * 255 / (WIDTH + HEIGHT - 2));

            pixels[index + 0] = r;
            pixels[index + 1] = g;
            pixels[index + 2] = b;
        }
    }

    filename := make_filename();
    stbi_write_png(filename.data, WIDTH, HEIGHT, 3, pixels.data, WIDTH * 3);
}
