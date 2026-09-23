Hit_Record :: struct {
    p          : Vector3;
    normal     : Vector3;   // Always points against the incident ray
    material   : Material;  // Copied from the object that was hit
    t          : float;
    front_face : bool;      // True if the ray hit the outside of the surface
}

//
// NOTE: `outward_normal` is assumed to have unit length.
//
set_face_normal :: (rec : *Hit_Record, ray : Ray, outward_normal : Vector3) {
    rec.front_face = dot(ray.direction, outward_normal) < 0;
    rec.normal = ifx rec.front_face then outward_normal else -outward_normal;
}

// ----------------------------------------------------------------------------: world

//
// No abstract "hittable" base: every shape kind gets its own array here,
// and each one provides an overload of `hit`.
//
World :: struct {
    spheres : [..] Sphere;
}

hit :: (world : World, ray : Ray, ray_t : Interval) -> bool, Hit_Record {
    rec : Hit_Record;
    hit_anything   := false;
    closest_so_far := ray_t.max;

    for world.spheres {
        ok, temp := hit(it, ray, Interval.{ray_t.min, closest_so_far});
        if ok {
            hit_anything   = true;
            closest_so_far = temp.t;
            rec            = temp;
        }
    }

    return hit_anything, rec;
}
