//
//  UIFillLayout.swift
//  Demo
//
//  Created by 高炼 on 2017/9/12.
//  Copyright © 2017年 高炼. All rights reserved.
//

import UIKit


fileprivate extension CGRect {
    func fill(_ sizes: [CGSize], interSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) -> [CGRect] {
        // the result rectangles contain all position infomations of the CGSize insert to self.
        var rects = [CGRect]()
        
        // Initial anchor points
        var points: [CGPoint] = [CGPoint(x: -interSpacing, y: -lineSpacing)]
        
        sizes.forEach { (size) in
            let avaliablePoints = points.map({ CGPoint(x: $0.x + interSpacing, y: $0.y + lineSpacing) })
                .filter({ (point) -> Bool in
                    let endPoint = CGPoint(x: point.x + size.width, y: point.y + size.height)
                    return endPoint.x <= maxX && endPoint.y <= maxY
                })
            
            guard let found = avaliablePoints.enumerated().sorted(by: { (left, right) -> Bool in
                return left.element.y < right.element.y || left.element.x < right.element.x || left.offset < right.offset
            }).first else { return }
            
            let rect = CGRect(origin: found.element, size: size)
            rects.append(rect)
            
            let anchor = points[found.offset]
            points.replaceSubrange(found.offset..<(found.offset + 1),
                                   with: [ CGPoint(x: anchor.x, y: anchor.y + size.height + lineSpacing),
                                           CGPoint(x: anchor.x + size.width + interSpacing, y: anchor.y) ])
            
            let boundsPoint = CGPoint(x: rect.maxX, y: rect.maxY)
            points = points.filter { $0.x >= boundsPoint.x || $0.y >= boundsPoint.y }
            points[0].x = -interSpacing
            points[points.count - 1].y = -lineSpacing
        }
        
        return rects.map { CGRect(x: origin.x + $0.origin.x, y: origin.y + $0.origin.y, width: $0.width, height: $0.height) }
    }
}

class UIFillLayout: UICollectionViewLayout {
    fileprivate var attributes: [UICollectionViewLayoutAttributes]?
    
    var itemSize: CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        attributes = nil
    }
    
    var cachedContentSize: CGSize!
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        guard cachedContentSize == nil else { return cachedContentSize }
        
        let sections = collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0
        
        var Y: CGFloat = 0
        
        for section in (0..<sections) {
            if let size = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
                Y += size.height
            }
            
            let sectionInset: UIEdgeInsets = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? .zero
            
            Y += sectionInset.top
            
            let rows = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
            let sizes = (0..<rows).map { IndexPath(row: $0, section: section) }
                .map { (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, sizeForItemAt: $0) ?? itemSize }
            
            let container = CGRect(x: sectionInset.left,
                                   y: Y,
                                   width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - sectionInset.left - sectionInset.right,
                                   height: CGFloat.infinity)
            
            let interSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? 0
            
            let lineSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? 0
            
            var rects = container.fill(sizes, interSpacing: interSpacing, lineSpacing: lineSpacing)
            
            rects.sort(by: { $0.0.maxY > $0.1.maxY })
            
            if let maxY = rects.first?.maxY {
                Y = maxY
            }
            
            Y += sectionInset.bottom
            
            if let size = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
                Y += size.height
            }
        }
        
        cachedContentSize = CGSize(width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right, height: Y)
        return cachedContentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard attributes == nil else { return attributes }
        
        attributes = [UICollectionViewLayoutAttributes]()
        
        let sections = collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0
        
        var Y: CGFloat = 0
        
        for section in (0..<sections) {
            if let size = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
                let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(row: 0, section: section))
                attribute.frame = CGRect(origin: CGPoint(x: 0, y: Y), size: size)
                attributes?.append(attribute)
                
                Y += size.height
            }
            
            let sectionInset: UIEdgeInsets = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? .zero
            
            Y += sectionInset.top
            
            let rows = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
            let sizes = (0..<rows).map { IndexPath(row: $0, section: section) }
                .map { (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, sizeForItemAt: $0) ?? itemSize }
            
            let container = CGRect(x: sectionInset.left,
                                   y: Y,
                                   width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - sectionInset.left - sectionInset.right,
                                   height: CGFloat.infinity)
            
            let interSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? 0
            
            let lineSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? 0
            
            var rects = container.fill(sizes, interSpacing: interSpacing, lineSpacing: lineSpacing)
            
            rects.enumerated().forEach({ (index, rect) in
                let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: index, section: section))
                attribute.frame = rect
                attributes?.append(attribute)
            })
            
            rects.sort(by: { $0.0.maxY > $0.1.maxY })
            
            if let maxY = rects.first?.maxY {
                Y = maxY
            }
            
            Y += sectionInset.bottom
            
            if let size = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
                let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(row: 0, section: section))
                attribute.frame = CGRect(origin: CGPoint(x: 0, y: Y), size: size)
                attributes?.append(attribute)
                
                Y += size.height
            }
        }
        
        return attributes
    }
}






























