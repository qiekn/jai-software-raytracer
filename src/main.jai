main :: () {
    world : World;
    array_add(*world.spheres, Sphere.{center = .{0,      0, -1}, radius = 0.5});
    array_add(*world.spheres, Sphere.{center = .{0, -100.5, -1}, radius = 100});

    render(world);
}

#import "Basic";
#import "Math";
#import "stb_image_write";

#load "utils.jai";
#load "interval.jai";
#load "ray.jai";
#load "hittable.jai";
#load "sphere.jai";
#load "camera.jai";
