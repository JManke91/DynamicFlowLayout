# DynamicFlowLayout

A lightweight and configurable SwiftUI `Layout` that flows views horizontally and wraps them across multiple lines, with optional row limits.

## Usage

```swift
import DynamicFlowLayout

FlowLayout(maxRows: 2) {
    ForEach(0..<20) { i in
        Text("Item \(i)")
            .padding(8)
            .background(Color.blue)
            .cornerRadius(8)
    }
}
