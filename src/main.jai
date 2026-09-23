main :: () {
    material_ground := lambertian(.{0.8, 0.8, 0.0});
    material_center := lambertian(.{0.1, 0.2, 0.5});
    material_left   := dielectric(1.50);
    material_bubble := dielectric(1.00 / 1.50);  // Air inside glass: hollow glass sphere
    material_right  := metal(.{0.8, 0.6, 0.2}, 1.0);

    world : World;
    array_add(*world.spheres, Sphere.{.{ 0.0, -100.5, -1.0}, 100.0, material_ground});
    array_add(*world.spheres, Sphere.{.{ 0.0,    0.0, -1.2},   0.5, material_center});
    array_add(*world.spheres, Sphere.{.{-1.0,    0.0, -1.0},   0.5, material_left});
    array_add(*world.spheres, Sphere.{.{-1.0,    0.0, -1.0},   0.4, material_bubble});
    array_add(*world.spheres, Sphere.{.{ 1.0,    0.0, -1.0},   0.5, material_right});

    samples_per_pixel = 100;
    max_depth         = 50;

    vfov      = 90;
    look_from = .{-2, 2,  1};
    look_at   = .{ 0, 0, -1};
    vup       = .{ 0, 1,  0};

    render(world);
}

#import "Basic";
#import "Math";
#import "Random";
#import "stb_image_write";

#load "utils.jai";
#load "interval.jai";
#load "ray.jai";
#load "hittable.jai";
#load "sphere.jai";
#load "material.jai";
#load "camera.jai";
