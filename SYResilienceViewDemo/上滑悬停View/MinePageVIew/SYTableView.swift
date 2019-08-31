//
//  SYTableView.swift
//  SYScrollView
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import UIKit


class SYTableView: UITableView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}
