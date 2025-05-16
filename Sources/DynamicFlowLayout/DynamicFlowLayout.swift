// Sources/DynamicFlowLayout/FlowLayout.swift

import SwiftUI

public struct FlowLayout: Layout {
    public var maxRows: Int?
    public var horizontalSpacing: CGFloat
    public var verticalSpacing: CGFloat


    public init(maxRows: Int? = nil, horizontalSpacing: CGFloat = 0, verticalSpacing: CGFloat = 0) {
        self.maxRows = maxRows
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }
        let rowHeight = subSizes.lazy.map(\.height).max() ?? 0
        let proposedWidth = proposal.width ?? .infinity

        var position = CGPoint.zero
        var currentRow = 0

        for (index, subSize) in subSizes.enumerated() {
            let lineBreakAllowed = position.x > 0
            let spacingX = (lineBreakAllowed ? horizontalSpacing : 0)

            if lineBreakAllowed, position.x + spacingX + subSize.width > proposedWidth {
                currentRow += 1
                if let maxRows, currentRow >= maxRows {
                    break
                }
                position.x = 0
                position.y += rowHeight + verticalSpacing
            }

            if let maxRows, currentRow >= maxRows {
                break
            }

            position.x += (index > 0 ? horizontalSpacing : 0) + subSize.width
        }

        return CGSize(
            width: proposedWidth.isFinite ? proposedWidth : position.x,
            height: CGFloat(currentRow + 1) * rowHeight + CGFloat(currentRow) * verticalSpacing
        )
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }
        let rowHeight = subSizes.lazy.map(\.height).max() ?? 0
        let proposedWidth = proposal.width ?? .infinity

        var position = CGPoint.zero
        var currentRow = 0
        var exceededMaxRows = false

        for (index, (subview, subSize)) in zip(subviews, subSizes).enumerated() {
            let lineBreakAllowed = position.x > 0
            let spacingX = (lineBreakAllowed ? horizontalSpacing : 0)

            if lineBreakAllowed, position.x + spacingX + subSize.width > proposedWidth {
                currentRow += 1
                position.x = 0
                position.y += rowHeight + verticalSpacing
            }

            if let maxRows, currentRow >= maxRows {
                exceededMaxRows = true
            }

            if exceededMaxRows {
                subview.place(
                    at: CGPoint(x: -5000, y: -5000), // for the uncommon case that style modifiers are still rendered at (0,0)
                    proposal: ProposedViewSize(width: 0, height: 0)
                )
            } else {
                subview.place(
                    at: CGPoint(
                        x: bounds.origin.x + position.x,
                        y: bounds.origin.y + position.y + 0.5 * (rowHeight - subSize.height)
                    ),
                    proposal: proposal
                )
                position.x += (index > 0 ? horizontalSpacing : 0) + subSize.width
            }
        }
    }
}
