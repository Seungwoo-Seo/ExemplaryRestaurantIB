//
//  TestViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/21.
//

import UIKit
import FirebaseStorage

class TestViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test_storage()
    }
    
    func test_storage() {
        let path = Storage.storage().reference().child("adfadfadf")
        
        path.listAll { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
            }
        }
        
        path.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                guard let data = data else {
                    print("데이터 없음")
                    return}
                
                let image = UIImage(data: data)
                self?.imageView.image = image
            }
            
        }
        
        
    }
    
    
}
