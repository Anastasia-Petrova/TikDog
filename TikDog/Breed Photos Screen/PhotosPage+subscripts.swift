//
//  Page+subscripts.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Foundation

extension PhotosPage {
    subscript(indexPath: IndexPath) -> Item? {
        get {
            let rowIndex = indexPath.row
            switch indexPath.section {
            case 0:
                return topSection[rowIndex]
            case 1:
                return middleSection?[rowIndex]
            case 2:
                return bottomSection?[rowIndex]
            default:
                fatalError("Index out of range")
            }
        }
        set {
            let rowIndex = indexPath.row
            
            switch indexPath.section {
            case 0:
                if let newValue = newValue {
                    topSection[rowIndex] = newValue
                }
            case 1:
                middleSection?[rowIndex] = newValue
            case 2:
                bottomSection?[rowIndex] = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
}

extension PhotosPage.Section.Top {
    subscript(index: Int) -> Item {
        get {
            switch index {
            case 0:
                return item
            default:
                fatalError("Index out of range")
            }
        }
        set {
            switch index {
            case 0:
                item = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
}

extension PhotosPage.Section.Middle {
    subscript(index: Int) -> Item? {
        get {
            switch index {
            case 0:
                return leadingColumn.top
            case 1:
                return leadingColumn.bottom
            case 2:
                return centralColumn?.top
            case 3:
                return centralColumn?.bottom
            case 4:
                return trailingColumn?.top
            case 5:
                return trailingColumn?.bottom
            default:
                fatalError("Index out of range")
            }
        }
        set {
            switch index {
            case 0:
                if let newValue = newValue {
                    leadingColumn.top = newValue
                }
            case 1:
                leadingColumn.bottom = newValue
            case 2:
                if let newValue = newValue {
                    centralColumn?.top = newValue
                }
            case 3:
                centralColumn?.bottom = newValue
            case 4:
                if let newValue = newValue {
                    trailingColumn?.top = newValue
                }
            case 5:
                trailingColumn?.bottom = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
}

extension PhotosPage.Section.Bottom {
    subscript(index: Int) -> Item? {
        get {
            switch index {
            case 0:
                return leadingItem
            case 1:
                return trailingColumn?.top
            case 2:
                return trailingColumn?.bottom
            default:
                fatalError("Index out of range")
            }
        }
        set {
            switch index {
            case 0:
                if let newValue = newValue {
                    leadingItem = newValue
                }
            case 1:
                if let newValue = newValue {
                    trailingColumn?.top = newValue
                }
            case 2:
                trailingColumn?.bottom = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
}
