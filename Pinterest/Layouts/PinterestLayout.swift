//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by Corwin Crownover on 5/12/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//


/*
 Your layout subclass must implement the following methods:
 
 collectionViewContentSize:
 This method returns the width and height of the collection view’s contents. You must override it. Then return the height and width of the entire collection view’s content — not just the visible content. The collection view uses this information internally to configure its scroll view’s content size.
 
 prepare():
 This method is called whenever a layout operation is about to take place. It’s your opportunity to prepare and perform any calculations required to determine the collection view’s size and the positions of the items.
 
 layoutAttributesForElements(in:):
 In this method you need to return the layout attributes for all the items inside the given rectangle. You return the attributes to the collection view as an array of UICollectionViewLayoutAttributes.
 
 layoutAttributesForItem(at:):
 This method provides on demand layout information to the collection view. You need to override it and return the layout attributes for the item at the requested indexPath.
*/


import UIKit


/*
This code declares the PinterestLayoutDelegate protocol, which has a method to request the height of the photo. You’ll implement this protocol in PhotoStreamViewController shortly.
*/
protocol PinterestLayoutDelegate: class {
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
  /* Calculate Layout Attributes */
  // 1
  /* This keeps a reference to the delegate. */
  weak var delegate: PinterestLayoutDelegate!
  
  // 2
  /* These are two properties for configuring the layout: the number of columns and the cell padding. */
  fileprivate var numberOfColumns = 2
  fileprivate var cellPadding: CGFloat = 6
  
  // 3
  /*
  This is an array to cache the calculated attributes. When you call prepare(), you’ll calculate the attributes for all items and add them to the cache. When the collection view later requests the layout attributes, you can be efficient and query the cache instead of recalculating them every time.
  */
  fileprivate var cache = [UICollectionViewLayoutAttributes]()
  
  // 4
  /*
  This declares two properties to store the content size. contentHeight is incremented as photos are added, and contentWidth is calculated based on the collection view width and its content inset.
  */
  fileprivate var contentHeight: CGFloat = 0
  
  fileprivate var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }
  
  // 5
  /*
  This overrides the collectionViewContentSize method to return the size of the collection view’s contents. You use both contentWidth and contentHeight from previous steps to calculate the size.
  */
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  
  /* Prepare */
  /*
  Note: As prepare() is called whenever the collection view's layout is invalidated, there are many situations in a typical implementation where you might need to recalculate attributes here. For example, the bounds of the UICollectionView might change - such as when the orientation changes - or items may be added or removed from the collection. These cases are out of scope for this tutorial, but it's important to be aware of them in a non-trivial implementation.
 */
  override func prepare() {
    // 1
    /* You only calculate the layout attributes if cache is empty and the collection view exists. */
    guard cache.isEmpty == true, let collectionView = collectionView else {
      return
    }
    // 2
    /*
    This declares and fills the xOffset array with the x-coordinate for every column based on the column widths. The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since this is the offset of the first item in each column.
    */
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset = [CGFloat]()
    for column in 0 ..< numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth)
    }
    var column = 0
    var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
    
    // 3
    /* This loops through all the items in the first section, as this particular layout has only one section. */
    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
      
      let indexPath = IndexPath(item: item, section: 0)
      
      // 4
      /*
      This is where you perform the frame calculation. width is the previously calculated cellWidth, with the padding between cells removed. You ask the delegate for the height of the photo and calculate the frame height based on this height and the predefined cellPadding for the top and bottom. You then combine this with the x and y offsets of the current column to create the insetFrame used by the attribute.
      */
      let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
      let height = cellPadding * 2 + photoHeight
      let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      
      // 5
      /* This creates an instance of UICollectionViewLayoutAttribute, sets its frame using insetFrame and appends the attributes to cache. */
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
      
      // 6
      /*
      This expands contentHeight to account for the frame of the newly calculated item. It then advances the yOffset for the current column based on the frame. Finally, it advances the column so that the next item will be placed in the next column.
      */
      contentHeight = max(contentHeight, frame.maxY)
      yOffset[column] = yOffset[column] + height
      
      column = column < (numberOfColumns - 1) ? (column + 1) : 0
    }
  }
  
  
  /* Determine which items are visible in the given rect*/
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  
  /* Retrieve and return from cache the layout attributes which correspond to the requested indexPath */
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
  
}
