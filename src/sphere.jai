Sphere :: struct {
    center : Vector3;
    radius : float;
}

hit :: (using sphere : Sphere, ray : Ray, ray_t : Interval) -> bool, Hit_Record {
    rec : Hit_Record;

    oc := center - ray.origin;
    a  := length_squared(ray.direction);
    h  := dot(ray.direction, oc);  // b = -2h
    c  := length_squared(oc) - radius * radius;

    discriminant := h*h - a*c;
    if discriminant < 0  return false, rec;

    sqrtd := sqrt(discriminant);

    // Find the nearest root that lies in the acceptable range.
    root := (h - sqrtd) / a;
    if !surrounds(ray_t, root) {
        root = (h + sqrtd) / a;
        if !surrounds(ray_t, root)  return false, rec;
    }

    rec.t = root;
    rec.p = ray_at(ray, rec.t);
    outward_normal := (rec.p - center) / radius;
    set_face_normal(*rec, ray, outward_normal);

    return true, rec;
}
