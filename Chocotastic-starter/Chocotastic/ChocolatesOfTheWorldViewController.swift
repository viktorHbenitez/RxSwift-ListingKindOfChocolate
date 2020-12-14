/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  
  // you will use to clean up any Observers you set up
  private let disposeBag = DisposeBag()
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
}

//MARK: View Lifecycle
extension ChocolatesOfTheWorldViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    // Set up Rx Observers
    setupCartButtonObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
  
  
  
  func setupCellConfiguration(){
    
    europeanChocolates.bind(to: tableView.rx.items(cellIdentifier: ChocolateCell.Identifier, cellType: ChocolateCell.self)){ row, chocolate, cell in
      
      cell.configureWithChocolate(chocolate: chocolate)
    }
    .disposed(by: disposeBag)
    
  }
  
  func setupCellTapHandling() {
    tableView
      .rx
      .modelSelected(Chocolate.self) //1
      .subscribe(onNext: { [unowned self] chocolate in // 2
        let newValue =  ShoppingCart.sharedCart.chocolates.value + [chocolate]
        ShoppingCart.sharedCart.chocolates.accept(newValue) //3
          
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        } //4
      })
      .disposed(by: disposeBag) //5
  }


  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    updateCartButton()
  }
}

//MARK: - Rx Setup
private extension ChocolatesOfTheWorldViewController {
  
  
  /*
   This set up a reactive Observer to update the cart automatically. As you can see, RxSwift makes heavy use of chained functions, meaning that each function takes the result of the previous function.
   */
  
   func setupCartButtonObserver() {
     // 1
     ShoppingCart.sharedCart.chocolates.asObservable()
       .subscribe(onNext: { // 2
         [unowned self] chocolates in
        self.cartButton.title = "\(chocolates.count) \u{1f36b}"
        
        print("Response: ", chocolates.count)
       })
       .disposed(by: disposeBag) //3
   }
   
  /*
  
   1. Grab the shopping cart’s chocolates variable as an Observable.
   2. Call subscribe(onNext:) on that Observable to discover changes to the Observable’s value. subscribe(onNext:) accepts a closure that executes every time the value changes. The incoming parameter to the closure is the new value of your Observable. You’ll keep getting these notifications until you either unsubscribe or dispose of your subscription. What you get back from this method is an Observer conforming to Disposable.
   3. Add the Observer from the previous step to your disposeBag. This disposes of your subscription upon deallocating the subscribing object.
   */
  
}

//MARK: - Imperative methods
private extension ChocolatesOfTheWorldViewController {
  func updateCartButton() {
    cartButton.title = "\(ShoppingCart.sharedCart.chocolates.value.count) 🍫"
  }
}

extension ChocolatesOfTheWorldViewController: SegueHandler{
  enum SegueIdentifier: String{
    case goToCart
  }
}
