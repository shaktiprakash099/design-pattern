/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

final class ViewController: UIViewController {
  
  private var curentAlbumIndex = 0;
  private var currenAlbumData:[AlbumData]?
  private var allalbums = [Album]()
  @IBOutlet var tableView: UITableView!
  @IBOutlet var undoBarButtonItem: UIBarButtonItem!
  @IBOutlet var trashBarButtonItem: UIBarButtonItem!
  
    @IBOutlet weak var horizontalScollView: HorizontalScrollerView!
    private enum Constants {
    static let CellIdentifier = "Cell"
      static let IndexRestorationKey = "currentAlbumIndex"
  }
  override func viewDidLoad() {
    super.viewDidLoad()
   allalbums = LiabraryAPI.shared.getAlbums()
    tableView.dataSource = self
    horizontalScollView.dataSource = self;
    horizontalScollView.delegate = self;
    horizontalScollView.reload()
    showDataforAlbum(at: curentAlbumIndex)
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    horizontalScollView.scollToView(at: curentAlbumIndex,animated: false)
  }

  private func showDataforAlbum(at index : Int){
    
    if (index < allalbums.count && index > -1){
      let album = allalbums[index]
      currenAlbumData = album.tablerepresentaions
    }
    else{
      
      currenAlbumData = nil
    }
    
    tableView.reloadData()
  }

}
extension ViewController:UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let  albumdata =  currenAlbumData else { return 0 }
    return albumdata.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
    if let albumdata = currenAlbumData{
      let row = indexPath.row
      cell.textLabel!.text = albumdata[row].title
      cell.detailTextLabel!.text = albumdata[row].value
    }
  
    return cell
  }
  
}
extension ViewController : HorozontalScrollViewDelegate,HorizontalScrollerViewDataSource{
  func numberofViews(in horizontalScrollView: HorizontalScrollerView) -> Int {
    return allalbums.count
  }
  
  func horizontalScrollView(_ horizontalScrollView: HorizontalScrollerView, viewAt index: Int) -> UIView {
    let album = allalbums[index]
    let albumView = AlbumView(frame: CGRect(x: 0,y: 0,width: 100,height: 100), coverUrl: album.coverUrl)
    if curentAlbumIndex == index{
      albumView.highlightAlbum(true)
    }
    else{
       albumView.highlightAlbum(false)
    }
    return albumView
  }
  
  func horizontalScrollView(_ horizontalScrollView: HorizontalScrollerView, didselectViewAt index: Int) {
    
    let previousAlbumView = horizontalScrollView.view(at: curentAlbumIndex)  as! AlbumView
    previousAlbumView.highlightAlbum(false)
    curentAlbumIndex = index
    let albumView = horizontalScrollView.view(at: curentAlbumIndex) as! AlbumView
    albumView.highlightAlbum(true)
    showDataforAlbum(at: index)
    
    }
  
  
}

//MARK: State restoration
extension ViewController {
  
  override func encodeRestorableState(with coder: NSCoder) {
    coder.encode(curentAlbumIndex, forKey: Constants.IndexRestorationKey)
    super.encodeRestorableState(with: coder)
  }
  
  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    curentAlbumIndex = coder.decodeInteger(forKey: Constants.IndexRestorationKey)
    showDataforAlbum(at: curentAlbumIndex)
    horizontalScollView.reload()
  }
  
}
