import CoreGraphics
import Testing
@testable import KLCharts

@Suite
struct ChartGeometryTests {
    @Test
    func `preserves readable width for every group`() {
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: 480,
                groupCount: 6,
                minimumGroupWidth: 144
            ) == 864
        )
    }

    @Test
    func `avoids scrolling when the chart already fits`() {
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: 480,
                groupCount: 2,
                minimumGroupWidth: 144
            ) == 480
        )
    }

    @Test(arguments: [0, -3])
    func `treats a group count below one as one`(groupCount: Int) {
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: 120,
                groupCount: groupCount,
                minimumGroupWidth: 80
            ) == 120
        )
    }

    @Test
    func `passes negative widths through the documented formula`() {
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: -100,
                groupCount: 0,
                minimumGroupWidth: -20
            ) == -20
        )
    }

    @Test
    func `preserves the documented nonfinite width behavior`() {
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: .nan,
                groupCount: 2,
                minimumGroupWidth: 40
            ).isNaN
        )
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: 120,
                groupCount: 2,
                minimumGroupWidth: .nan
            ) == 120
        )
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: 120,
                groupCount: 2,
                minimumGroupWidth: .infinity
            ) == .infinity
        )
        #expect(
            KLFlatBarChartLayout.chartWidth(
                availableWidth: 120,
                groupCount: 2,
                minimumGroupWidth: -.infinity
            ) == 120
        )
    }

    @Test(arguments: [
        (distance: CGFloat(12), radius: CGFloat(24), expected: true),
        (distance: CGFloat(24), radius: CGFloat(24), expected: true),
        (distance: CGFloat(25), radius: CGFloat(24), expected: false),
        (distance: CGFloat.nan, radius: CGFloat(24), expected: false),
        (distance: CGFloat(12), radius: CGFloat.nan, expected: false),
        (distance: CGFloat(12), radius: CGFloat(-1), expected: false),
        (distance: CGFloat(-1), radius: CGFloat(0), expected: true),
        (distance: CGFloat.infinity, radius: CGFloat(24), expected: false),
        (distance: -CGFloat.infinity, radius: CGFloat(24), expected: false),
        (distance: CGFloat(12), radius: CGFloat.infinity, expected: false),
        (distance: CGFloat(12), radius: -CGFloat.infinity, expected: false),
    ])
    func `hit testing rejects invalid and distant taps`(
        argument: (distance: CGFloat, radius: CGFloat, expected: Bool)
    ) {
        #expect(
            KLDimensionalHitTesting.acceptsTap(
                distance: argument.distance,
                hitRadius: argument.radius
            ) == argument.expected
        )
    }
}
