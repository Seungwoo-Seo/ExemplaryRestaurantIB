//
//  ReviewViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class ReviewViewController: UIViewController {
    
    @IBOutlet var reviewTableView: UITableView!

    // MARK: ViewModel
    let vm = ReviewViewModel()
    
    // MARK: Firebase
    var ref: DatabaseReference!
    var handle: AuthStateDidChangeListenerHandle?
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        ref = Database.database().reference()
        
        setupUI()
        setupLayout()
        setupGesture()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self,
                  let user = user else {return}
            
            self.ref.child("UsersReviews").child("\(user.uid)Reviews").observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {return}
                
                do {
                    // 딕셔너리나, 배열을 Json 데이터로 바꿔주는 객체
                    //가져온 유저의 리뷰info들 변환
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let userReviewList = try JSONDecoder().decode([String: Review].self, from: jsonData)
                    
                    self.vm.setupModel_userReviewList(userReviewList)
                    
                    let group = DispatchGroup()
                    var userReviewImageList: [String: [UIImage]] = [:]
                    
                    print(userReviewList.count)
                    
                    for userReview in userReviewList {
                        let key = userReview.key
                        let path = Storage.storage().reference().child("reviewImageList/\(key)")
                        
                        group.enter()
                        path.listAll { results, error in
                            if let _ = error {}
                            
                            guard let results = results else {return}
                            
                            for item in results.items {
                                userReviewImageList.updateValue([], forKey: key)
                                
                                group.enter()
                                item.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                    if let _ = error {}
                                    
                                    let image = UIImage(data: data!)
                                    
                                    userReviewImageList[key]?.append(image!)
                                    
                                    group.leave() // 이 시점에 notify가 실행된다는건데
                                }
                            }
                            
                            group.leave()
                        }
                        
                    }
                    
                    group.notify(queue: .main) {

                        self.vm.setupModel_userReviewImageList(userReviewImageList)
                        self.vm.combine_finalUserReviewList()
                                                
                        self.reviewTableView.reloadData()
                        
                    }
                    
                    
                } catch let error {
                    print("Error JSON parsing \(error.localizedDescription)")
                }
            })
        }
    }
                                                                                     
                                                                        
    
                                                                                     
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}

extension ReviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.vm.finalUserReviewList.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {return UITableViewCell()}
        
        
        
        let list = self.vm.finalUserReviewList[indexPath.row]
        let review = list.0
        let images = list.1
        
        
        // 스토어 이름
        let storeName = review.storeName
        cell.storeNameButton.setTitle(storeName, for: .normal)
        
        // 리뷰 별점
        let reviewStarScore = review.reviewStarScore ?? 0
        for index in 0..<reviewStarScore {
            if let imageView =   cell.reviewStarScoreStackView.subviews[index] as? UIImageView {
                imageView.image = UIImage(systemName: "star.fill")
                imageView.tintColor = .yellow
            }
        }
        
        // 리뷰 이미지
        cell.setupImageCollectionView(images: images)
        
        
        // 리뷰 텍스트
        cell.reviewTextLabel.text = ""
        
        
        return cell
    }
    
}

// MARK: Setup
extension ReviewViewController: Setup {
    
    func setupUI() {
        setupUI_navigation()
        setupUI_reviewTableView()
        
    }
    
    func setupLayout() {
                        
    }
    
    func setupGesture() {
        
    }
    
}

// MARK: for setupUI
private extension ReviewViewController {
    
    func setupUI_navigation() {
        self.navigationItem.title = "리뷰내역"
    }
    
    func setupUI_reviewTableView() {
        self.reviewTableView.dataSource = self
        self.reviewTableView.delegate = self
    }
    
    func setupUI_imageCollectionView() {
        
    }
    
}
// MARK: for setupLayout

// MARK: for setupGesture




