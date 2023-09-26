//
//  UITableView+Extension.swift
//  Nucleus
//
//  Created by Mikhail Sein on 24.05.2021.
//

import UIKit

extension UITableView {
    
    /// Registers a classes for use in creating new table cells
    ///
    /// Method uses default identifiers based on class type
    /// # Example
    /// This line
    /// ```
    /// register(CellA.self, CellB.self)
    /// ```
    /// is equal
    /// ```
    /// register(CellA.self, forCellWithReuseIdentifier: "CellA")
    /// register(CellB.self, forCellWithReuseIdentifier: "CellB")
    /// ```
    /// - Parameter classes: Zero or more class types to register.
    func register(_ classes: UITableViewCell.Type...) {
        classes.forEach {
            register($0, forCellReuseIdentifier: String(describing: $0))
        }
    }
    
    /// Dequeues a reusable cell object located by its *class type* identifier.
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: A reusable cell object downcasted to given type
    /// # Example
    /// ```
    /// let cell: MyCellType = tableView.dequeueReusableCell(for: indexPath)
    /// ```
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
        // swiftlint:enable force_cast
    }
}
