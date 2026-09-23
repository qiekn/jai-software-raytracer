#import "Basic";
#import "Math";
#import "stb_image_write";

#load "utils.jai";
#load "ray.jai";
#load "camera.jai";

main :: () {
    init_camera();
    render();
}

hit_sphere :: (center : Vector3, radius : float, ray: Ray) -> float {
    oc := center - ray.origin;
    a := dot(ray.direction, ray.direction);
    b := -2.0 * dot(ray.direction, oc);
    c := dot(oc, oc) - radius * radius;
    discriminant := b*b - 4*a*c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-b - sqrt(discriminant)) / (2.0 * a); // t
    }
}

ray_color :: (ray : Ray) -> Vector3 {
    t := hit_sphere(.{0,0,-1}, 0.5, ray);
    if (t > 0) {
        normal := unit_vector(ray_at(ray, t) - .{0, 0, -1});
        return 0.5 * (normal + 1.0); // [-1, 1] -> [0, 1]
    }

    unit_direction := unit_vector(ray.direction);
    a := 0.5 * (unit_direction.y + 1.0);
    return (1.0 - a) * Vector3.{1, 1, 1} + a * Vector3.{0.5, 0.7, 1.0};
}
