//
//  TestViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/21.
//

import UIKit
import SnapKit
import RxSwift
import Kingfisher

class TestViewController: UIViewController {
        
    @IBOutlet var imageView: UIImageView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.from([1,2,3,4,5])
            .subscribe(onNext: { num in
                print(num)
            }, onCompleted: {
                print("completed")
            })
            .disposed(by: disposeBag)
        
        
        let url = URL(string: "https://firebasestorage.googleapis.com:443/v0/b/exemplaryrestaurantibserver.appspot.com/o/ReviewImageList%2F-NM_fGgvSEeazIiNJ9_M%2Fimage1?alt=media&token=12c5ad1d-0aad-4d9a-9653-ee30f6b44edc")
        imageView.kf.setImage(with: url)
    }
    
}
