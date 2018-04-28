//
//  HorizontalScrollerView.swift
//  RWBlueLibrary
//
//  Created by GLB-312-PC on 26/04/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

protocol HorizontalScrollerViewDataSource: class {
  func numberofViews(in horizontalScrollView: HorizontalScrollerView) ->Int
  func horizontalScrollView(_ horizontalScrollView: HorizontalScrollerView,viewAt index: Int)->UIView
}
protocol HorozontalScrollViewDelegate: class{
  
  func horizontalScrollView(_ horizontalScrollView: HorizontalScrollerView,didselectViewAt index: Int)
}

class HorizontalScrollerView: UIView {
  weak var dataSource : HorizontalScrollerViewDataSource?
  weak var delegate : HorozontalScrollViewDelegate?
  
  private enum ViewConstants {
    static let  Padding: CGFloat = 10
    static let Dimentions: CGFloat = 100
    static let Offset : CGFloat = 100
    
  }

  private let scroller = UIScrollView()
  private var contentViews = [UIView]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollview()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollview()
  }
  
  func initializeScrollview() {
    scroller.delegate = self
    addSubview(scroller)
    scroller.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: self.topAnchor),
      scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])
    
    let tapRecognizer  = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gestures:)))
    scroller.addGestureRecognizer(tapRecognizer)
  }
  
  
  @objc func scrollerTapped(gestures:UITapGestureRecognizer){
    let location = gestures.location(in: scroller)
    guard let index =  contentViews.index(where: {$0.frame.contains(location)})
      else { return  }
    delegate?.horizontalScrollView(self, didselectViewAt: index)
    scollToView(at: index)
    
  }
  
  func scollToView(at index: Int,animated: Bool = true){
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width/2)
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y :0), animated: animated)
    
  }
  func view(at index: Int)->UIView {
    return contentViews[index]
    
  }
  
  func reload() {
    guard let dataSource =  dataSource else
    { return  }
    //removing old content views
    contentViews.forEach {$0.removeFromSuperview()}
    var xValue = ViewConstants.Offset
    contentViews = (0..<dataSource.numberofViews(in: self)).map{
      index in
      xValue += ViewConstants.Padding
      let view = dataSource.horizontalScrollView(self, viewAt: index)
      view.frame = CGRect(x: CGFloat(xValue), y: ViewConstants.Padding, width: ViewConstants.Dimentions, height: ViewConstants.Dimentions)
      scroller.addSubview(view)
      xValue += ViewConstants.Dimentions + ViewConstants.Padding
      return view
    }
    scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
  }
  private func centerCurrentView(){
    let centerRect = CGRect(origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding,y:0), size: CGSize(width: ViewConstants.Padding, height: bounds.height))
    guard let selectedIndex  =  contentViews.index(where: {
      $0.frame.intersects(centerRect)
    })
      else { return  }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetoffsetX = targetCenter.x - (scroller.bounds.width / 2)
    scroller.setContentOffset(CGPoint(x:targetoffsetX,y:0), animated: true)
    delegate?.horizontalScrollView(self, didselectViewAt: selectedIndex)
  }
  
}
extension HorizontalScrollerView:UIScrollViewDelegate{
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate{
      centerCurrentView()
    }
  }
  
}
