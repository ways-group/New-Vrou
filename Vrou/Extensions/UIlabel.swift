//
//  UIlabel.swift
//  Vrou
//
//  Created by Mac on 1/2/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation
import UIKit

class SelectableLabel: UILabel {

override func awakeFromNib() {
    super.awakeFromNib()

    isUserInteractionEnabled = true
    addGestureRecognizer(
        UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
    )
}

override var canBecomeFirstResponder: Bool {
    return true
}

override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return action == #selector(copy(_:))
}

// MARK: - UIResponderStandardEditActions

override func copy(_ sender: Any?) {
    UIPasteboard.general.string = text
}

// MARK: - Long-press Handler

@objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
    if recognizer.state == .began,
        let recognizerView = recognizer.view,
        let recognizerSuperview = recognizerView.superview {
        UIMenuController.shared.setTargetRect(recognizerView.frame, in: recognizerSuperview)
        UIMenuController.shared.setMenuVisible(true, animated:true)
        recognizerView.becomeFirstResponder()
    }
}
}
