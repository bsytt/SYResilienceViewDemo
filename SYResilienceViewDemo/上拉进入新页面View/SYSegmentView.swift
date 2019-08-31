//
//  SYSegmentView.swift
//  DatianDigitalAgriculture
//
//  Created by bsoshy on 2019/7/30.
//  Copyright © 2019 qiaoxy. All rights reserved.
//

import UIKit
typealias SYSegmentViewBlock = (Int)->()
class SYSegmentView: UIView {

    var titles = [String]()
    var segmentViewBlock : SYSegmentViewBlock!
    
    var selectIndex : Int?{
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    init(frame: CGRect,titles:[String],segmentViewBlock:@escaping (Int)->()) {
        super.init(frame: frame)
        self.titles.append(contentsOf: titles)
        initSubview()
        self.segmentViewBlock = segmentViewBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubview() {
        self.addSubview(self.collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        collectionView.register(UINib(nibName: "SYSegmentCell", bundle: nil), forCellWithReuseIdentifier: "SYSegmentCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (self.frame.width-2)/2, height: 40)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collection
    }()
}
extension SYSegmentView:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SYSegmentCell", for: indexPath) as! SYSegmentCell
        cell.titleLab.text = titles[indexPath.item]
        if selectIndex == indexPath.item {
            cell.titleLab.textColor = .blue
            cell.lineView.isHidden = false
        }else {
            cell.titleLab.textColor = .gray
            cell.lineView.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         self.segmentViewBlock?(indexPath.item)
    }
    
}
