//
//  SYTableViewProtocal.swift
//  SYScrollView
//
//  Created by bsy on 2017/9/18.
//  Copyright © 2017年 bsy. All rights reserved.
//

import Foundation
import UIKit

public protocol SYTableViewProtocal { }

public extension SYTableViewProtocal {
    
    private func configIdentifier(_ identifier: inout String) -> String {
        var index = identifier.firstIndex(of: ".")
        guard index != nil else { return identifier }
        index = identifier.index(index!, offsetBy: 1)
        identifier = String(identifier[index! ..< identifier.endIndex])
        return identifier
    }
    
    func registerCell(_ tableView: UITableView, _ cellCls: AnyClass) {
        var identifier = NSStringFromClass(cellCls)
        identifier = configIdentifier(&identifier)
        tableView.register(cellCls, forCellReuseIdentifier: identifier)
    }
    
    func cellWithTableView<T: UITableViewCell>(_ tableView: UITableView) -> T {
        var identifier = NSStringFromClass(T.self)
        identifier = configIdentifier(&identifier)
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        return cell as! T
    }
    
    func tableViewConfig(_ delegate: UITableViewDelegate, _ dataSource: UITableViewDataSource, _ style: UITableView.Style?) -> UITableView  {
        let tableView = UITableView(frame:  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: style ?? .plain)
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        return tableView
    }
    
    func tableViewConfig(_ frame: CGRect ,_ delegate: UITableViewDelegate, _ dataSource: UITableViewDataSource, _ style: UITableView.Style?) -> UITableView  {
        let tableView = UITableView(frame: frame, style: style ?? .plain)
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        return tableView
    }
}
