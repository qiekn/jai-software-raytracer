main :: () {
    world := cover_scene();
    image_width = 400; samples_per_pixel = 10;  // TEMP preview, remove
    render(world);
}

//
// Each scene builds its world and sets the camera parameters it wants.
//

//
// The cover of the book: a field of small random spheres around three big ones.
//
cover_scene :: () -> World {
    world : World;

    array_add(*world.spheres, Sphere.{.{0, -1000, 0}, 1000, lambertian(.{0.5, 0.5, 0.5})});

    for a : -11..10 {
        for b : -11..10 {
            choose_mat := random_get_zero_to_one_open();
            center := Vector3.{a.(float) + 0.9 * random_get_zero_to_one_open(), 0.2, b.(float) + 0.9 * random_get_zero_to_one_open()};

            // Keep clear of the big metal sphere.
            if length(center - Vector3.{4, 0.2, 0}) <= 0.9  continue;

            material : Material;
            if choose_mat < 0.8 {
                material = lambertian(random_vector3() * random_vector3());                 // Diffuse
            } else if choose_mat < 0.95 {
                material = metal(random_vector3(0.5, 1), random_get_within_range(0, 0.5));  // Metal
            } else {
                material = dielectric(1.5);                                                 // Glass
            }

            array_add(*world.spheres, Sphere.{center, 0.2, material});
        }
    }

    array_add(*world.spheres, Sphere.{.{ 0, 1, 0}, 1.0, dielectric(1.5)});
    array_add(*world.spheres, Sphere.{.{-4, 1, 0}, 1.0, lambertian(.{0.4, 0.2, 0.1})});
    array_add(*world.spheres, Sphere.{.{ 4, 1, 0}, 1.0, metal(.{0.7, 0.6, 0.5}, 0.0)});

    aspect_ratio      = 16.0 / 9.0;
    image_width       = 1200;
    samples_per_pixel = 500;
    max_depth         = 50;

    vfov      = 20;
    look_from = .{13, 2, 3};
    look_at   = .{ 0, 0, 0};
    vup       = .{ 0, 1, 0};

    defocus_angle = 0.6;
    focus_dist    = 10.0;

    return world;
}

//
// The scene used through chapters 10-13: ground, blue diffuse, hollow glass, gold metal.
//
three_spheres_scene :: () -> World {
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

    defocus_angle = 10.0;
    focus_dist    = 3.4;

    return world;
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
