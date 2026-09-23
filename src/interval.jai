Interval :: struct {
    min : float =  FLOAT32_INFINITY;  // Default interval is empty
    max : float = -FLOAT32_INFINITY;
}

EMPTY\  _INTERVAL :: Interval.{ FLOAT32_INFINITY, -FLOAT32_INFINITY};
UNIVERSE_INTERVAL :: Interval.{-FLOAT32_INFINITY,  FLOAT32_INFINITY};

size :: (interval : Interval) -> float {
    return interval.max - interval.min;
}

contains :: (interval : Interval, x : float) -> bool {
    return interval.min <= x && x <= interval.max;
}

surrounds :: (interval : Interval, x : float) -> bool {
    return interval.min < x && x < interval.max;
}

clamp :: (interval : Interval, x : float) -> float {
    if x < interval.min  return interval.min;
    if x > interval.max  return interval.max;
    return x;
}
