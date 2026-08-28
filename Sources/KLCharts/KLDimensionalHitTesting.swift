import Foundation

/// Deterministic radius checks used by dimensional chart hit testing.
///
/// The helper performs no geometric normalization. In particular, a negative
/// `distance` is considered within any finite, nonnegative radius because it
/// satisfies the direct `distance <= hitRadius` comparison.
public enum KLDimensionalHitTesting {
    /// Returns whether a distance is within an inclusive hit radius.
    ///
    /// Both arguments must be finite, and `hitRadius` must be nonnegative. A
    /// distance exactly equal to the radius is accepted. Negative finite
    /// distances are accepted when they are less than or equal to the radius.
    /// Any NaN or positive or negative infinity is rejected.
    ///
    /// - Parameters:
    ///   - distance: The distance to compare. The function does not require it
    ///     to be nonnegative.
    ///   - hitRadius: The inclusive radius. Negative and nonfinite values are
    ///     rejected.
    /// - Returns: `true` exactly when both values are finite,
    ///   `hitRadius >= 0`, and `distance <= hitRadius`.
    public static func acceptsTap(
        distance: CGFloat,
        hitRadius: CGFloat
    ) -> Bool {
        distance.isFinite
            && hitRadius.isFinite
            && hitRadius >= 0
            && distance <= hitRadius
    }
}
