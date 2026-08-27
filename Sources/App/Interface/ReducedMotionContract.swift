enum ReducedMotionContract {
    static func duration(reduceMotion: Bool) -> Double { reduceMotion ? 0 : 0.2 }
}
