//
// One flat struct for every material instead of a class hierarchy:
// `kind` picks the behavior in `scatter`, and each kind only reads the fields it cares about.
//
Material_Kind :: enum u8 {
    LAMBERTIAN;
    METAL;
    DIELECTRIC;
}

Material :: struct {
    kind             : Material_Kind;
    albedo           : Vector3;  // Fraction of light kept per bounce, per color channel
    fuzz             : float;    // METAL: 0 is a perfect mirror, 1 is very blurry

    // DIELECTRIC: refractive index in vacuum or air, or the ratio of the material's
    // refractive index over the refractive index of the enclosing media.
    refraction_index : float;
}

lambertian :: (albedo : Vector3) -> Material {
    return .{kind = .LAMBERTIAN, albedo = albedo};
}

metal :: (albedo : Vector3, fuzz : float) -> Material {
    return .{kind = .METAL, albedo = albedo, fuzz = min(fuzz, 1)};
}

dielectric :: (refraction_index : float) -> Material {
    return .{kind = .DIELECTRIC, refraction_index = refraction_index};
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

      case .DIELECTRIC;
        // Entering the surface goes from 1 to refraction_index; leaving goes back.
        ri := ifx rec.front_face then 1.0 / material.refraction_index else material.refraction_index;

        unit_direction := unit_vector(ray_in.direction);
        cos_theta := min(dot(-unit_direction, rec.normal), 1.0);
        sin_theta := sqrt(1.0 - cos_theta*cos_theta);

        // Snell's law has no solution: total internal reflection.
        cannot_refract := ri * sin_theta > 1.0;

        // Otherwise pick reflection with the probability given by Schlick's approximation,
        // so on average the split between reflected and refracted light is right.
        must_reflect := cannot_refract || reflectance(cos_theta, ri) > random_get_zero_to_one_open();
        bent := ifx must_reflect then reflect(unit_direction, rec.normal)
                                 else refract(unit_direction, rec.normal, ri);

        return true, .{1, 1, 1}, .{rec.p, bent};  // Glass absorbs nothing
    }

    return false, .{}, .{};
}

//
// Schlick's approximation for how much light a dielectric reflects at this angle.
//
reflectance :: (cosine : float, refraction_index : float) -> float {
    r0 := (1 - refraction_index) / (1 + refraction_index);
    r0  = r0 * r0;
    x  := 1 - cosine;
    return r0 + (1 - r0) * x*x*x*x*x;
}
