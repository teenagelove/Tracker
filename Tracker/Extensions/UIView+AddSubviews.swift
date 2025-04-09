//
//  UIView+AddSubviews.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
}
