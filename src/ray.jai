Ray :: struct {
    origin:    Vector3;
    direction:= Vector3.{0,0,-1};
}

ray_at :: (ray : Ray, t : float) -> Vector3 {
    return ray.origin + t * ray.direction;
}
