import Foundation

/// Utility helpers shared across days.
public enum Utils {
    /// Measure execution time of a block and return its result with elapsed milliseconds.
    @inlinable
    public static func measure<T>(_ label: String, _ block: () -> T) -> (T, Double) {
        let start = CFAbsoluteTimeGetCurrent()
        let value = block()
        let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
        return (value, elapsedMs)
    }
}