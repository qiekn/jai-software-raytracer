//
// One flat struct for every material instead of a class hierarchy:
// `kind` picks the behavior in `scatter`, and each kind only reads the fields it cares about.
//
Material_Kind :: enum u8 {
    LAMBERTIAN;
    METAL;
}

Material :: struct {
    kind   : Material_Kind;
    albedo : Vector3;  // Fraction of light kept per bounce, per color channel
    fuzz   : float;    // METAL: 0 is a perfect mirror, 1 is very blurry
}

lambertian :: (albedo : Vector3) -> Material {
    return .{kind = .LAMBERTIAN, albedo = albedo};
}

metal :: (albedo : Vector3, fuzz : float) -> Material {
    return .{kind = .METAL, albedo = albedo, fuzz = min(fuzz, 1)};
}

//
// Returns whether the ray was scattered (false means absorbed),
// how much it is attenuated, and the scattered ray.
//
scatter :: (material : Material, ray_in : Ray, rec : Hit_Record) -> bool, Vector3, Ray {
    if #complete material.kind == {
      case .LAMBERTIAN;
        direction := rec.normal + random_unit_vector();

        // Catch degenerate scatter direction: the random vector was almost exactly -normal.
        if near_zero(direction)  direction = rec.normal;

        return true, material.albedo, .{rec.p, direction};

      case .METAL;
        reflected := reflect(ray_in.direction, rec.normal);
        reflected  = unit_vector(reflected) + material.fuzz * random_unit_vector();

        // Fuzz can push the ray below the surface; the surface absorbs those.
        return dot(reflected, rec.normal) > 0, material.albedo, .{rec.p, reflected};
    }

    return false, .{}, .{};
}
