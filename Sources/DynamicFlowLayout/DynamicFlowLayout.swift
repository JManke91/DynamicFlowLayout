// Sources/DynamicFlowLayout/FlowLayout.swift

import SwiftUI

public struct FlowLayout: Layout {
    public var maxRows: Int?

    public init(maxRows: Int? = nil) {
        self.maxRows = maxRows
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

        for subSize in subSizes {
            let lineBreakAllowed = position.x > 0
            if lineBreakAllowed, position.x + subSize.width > proposedWidth {
                currentRow += 1
                if let maxRows, currentRow >= maxRows {
                    break
                }
                position.x = 0
                position.y += rowHeight
            }

            if let maxRows, currentRow >= maxRows {
                break
            }

            position.x += subSize.width
        }

        return CGSize(
            width: proposedWidth.isFinite ? proposedWidth : position.x,
            height: CGFloat(currentRow + 1) * rowHeight
        )
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let subSizes = subviews.map { $0.sizeThatFits(proposal) }
        let rowHeight = subSizes.lazy.map(\.height).max() ?? 0
        let proposedWidth = proposal.width ?? .infinity

        var position = CGPoint.zero
        var currentRow = 0
        var exceededMaxRows = false

        for (subview, subSize) in zip(subviews, subSizes) {
            let lineBreakAllowed = position.x > 0
            if lineBreakAllowed, position.x + subSize.width > proposedWidth {
                currentRow += 1
                if let maxRows, currentRow >= maxRows {
                    exceededMaxRows = true
                }
                position.x = 0
                position.y += rowHeight
            }

            if let maxRows, currentRow >= maxRows {
                exceededMaxRows = true
            }

            if exceededMaxRows {
                subview.place(
                    at: .zero,
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
                position.x += subSize.width
            }
        }
    }
}
