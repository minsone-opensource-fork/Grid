//
//  GridLayoutMath.swift
//  GridLayout
//
//  Created by Denis Obukhov on 16.04.2020.
//  Copyright © 2020 Denis Obukhov. All rights reserved.
//

import Foundation

/// User defined
struct GridItem {
    var tag: String?
    var rowSpan = 1
    var columnSpan = 1
}

struct GridPosition: Equatable {
    var row: Int
    var column: Int
}

/// Result position of item
struct ArrangedItem {
    let gridItem: GridItem
    let startPosition: GridPosition
    let endPosition: GridPosition
    
    func contains(_ position: GridPosition) -> Bool {
        return position.column >= startPosition.column
            && position.column <= endPosition.column
            && position.row >= startPosition.row
            && position.row <= endPosition.row
    }
    
    var area: Int {
        return (startPosition.row - endPosition.row + 1) * (startPosition.column - endPosition.column + 1)
    }
}

struct LayoutArrangement {
    let columnsCount: Int
    var items: [ArrangedItem]
}

extension LayoutArrangement: CustomStringConvertible {
    var description: String {
        var iterations = 0
        var result = ""
        let maxRow = self.items.map(\.endPosition.row).max(by: <) ?? 0
        
        var items = self.items.map { (arrangement: $0, square: $0.area) }

        for row in 0...maxRow {
            columnsCycle: for column in 0..<self.columnsCount {
                for (index, item) in items.enumerated() {
                    iterations += 1
                    if item.arrangement.contains(GridPosition(row: row, column: column)) {
                        result += item.arrangement.gridItem.tag ?? "-"
                        items[index].square -= 1
                        if items[index].square == 0 {
                            items.remove(at: index)
                        }
                        continue columnsCycle
                    }
                }
                result += "."
            }
            result += "\n"
        }
        
        return result
    }
}

extension Array where Element == GridPosition {
    func contains(_ startPosition: GridPosition, rowSpan: Int, columnSpan: Int) -> Bool {
        for row in startPosition.row..<startPosition.row + rowSpan {
            for column in startPosition.column..<startPosition.column + columnSpan {
                if self.contains(GridPosition(row: row, column: column)) {
                    return true
                }
            }
        }
        return false
    }
}

extension GridPosition {
    fileprivate func nextPosition(columnsCount: Int) -> GridPosition {
        var column = self.column
        var row = self.row
        
        column += 1
        if column >= columnsCount {
            column = 0
            row += 1
        }
        
        return GridPosition(row: row, column: column)
    }
}

class LayoutArranger {
    
    func arrange(items: [GridItem], columnsCount: Int) -> LayoutArrangement {
        guard columnsCount > 0 else { return LayoutArrangement(columnsCount: columnsCount, items: []) }
            
        var result: [ArrangedItem] = []
        var occupiedPositions: [GridPosition] = []
        
        var lastPosition = GridPosition(row: 0, column: 0)
        
        for item in items {
            guard item.columnSpan <= columnsCount else { continue } // TODO: Reduce span
            
            while occupiedPositions.contains(lastPosition, rowSpan: item.rowSpan, columnSpan: item.columnSpan)
                || lastPosition.column + item.columnSpan > columnsCount {
                    lastPosition = lastPosition.nextPosition(columnsCount: columnsCount)
            }

            for row in lastPosition.row..<lastPosition.row + item.rowSpan {
                for column in lastPosition.column..<lastPosition.column + item.columnSpan {
                    occupiedPositions.append(GridPosition(row: row, column: column))
                }
            }
            
            let startPosition = lastPosition
            let endPosition = GridPosition(row: startPosition.row + item.rowSpan - 1,
                                           column: startPosition.column + item.columnSpan - 1)

            result.append(ArrangedItem(gridItem: item, startPosition: startPosition, endPosition: endPosition))
            lastPosition = lastPosition.nextPosition(columnsCount: columnsCount)
            
        }
        return LayoutArrangement(columnsCount: columnsCount, items: result)
    }
}
